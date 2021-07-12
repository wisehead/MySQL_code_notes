

# [MySQL Global&Session 变量的实现原理]

MySQL的系统变量存在两个作用域：全局作用域（Global）和会话作用域（Session）：

*   MySQL启动时，初始化所有系统变量全局作用域的值（除非一个系统变量只有会话作用域）:
    *   默认值
    *   配置文件中的值
*   新建立一个会话时，根据当前所有系统变量全局作用域的值，初始化相应系统变量会话作用域的值

注意：

*   在当前会话中修改Global.Var的值，当前会话的Session.Var不受影响，但新建立会话后，Session.Var会受影响

## 实现

在MySQL中，对系统变量进行了分类实现：

*   Sys\_var\_bit：位类型，如unique\_ckecks / autocommit
*   Sys\_var\_double：浮点类型，如`long_query_time`
    
*   Sys\_var\_enum：枚举类型，如binlog\_format
*   ......

这里只说明对Sys\_var\_bit的SET的实现，以unique\_checks为例：

【会话作用域】

*   每个线程维护一个自身的“变量比特位”（option\_bits），每一个比特位表示一个变量的取值
*   每个系统变量（Sys\_var\_bit类型）定义自身的掩码，例如OPTION\_RELAXED\_UNIQUE\_CHECKS=1<<27（unique\_checks）
*   查看线程THD的unique\_checks：
    *   THD.option\_bits & OPTION\_RELAXED\_UNIQUE\_CHECKS（取变量比特位的第27位，就是这个线程unique\_checks的取值）
*   修改线程THD的unique\_checks：
    *   THD.option\_bits |= OPTION\_RELAXED\_UNIQUE\_CHECKS（设置变量比特位的第27位，就是设置这个线程unique\_checks的值）

【全局作用域】

*   定义全局变量global\_system\_variables，维护掩码（option\_bits）
*   其余同【会话作用域】

下面是MySQL在实现的几个细节：

*   每个线程THD中，system\_variables保存系统变量
*   system\_variables中option\_bits保存这个THD中的所有Sys\_var\_bit类型变量的取值
*   如何获取system\_variables中的option\_bits？（简单的system\_variables.option\_bits就可以了，但MySQL不是这么实现的） 
    
    ```plain
    // TYPE是结构体，MEMBER是成员，获取MEMBER在TYPE中的地址偏移
    #define offsetof(TYPE, MEMBER) ((size_t) &((TYPE *)0)->MEMBER)
    ```
    
