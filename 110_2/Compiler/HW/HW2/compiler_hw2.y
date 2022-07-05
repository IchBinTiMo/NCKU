/* Please feel free to modify any content */

/* Definition section */
%{
    #include "compiler_hw_common.h" //Extern variables that communicate with lex
    // #define YYDEBUG 1
    // int yydebug = 1;

    extern int yylineno;
    extern int yylex();
    extern FILE *yyin;

    int yylex_destroy ();
    void yyerror (char const *s)
    {
        printf("error:%d: %s\n", yylineno, s);
    }

    extern int yylineno;
    extern int yylex();
    extern FILE *yyin;

    /* Symbol table function - you can add new functions if needed. */
    /* parameters and return type can be changed */
    static char* lookup_symbol(char*);
    static void dump_symbol();

    static void lookupFunc(char*);

    /*Functions about symbol tables*/
    static symbolTable* newSymbolTable(char*);
    static symbolTable* pushTable(symbolTable*);

    /*Functions about symbols*/
    static Symbol* newSymbol(int, char*, char*, int*, int, char*, char*);
    static Symbol* insertSymbol(Symbol*, Symbol*);

    /*Functions about function signature*/

    static void getParamType(char);
    static void funcSignEnd(char);

    static void redeclarationCheck(char*);
    static void ACLsOperationCheck(char*, char*, char*, char*);
    static void signNotOperationCheck(char*, char*, char*);

    /* Global variables */
    bool HAS_ERROR = false;

    int address = 0;
    int scopeDepth = 0;
    int currentScopeDepth = 0;
    symbolTable* topTable = NULL;
    symbolTable* programTable = NULL;    
    
    char* funcSign;
    int funcSignLen;
    int isReturn = 0;
    char funcType;
%}

%error-verbose

/* Use variable or self-defined structure to represent
 * nonterminal and token type
 *  - you can add new fields if needed.
 */
%union {
    int i_val;
    float f_val;
    char *s_val;
    /* ... */
}

/* Token without return */
%token VAR NEWLINE RETURN
%token INT FLOAT BOOL STRING
%token INC DEC GTR LSS GEQ LEQ EQL NEQ LOR LAND 
%token addAssign subAssign mulAssign divAssign remAssign
%token IF ELSE FOR SWITCH CASE DEFAULT
%token PRINT PRINTLN PACKAGE FUNC

/* Token with return, which need to sepcify type */
%token <i_val> INT_LIT
%token <f_val> FLOAT_LIT
%token <s_val> STRING_LIT
%token <s_val> BOOL_LIT
%token <s_val> IDENT

/* Nonterminal with return, which need to sepcify type */
%type <s_val> Type Literal rawLiteral
%type <s_val> rightHandValue
%type <s_val> addSubOp mulDivOp notOp signOp Compare LOR LAND byOne calAssignmentOp
%type <s_val> ACLs Others ACs As mulDiv signNot Sign highestPriority funcCall

/* Yacc will start at this nonterminal */
%start Program

/* Grammar section */
%%

Program
    : {
          symbolTable *tmpTable = newSymbolTable("program");
          topTable = pushTable(tmpTable);
          programTable = topTable;
      } 
      GlobalStatementList 
      { dump_symbol(); }
;

GlobalStatementList 
    : GlobalStatementList GlobalStatement
    | GlobalStatement
;

GlobalStatement
    : PackageStmt NEWLINE
    | FunctionDeclStmt
    | NEWLINE 
;


PackageStmt
    : PACKAGE IDENT { printf("package: %s\n", $2); }
;

FunctionDeclStmt
    : FUNC IDENT
      {
          printf("func: %s\n", $2);
          //funcSignInit();
          funcSign = malloc(sizeof(char));
          funcSignLen = 0;
          symbolTable* tmpTable = newSymbolTable($2);
          topTable = pushTable(tmpTable);
      }
      funcParams returnType 
      {
          funcSignEnd(funcType);
          printf("func_signature: %s\n", funcSign);
          int a = -1;
          Symbol* tmpSymbol = newSymbol(programTable->length, $2, "func", &a, yylineno + 1, funcSign, "program");
          programTable->symbols = insertSymbol(programTable->symbols, tmpSymbol);
          programTable->length++;
          
      }
      funcBlock
;

funcParams
    : '(' parameters ')'
    | '(' ')'
;

parameters
    : parameters ',' parameter
    | parameter
;

parameter
    : IDENT Type 
      {
          printf("param %s, type: %c\n", $1, $2[0] - 32); 
          getParamType($2[0] - 32);
          Symbol* tmpSymbol = newSymbol(topTable->length, $1, $2, &(address), yylineno + 1, "-", topTable->name);
          topTable->symbols = insertSymbol(topTable->symbols, tmpSymbol);
          topTable->length++;
      }
;

returnType
    : Type { funcType = $1[0] - 32; }
    | {funcType = 'V'; }
;

funcBlock
    : '{' Expressions '}' 
      { dump_symbol(); }
;

Type
    : INT { $$ = strdup("int32"); }
    | FLOAT { $$ = strdup("float32"); }
    | STRING { $$ = strdup("string"); }
    | BOOL { $$ = strdup("bool"); }
;

Expressions
    : Expressions Expression
    | Expression 
;

Expression
    : declExpr NEWLINE 
    | printExpr NEWLINE
    | byOneExpr NEWLINE
    | calAssignment NEWLINE
    | Block
    | ifElse 
    | forLoop
    | ACLs NEWLINE
    | Switch
    | Cases 
    | funcCall 
    | Return 
    | NEWLINE
;

declExpr
    : VAR IDENT Type Assignment
      {
          Symbol* tmpSymbol = newSymbol(topTable->length, $2, $3, &(address), yylineno, "-", topTable->name);
          topTable->symbols = insertSymbol(topTable->symbols, tmpSymbol);
          topTable->length++;
      }
      
;

printExpr
    : PRINTLN '(' rightHandValue ')' { printf("PRINTLN %s\n", $3); }
    | PRINT '(' rightHandValue ')' { printf("PRINT %s\n", $3); }
;

byOneExpr
    : ACLs byOne { printf("%s\n", $2); }

;

calAssignment
    : IDENT
      {
          $1 = lookup_symbol($1);
      }
      calAssignmentOp ACLs { ACLsOperationCheck($1, $3, "CAL", $4); printf("%s\n", $3); }
;

Block
    : { 
          symbolTable* tmpTable = newSymbolTable("BLOCK");
          topTable = pushTable(tmpTable);
      }
      '{' Expressions '}'
      { dump_symbol(); }
;

ifElse
    : IF ACLs
      {
          if(strcmp($2, "bool") != 0){
              printf("error:%d: non-bool (type %s) used as for condition\n", yylineno + 1, $2);
          }
      }
      Block Else

;

Else
    : ELSE Block
    | 
;

forLoop
    : FOR ACLs
      {
          if(strcmp($2, "bool") != 0){
              printf("error:%d: non-bool (type %s) used as for condition\n", yylineno + 1, $2);
          }
      } 
      Block

;

Switch
    : SWITCH ACLs Block 
;

Cases
    : Cases caseBlock
    | caseBlock
;

caseBlock
    : CASE rawLiteral ':'
      { 
          $2 = strdup($2);
          printf("case %s\n", $2);
      }
      Block
      
    | DEFAULT ':' Block
;

byOne
    : INC { $$ = strdup("INC"); }
    | DEC { $$ = strdup("DEC"); }

;

calAssignmentOp
    : '=' { $$ = strdup("ASSIGN"); }
    | addAssign { $$ = strdup("ADD"); }
    | subAssign { $$ = strdup("SUB"); }
    | mulAssign { $$ = strdup("MUL"); }
    | divAssign { $$ = strdup("QUO"); }
    | remAssign { $$ = strdup("REM"); }
;

funcCall
    : IDENT '(' passParams ')'
      {
          lookupFunc($1);
      }
;

passParams
    : passParams ',' passParam
    | passParam
;

passParam
    : ACLs
    |
;

Return
    : RETURN returnVal

;

returnVal
    : ACLs { isReturn = 1; printf("%creturn\n", $1[0]); }
    | { isReturn = 1; printf("return\n"); }

;

Assignment
    : '=' rightHandValue
    | 
;

rightHandValue
    : Literal
    | IDENT { $$ = lookup_symbol($1); }
    | ACLs
;

ACLs
    : ACLs LOR { $2 = strdup("LOR"); }
      Others
      {
          ACLsOperationCheck($1, $2, "BOOL", $4);
          printf("%s\n", $2);
          $$ = strdup("bool");
      }
    | Others
;

Others
    : Others LAND { $2 = strdup("LAND"); }
      ACs
      {
          ACLsOperationCheck($1, $2, "BOOL", $4);
          printf("%s\n", $2);
          $$ = strdup("bool");
      }
    | ACs
;

ACs
    : ACs Compare As
      {
          ACLsOperationCheck($1, $2, "COMPARE", $3);
          printf("%s\n", $2);
          $$ = strdup("bool");
      }
    | As
;

As
    : As addSubOp mulDiv
      {
          ACLsOperationCheck($1, $2, "CAL", $3);
          printf("%s\n", $2);
          $$ = $3;
      }
    | mulDiv
;

mulDiv
    : mulDiv mulDivOp signNot
      {
          ACLsOperationCheck($1, $2, "CAL", $3);
          printf("%s\n", $2);
          $$ = $3;
          
      }
    | signNot
;

signNot
    : notOp signNot
      {
          signNotOperationCheck($1, "NOT", $2);
          printf("%s\n", $1);
          $$ = $2;
      }
    | Sign
;

Sign
    : signOp highestPriority
      {
          signNotOperationCheck($1, "SIGN", $2);
          printf("%s\n", $1);
          $$ = $2;
      }
    | highestPriority
;

highestPriority
    : IDENT 
      { 
          $$ = lookup_symbol($1);
      }
    | Literal
    | '(' ACLs')' { $$ = $2; }
    | Type '(' ACLs ')' { printf("%c2%c\n", $3[0], $1[0]); }
    | funcCall

;

addSubOp
    : '+' { $$ = strdup("ADD"); }
    | '-' { $$ = strdup("SUB"); }
;

mulDivOp
    : '*' { $$ = strdup("MUL"); }
    | '/' { $$ = strdup("QUO"); }
    | '%' { $$ = strdup("REM"); }
;

signOp
    : '+' { $$ = strdup("POS"); }
    | '-' { $$ = strdup("NEG"); }
;

notOp
    : '!' { $$ = strdup("NOT"); }

Compare
    : GTR { $$ = strdup("GTR"); }
    | LSS { $$ = strdup("LSS"); }
    | GEQ { $$ = strdup("GEQ"); }
    | LEQ { $$ = strdup("LEQ"); }
    | EQL { $$ = strdup("EQL"); }
    | NEQ { $$ = strdup("NEQ"); }
;


Literal
    : INT_LIT 
      { 
          printf("INT_LIT %d\n", $1);
          $$ = strdup("int32");
      }
    | FLOAT_LIT
      {
          printf("FLOAT_LIT %f\n", $1);
          $$ = strdup("float32");
      }
    | '\"' STRING_LIT '\"'
      {
          printf("STRING_LIT %s\n", $2);
          $$ = strdup("string");
      }
    | BOOL_LIT
      {
          printf("%s %d\n", $1[0] == 't' ? "TRUE" : "FALSE", $1[0] == 't' ? 1 : 0);
          $$ = strdup("bool");
      }
;

rawLiteral
    : INT_LIT
      {
          char buffer[32];
          sprintf(buffer, "%d", $1);
          $$ = strdup(buffer);
      }
    | FLOAT_LIT
      {
          char buffer[32];
          sprintf(buffer, "%f", $1);
          $$ = strdup(buffer);
      }
    | STRING_LIT
      {
          $$ = $1;
      }
    | BOOL_LIT
      {
          $$ = strdup($1[0] == 't' ? "true" : "false");
      }
;
%%

/* C code section */
int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }

    yylineno = 0;
    yyparse();

    
	printf("Total lines: %d\n", yylineno);
    fclose(yyin);
    return 0;
}

static void getParamType(char type)
{
    funcSignLen++;
    funcSign = realloc(funcSign, sizeof(char) * (funcSignLen));
    funcSign[funcSignLen - 1] = type;
}

static void funcSignEnd(char type)
{
    char end[2] = {')', type};
    char* result = malloc(sizeof(char) * (funcSignLen + 3));
    
    strcat(result, "(");
    strcat(result, funcSign);
    strcat(result, end);

    funcSign = result;
}

static void redeclarationCheck(char* target)
{
    Symbol* tmp = topTable->symbols;

    while(tmp != NULL){
        if(strcmp(tmp->name, target) == 0){
            printf("error:%d: %s redeclared in this block. previous declaration at line %d\n", yylineno, tmp->name, tmp->lineNum);
        }
        tmp = tmp->next;
    }
}

static void ACLsOperationCheck(char* left, char* op, char* opType, char* right)
{
    if(strcmp(opType, "BOOL") == 0){
        if(strcmp(left, "bool") != 0){
            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", yylineno, op, left);
        }
        else if(strcmp(right, "bool") != 0){
            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", yylineno, op, right);
        }
    }
    else if(strcmp(opType, "COMPARE") == 0){
        if(strcmp(left, right) != 0){
            printf("error:%d: invalid operation: %s (mismatched types %s and %s)\n", yylineno + 1, op, left, right);
        }

        else if(strcmp(left, "int32") != 0 && strcmp(left, "float32") != 0){
            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", yylineno + 1, op, left);
        }
        else if(strcmp(right, "int32") != 0 && strcmp(right, "float32") != 0){
            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", yylineno + 1, op, right);
        }
    }
    else if(strcmp(op, "REM") == 0){
        if(strcmp(left, "int32") != 0){
            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", 0 + yylineno, op, left);
        }
        else if(strcmp(right, "int32") != 0){
            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", 0 + yylineno, op, right);
        }
    }
    else if(strcmp(left, right) != 0){
        printf("error:%d: invalid operation: %s (mismatched types %s and %s)\n", yylineno, op, left, right);
    }
}

static void signNotOperationCheck(char* op, char* opType, char* target)
{
    if(strcmp(opType, "SIGN") == 0){
        if(strcmp(target, "int32") != 0 && strcmp(target, "float32") != 0){
            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", yylineno + 1, op, target);
        }
    }
    else if(strcmp(opType, "NOT") == 0){
        if(strcmp(target, "bool") != 0){
            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", yylineno + 1, op, target);
        }
    }
}


static symbolTable* newSymbolTable(char *name)
{
    printf("> Create symbol table (scope level %d)\n", currentScopeDepth);

    symbolTable *tmp = malloc(sizeof(symbolTable));
    tmp->scopeLevel = currentScopeDepth;
    tmp->length = 0;
    tmp->symbols = NULL;
    tmp->next = NULL;
    tmp->name = name;


    if(scopeDepth == currentScopeDepth){
        scopeDepth++;
    }    
    currentScopeDepth++;

    return tmp;
}

static symbolTable* pushTable(symbolTable* toPush)
{
    if(topTable == NULL){
        return toPush;
    }
    toPush->next = topTable;
    topTable = toPush;

    return toPush;
}

static Symbol* newSymbol(int idx, char* name, char* type, int* addr, int lineNum, char* funcSign, char* owner)
{
    redeclarationCheck(name);
    Symbol* tmp = malloc(sizeof(Symbol));
    tmp->index = idx;
    tmp->name = name;
    tmp->type = type;
    tmp->addr = *addr;
    (*addr)++;
    tmp->lineNum = lineNum;
    tmp->funcSign = funcSign;
    tmp->owner = owner;
    tmp->next = NULL;
    
    return tmp;
}

static Symbol* insertSymbol(Symbol* head, Symbol* toInsert)
{
    if(head == NULL){
         if(toInsert->addr == -1){
             printf("> Insert `%s` (addr: %d) to scope level %d\n", toInsert->name, toInsert->addr, programTable->scopeLevel);
         }
         else{
             printf("> Insert `%s` (addr: %d) to scope level %d\n", toInsert->name, toInsert->addr, topTable->scopeLevel);
         }
         return toInsert;
    }
    head->next = insertSymbol(head->next, toInsert);

    return head;
}

static char* lookup_symbol(char* target) {

    symbolTable* tmpTable = topTable;

    while(tmpTable != NULL){
        Symbol* tmp = tmpTable->symbols;
        while(tmp != NULL){
            if(strcmp(tmp->name, target) == 0){
                printf("IDENT (name=%s, address=%d)\n", tmp->name, tmp->addr);
                return strdup(tmp->type);
            }
            tmp = tmp->next;
        }
        tmpTable = tmpTable->next;
    }
    printf("error:%d: undefined: %s\n", yylineno + 1, target);
    return strdup("ERROR");
}

static void lookupFunc(char* target) 
{
    symbolTable* tmpTable = topTable;

    while(tmpTable != NULL){
        Symbol* tmp = tmpTable->symbols;
        while(tmp != NULL){
            if(strcmp(tmp->name, target) == 0 && strcmp(tmp->type, "func") == 0){
                printf("call: %s%s\n", tmp->name, tmp->funcSign);
            }
            tmp = tmp->next;
        }
        tmpTable = tmpTable->next;
    }
}

static void dump_symbol() {
    printf("\n> Dump symbol table (scope level: %d)\n", topTable->scopeLevel);
    printf("%-10s%-10s%-10s%-10s%-10s%-10s\n", "Index", "Name", "Type", "Addr", "Lineno", "Func_sig");

    Symbol* tmpSymbol = topTable->symbols;
    while(tmpSymbol != NULL){
        printf("%-10d%-10s%-10s%-10d%-10d%-10s\n", tmpSymbol->index, tmpSymbol->name, tmpSymbol->type, tmpSymbol->addr, tmpSymbol->lineNum, tmpSymbol->funcSign);
        tmpSymbol = tmpSymbol->next;
    }
    topTable = topTable->next;
    currentScopeDepth--;
    printf("\n");
}
