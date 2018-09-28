%x COMMENT

digit [0-9]
upper [A-Z]
low   [a-z]
ws    [ \f\n\r\t\v]

%{
#include <string.h>
#include "y.tab.h"

extern YYSTYPE yylval;
int comment_ctr;
%}

%%

<COMMENT>"/*"       { ++comment_ctr; }
<COMMENT>"*/"       { --comment_ctr; if (comment_ctr < 1) BEGIN INITIAL; }
<COMMENT>(.|\n)     { /* ignore comment content */ }

"begin"	            { return TOKBEGIN; }
{digit}+            { yylval.number = atoi(yytext); return TOKNUMBER; }
({upper}|{low})+    { yylval.string = strdup(yytext); return TOKWORD; }
,                   return TOKCOMMA;

{ws}                { /* skip over blanks */ }
.                   { /* skip all other symbols, they're printed by default */ }

%%

// Change input after EOF was found.
// If reading could be continued - return 0.
int yywrap()
{
    return 1;
}