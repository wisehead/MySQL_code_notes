---
title: Mysql源码学习——词法分析MYSQLlex - 心中无码 - 博客园
category: default
tags: 
  - www.cnblogs.com
created_at: 2020-05-17 17:57:19
original_url: https://www.cnblogs.com/nocode/archive/2011/08/03/2126726.html
---


# Mysql源码学习——词法分析MYSQLlex - 心中无码 - 博客园

## [Mysql源码学习——词法分析MYSQLlex](https://www.cnblogs.com/nocode/archive/2011/08/03/2126726.html)

2011-08-03 22:23  [心中无码](https://www.cnblogs.com/nocode/)  阅读(3842)  评论(9)  [编辑](https://i.cnblogs.com/EditPosts.aspx?postid=2126726)  [收藏](javascript:)

**词法分析****MYSQLlex**

客户端向服务器发送过来SQL语句后，服务器首先要进行词法分析，而后进行语法分析，语义分析，构造执行树，生成执行计划。词法分析是第一阶段，虽然在理解Mysql实现上意义不是很大，但作为基础还是学习下比较好。

词法分析即将输入的语句进行分词(token)，解析出每个token的意义。分词的本质便是正则表达式的匹配过程，比较流行的分词工具应该是lex，通过简单的规则制定，来实现分词。Lex一般和yacc结合使用。关于lex和yacc的基础知识请参考[Yacc与Lex快速入门 - IBM](http://www.google.com.hk/url?q=http://www.ibm.com/developerworks/cn/linux/sdk/lex/index.html&sa=U&ei=7eo4TsHbAsHsrAfn8onkDw&ved=0CA4QFjAA&usg=AFQjCNE7rsDghtWnWwnlgsyVmisTZk59Lg)。如果想深入学习的话，可以看下《LEX与YACC》。

然而Mysql并没有使用lex来实现词法分析，但是语法分析却用了yacc，而yacc需要词法分析函数yylex，故在sql_yacc.cc文件最前面我们可以看到如下的宏定义:

```plain
/*
 Substitute the variable and function names.  
*/

#define
 yyparse         MYSQLparse

#define
 yylex           MYSQLlex
```

　　这里的MYSQLlex也就是本文的重点，即MYSQL自己的词法分析程序。源码版本5.1.48。源码太长，贴不上来，算啦..在sql_lex.cc里面。

　　我们第一次进入词法分析，state默认值为MY\_LEX\_START，就是开始状态了，其实state的宏的意义可以从名称上猜个差不多，再比如MY\_LEX\_IDEN便是标识符。对START状态的处理伪代码如下：

[![复制代码](assets/1589709439-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

```plain
case
 MY_LEX_START:{Skip空格获取第一个有效字符cstate 
=
 state_map[c];Break;}
```

[![复制代码](assets/1589709439-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

　　我困惑了，这尼玛肿么出来个state_map？找到了在函数开始出有个赋值的地方：

```plain
uchar 
*
state_map
=
 cs
->
state_map;
```

　　cs？！不会是反恐精英吧!!快速监视下cs为my\_charset\_latin1,哥了然了，原来cs是latin字符集，character set的缩写吧。那么为神马state_map可以直接决定状态？找到其赋值的地方，在init\_state\_maps函数中，代码如下所示：

[![复制代码](assets/1589709439-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

```plain
/*
 Fill state_map with states to get a faster parser 
*/
  
for
 (i
=
0
; i 
<
 
256
 ; i
++
)  {    
if
 (my_isalpha(cs,i))      state_map[i]
=
(uchar) MY_LEX_IDENT;    
else
 
if
 (my_isdigit(cs,i))      state_map[i]
=
(uchar) MY_LEX_NUMBER_IDENT;
#if
 defined(USE_MB) && defined(USE_MB_IDENT)
    
else
 
if
 (my_mbcharlen(cs, i)
>
1
)      state_map[i]
=
(uchar) MY_LEX_IDENT;
#endif
    
else
 
if
 (my_isspace(cs,i))      state_map[i]
=
(uchar) MY_LEX_SKIP;    
else
      state_map[i]
=
(uchar) MY_LEX_CHAR;  }  state_map[(uchar)
'
_
'
]
=
state_map[(uchar)
'
$
'
]
=
(uchar) MY_LEX_IDENT;  state_map[(uchar)
'
\'
'
]
=
(uchar) MY_LEX_STRING;  state_map[(uchar)
'
.
'
]
=
(uchar) MY_LEX_REAL_OR_POINT;  state_map[(uchar)
'
>
'
]
=
state_map[(uchar)
'
=
'
]
=
state_map[(uchar)
'
!
'
]
=
 (uchar) MY_LEX_CMP_OP;  state_map[(uchar)
'
<
'
]
=
 (uchar) MY_LEX_LONG_CMP_OP;  state_map[(uchar)
'
&
'
]
=
state_map[(uchar)
'
|
'
]
=
(uchar) MY_LEX_BOOL;  state_map[(uchar)
'
#
'
]
=
(uchar) MY_LEX_COMMENT;  state_map[(uchar)
'
;
'
]
=
(uchar) MY_LEX_SEMICOLON;  state_map[(uchar)
'
:
'
]
=
(uchar) MY_LEX_SET_VAR;  state_map[
0
]
=
(uchar) MY_LEX_EOL;  state_map[(uchar)
'
\\
'
]
=
 (uchar) MY_LEX_ESCAPE;  state_map[(uchar)
'
/
'
]
=
 (uchar) MY_LEX_LONG_COMMENT;  state_map[(uchar)
'
*
'
]
=
 (uchar) MY_LEX_END_LONG_COMMENT;  state_map[(uchar)
'
@
'
]
=
 (uchar) MY_LEX_USER_END;  state_map[(uchar) 
'
`
'
]
=
 (uchar) MY_LEX_USER_VARIABLE_DELIMITER;  state_map[(uchar)
'
"
'
]
=
 (uchar) MY_LEX_STRING_OR_DELIMITER;
```

[![复制代码](assets/1589709439-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

```plain
　　先来看这个
for
循环，
256
应该是
256
个字符了，每个字符的处理应该如下规则：如果是字母，则
state = MY_LEX_IDENT
；如果是数字，则
state = MY_LEX_NUMBER_IDENT
，如果是空格，则
state = MY_LEX_SKIP
，剩下的全为
MY_LEX_CHAR
。
```

       for循环之后，又对一些特殊字符进行了处理，由于我们的语句“select @@version_comment limit 1”中有个特殊字符@，这个字符的state进行了特殊处理，为MY\_LEX\_USER_END。

对于my_isalpha等这几个函数是如何进行判断一个字符属于什么范畴的呢？跟进去看下，发现是宏定义：

```plain
#define
    my_isalpha(s, c)  (((s)->ctype+1)[(uchar) (c)] & (_MY_U | _MY_L))
```

Wtf，肿么又来了个ctype，c作为ctype的下标，\_MY\_U | \_MY\_L如下所示，

```plain
#define
    _MY_U   01    /* Upper case */

#define
    _MY_L   02    /* Lower case */
```

　　ctype里面到底存放了什么？在ctype-latin1.c源文件里面，我们找到了my\_charset\_latin1字符集的初始值：

[![复制代码](assets/1589709439-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

```plain
CHARSET_INFO my_charset_latin1
=
{    
8
,
0
,
0
,                           
/*
 number    
*/
    MY_CS_COMPILED 
|
 MY_CS_PRIMARY, 
/*
 state     
*/
    
"
latin1
"
,                        
/*
 cs name    
*/
    
"
latin1_swedish_ci
"
,              
/*
 name      
*/
    
""
,                                
/*
 comment   
*/
    NULL,                         
/*
 tailoring 
*/
    ctype_latin1,    to_lower_latin1,    to_upper_latin1,    sort_order_latin1,    NULL,           
/*
 contractions 
*/
    NULL,           
/*
 sort_order_big
*/
    cs_to_uni,             
/*
 tab_to_uni   
*/
    NULL,           
/*
 tab_from_uni 
*/
    my_unicase_default, 
/*
 caseinfo     
*/
    NULL,           
/*
 state_map    
*/
    NULL,           
/*
 ident_map    
*/
    
1
,                  
/*
 strxfrm_multiply 
*/
    
1
,                  
/*
 caseup_multiply  
*/
    
1
,                  
/*
 casedn_multiply  
*/
    
1
,                  
/*
 mbminlen   
*/
    
1
,                  
/*
 mbmaxlen  
*/
    
0
,                  
/*
 min_sort_char 
*/
    
255
,        
/*
 max_sort_char 
*/
    
'
 
'
,                
/*
 pad char      
*/
    
0
,                  
/*
 escape_with_backslash_is_dangerous 
*/
    
&
my_charset_handler,    
&
my_collation_8bit_simple_ci_handler};
```

[![复制代码](assets/1589709439-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

　　可以看出ctype = ctype_latin1；而ctype_latin1值为：

[![复制代码](assets/1589709439-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

```plain
static
 uchar ctype_latin1[] 
=
 {    
0
,   
32
, 
32
, 
32
, 
32
, 
32
, 
32
, 
32
, 
32
, 
32
, 
40
, 
40
, 
40
, 
40
, 
40
, 
32
, 
32
,   
32
, 
32
, 
32
, 
32
, 
32
, 
32
, 
32
, 
32
, 
32
, 
32
, 
32
, 
32
, 
32
, 
32
, 
32
, 
32
,   
72
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
,  
132
,
132
,
132
,
132
,
132
,
132
,
132
,
132
,
132
,
132
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
,   
16
,
129
,
129
,
129
,
129
,
129
,
129
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,    
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
, 
16
, 
16
, 
16
, 
16
, 
16
,   
16
,
130
,
130
,
130
,
130
,
130
,
130
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,    
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
, 
16
, 
16
, 
16
, 
16
, 
32
,   
16
,  
0
, 
16
,  
2
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
,  
1
, 
16
,  
1
,  
0
,  
1
,  
0
,    
0
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
,  
2
, 
16
,  
2
,  
0
,  
2
,  
1
,   
72
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
,   
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
, 
16
,    
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,    
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
, 
16
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
1
,  
2
,    
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,    
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
, 
16
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
,  
2
};
```

[![复制代码](assets/1589709439-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

　　看到这里哥再一次了然了，这些值都是经过预计算的，第一个0是无效的，这也是为什么my_isalpha(s, c)定义里面ctype要先+1的原因。通过\_MY\_U和\_MY\_L的定义，可以知道，这些值肯定是按照相应的ASCII码的具体意义进行置位的。比如字符'A'，其ASCII码为65，其实大写字母，故必然具有\_MY\_U，即第0位必然为1，找到ctype里面第66个（略过第一个无意义的0）元素，为129 = 10000001，显然第0位为1(右边起)，说明为大写字母。写代码的人确实比较牛X，如此运用位，哥估计这辈子也想不到了，小小佩服下。State的问题点到为止了。

继续进行词法分析，第一个字母为s，其state = MY\_LEX\_IDENT（IDENTIFIER:标识符的意思）,break出来，继续循环，case进入MY\_LEX\_IDENT分支：

[![复制代码](assets/1589709439-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

```plain
Case MY_LEX_IDENT：{由s开始读，直到空格为止If（读入的单词为关键字）{nextstate 
=
 MY_LEX_START；Return tokval;        
//
关键字的唯一标识

}Else{
return
 IDENT_QUOTED 或者 IDENT；表示为一般标识符}}
```

[![复制代码](assets/1589709439-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

　　这里SELECT肯定为关键字，至于为什么呢？下节的语法分析会讲。

解析完SELECT后，需要解析@@version_comment,第一个字符为@,进入START分支，state = MY\_LEX\_USER_END；

进入MY\_LEX\_USER_END分支，如下：

[![复制代码](assets/1589709439-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

```plain
case
 MY_LEX_USER_END:        
//
 end '@' of user@hostname

      
switch
 (state_map[lip
->
yyPeek()]) {      
case
 MY_LEX_STRING:      
case
 MY_LEX_USER_VARIABLE_DELIMITER:      
case
 MY_LEX_STRING_OR_DELIMITER:    
break
;      
case
 MY_LEX_USER_END:    lip
->
next_state
=
MY_LEX_SYSTEM_VAR;    
break
;      
default
:    lip
->
next_state
=
MY_LEX_HOSTNAME;    
break
;
```

[![复制代码](assets/1589709439-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

　　哥会心的笑了，两个@符号就是系统变量吧～～,下面进入MY\_LEX\_SYSTEM_VAR分支

[![复制代码](assets/1589709439-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

```plain
case
 MY_LEX_SYSTEM_VAR:      yylval
->
lex_str.str
=
(
char
*
) lip
->
get_ptr();      yylval
->
lex_str.length
=
1
;      lip
->
yySkip();                                    
//
 Skip '@'

      lip
->
next_state
=
 (state_map[lip
->
yyPeek()] 
==
            MY_LEX_USER_VARIABLE_DELIMITER 
?
            MY_LEX_OPERATOR_OR_IDENT :            MY_LEX_IDENT_OR_KEYWORD);      
return
((
int
) 
'
@
'
);
```

[![复制代码](assets/1589709439-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

　　所作的操作是略过@，next_state设置为MY\_LEX\_IDENT\_OR\_KEYWORD，再之后便是解析MY\_LEX\_IDENT\_OR\_KEYWORD了，也就是version_comment了，此解析应该和SELECT解析路径一致，但不是KEYWORD。剩下的留给有心的读者了（想起了歌手经常说的一句话：大家一起来，哈哈）。

Mysql的词法解析的状态还是比较多的，如果细究还是需要点时间的，但这不是Mysql的重点，我就浅尝辄止了。下节会针对上面的SQL语句讲解下语法分析。

PS: 一直想好好学习下Mysql，总是被这样或那样的事耽误，当然都是自己的原因，希望这次能走的远点.....

PS again：本文只代表本人的学习感悟，如有异议，欢迎指正。

踏着落叶，追寻着我的梦想。转载请注明出处

[«](https://www.cnblogs.com/nocode/archive/2011/05/04/2036873.html) 上一篇： [Oracle的bug还是故意为之？](https://www.cnblogs.com/nocode/archive/2011/05/04/2036873.html "发布于 2011-05-04 18:22")  
[»](https://www.cnblogs.com/nocode/archive/2011/08/09/2132814.html) 下一篇： [Mysql源码学习——打造专属语法](https://www.cnblogs.com/nocode/archive/2011/08/09/2132814.html "发布于 2011-08-09 21:11")

*   分类 [MySQL Code Trace](https://www.cnblogs.com/nocode/category/293180.html)
*   标签 [MYSQL](https://www.cnblogs.com/nocode/tag/MYSQL/) , [词法分析](https://www.cnblogs.com/nocode/tag/%E8%AF%8D%E6%B3%95%E5%88%86%E6%9E%90/) , [LEX](https://www.cnblogs.com/nocode/tag/LEX/)

---------------------------------------------------


原网址: [访问](https://www.cnblogs.com/nocode/archive/2011/08/03/2126726.html)

创建于: 2020-05-17 17:57:19

目录: default

标签: `www.cnblogs.com`

