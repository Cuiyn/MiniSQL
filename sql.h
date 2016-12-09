#ifndef _SQL_H
#define _SQL_H

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>


struct Createfieldsdef{
    char *field;
    char *type;
    int length;
    struct Createfieldsdef *next_fdef;
};
struct Createstruct{
    char *table;
    struct Createfieldsdef *fdef;
};

struct insertValue {
    char *value;
    struct insertValue *nextValue;
};

struct Conditions{/*条件*/
    struct  Conditions *left; //左部条件
    struct  Conditions *right; //右部条件
    char *comp_op; /* 'a'是and, 'o'是or, '<' , '>' , '=', ‘!='  */
    int type; /* 0是字段，1是字符串，2是整数 */
    char *value;/* 根据type存放字段名、字符串或整数 */
    char *table;/* NULL或表名 */
};
struct Selectedfields{/*select语句中选中的字段*/
    char *table; //字段所属表
    char *field; //字段名称
    struct Selectedfields *next_sf;//下一个字段
};
struct Selectedtables{ /*select语句中选中的表*/
    char *table; //基本表名称
    struct  Selectedtables  *next_st; //下一个表
};
struct Selectstruct{ /*select语法树的根节点*/
    struct Selectedfields *sf; //所选字段
    struct Selectedtables *st; //所选基本表
    struct Conditions *cons; //条件
};
struct Setstruct
{
    struct Setstruct *next_s;
    char *field;
    char *value;
};

void getDB();
void useDB();
void createDB();
void dropDB();

void createTable(struct Createstruct *cs_root);
void getTable();
void dropTable(char * tableName);

void insertSingle(char * tableName, struct insertValue* values);
void insertDouble(char * tableName, struct insertValue* rowNames, struct insertValue* valueNames);
void deleteAll(char * tableName);
void selectNoWhere(struct Selectedfields *fieldRoot, struct Selectedtables *tableRoot);
void freeWhere(struct Conditions *conditionRoot);
int whereSearch(struct Conditions *conditionRoot, int totField, char allField[][64], char value[][64]);
void selectWhere(struct Selectedfields *fieldRoot, struct Selectedtables *tableRoot, struct Conditions *conditionRoot);
void deleteWhere(char *tableName, struct Conditions *conditionRoot);
void updateWhere(char *tableName, struct Setstruct *setRoot, struct Conditions *conditionRoot);




#endif