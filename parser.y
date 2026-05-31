
%{

/* Orismoi kai dhlwseis glwssas C. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int line = 1;
int error_count = 0;
char output_buffer[4096] = "";
extern char *yytext;
extern FILE *yyin;

int yylex();
int yyerror(char *s);

/* --- VARIABLE MEMORY (Symbol Table) --- */
char* var_names[100];
int var_values[100];
int var_count = 0;

void set_var(char* name, int val) {
    for(int i = 0; i < var_count; i++) {
        if(strcmp(var_names[i], name) == 0) {
            var_values[i] = val;
            return;
        }
    }
    var_names[var_count] = strdup(name);
    var_values[var_count] = val;
    var_count++;
}

int get_var(char* name) {
    for(int i = 0; i < var_count; i++) {
        if(strcmp(var_names[i], name) == 0) {
            return var_values[i];
        }
    }
    return 0;
}
%}

/*  BISON VARIABLE DECLARATIONS */
%union {
    int num;
    char* str;
}

%token <num> TOK_INTEGER
%token <str> TOK_VARIABLE TOK_STRING
%token TOK_MAIN TOK_SHOW TOK_ASSIGN
%token TOK_PLUS TOK_MINUS TOK_MUL TOK_DIV
%token TOK_LPAREN TOK_RPAREN TOK_LBRACE TOK_RBRACE

%type <num> expression

%left TOK_PLUS TOK_MINUS
%left TOK_MUL TOK_DIV

%start program

%%

/* GRAMMATICAL RULES. */

program	: TOK_MAIN TOK_LPAREN statements TOK_RPAREN
	| error TOK_RPAREN { printf("\t[Error %d] Line:%d ERROR\n", ++error_count, line); }
	;

statements: statement statements
	  | 
	  ;

statement: TOK_VARIABLE TOK_ASSIGN expression 
		{ 
			set_var($1, $3);
		}
	 | TOK_SHOW TOK_LBRACE expression TOK_RBRACE 
		{ 
			char temp[100];
			sprintf(temp, "%d\n", $3);
			strcat(output_buffer, temp);
		}
	 | TOK_SHOW TOK_LBRACE TOK_STRING TOK_RBRACE 
		{ 
			char temp[256];
			sprintf(temp, "%s\n", $3);
			strcat(output_buffer, temp);
		}
         | error { printf("\t[Error %d] Line:%d ERROR\n", ++error_count, line); }
	 ;

expression: expression TOK_PLUS expression   { $$ = $1 + $3; }
	  | expression TOK_MINUS expression  { $$ = $1 - $3; }
	  | expression TOK_MUL expression    { $$ = $1 * $3; }
	  | expression TOK_DIV expression    
	  { 
		if($3==0)
		{
			printf("\t[Error %d] Line:%d Error: Division by zero\n", ++error_count, line);
			$$=0;
		}else{
			$$=$1/$3;
		}
	   }
	  | TOK_LPAREN expression TOK_RPAREN { $$ = $2; }
	  | TOK_VARIABLE                     { $$ = get_var($1); }
	  | TOK_INTEGER                      { $$ = $1; }
	  ;

%%


/* YYERROR IS USED TO INFORM THE USER ABOUT ERRORS */
int yyerror(char *s)
{}

/* MAIN FUNCTION THATS THE STARTING POINT OF THE PROGRAM. */
int main(int argc, char **argv)
{
	if(argc == 2)
		yyin = fopen(argv[1], "r");
	else
		yyin = stdin;

	int parse = yyparse();

	if (error_count == 0 && parse == 0){
		printf("\nErrors: 0.\n");
		printf("Output: \n%s", output_buffer);
		printf("\nINPUT FILE: PARSING SUCCEEDED.\n");
	} else {
		printf("\nErrors: %d\n", error_count);
		printf("\nINPUT FILE: PARSING FAILED.\n");
	}
	return 0;
}
