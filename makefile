all: sql.c lex.yy.c y.tab.c
	gcc sql.c lex.yy.c y.tab.c -o minisql -std=c99

lex.yy.c: sql.l
	flex sql.l
y.tab.c: sql.y
	yacc -d sql.y

clean:
	rm minisql lex.yy.c y.tab.c y.tab.h
