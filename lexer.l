
%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Header file pou periexei lista me ola ta tokens
#include "parser.tab.h"

extern int line;
%}

// Onomata kai antistoixoi orismoi ypo morfh kanonikhs ekfrashs
DELIMITERS  [ \t\r]+
ID          [0-9]*[a-zA-Z][a-zA-Z0-9]*
NUMBER      ([1-9][0-9]*|0)
STRING      \"[^\"]*\"

%%

"main"      { return TOK_MAIN; }
"SHOW"      { return TOK_SHOW; }
"<="        { return TOK_ASSIGN; }

"+"         { return TOK_PLUS; }
"-"         { return TOK_MINUS; }
"*"         { return TOK_MUL; }
"/"         { return TOK_DIV; }

"("         { return TOK_LPAREN; }
")"         { return TOK_RPAREN; }
"{"         { return TOK_LBRACE; }
"}"         { return TOK_RBRACE; }

{ID}        { yylval.str = strdup(yytext); return TOK_VARIABLE; }
{NUMBER}    { yylval.num = atoi(yytext); return TOK_INTEGER; }
{STRING}    { yylval.str = strdup(yytext); return TOK_STRING; }

![^\n]* { /* Agnooume ta sxolia */ }
{DELIMITERS} { /* Agnooume ta kena */ }
\n          { line++; }

.           { printf("\n\tToken error '%s' sth grammh %d\n", yytext, line); }

%%
