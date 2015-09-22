%{
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()

#include "venn.tab.h"

%}
%%
[ \t] ;
[0-9]+			{ yylval.ival = atoi(yytext); return Number; }
\n			{ yylval.sval = strdup(yytext); return Newline; }
VennGen\-		{ yylval.sval = strdup(yytext); return VennHeader; }
\(			{ yylval.sval = strdup(yytext); return OpenParen; }
\)			{ yylval.sval = strdup(yytext); return CloseParen; }
[ABC]			{ yylval.sval = strdup(yytext); return Set; }
UNION 			{ yylval.sval = strdup(yytext); return Union; }
INTERSECT		{ yylval.sval = strdup(yytext); return Intersect; }
[a-zA-Z]+		{ yylval.sval = strdup(yytext); return Color; }
%%
