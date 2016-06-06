%{
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>

char database[64]={0};
char rootDir[128]={0};

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


void getDB()
{
    FILE* fstream;
    char name[40];

    chdir(rootDir);
    fstream = fopen(".databases", "r");
    if(fstream == NULL)
    {
        printf("\nError!\n");
        return;
    }
    while(fscanf(fstream, "%s", name) != EOF)
    {
        printf("%s\n", name);
    }
    fclose(fstream);
    chdir(rootDir);
    printf("MiniSQL>");
}

void useDB()
{
    char dir[128]={0};
    strcpy(dir, rootDir);
    strcat(dir, "/");
    strcat(dir, database);
    if(chdir(dir) == -1)
        printf("\nError!\n");
    else
    {
        printf("Current Database: \n%s\n", database);
        chdir("rootDir");
    }
    printf("MiniSQL>");
}

void createDB()
{
    chdir(rootDir);
    if(mkdir(database, S_IRUSR | S_IWUSR | S_IXUSR) == -1)
        printf("\nError!\n");
    else
    {
        FILE* fstream;
        fstream = fopen(".databases", "a+");
        if(fstream == NULL)
        {
            printf("\nError!\n");
            return;
        }
        else
        {
            fprintf(fstream, "%s\n", database);
            printf("\nCreate database %s succeed!\n", database);
            fflush(fstream);
            fclose(fstream);
        }
    }
    strcpy(database, "\0");
    chdir(rootDir);
    printf("MiniSQL>");
}

void dropDB()
{
    chdir(rootDir);
    if(chdir(database) == -1)
        printf("\nError!\n");
    else
    {
        char cmd[128]="rm -rf ";
        FILE* filein;
        FILE* fileout;
        char dbname[64] = {0};

        chdir("..");
        strcat(cmd, database);
        system(cmd);

        system("mv .databases .databases.tmp");
        filein = fopen(".databases.tmp", "r");
        fileout = fopen(".databases", "w");

        while(fscanf(filein, "%s", dbname) != EOF)
        {
            if(strcmp(dbname, database) != 0)
            {
                fprintf(fileout, "%s\n", dbname);
            }
        }
        fclose(filein);
        fclose(fileout);
        system("rm .databases.tmp");
    }
    chdir(rootDir);
    printf("Drop database %s succeed.\n", database);
    printf("MiniSQL>");
}

void createTable(struct Createstruct *cs_root)
{
    int tot = 0, i = 0;
    struct Createfieldsdef * fieldPointer = NULL;
    char rows[64][64]={0};

    chdir(rootDir);
    if(strlen(database) == 0)
        printf("\nNo database, error!\n");
    else if(chdir(database) == -1)
        printf("\nError!\n");
    else
    {
        FILE* ftables;
        ftables = fopen(".tables", "a+");
        if(ftables == NULL)
        {
            printf("\nError!\n");
        }
        else
        {
            if(access(cs_root->table, F_OK) != -1)
            {
                printf("Table already exist!\n");
            }
            else {
                fprintf(ftables, "%s\n", cs_root->table);
                fclose(ftables);
                fieldPointer = cs_root->fdef;
                FILE* ftable;
                ftable = fopen(cs_root->table, "a+");
                if(ftable == NULL)
                {
                    printf("\nError!\n");
                }
                else {
                    while(fieldPointer != NULL)
                    {
                        strcpy(rows[tot], fieldPointer->field);
                        tot ++;
                        fieldPointer = fieldPointer->next_fdef;
                    }
                    fprintf(ftable, "%d\n", tot);
                    for(i = tot - 1; i >= 0; i--)
                        fprintf(ftable, "%s\n", rows[i]);
                    printf("\nCreate table %s succeed, %d row(s) created.\n", cs_root->table, tot);
                    fclose(ftable);
                }
            }
            chdir(rootDir);
        }
    }

    fieldPointer = cs_root->fdef;
    while(fieldPointer != NULL)
    {
        struct Createfieldsdef * fieldPointertmp = fieldPointer;
        fieldPointer = fieldPointer->next_fdef;
        free(fieldPointertmp);
    }
    free(cs_root);
    chdir(rootDir);
    printf("MiniSQL>");
}

void getTable(){
    chdir(rootDir);
    if(strlen(database) == 0)
        printf("\nNo database, error!\n");
    else if(chdir(database) == -1)
        printf("\nError!\n");
    else
    {
        FILE* fstream;
        char name[40];

        fstream = fopen(".tables", "a+");
        if(fstream == NULL)
        {
            printf("\nError!\n");
            return;
        }
        while(fscanf(fstream, "%s", name) != EOF)
        {
            printf("%s\n", name);
        }
        fclose(fstream);
    }
    chdir(rootDir);
    printf("MiniSQL>");
}

void dropTable(char * tableName)
{
    chdir(rootDir);
    if(strlen(database) == 0)
        printf("\nNo database, error!\n");
    else if(chdir(database) == -1)
        printf("\nError!\n");
    else
    {
        if(access(tableName, F_OK) != -1)
        {
            char cmd[128]="rm -rf ";
            char tbname[64] = {0};
            FILE* filein;
            FILE* fileout;

            strcat(cmd, tableName);
            system(cmd);

            system("mv .tables .tables.tmp");
            filein = fopen(".tables.tmp", "r");
            fileout = fopen(".tables", "w");

            while(fscanf(filein, "%s", tbname) != EOF)
            {
                if(strcmp(tbname, tableName) != 0)
                {
                    fprintf(fileout, "%s\n", tbname);
                }
            }
            fclose(filein);
            fclose(fileout);
            system("rm .tables.tmp");
        }
        else
            printf("Table %s doesn't exist!\n", tableName);
    }
    chdir(rootDir);
    printf("Drop table %s succeed.\n", tableName);
    printf("MiniSQL>");
}

void insertSingle(char * tableName, struct insertValue* values)
{
    chdir(rootDir);
    char valueChar[64][64] = {0};
    if(strlen(database) == 0)
        printf("\nNo database, error!\n");
    else if(chdir(database) == -1)
        printf("\nError!\n");
    else
    {
        if(access(tableName, F_OK) != -1)
        {
            FILE* fileTable;
            int tot = 0, i = 0;
            fileTable = fopen(tableName, "a+");
            struct insertValue* valuesTmp = values;
            while(valuesTmp != NULL)
            {
                //printf("%s\n", valuesTmp->value);
                strcpy(valueChar[tot], valuesTmp->value);
                tot ++;
                //fprintf(fileTable, "%s\n", valuesTmp->value);
                valuesTmp = valuesTmp->nextValue;
            }
            for (i = tot-1; i >= 0; i--)
            {
                fprintf(fileTable, "%s\n", valueChar[i]);
            }
            fclose(fileTable);
            printf("Insert succeed.\n");
        }
        else
            printf("Table %s doesn't exist!\n", tableName);
    }
    while(values != NULL)
    {
        struct insertValue* valuesTmp = values;
        values = values->nextValue;
        free(valuesTmp);
    }
    chdir(rootDir);
    printf("MiniSQL>");
}

void insertDouble(char * tableName, struct insertValue* rowNames, struct insertValue* valueNames)
{
    chdir(rootDir);
    char rows[64][64] = {0};
    char insertRow[64][64] = {0}, insertValue[64][64] = {0};
    if(strlen(database) == 0)
        printf("\nNo database, error!\n");
    else if(chdir(database) == -1)
        printf("\nError!\n");
    else
    {
        if(access(tableName, F_OK) != -1)
        {
            FILE* fileTable;
            fileTable = fopen(tableName, "at+");
            int tot = 0, i = 0, j = 0, totRow = 0, totValue = 0, flag = 0;
            struct insertValue* valuesTmp = rowNames;

            fscanf(fileTable, "%d", &tot);
            for (i = 0; i < tot; ++i)
            {
                fscanf(fileTable, "%s", &rows[i]);
            }
            while(valuesTmp != NULL)
            {
                strcpy(insertRow[totRow], valuesTmp->value);
                totRow++;
                valuesTmp = valuesTmp->nextValue;
            }
            valuesTmp = valueNames;
            while(valuesTmp != NULL)
            {
                strcpy(insertValue[totValue], valuesTmp->value);
                totValue++;
                valuesTmp = valuesTmp->nextValue;
            }
            if (totRow != totValue || totRow != tot)
            {
                printf("Rows and values don't match!\n");
            }
            else
            {
                for (i = 0; i < tot; ++i)
                {
                    //printf("%s\n", rows[i]);
                    flag = 0;
                    for (j = 0; j < tot; ++j)
                    {
                        if (strcmp(rows[i], insertRow[j]) == 0)
                        {
                            //printf("%s %s\n", insertRow[j], insertValue[j]);
                            fprintf(fileTable, "%s\n", insertValue[j]);
                            flag = 1;
                            break;
                        }
                    }
                    if (flag == 0)
                    {
                        printf("Error, row name doesn't match!\n");
                    }
                }
                printf("Insert succeed.\n");
            }
            fclose(fileTable);
        }
        else
            printf("Table %s doesn't exist!\n", tableName);
    }
    while(rowNames != NULL)
    {
        struct insertValue* valuesTmp = rowNames;
        rowNames = rowNames->nextValue;
        free(valuesTmp);
    }
    while(valueNames != NULL)
    {
        struct insertValue* valuesTmp = valueNames;
        valueNames = valueNames->nextValue;
        free(valuesTmp);
    }
    chdir(rootDir);
    printf("MiniSQL>");
}

void deleteAll(char * tableName)
{
    chdir(rootDir);
    char rows[64][64] = {0};
    if(strlen(database) == 0)
        printf("\nNo database, error!\n");
    else if(chdir(database) == -1)
        printf("\nError!\n");
    else
    {
        if(access(tableName, F_OK) != -1)
        {
            char cmd[128]="rm -rf ";
            FILE* filein;
            FILE* fileout;
            int tot = 0, i = 0;

            filein = fopen(tableName, "r");
            fscanf(filein, "%d", &tot);
            for (i = 0; i < tot; ++i)
            {
                fscanf(filein, "%s", rows[i]);
                //printf("%s\n", rows[i]);
            }

            fclose(filein);
            strcat(cmd, tableName);
            system(cmd);

            fileout = fopen(tableName, "a+");
            fprintf(fileout, "%d\n", tot);
            for (i = 0; i < tot; ++i)
            {
                fprintf(fileout, "%s\n", rows[i]);
            }
            fclose(fileout);
            printf("Delete succeed.\n");
        }
        else
            printf("Table %s doesn't exist!\n", tableName);
    }
    printf("MiniSQL>");
    chdir(rootDir);
}

void selectNoWhere(struct Selectedfields *fieldRoot, struct Selectedtables *tableRoot)
{
    int totTable = 0, totField = 0, i = 0;
    char tableName[64][64] = {0}, fieldName[64][64] = {0};
    struct Selectedfields *fieldTmp = fieldRoot;
    struct Selectedtables *tableTmp = tableRoot;

    chdir(rootDir);

    if(strlen(database) == 0)
        printf("\nNo database, error!\n");
    else if(chdir(database) == -1)
        printf("\nError!\n");
    else
    {
        while(tableTmp != NULL)
        {
            strcpy(tableName[totTable], tableTmp->table);
            tableTmp = tableTmp->next_st;
            totTable ++;
        }
        if (fieldRoot == NULL)
        {
            int flag = 1;
            for (i = totTable-1; i >= 0; --i)
            {
                if(access(tableName[i], F_OK) == -1)
                {
                    printf("Table %s doesn't exist!\n", tableName[i]);
                    flag = 0;
                    break;
                }
            }
            if (flag && totTable == 1)
            {
                FILE* filein;
                int tot = 0, i = 0;
                char value[64];

                filein = fopen(tableName[0], "r");
                fscanf(filein, "%d", &tot);
                i = tot;
                while(fscanf(filein, "%s", value) != EOF)
                {
                    printf("%*s", 16, value);
                    i--;
                    if (i == 0)
                    {
                        i = tot;
                        printf("\n");
                    }
                }
                fclose(filein);
                printf("Select succeed.\n");
            }
            else if (flag && totTable != 1)
            {
                //Multi tables
                /*
                int tot = 0;
                char rows[128][64] = {0};
                for (i = totTable-1; i >= 0; --i)
                {
                    FILE* filein;
                    int tott = 0, i = 0;

                    filein = fopen(tableName[i], "r");
                    fscanf(filein, "%d", &tott);
                    for (i = tot; i < tott+tot; ++i)
                    {
                        fscanf(filein, "%s", rows[i]);
                        printf("%*s", 20, rows[i]);
                    }
                    tot += tott;
                    fclose(filein);
                }
                */
            }
        }
        else
        {
            int flag = 1;
            char allField[64][64] = {0};
            for (i = totTable-1; i >= 0; --i)
            {
                if(access(tableName[i], F_OK) == -1)
                {
                    printf("Table %s doesn't exist!\n", tableName[i]);
                    flag = 0;
                    break;
                }
            }
            if (flag && totTable == 1)
            {
                FILE* filein;
                int tot = 0, i = 0, j = 0;
                char value[64];
                int isField[64] = {0};

                while(fieldTmp != NULL)
                {
                    strcpy(fieldName[totField], fieldTmp->field);
                    fieldTmp = fieldTmp->next_sf;
                    totField ++;
                }

                filein = fopen(tableName[0], "r");
                fscanf(filein, "%d", &tot);
                for (i = 0; i < tot; ++i)
                {
                    fscanf(filein, "%s", allField[i]);
                    for (j = 0; j < totField; ++j)
                    {
                        if (strcmp(allField[i], fieldName[j]) == 0)
                        {
                            isField[i] = 1;
                            break;
                        }
                    }
                }
                for (i = 0; i < tot; ++i)
                {
                    if (isField[i])
                        printf("%*s", 16, allField[i]);
                }
                printf("\n");

                i = tot;
                while(fscanf(filein, "%s", value) != EOF)
                {
                    if (isField[tot - i])
                    {
                        printf("%*s", 16, value);
                    }
                    i--;
                    if (i == 0)
                    {
                        i = tot;
                        printf("\n");
                    }
                }
                fclose(filein);
                printf("Select succeed.\n");
            }
            else if (flag && totTable != 1)
            {
                //Multi tables
            }
        }
    }

    fieldTmp = fieldRoot;
    tableTmp = tableRoot;
    while(fieldRoot != NULL)
    {
        fieldTmp = fieldRoot;
        fieldRoot = fieldRoot->next_sf;
        free(fieldTmp);
    }
    while(tableRoot != NULL)
    {
        tableTmp = tableRoot;
        tableRoot = tableRoot->next_st;
        free(tableTmp);
    }
    chdir(rootDir);
    printf("MiniSQL>");
}

void selectWhere(struct Selectedfields *fieldRoot, struct Selectedtables *tableRoot, struct Conditions *conditionRoot)
{
    int totTable = 0, totField = 0, i = 0;
    int flag = 1;
    char allField[64][64] = {0};
    char tableName[64][64] = {0}, fieldName[64][64] = {0};
    struct Selectedfields *fieldTmp = fieldRoot;
    struct Selectedtables *tableTmp = tableRoot;
    struct Conditions *conditionTmp = conditionRoot;

    chdir(rootDir);

    if(strlen(database) == 0)
        printf("\nNo database, error!\n");
    else if(chdir(database) == -1)
        printf("\nError!\n");
    else
    {
        while(tableTmp != NULL)
        {
            strcpy(tableName[totTable], tableTmp->table);
            tableTmp = tableTmp->next_st;
            totTable ++;
        }

        for (i = totTable-1; i >= 0; --i)
        {
            if(access(tableName[i], F_OK) == -1)
            {
                printf("Table %s doesn't exist!\n", tableName[i]);
                flag = 0;
                break;
            }
        }
        if (flag && totTable == 1)
        {
            FILE* filein;
            int tot = 0, i = 0, j = 0, totValue = 0;
            char value[64];
            char values[64][64][64];
            int isField[64] = {0};

            while(fieldTmp != NULL)
            {
                strcpy(fieldName[totField], fieldTmp->field);
                fieldTmp = fieldTmp->next_sf;
                totField ++;
            }

            filein = fopen(tableName[0], "r");
            fscanf(filein, "%d", &tot);

            if (fieldRoot != NULL)
            {
                for (i = 0; i < tot; ++i)
                {
                    fscanf(filein, "%s", allField[i]);
                    for (j = 0; j < totField; ++j)
                    {
                        if (strcmp(allField[i], fieldName[j]) == 0)
                        {
                            isField[i] = 1;
                            break;
                        }
                    }
                }
            }
            else
            {
                for (i = 0; i < tot; ++i)
                {
                    fscanf(filein, "%s", allField[i]);
                    isField[i] = 1;
                }
            }
            for (i = 0; i < tot; ++i)
            {
                if (isField[i])
                    printf("%*s", 16, allField[i]);
            }
            printf("\n");

            i = 0;
            j = 0;
            while(fscanf(filein, "%s", value) != EOF)
            {
                strcpy(values[i][j], value);
                j++;
                if (j == tot-1)
                {
                    j = 0;
                    i++;
                }
            }
            totValue = i;
            for (i = 0; i < totValue; ++i)
            {
                int conditionFlag = 0;
                while(conditionTmp->left != NULL)
                {

                }
                conditionTmp = conditionRoot;
                if (conditionFlag)
                {
                    for (j = 0; j < count; ++j)
                    {
                        printf("%*s", 16, values[i][j]);
                    }
                    printf("\n");
                }
            }

            /*
            i = tot;
            while(fscanf(filein, "%s", value) != EOF)
            {
                if (isField[tot - i])
                {
                    printf("%*s", 16, value);
                }
                i--;
                if (i == 0)
                {
                    i = tot;
                    printf("\n");
                }
            }
            */
            fclose(filein);
            printf("Select succeed.\n");
        }
        else if (flag && totTable != 1)
        {
            //TODO: Multi tables
        }
    }

    fieldTmp = fieldRoot;
    tableTmp = tableRoot;
    conditionTmp = conditionRoot;
    while(fieldRoot != NULL)
    {
        fieldTmp = fieldRoot;
        fieldRoot = fieldRoot->next_sf;
        free(fieldTmp);
    }
    while(tableRoot != NULL)
    {
        tableTmp = tableRoot;
        tableRoot = tableRoot->next_st;
        free(tableTmp);
    }
    /*
    while(conditionRoot != NULL)
    {
        //TODO: Memory leak
    }
    */
    chdir(rootDir);
    printf("MiniSQL>");
}


void yyerror(const char *str){
    fprintf(stderr,"error:%s\n",str);
}

int yywrap(){
    return 1;
}
main()
{
    printf("***********************\n");
    printf("  Welcome to MiniSQL!  \n");
    printf("***********************\n\n");
    printf("MiniSQL>");
    getcwd(rootDir, sizeof(rootDir));
    strcat(rootDir, "/sql");
    yyparse();
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
                       }
            comp_right: table_field
                        {
                            $$ = (struct Conditions *)malloc(sizeof(struct Conditions));
                            $$->type = 1;
                            $$->value = $1->field;
                            $$->table = $1->table;
                        }
                        | NUMBER
                        {
                            $$ = (struct Conditions *)malloc(sizeof(struct Conditions));
                            $$->type = 2;
                            $$->value = $1;
                            $$->table = NULL;
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
            //TODO
                printf("Delete todo...\n");
            }
            equal: '='

updatesql: UPDATE table SET sets WHERE field equal value ';'
            {
            //TODO
                printf("Update todo...\n");
            }
            sets: set | sets ',' set
            set: field equal value

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
