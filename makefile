all: lex.yy.c y.tab.c
	gcc lex.yy.c y.tab.c -o minisql

lex.yy.c: sql.l
	lex sql.l
y.tab.c: sql.y
	yacc -d sql.y

clean:
	rm minisql lex.yy.c y.tab.c y.tab.h
