%{
#include <cstdio>
#include <stdlib.h>
#include <iostream>

using namespace std;

extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char *s);

#define STACK_SIZE 16

extern "C" void registerColor(int, char*);

typedef int stackExpression;

typedef struct {
	stackExpression *contents;
	int maxSize;
	int top;
} stackExpressions;

char *orderedColors[7] = {"white", "white", "white", "white", "white", "white", "white"};

extern "C" int setUnion(int, int);
extern "C" int setIntersect(int, int);

extern "C" stackExpressions ExpressionStack();
extern "C" void push(stackExpression);
extern "C" stackExpression pop();


const int defaultSets[3] = {0b1001101, 0b0101011, 0b0010111};

void registerColor(int expression, char *color){
	int mutableExpression = expression; // just to be sure
	for(int i = 6; i >= 0; i--){
		if((mutableExpression & 0x1) == 1){
			orderedColors[i] = color;
		}
		mutableExpression /= 2;
	}
}

/*
	StackExpression standard:
	A / B / C / A INT B / A INT C / B INT C / A INT B INT C
*/

stackExpressions stack;
int dimensionCount = -1;

stackExpressions ExpressionsStack(){
	if(stack.maxSize != STACK_SIZE){
		stack.maxSize = STACK_SIZE;
		
		stackExpression *newContents;
		newContents = (stackExpression *) malloc(sizeof(stackExpression) * stack.maxSize);
		
		if(newContents == NULL){
			fprintf(stderr, "Not enough memory to initialize stack of size %d.", STACK_SIZE);
			exit(1);
		}

		stack.contents = newContents;
		stack.top = -1;
	}
	return stack;
}

int isStackEmpty(){
	return stack.top < 0;
}

void push(stackExpression element){
	stack.contents[++stack.top] = element;
}

stackExpression pop(){
	return stack.contents[stack.top--];
}

%}

%union {
	int ival; // for number of dimensions
	char *sval; // for parens, union/intersect, colors, header, set names
}

%token <ival> Number
%token <sval> VennHeader
%token <sval> Newline
%token <sval> Color
%token <sval> OpenParen
%token <sval> CloseParen
%token <sval> Set
%token <sval> Union
%token <sval> Intersect

%%
file: header Newline rules {  };
header: VennHeader Number { dimensionCount = $2; ExpressionsStack(); };
rules:	rules expression Color Newline { registerColor(pop(), $3); }
	| ;
expression:	OpenParen Set CloseParen { push(defaultSets[($2[0]) - 'A']); } |
		OpenParen expression Union expression CloseParen { push(setUnion(pop(), pop())); } |
		OpenParen expression Intersect expression CloseParen { push(setIntersect(pop(), pop())); };

%%

#include <iostream>

using namespace std;

int setUnion(int setA, int setB){
	return setA | setB;
}

int setIntersect(int setA, int setB){
	return setA & setB;
}

int main(int argc, char** argv){
	do {
		yyparse();
	} while(!feof(yyin));

	printf("%% this part goes in the preamble\n\n");
	printf("\\def \\setA{ (0, 0) circle (1cm) }\n");
	printf("\\def \\setB{ (1.5, 0) circle (1cm) }\n");
	printf("\\def \\setC{ (0.75, 1) circle (1cm) }\n\n");
	printf("\\def \\colorA{%s}\n", orderedColors[0]);
	printf("\\def \\colorB{%s}\n", orderedColors[1]);
	printf("\\def \\colorC{%s}\n", orderedColors[2]);
	printf("\\def \\colorAB{%s}\n", orderedColors[3]);
	printf("\\def \\colorAC{%s}\n", orderedColors[4]);
	printf("\\def \\colorBC{%s}\n", orderedColors[5]);
	printf("\\def \\colorABC{%s}\n", orderedColors[6]);
	printf("\\usepackage{tikz}\n");
	printf("\\usetikzlibrary{shapes, backgrounds}\n");
	printf("%% this part goes where you want the figure!\n");
	printf("\\begin{center}\n\\begin{tikzpicture}\n");
	printf("\\fill[\\colorA] \\setA;\n");
	printf("\\fill[\\colorB] \\setB;\n");
	printf("\\fill[\\colorC] \\setC;\n");
	printf("\\begin{scope}\n \\clip \\setA;\n \\fill[\\colorAB] \\setB;\n \\end{scope}\n");
	printf("\\begin{scope}\n \\clip \\setA;\n \\fill[\\colorAC] \\setC;\n \\end{scope}\n");
	printf("\\begin{scope}\n \\clip \\setB;\n \\fill[\\colorBC] \\setC;\n \\end{scope}\n");
	printf("\\begin{scope}\n \\clip \\setA;\n \\clip \\setB;\n \\fill[\\colorABC] \\setC;\n\\end{scope}\n\n");
	printf("\\draw \\setA;\n\\draw \\setB;\n\\draw \\setC;\n\\draw (-1.5, -1.5) rectangle (3, 2.5);\n");
	printf("\\end{tikzpicture}\n\\end{center}");
}

void yyerror(const char *message){
	printf("Parse error: %s\n", message);
	exit(1);
}
