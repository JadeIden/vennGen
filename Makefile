venn.tab.c venn.tab.h: venn.y
	bison -d venn.y

lex.yy.c: venn.l venn.tab.h
	flex venn.l

venn: lex.yy.c venn.tab.c venn.tab.h
	g++ venn.tab.c lex.yy.c -lfl -o venn
