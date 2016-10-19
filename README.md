# MiniSQL
A very, very simple DBMS using C/Lex/Yacc. Compilation Principle assignment in School of Computer, Xidian University.

## Run
First, make sure you have a __Unix-like__ OS (Linux, Mac OS X, etc), because I've used some functions only in POSIX.

Then install __Lex__ and __Yacc__. In Linux they are called __Flex__ and __Bison__. And don't forget to get the source code. On Debian/Ubuntu you may do this:
```bash
git clone https://github.com/Cuiyn/Minisql && cd Minisql
sudo apt-get install flex bison
```
Finally,  run __make__ in your terminal. Then use __./minisql__.

__Enjoy it!__

## Features
+ Simple SQL support such as CREATE, SELECT, DELETE, UPDATE, etc
+ Multiple tables search(Less than 3 tables)
+ WHERE support

## License
[GNU GENERAL PUBLIC LICENSE](https://github.com/Cuiyn/MiniSQL/blob/master/LICENSE)

Because this project is one of assignments in Xidian University, please __DO NOT CHEAT__. I hope you can get inspiration from my code, rather than copy my code directly in your assignment.

If your assignment include any of my code, please tell your teacher and classmates, then make the code public under GPL License. If you are a teacher and doubtful of whether your students are cheating, please do let me know via email: cuiyn6688#hotmail.com. I'm very sorry for any inconvenience.
