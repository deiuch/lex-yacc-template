%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yydebug;  // TODO: REMOVE IN PROD, 'yacc' it with -t flag.
extern int yylex();
char const *yyerror(const char *str);
%}

%expect 0  // For expected amount of conflicts

%start unit

%union
{
    int number;
    char *string;
}

%token <number> TOKNUMBER
%token <string> TOKWORD

%token TOKBEGIN
%token TOKCOMMA

%type <string> token

// %left, %right, %nonassoc - precedence and association setting.
// Start with lower priority - next to higher.
// Useful for expression ambiguity like:
// expr: expr '+' expr | expr '*' expr | int;

// Declaration example:
//%left PLUS MINUS
//%left MULTIPLY DIVIDE

// Also some specific RULES may have a precedence equal
// to the precedence of one from this list.
// Just write %prec after the rule before the semantic action.
// Useful for "Dangling else".
// Example of solution for "Dangling else" with variation:
// https://stackoverflow.com/questions/6911214/how-to-make-else-associate-with-farthest-if-in-yacc

%%

unit
        : /* empty */
        | TOKBEGIN tokens
        ;

tokens
        :                 token { printf("\tTOKWORD found: %s\n", $1); }
        | tokens TOKCOMMA token { printf("\tTOKWORD found: %s\n", $3); }
        ;

token
        : TOKNUMBER
        {
            $$ = (char *) malloc(11 * sizeof(char));
            itoa($1, $$, 10);
        }
        | TOKWORD   { $$ = $1; }
        ;

%%

// Called when parse error was detected.
char const *yyerror(const char *str)
{
    fprintf(stderr, "yyerror: %s\n", str);
}

// Program entry point.
int main()
{
    yydebug = 1;  // TODO: REMOVE IN PROD, set 0 for no debug info.
    return yyparse();
}