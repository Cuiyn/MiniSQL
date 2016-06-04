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
    struct insertValue *is_val //Insert Value
}
%token CREATE SHOW DATABASE DATABASES TABLE TABLES INSERT SELECT UPDATE DELETE DROP EXIT NUMBER CHAR INT ID AND OR FROM WHERE VALUES INTO SET QUOTE USE
%type <yych> table field type ID NUMBER CHAR INT
%type <cfdef_var> fieldsdefinition field_type
%type <cs_var> createsql
%type <is_val> values value
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
            //TODO
                printf("Select succeed.\n");
            }
            | SELECT fields_star FROM tables WHERE conditions ';'
            {
            //TODO
                printf("Select succeed.\n");
            }
            fields_star: table_fields | '*'
            table_fields: table_field | table_fields ',' table_field
            table_field: field | table '.' field
            tables: tables ',' table | table
            conditions: condition | '(' conditions ')'
                       | conditions  AND conditions | conditions OR conditions
            condition: comp_left comp_op comp_right
            comp_left: table_field
            comp_right: table_field | NUMBER
            comp_op: '<' | '>' | '=' | '!' '='

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
                printf("Delete succeed.\n");
            }
            equal: '='

updatesql: UPDATE table SET sets WHERE field equal value ';'
            {
            //TODO
                printf("Update succeed.\n");
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