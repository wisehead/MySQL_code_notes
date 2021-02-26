
# (3条消息) mysql embeded 用法_MySQL的Embedded模式C接口_盗心魔幻的博客-CSDN博客

MySQL除了CS运行模式, 还有embedded模式. 相关文档介绍比较少,也比较散乱, 最近项目中正好用到, 现通过本文对其基本用法做个介绍,给出可以运行的基本例子.本文基于mysql5.5.

环境配置

要使用embedded模式的MySQL, 有两种方法, 一种是从源码编译, 一种是下载libmysqld库. 本文首先采用下载库的方法, 在ubuntu16.04上, 有如下的命令.

sudo apt install libmysqld-dev

下载完成以后, 在相应的接口代码中, 使用如下的选项进行编译和链接即可.

\`mysql\_config --include --libmysqld-libs\`

libmysqld中开放的接口有限, 如果选择从源码编译, 除了可以用基本的embedded的功能外, 还能用到其他有意思的功能, 比如调用MySQL解析器, 这个将在后续的文章中介绍.

运行基本程序

为了验证是否安装成功, 写一个如下的小程序, 并且编译运行. 在运行前, 先在当前目录创建一个新的文件夹shadow

#include

#include

#include

static bool lib\_initialized = false;

int main(){

if (!\_\_sync\_bool\_compare\_and\_swap(&lib\_initialized, false, true)) {

return 0;

}

char dir\_arg\[1024\];

snprintf(dir\_arg, sizeof(dir\_arg), "--datadir=%s", "./shadow");

char \*mysql\_av\[5\]=

{ "progname",

"--skip-grant-tables",

dir\_arg,

"--character-set-server=utf8",

"--language=/home/casualet/Desktop/cryptdb/mysql-src/build/sql/share/"

};

assert(0 == mysql\_library\_init(sizeof(mysql\_av)/sizeof(mysql\_av\[0\]),(char\*\*) mysql\_av, 0));

assert(0 == mysql\_thread\_init());

MYSQL\* mysql = mysql\_init(NULL);

if(mysql==NULL){

printf("error 26\\n");

}else{

printf("mysql init succeed\\n");

}

mysql\_options(mysql, MYSQL\_READ\_DEFAULT\_GROUP, "libmysqld\_client");

mysql\_options(mysql, MYSQL\_OPT\_USE\_EMBEDDED\_CONNECTION, NULL);

mysql\_real\_connect(mysql, NULL, NULL, NULL, "information\_schema", 0, NULL, 0);

mysql\_query(mysql, "SHOW DATABASES;");

MYSQL\_RES \*results = mysql\_store\_result(mysql);

MYSQL\_ROW record;

while(record=mysql\_fetch\_row(results)){

printf("hehe\\n");

printf("%s\\n", record\[0\]);

}

mysql\_query(mysql, "CREATE DATABASE testdb1;");

return 0;

}

上面的代码通过如下的命令编译:

g++ -o Embed Embed.cc \`mysql\_config --include --libmysqld-libs\` -std=c++11

作为对比, 如果使用的是cs模式的接口, 使用如下的编译方法

sudo apt-get install libmysqlclient-dev

\`mysql\_config --cflags --libs\`

如果该程序成功运行且没有错误, 则基本配置成功. 下面对具体的接口进行介绍.

完整的接口介绍和多线程环境

给出一段如下所示的实例程序:

#include

#include

#include

#include

#include

#include

#include

#include

#include

#define THREAD\_NUM 16

using namespace std;

static bool lib\_initialized = false;

//调用出错是用到的函数

void finish\_with\_error(MYSQL \*con){

fprintf(stderr, "%s\\n", mysql\_error(con));

mysql\_close(con);

return;

}

//获得命令执行的结果.

void mysql\_result\_wrapper(MYSQL \*con){

MYSQL\_RES \*result = mysql\_store\_result(con);

if(result == NULL) return;

int num\_fields = mysql\_num\_fields(result);

if(num\_fields==0) return;

MYSQL\_FIELD \*field;

MYSQL\_ROW row;

while(row = mysql\_fetch\_row(result)){

for(int i = 0; i < num\_fields; i++) {

if (i == 0)

{

while(field = mysql\_fetch\_field(result))

{

printf("%s ", field->name);

}

printf("\\n");

}

printf("%s ", row\[i\] ? row\[i\] : "NULL");

}

//以数组的方式返回get的当前row的所有字段的长度

//const unsigned long \*const l = mysql\_fetch\_lengths(result);

//for(int i = 0; i < num\_fields; i++) {

// cout<

//}

}

printf("\\n");

}

//发送单个MySQL命令

void mysql\_query\_wrapper(MYSQL \*con,string s){

if(mysql\_query(con, s.c\_str())) {

finish\_with\_error(con);

}

mysql\_result\_wrapper(con);

}

//初始化MySQL

void init\_mysql(){

//保证该函数只被调用一次

if (!\_\_sync\_bool\_compare\_and\_swap(&lib\_initialized, false, true)) {

return ;

}

char dir\_arg\[1024\];

snprintf(dir\_arg, sizeof(dir\_arg), "--datadir=%s", "./shadow");

//第一个参数被忽略, 一般给个名字. 所有参数会复制, 所以调用以后销毁参数是可以的.用这个函数, 是为了多线程,否则mysql\_init就可以了.

char \*mysql\_av\[4\]=

{ "progname",

"--skip-grant-tables",

dir\_arg,

"--character-set-server=utf8"

/\* "--language=/home/casualet/Desktop/cryptdb/mysql-src/build/sql/share"\*/

};

//int mysql\_library\_init(int argc, char \*\*argv, char \*\*groups)

assert(0 == mysql\_library\_init(sizeof(mysql\_av)/sizeof(mysql\_av\[0\]),(char\*\*) mysql\_av, 0));

//多线程条件下, 每个线程在使用mysql库中的函数时, 都要调用该函数进行初始化.

assert(0 == mysql\_thread\_init());

}

void \*thread\_func(void \*arg) {

int v = (long)arg;

//每个线程使用mysql相关的函数之前, 先调用该函数进行初始化.

assert(0 == mysql\_thread\_init());

MYSQL\* mysql = mysql\_init(NULL);

mysql\_options(mysql, MYSQL\_READ\_DEFAULT\_GROUP, "libmysqld\_client");

mysql\_options(mysql, MYSQL\_OPT\_USE\_EMBEDDED\_CONNECTION, NULL);

mysql\_real\_connect(mysql, NULL, NULL, NULL, "information\_schema", 0, NULL, 0);

MYSQL\* con = mysql;

string use="use ttddbb;";

mysql\_query\_wrapper(con,use);

string num = to\_string(v);

string s="insert into student values("+ num+",'zhangfei')";

mysql\_query\_wrapper(con,s);

return (void\*)0;

}

int main(){

//初始化, 只需要调用一次.

init\_mysql();

assert(0 == mysql\_thread\_init());

MYSQL\* mysql = mysql\_init(NULL);

mysql\_options(mysql, MYSQL\_READ\_DEFAULT\_GROUP, "libmysqld\_client");

mysql\_options(mysql, MYSQL\_OPT\_USE\_EMBEDDED\_CONNECTION, NULL);

mysql\_real\_connect(mysql, NULL, NULL, NULL, "information\_schema", 0, NULL, 0);

MYSQL\* con = mysql;

string s;

s="SELECT @@sql\_safe\_updates";

mysql\_query\_wrapper(con,s);

s="create database if not exists ttddbb;";

mysql\_query\_wrapper(con,s);

s="use ttddbb;";

mysql\_query\_wrapper(con,s);

s="create table if not exists student (id integer, name varchar(20));";

mysql\_query\_wrapper(con,s);

pthread\_t pids\[THREAD\_NUM\];

int i;

for (i = 0; i < THREAD\_NUM; i++) {

pthread\_create(&pids\[i\], NULL, thread\_func, (void\*)(unsigned long)(i));

}

for (i = 0; i < THREAD\_NUM; i++) {

pthread\_join(pids\[i\], NULL);

}

s="select \* from student";

mysql\_query\_wrapper(con,s);

return 0;

}

其他接口的补充

mysql\_insert\_id()

如果表格中定义了AUTO\_INCREMENT的列, 则调用该函数可以返回表格中上一次插入的id.

这样, 对于多线程情况下, 调用MySQL embedded的基本使用就没有问题了. 对于单线程以及CS模式, 可以参考\[3\].

参考文献

原始链接:yiwenshao.github.io/2017/01/01/MySQL的Embedded模式C接口/

文章作者:Yiwen Shao

许可协议: Attribution-NonCommercial 4.0

转载请保留以上信息, 谢谢!