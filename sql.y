%{
//#include <stdio.h>
//#include <stdlib.h>
//#include <sys/types.h>
//#include <sys/stat.h>
//#include <unistd.h>
//#include <string.h>
//#include <fcntl.h>
#include "sql.h"

char database[64]={0};
char rootDir[128]={0};

void yyerror(const char *str){
    fprintf(stderr,"error:%s\n",str);
}

int yywrap(){
    return 1;
}
int main()
{
    printf("***********************\n");
    printf("  Welcome to MiniSQL!  \n");
    printf("***********************\n\n");
    printf("MiniSQL>");
    getcwd(rootDir, sizeof(rootDir));
    strcat(rootDir, "/sql");
    yyparse();
	
	return 0;
}

%}

%union /*定义yylval的格式*/
{
    char * yych;
    struct Createfieldsdef *cfdef_var; //字段定义
    struct Createstruct *cs_var; //整个create语句

    struct insertValue *is_val; //Insert Value

    struct Selectedfields *sf_var; //所选字段
    struct Selectedtables *st_var; //所选表格
    struct Conditions *cons_var; //条件语句
    struct Selectstruct *ss_var; //整个select语句
    struct Setstruct *s_var; //Update set
}

%token CREATE SHOW DATABASE DATABASES TABLE TABLES INSERT SELECT UPDATE DELETE DROP EXIT NUMBER CHAR INT ID AND OR FROM WHERE VALUES INTO SET QUOTE USE
%type <yych> table field type ID NUMBER CHAR INT comp_op
%type <cfdef_var> fieldsdefinition field_type
%type <cs_var> createsql
%type <is_val> values value
%type <sf_var>  fields_star table_fields table_field
%type <st_var>  tables
%type <cons_var>  condition  conditions comp_left comp_right
%type <ss_var>  selectsql
%type <s_var> set sets
%left OR
%left AND

%%
statements: statements statement | statement
statement: createsql | showsql | selectsql | insertsql | deletesql | updatesql | dropsql | exitsql | usesql

createsql: CREATE TABLE table '(' fieldsdefinition ')' ';'
            {
                $$ = ((struct Createstruct *)malloc(sizeof(struct Createstruct)));
                $$->table = $3;
                $$->fdef = $5;
                createTable($$);
            }
            | CREATE DATABASE ID ';'
            {
                strcpy(database, $3);
                createDB();
            }
            table: ID{$$=$1;}
            fieldsdefinition: field_type
                              {
                                  $$ = (struct Createfieldsdef *)malloc(sizeof(struct Createfieldsdef));
                                  $$->next_fdef = NULL;
                                  $$->field = $1->field;
                                  $$->type = $1->type;
                              }
                              |
                              fieldsdefinition ',' field_type
                              {
                                  $$ = (struct Createfieldsdef *)malloc(sizeof(struct Createfieldsdef));
                                  $$->next_fdef = $1;
                                  $$->field = $3->field;
                                  $$->type = $3->type;
                              }
            field_type: field type
                        {
                            $$ = (struct Createfieldsdef *)malloc(sizeof(struct Createfieldsdef));
                            $$->field = $1;
                            $$->type = $2;
                            $$->next_fdef = NULL;
                        }
            field: ID{$$=$1;}
            type: CHAR '(' NUMBER ')' {$$=$1;}| INT{$$=$1;}

usesql: USE ID ';'
        {
            strcpy(database, $2);
            useDB();
        }

showsql: SHOW DATABASES ';'
        {
            printf("Databases:\n");
            getDB();
        }
        |SHOW TABLES ';'
        {
            printf("Tables:\n");
            getTable();
        }

selectsql:  SELECT fields_star FROM tables ';'
            {
                selectNoWhere($2, $4);
            }
            | SELECT fields_star FROM tables WHERE conditions ';'
            {

                selectWhere($2, $4, $6);
            }
            fields_star: table_fields
                         {
                             $$ = $1;
                         }
                         | '*'
                         {
                             $$ = NULL;
                         }
            table_fields: table_field
                          {
                               $$ = $1;
                          }
                          |
                          table_fields ',' table_field
                          {
                               $$ = (struct Selectedfields *)malloc(sizeof(struct Selectedfields));
                               $$->field = $3->field;
                               $$->table = $3->table;
                               $$->next_sf = $1;
                          }
            table_field: field
                         {
                             $$ = (struct Selectedfields *)malloc(sizeof(struct Selectedfields));
                             $$->field = $1;
                             $$->table = NULL;
                             $$->next_sf = NULL;
                         }
                         | table '.' field
                         {
                             $$ = (struct Selectedfields *)malloc(sizeof(struct Selectedfields));
                             $$->field = $3;
                             $$->table = $1;
                             $$->next_sf = NULL;
                         }
            tables: tables ',' table
                    {
                        $$ = (struct Selectedtables *)malloc(sizeof(struct Selectedtables));
                        $$->table = $3;
                        $$->next_st = $1;
                    }
                    | table
                    {
                        $$ = (struct Selectedtables *)malloc(sizeof(struct Selectedtables));
                        $$->table = $1;
                        $$->next_st = NULL;
                    }
            conditions: condition
                        {
                            $$ = $1;
                        }
                        | '(' conditions ')'
                        {
                            $$ = $2;
                        }
                        | conditions AND conditions
                        {
                            $$ = (struct Conditions *)malloc(sizeof(struct Conditions));
                            $$->left = $1;
                            $$->right = $3;
                            char c = 'a';
                            char *cc = &c;
                            $$->comp_op = cc;
                        }
                        | conditions OR conditions
                        {
                            $$ = (struct Conditions *)malloc(sizeof(struct Conditions));
                            $$->left = $1;
                            $$->right = $3;
                            char c = 'o';
                            char *cc = &c;
                            $$->comp_op = cc;
                        }
            condition: comp_left comp_op comp_right
                       {
                            $$ = (struct Conditions *)malloc(sizeof(struct Conditions));
                            $$->left = $1;
                            $$->right = $3;
                            $$->comp_op = $2;
                       }
            comp_left: table_field
                       {
                            $$ = (struct Conditions *)malloc(sizeof(struct Conditions));
                            $$->type = 0;
                            $$->value = $1->field;
                            $$->table = $1->table;
                            $$->left = NULL;
                            $$->right = NULL;
                       }
            comp_right: QUOTE table_field QUOTE
                        {
                            $$ = (struct Conditions *)malloc(sizeof(struct Conditions));
                            $$->type = 1;
                            $$->value = $2->field;
                            $$->table = $2->table;
                            $$->left = NULL;
                            $$->right = NULL;
                        }
                        | NUMBER
                        {
                            $$ = (struct Conditions *)malloc(sizeof(struct Conditions));
                            $$->type = 2;
                            $$->value = $1;
                            $$->table = NULL;
                            $$->left = NULL;
                            $$->right = NULL;
                        }
            comp_op: '<'
                     {
                        char c = '<';
                        $$ = &c;
                     }
                     | '>'
                     {
                        char c = '>';
                        $$ = &c;
                     }
                     | '='
                     {
                        char c = '=';
                        $$ = &c;
                     }
                     | '!' '='
                     {
                        char c = '!';
                        $$ = &c;
                     }
                     | AND
                     {
                        char c = 'a';
                        $$ = &c;
                     }
                     | OR
                     {
                        char c = 'o';
                        $$ = &c;
                     }

insertsql: INSERT INTO table VALUES '(' values ')' ';'
            {
                insertSingle($3, $6);
            }
            | INSERT INTO table '(' values ')' VALUES '(' values ')' ';'
            {
                insertDouble($3, $5, $9);
            }
            values: value
                    {
                        $$ = (struct insertValue *)malloc(sizeof(struct insertValue));
                        $$->value = $1->value;
                        $$->nextValue = NULL;
                    }
                   | values ',' value
                   {
                        $$ = (struct insertValue *)malloc(sizeof(struct insertValue));
                        $$->value = $3->value;
                        $$->nextValue = $1;
                   }
            value: QUOTE ID QUOTE
                   {
                        $$ = (struct insertValue *)malloc(sizeof(struct insertValue));
                        $$->value = $2;
                        $$->nextValue = NULL;
                   }
                   | NUMBER
                   {
                        $$ = (struct insertValue *)malloc(sizeof(struct insertValue));
                        $$->value = $1;
                        $$->nextValue = NULL;
                   }
                   |ID
                   {
                        $$ = (struct insertValue *)malloc(sizeof(struct insertValue));
                        $$->value = $1;
                        $$->nextValue = NULL;
                   }

deletesql: DELETE FROM table ';'
            {
                deleteAll($3);
            }
            | DELETE '*' FROM table ';'
            {
                deleteAll($4);
            }
            | DELETE FROM table WHERE conditions ';'
            {
                deleteWhere($3, $5);
            }

updatesql: UPDATE table SET sets WHERE conditions ';'
            {
                updateWhere($2, $4, $6);
            }
            sets: set
                  {
                      $$ = $1;
                  }
                  | sets ',' set
                  {
                      $$ = (struct Setstruct *)malloc(sizeof(struct Setstruct));
                      $$->next_s = $1;
                      $$->field = $3->field;
                      $$->value = $3->value;
                      free($3);
                  }
            set: ID '=' NUMBER
                 {
                     $$ = (struct Setstruct *)malloc(sizeof(struct Setstruct));
                     $$->field = $1;
                     $$->value = $3;
                     $$->next_s = NULL;
                 }
                 |
                 ID '=' QUOTE ID QUOTE
                 {
                     $$ = (struct Setstruct *)malloc(sizeof(struct Setstruct));
                     $$->field = $1;
                     $$->value = $4;
                     $$->next_s = NULL;
                 }

dropsql: DROP TABLE ID ';'
        {
            dropTable($3);
        }
        | DROP DATABASE ID ';'
        {
            strcpy(database, $3);
            dropDB();
        }

exitsql: EXIT ';'
        {
            printf("Bye!\n");
            exit(0);
        }
