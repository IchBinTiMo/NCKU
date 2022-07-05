

/* Definition section */
%{
    #include "compiler_hw_common.h"
    #include "y.tab.h"	/* header file generated by bison */
    extern YYSTYPE yylval;

    #define YY_NO_UNPUT
    #define YY_NO_INPUT
    #define XXX printf("not implemented yet!\n")
%}

/* Define regular expression label */
letter [a-zA-Z_]
digit [0-9]
id {letter}+({letter}|{digit})*
inumber {digit}+
fnumber ({digit}*\.{digit}+)

%x CMT
%x STR
%option yylineno

/* Rules section */
%%

"/*"        { BEGIN(CMT); }
<CMT>"*/"   { BEGIN(INITIAL); }
<CMT>\n     {;}
<CMT>.      {;}
"//".*      {;}
"\""        { BEGIN(STR);
                return '"';
            }
<STR>"\""   { BEGIN(INITIAL);
                return '"';
            }
<STR>[^\"]* { yylval.s_val = strdup(yytext);
                return STRING_LIT;
            }
"+"         { return '+'; }
"-"         { return '-'; }
"*"         { return '*'; }
"/"         { return '/'; }
"%"         { return '%'; }
"++"        { return INC; }
"--"        { return DEC; }
">"         { return GTR; }
"<"         { return LSS; }
">="        { return GEQ; }
"<="        { return LEQ; }
"=="        { return EQL; }
"!="        { return NEQ; }
"="         { return '='; }
"+="        { return addAssign; }
"-="        { return subAssign; }
"*="        { return mulAssign; }
"/="        { return divAssign; }
"%="        { return remAssign; }
"&&"        { return LAND; }
"||"        { return LOR; }
"!"         { return '!'; }
"("         { return '('; }
")"         { return ')'; }
"["         { return '['; }
"]"         { return ']'; }
"{"         { return '{'; }
"}"         { return '}'; }
";"         { return ';'; }
":"         { return ':'; }
","         { return ','; }
"\n"        { /*printf("%d\n", yylineno);*/ return NEWLINE; }
"package"   { return PACKAGE; }
"func"      { return FUNC; }
"print"     { return PRINT; }
"println"   { return PRINTLN; }
"if"        { return IF; }
"else"      { return ELSE; }
"for"       { return FOR; }
"switch"    { return SWITCH; }
"case"      { return CASE; }
"default"   { return DEFAULT; }
"return"    { return RETURN; }
"int32"     { return INT; }
"float32"   { return FLOAT;}
"string"    { return STRING; }
"bool"      { return BOOL; }
"true"      { yylval.s_val = strdup(yytext); 
                return BOOL_LIT;
            }
"false"     { yylval.s_val = strdup(yytext);
                return BOOL_LIT;
            }
"var"       { return VAR; }
{inumber}   { yylval.i_val = atoi(yytext);
                return INT_LIT;
            }
{fnumber}   { yylval.f_val = atof(yytext);
                return FLOAT_LIT;
            }
{id}        { yylval.s_val = strdup(yytext);
                return IDENT;
            }
<<EOF>>     { static int once = 0;
                if (once++) {
                    yyterminate();
                }
                yylineno++;
                //printf("yylineno++\n");
                return NEWLINE;
            }
[ \t]+      {;}
.           {;}
%%
/*  C Code section */
int yywrap(void)
{
    return 1;
}
