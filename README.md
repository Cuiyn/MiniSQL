# MiniSQL
A very, very simple DBMS using C/Lex/Yacc. Compilation Principle assignment in School of Computer, Xidian University.

## Run
First, make sure you have a __Unix-like__ OS (Linux, Mac OS X and so on), because I've used some functions only in POSIX.

Then install __Lex__ and __Yacc__. In Linux they are called __Flex__ and __Bison__. And don't forget to get the source code. On Debian/Ubuntu you may do this:
```bash
git clone https://github.com/Cuiyn/Minisql && cd Minisql
sudo apt-get install flex bison
```
Finally,  run __make__ in your terminal. Then use __./minisql__.

Enjoy it!
##Features
+ Simple SQL support such as CREATE, SELECT, DELETE, UPDATE, etc
+ Multiple tables search(Less than 3 tables)
+ WHERE support

## License
[GNU GENERAL PUBLIC LICENSE](https://github.com/Cuiyn/MiniSQL/blob/master/LICENSE)
