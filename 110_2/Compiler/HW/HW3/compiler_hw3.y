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

    /* Used to generate code */
    /* As printf; the usage: CODEGEN("%d - %s\n", 100, "Hello world"); */
    /* We do not enforce the use of this macro */
    #define CODEGEN(...) \
        do { \
            for (int i = 0; i < g_indent_cnt; i++) { \
                fprintf(fout, "\t"); \
            } \
            fprintf(fout, __VA_ARGS__); \
        } while (0)

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

    static node* newNode(char*);
    static node* pushNode(node*, node*);
    static node* popNode(node*);

    static caseLit* newCase(char*);
    static caseLit* pushCase(caseLit*, caseLit*);
    /*Functions about function signature*/

    static void getParamType(char);
    static void funcSignEnd(char);

    static void redeclarationCheck(char*);
    static void ACLsOperationCheck(char*, char*, char*, char*);
    static void signNotOperationCheck(char*, char*, char*);

    static void CMPGEN(char*, char);

    /* Global variables */
    bool g_has_error = false;
    FILE *fout = NULL;
    int g_indent_cnt = 0;

    bool HAS_ERROR = false;


    //int currentReg = 0;
    int assignment = 0;
    int cmpCnt = 0;


    int address = 0;
    int scopeDepth = 0;
    int currentScopeDepth = 0;
    symbolTable* topTable = NULL;
    symbolTable* programTable = NULL;    
    
    char* funcSign;
    int funcSignLen;
    int isReturn = 0;
    char funcType;
    char* tmpStr;
    int load = 1;
    int addressWanted;
    int target;
    int maxIf = 0;
    int maxFor = 0;
    int maxSwitch = 0;
    int caseCnt = 0;
    node* ifStack = NULL;
    node* forStack = NULL;
    node* switchStack = NULL;
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
    : PACKAGE IDENT { /*printf("package: %s\n", $2);*/ }
;

FunctionDeclStmt
    : FUNC IDENT
      {
//          printf("func: %s\n", $2);
          //funcSignInit();
          funcSign = malloc(sizeof(char));
          funcSignLen = 0;
          symbolTable* tmpTable = newSymbolTable($2);
          topTable = pushTable(tmpTable);
      }
      funcParams returnType 
      {
          funcSignEnd(funcType);
//          printf("func_signature: %s\n", funcSign);
          int a = -1;
          Symbol* tmpSymbol = newSymbol(programTable->length, $2, "func", &a, yylineno + 1, funcSign, "program");
          programTable->symbols = insertSymbol(programTable->symbols, tmpSymbol);
          programTable->length++;
	  if(strcmp($2, "main") == 0){
	  	CODEGEN(".method public static main([Ljava/lang/String;)V\n");
		CODEGEN(".limit stack 100\n");
		CODEGEN(".limit locals 100\n");
	  }
	  else{
		CODEGEN(".method public static %s%s\n", $2, funcSign);
		CODEGEN(".limit stack 100\n");
		CODEGEN(".limit locals 100\n");
	  }
          
      }
      funcBlock
      {
	  //CODEGEN("return\n.end method\n\n");
	  //printf("func type is %c\n", funcSign[strlen(funcSign) - 1]);
	  if(funcSign[strlen(funcSign) - 1] == 'V'){
//		printf("func type is %c\n", funcSign[strlen(funcSign) - 2]);
		CODEGEN("return\n");
		CODEGEN(".end method\n");
	  }
	  else{
		printf("funcSign: %c\n", funcSign[strlen(funcSign) - 1] + 32);
		CODEGEN("%creturn\n", funcSign[strlen(funcSign) - 1] + 32);
		CODEGEN(".end method\n");
	  }
	  
      }
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
//          printf("param %s, type: %c\n", $1, $2[0] - 32); 
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
//	  printf("%s %d\n", $2, assignment);
	  if(assignment == 0){
		if($3[0] == 'i'){
			CODEGEN("ldc 0\n");
		}
		else if($3[0] == 'f'){
			CODEGEN("ldc 0.0\n");
		}
		else{
			CODEGEN("ldc \"\"\n");
		}
	  }
//	  else if(assignment == 1){
	printf("%cstore %d\n", $3[0], address - 1);
	if($3[0] == 'i' || $3[0] == 'b'){
		CODEGEN("istore %d\n", address - 1);
	}
	else if($3[0] == 'f'){
		CODEGEN("fstore %d\n", address - 1);
	}
	else if($3[0] == 's'){
		CODEGEN("astore %d\n", address - 1);
	}
//	  }
      }
      
;

printExpr
    : PRINTLN '(' rightHandValue ')' 
      { 
	printf("PRINTLN %s\n", $3);
//	printf("println\n");
	if($3[0] == 'b'){
		CODEGEN("ifne cmp%d_0\n", cmpCnt);
		CODEGEN("ldc \"false\"\n");
		CODEGEN("goto cmp%d_1\n", cmpCnt);
		CODEGEN("cmp%d_0:\n", cmpCnt);
		CODEGEN("ldc \"true\"\n");
		CODEGEN("cmp%d_1:\n", cmpCnt);
		cmpCnt++;
	}
	CODEGEN("getstatic java/lang/System/out Ljava/io/PrintStream;\n");
	CODEGEN("swap\n");
	if($3[0] == 'i' || $3[0] == 'f'){
		CODEGEN("invokevirtual java/io/PrintStream/println(%c)V\n", $3[0] - 32);
	}
	else{
		CODEGEN("invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n");
	}

		
	
      }
    | PRINT '(' rightHandValue ')' 
      { 
//	printf("PRINT %s\n", $3); 
	printf("print\n");
	if($3[0] == 'b'){
		CODEGEN("ifne cmp%d_0\n", cmpCnt);
		CODEGEN("ldc \"false\"\n");
		CODEGEN("goto cmp%d_1\n", cmpCnt);
                CODEGEN("cmp%d_0:\n", cmpCnt);
                CODEGEN("ldc \"true\"\n");
		CODEGEN("cmp%d_1:\n", cmpCnt);
                cmpCnt++;
        }
        CODEGEN("getstatic java/lang/System/out Ljava/io/PrintStream;\n");
        CODEGEN("swap\n");
        if($3[0] == 'i' || $3[0] == 'f'){
                CODEGEN("invokevirtual java/io/PrintStream/print(%c)V\n", $3[0] - 32);
        }
        else{
                CODEGEN("invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");
        }
      }
;

byOneExpr
    : ACLs 
      {
//	CODEGEN("iconst_1\n");
//	printf("iconst_1\n");
	CODEGEN("%cconst_1\n", $1[0]);
	printf("%cconst_1\n", $1[0]);
      }
      byOne
      {
//	printf("%s\n", $3);
	CODEGEN("%c%s\n", $1[0], $3);
	printf("%c%s\n", $1[0], $3);
	CODEGEN("%cstore %d\n", $1[0], addressWanted);
	printf("%cstore %d\n", $1[0], addressWanted);
      }

;

calAssignment
    : IDENT
      {
	  //load = 0;
          $1 = lookup_symbol($1);
	  target = addressWanted;
	  //printf("%s\n", $3);
	  //load = 1;
      }
      calAssignmentOp 
      {
	  if($3[0] != '='){
		CODEGEN("%cload %d\n", $1[0], addressWanted);
	  }
      }
      ACLs 
      {
	   
	  ACLsOperationCheck($1, $3, "CAL", $5); 
	  printf("%s\n", $3); 
	  printf("%c\n", $1[0]);
	  if($3[0] != '='){
//		CODEGEN("%cload %d\n", $1[0], addressWanted);
		CODEGEN("%c%s\n", $1[0], $3);
	  }
	  if($1[0] == 'i' || $1[0] == 'b'){
		CODEGEN("istore %d\n", target);
          }
          else if($1[0] == 'f'){
		CODEGEN("fstore %d\n", target);
          }
          else{
          	CODEGEN("astore %d\n", target);
          }
	  
	  
      }
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
	  node* tmp = newNode("if");
	  ifStack = pushNode(tmp, ifStack);
	  CODEGEN("ifeq if%dFalse\n", ifStack->level);

          if(strcmp($2, "bool") != 0){
//              printf("error:%d: non-bool (type %s) used as for condition\n", yylineno + 1, $2);
          }
      }
      Block
      {
	  CODEGEN("goto if%dExit\n", ifStack->level);
	  CODEGEN("if%dFalse:\n", ifStack->level);
      }
      Else
      {
	  CODEGEN("if%dExit:\n", ifStack->level);
	  ifStack = popNode(ifStack);
      }

;

Else
    : ELSE Block
    | 
;

forLoop
    : FOR
      {
	  node *tmp = newNode("for");
	  forStack = pushNode(tmp, forStack);
	  CODEGEN("for%d:\n", forStack->level);
      }
      ACLs
      {
//	  node *tmp = newNode("for");
//	  forStack = pushNode(tmp, forStack);
//	  CODEGEN("for%d:\n", forStack->level);
	  CODEGEN("ifeq for%dExit\n", forStack->level);
//	  CODEGEN("goto for%d\n", forStack->level);
          if(strcmp($3, "bool") != 0){
//              printf("error:%d: non-bool (type %s) used as for condition\n", yylineno + 1, $2);
          }
      } 
      Block
      {
	  CODEGEN("goto for%d\n", forStack->level);
	  CODEGEN("for%dExit:\n", forStack->level);
	  forStack = popNode(forStack);
      }

;

Switch
    : SWITCH ACLs
      {
	  node *tmp = newNode("switch");
	  switchStack = pushNode(tmp, switchStack);	  
	  CODEGEN("goto switch%dBegin\n", switchStack->level);
      }
      Block
      {
	  CODEGEN("switch%dBegin:\n", switchStack->level);
	  CODEGEN("lookupswitch\n");
	  int i = 0;
	  for(caseLit* tmp = switchStack->cases; tmp != NULL; tmp = tmp->next){
	  	CODEGEN("%s: switch%d_%d\n", tmp->lit, switchStack->level, i);
		i++;
	  }
	  CODEGEN("switch%dExit:\n", switchStack->level);
	  switchStack = popNode(switchStack);
	  caseCnt = 0;
      } 
;

Cases
    : Cases caseBlock
    | caseBlock
;

caseBlock
    : CASE rawLiteral ':'
      {
	  CODEGEN("switch%d_%d:\n", switchStack->level, caseCnt);
	  caseLit* tmp = newCase($2);
	  printf("the lit is %s\n", $2);
	  switchStack->cases = pushCase(tmp, switchStack->cases);
	  caseCnt++; 
          $2 = strdup($2);
//          printf("case %s\n", $2);
      }
      Block
      {
	  CODEGEN("goto switch%dExit\n", switchStack->level);
      }
    | DEFAULT ':'
      {
	  CODEGEN("switch%d_%d:\n", switchStack->level, caseCnt);
	  caseLit* tmp = newCase("default");
	  switchStack->cases = pushCase(tmp, switchStack->cases);
	  caseCnt++;
      }
      Block
      {
	  CODEGEN("goto switch%dExit\n", switchStack->level);
      }
      
	  
;

byOne
    : INC { /*CODEGEN("iadd\n");*/ $$ = strdup("add"); }
    | DEC { /*CODEGEN("isub\n");*/ $$ = strdup("sub"); }

;

calAssignmentOp
    : '=' 
      { 
	$$ = strdup("="); 
      }
    | addAssign
      { 
	$$ = strdup("add");
      }
    | subAssign 
      { 
	$$ = strdup("sub"); 
      }
    | mulAssign 
      { 
	$$ = strdup("mul"); 
      }
    | divAssign 
      { 
	$$ = strdup("div"); 
      }
    | remAssign 
      { 
	$$ = strdup("rem"); 
      }
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
    : ACLs { isReturn = 1; /*printf("%creturn\n", $1[0]);*/ }
    | { isReturn = 1; /*printf("return\n");*/ }

;

Assignment
    : '=' rightHandValue
      {
	  assignment = 1;
      }
    | 
      {
	  assignment = 0;
      }
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
//          printf("%s\n", $2);
	  CODEGEN("ior\n");
          $$ = strdup("bool");
      }
    | Others
;

Others
    : Others LAND { $2 = strdup("LAND"); }
      ACs
      {
          ACLsOperationCheck($1, $2, "BOOL", $4);
//          printf("%s\n", $2);
	  CODEGEN("iand\n");
          $$ = strdup("bool");
      }
    | ACs
;

ACs
    : ACs Compare As
      {
          ACLsOperationCheck($1, $2, "COMPARE", $3);
//          printf("%s\n", $2);
	  CMPGEN($2, $1[0]);
          $$ = strdup("bool");
      }
    | As
;

As
    : As addSubOp mulDiv
      {
	  printf("%c%s\n", $1[0], $2);
          ACLsOperationCheck($1, $2, "CAL", $3);
	  CODEGEN("%c%s\n", $1[0], $2);
//          printf("%s\n", $2);
          $$ = $3;
      }
    | mulDiv
;

mulDiv
    : mulDiv mulDivOp signNot
      {
	  printf("%c%s\n", $1[0], $2);
          ACLsOperationCheck($1, $2, "CAL", $3);
	  CODEGEN("%c%s\n", $1[0], $2);
//          printf("%s\n", $2);
          $$ = $3;
          
      }
    | signNot
;

signNot
    : notOp signNot
      {
          signNotOperationCheck($1, "NOT", $2);
//          printf("%s\n", $1);
	  CODEGEN("iconst_1\n");
	  CODEGEN("ixor\n");
          $$ = $2;
      }
    | Sign
;

Sign
    : signOp highestPriority
      {
          signNotOperationCheck($1, "SIGN", $2);
//          printf("%s\n", $1);
	  if(strcmp($1, "pos") != 0){
		  CODEGEN("%c%s\n", $2[0], $1);
		  printf("%c%s\n", $2[0], $1);
	  }
          $$ = $2;
      }
    | highestPriority
;

highestPriority
    : IDENT 
      {   
//	  printf("%s\n", $1);
          $$ = lookup_symbol($1);
	  
      }
    | Literal
    | '(' ACLs')' { $$ = $2; }
    | Type '(' ACLs ')' 
      { 
	/*printf("%c2%c\n", $3[0], $1[0]);*/ 
	CODEGEN("%c2%c\n", $3[0], $1[0]);
      }
    | funcCall

;

addSubOp
    : '+' { $$ = strdup("add"); }
    | '-' { $$ = strdup("sub"); }
;

mulDivOp
    : '*' { $$ = strdup("mul"); }
    | '/' { $$ = strdup("div"); }
    | '%' { $$ = strdup("rem"); }
;

signOp
    : '+' { $$ = strdup("pos"); }
    | '-' { $$ = strdup("neg"); }
;

notOp
    : '!' { $$ = strdup("NOT"); }

Compare
    : GTR { $$ = strdup("gt"); }
    | LSS { $$ = strdup("lt"); }
    | GEQ { $$ = strdup("ge"); }
    | LEQ { $$ = strdup("le"); }
    | EQL { $$ = strdup("eq"); }
    | NEQ { $$ = strdup("ne"); }
;


Literal
    : INT_LIT 
      { 
//          printf("INT_LIT %d\n", $1);
	  CODEGEN("ldc %d\n", $1);
	  printf("ldc %d\n", $1);
          $$ = strdup("int32");
      }
    | FLOAT_LIT
      {
//          printf("FLOAT_LIT %f\n", $1);
	  CODEGEN("ldc %f\n", $1);
	  printf("ldc %f\n", $1);
          $$ = strdup("float32");
      }
    | '\"' STRING_LIT '\"'
      {
//          printf("STRING_LIT %s\n", $2);
	  CODEGEN("ldc \"%s\"\n", $2);
	  printf("ldc \"%s\"\n", $2);
          $$ = strdup("string");
      }
    | BOOL_LIT
      {
//          printf("%s %d\n", $1[0] == 't' ? "TRUE" : "FALSE", $1[0] == 't' ? 1 : 0);
	  CODEGEN("ldc %d\n", $1[0] == 't' ? 1 : 0);
	  printf("%s\n", $1);
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
    if (!yyin) {
        printf("file `%s` doesn't exists or cannot be opened\n", argv[1]);
        exit(1);
    }

    /* Codegen output init */
    char *bytecode_filename = "hw3.j";
    fout = fopen(bytecode_filename, "w");
    CODEGEN(".source hw3.j\n");
    CODEGEN(".class public Main\n");
    CODEGEN(".super java/lang/Object\n\n");

    /* Symbol table init */
    // Add your code

    yylineno = 0;
    yyparse();

    /* Symbol table dump */
    // Add your code

    printf("Total lines: %d\n", yylineno);
    fclose(fout);
    fclose(yyin);

    if (g_has_error) {
        remove(bytecode_filename);
    }
    yylex_destroy();
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
//            printf("error:%d: %s redeclared in this block. previous declaration at line %d\n", yylineno, tmp->name, tmp->lineNum);
        }
        tmp = tmp->next;
    }
}

static void ACLsOperationCheck(char* left, char* op, char* opType, char* right)
{
    if(strcmp(opType, "BOOL") == 0){
        if(strcmp(left, "bool") != 0){
//            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", yylineno, op, left);
        }
        else if(strcmp(right, "bool") != 0){
//            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", yylineno, op, right);
        }
    }
    else if(strcmp(opType, "COMPARE") == 0){
        if(strcmp(left, right) != 0){
//            printf("error:%d: invalid operation: %s (mismatched types %s and %s)\n", yylineno + 1, op, left, right);
        }

        else if(strcmp(left, "int32") != 0 && strcmp(left, "float32") != 0){
//            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", yylineno + 1, op, left);
        }
        else if(strcmp(right, "int32") != 0 && strcmp(right, "float32") != 0){
//            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", yylineno + 1, op, right);
        }
    }
    else if(strcmp(op, "REM") == 0){
        if(strcmp(left, "int32") != 0){
//            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", 0 + yylineno, op, left);
        }
        else if(strcmp(right, "int32") != 0){
//            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", 0 + yylineno, op, right);
        }
    }
    else if(strcmp(left, right) != 0){
//        printf("error:%d: invalid operation: %s (mismatched types %s and %s)\n", yylineno, op, left, right);
    }
}

static void signNotOperationCheck(char* op, char* opType, char* target)
{
    if(strcmp(opType, "SIGN") == 0){
        if(strcmp(target, "int32") != 0 && strcmp(target, "float32") != 0){
//            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", yylineno + 1, op, target);
        }
    }
    else if(strcmp(opType, "NOT") == 0){
        if(strcmp(target, "bool") != 0){
//            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", yylineno + 1, op, target);
        }
    }
}


static symbolTable* newSymbolTable(char *name)
{
//    printf("> Create symbol table (scope level %d)\n", currentScopeDepth);

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
//             printf("> Insert `%s` (addr: %d) to scope level %d\n", toInsert->name, toInsert->addr, programTable->scopeLevel);
         }
         else{
//             printf("> Insert `%s` (addr: %d) to scope level %d\n", toInsert->name, toInsert->addr, topTable->scopeLevel);
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
//                printf("IDENT (name=%s, address=%d)\n", tmp->name, tmp->addr);
		addressWanted = tmp->addr;
		if(load != -1){
			if(tmp->addr != -1){
				if(tmp->type[0] == 's'){
					CODEGEN("aload %d\n", tmp->addr);
				}
				else if(tmp->type[0] == 'b'){
					CODEGEN("iload %d\n", tmp->addr);
				}
				else{
					CODEGEN("%cload %d\n", tmp->type[0], tmp->addr);
				}
				printf("%cload %d\n", tmp->type[0], tmp->addr);
			}
			else{
				CODEGEN("invokestatic Main/%s%s\n", tmp->name, tmp->funcSign);
			}
		}
                return strdup(tmp->type);
            }
            tmp = tmp->next;
        }
        tmpTable = tmpTable->next;
    }
//    printf("error:%d: undefined: %s\n", yylineno + 1, target);
    return strdup("ERROR");
}

static void lookupFunc(char* target) 
{
    symbolTable* tmpTable = topTable;

    while(tmpTable != NULL){
        Symbol* tmp = tmpTable->symbols;
        while(tmp != NULL){
            if(strcmp(tmp->name, target) == 0 && strcmp(tmp->type, "func") == 0){
		CODEGEN("invokestatic Main/%s%s\n", tmp->name, tmp->funcSign);
//                printf("call: %s%s\n", tmp->name, tmp->funcSign);
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

static void CMPGEN(char* command, char type)
{
    if(type == 'i'){
	CODEGEN("if_icmp%s cmp%d_0\n", command, cmpCnt);
    }
    else{
	CODEGEN("fcmpl\n");
	CODEGEN("if%s cmp%d_0\n", command, cmpCnt);
    }
	CODEGEN("iconst_0\n");
	CODEGEN("goto cmp%d_1\n", cmpCnt);
	CODEGEN("cmp%d_0:\n", cmpCnt);
	CODEGEN("iconst_1\n");
	CODEGEN("cmp%d_1:\n", cmpCnt);
	cmpCnt++;

    /*
    else{
	CODEGEN("fcmpl\n");
	CODEGEN("if%s cmp%d_0\n", command, cmpCnt);
	CODEGEN("iconst_0\n");
	CODEGEN("goto cmp%d_1\n", cmpCnt);
	CODEGEN("cmp%d_0:\n", cmpCnt);
	CODEGEN
    */
}

static node* newNode(char* func)
{
	node* tmp = malloc(sizeof(node));
	if(strcmp(func, "if") == 0){
		tmp->level = maxIf;
		maxIf++;
	}
	else if(strcmp(func, "for") == 0){
		tmp->level = maxFor;
		maxFor++;
	}
	else if(strcmp(func, "switch") == 0){
		tmp->level = maxSwitch;
		maxSwitch++;
	}
	tmp->next = NULL;
	
	return tmp;
}

static node* pushNode(node* toPush, node* head)
{
	toPush->next = head;
	return toPush;
}

static node* popNode(node* head)
{
	return head->next;
}

static caseLit* newCase(char* literal)
{
	caseLit* tmp = malloc(sizeof(caseLit));
	tmp->lit = literal;
	tmp->next = NULL;
	
	return tmp;
}

static caseLit* pushCase(caseLit* toPush, caseLit* head)
{
	if(head == NULL){
		return toPush;
	}
	head->next = pushCase(toPush, head->next);
	return head;
}
