#1.TABLE_LIST, TABLE和TABLE_SHARE

在 MySQL 源码里，TABLE_LIST、TABLE 和 TABLE_SHARE 是与表操作紧密相关的数据结构，它们在 MySQL 的查询处理、表管理等流程中扮演着不同的角色，下面为你详细阐述它们之间的关系：
##数据结构概述
### TABLE_LIST：
主要用于表示 SQL 查询里涉及的表信息。它在查询解析阶段发挥作用，会记录表的别名、表名、连接类型、是否为外连接等和查询相关的表信息，是查询优化器处理查询时的关键数据结构。
###TABLE：
代表了一个打开的表实例。在 MySQL 执行查询时，会为每个要操作的表创建一个 TABLE 对象，它包含了表的元数据、数据缓存、锁信息等，和表的实际操作紧密相关。
###TABLE_SHARE：
是表共享数据结构，它存储了多个 TABLE 对象可以共享的表信息，像表的定义、索引信息、表的统计信息等。多个 TABLE 对象可以共享同一个 TABLE_SHARE 对象，以节省内存和提高效率。
##三者之间的关系
###TABLE_LIST 与 TABLE
在查询解析阶段，TABLE_LIST 会被创建并填充查询中涉及的表信息。当 MySQL 准备执行查询时，会根据 TABLE_LIST 里的信息为每个表创建对应的 TABLE 对象。可以把 TABLE_LIST 看作是查询层面的表描述，而 TABLE 是实际操作层面的表实例。
例如，在一个 SQL 查询 SELECT * FROM table1 JOIN table2 ON table1.id = table2.id 中，查询解析器会创建两个 TABLE_LIST 对象分别代表 table1 和 table2，然后在执行阶段为这两个表分别创建 TABLE 对象来进行实际的数据操作。
###TABLE 与 TABLE_SHARE
多个 TABLE 对象可以共享同一个 TABLE_SHARE 对象。当多个查询同时访问同一个表时，每个查询可能会创建自己的 TABLE 对象，但这些 TABLE 对象会共享该表的 TABLE_SHARE 对象，因为表的定义、索引信息等是不变的，共享这些信息可以避免重复存储和维护。
例如，在并发查询同一个表时，每个查询线程都会有自己的 TABLE 对象来处理该表的数据，但它们都会引用同一个 TABLE_SHARE 对象，该对象存储了表的元数据和统计信息等。
###TABLE_LIST 与 TABLE_SHARE
TABLE_LIST 并不直接和 TABLE_SHARE 关联，而是通过 TABLE 建立间接联系。TABLE_LIST 提供了查询中表的基本信息，根据这些信息创建 TABLE 对象，而 TABLE 对象会引用对应的 TABLE_SHARE 对象来获取表的共享信息。

##示例代码说明
下面是一个简化的示例代码，展示了它们之间的关系：



```cpp
// 假设这是查询解析阶段
TABLE_LIST *table_list1 = new TABLE_LIST("table1", "t1");
TABLE_LIST *table_list2 = new TABLE_LIST("table2", "t2");

// 执行阶段，根据 TABLE_LIST 创建 TABLE 对象
TABLE *table1 = open_table(table_list1);
TABLE *table2 = open_table(table_list2);

// TABLE 对象共享 TABLE_SHARE
TABLE_SHARE *share1 = table1->s;
TABLE_SHARE *share2 = table2->s;

// 这里 share1 和 share2 可能指向同一个 TABLE_SHARE 对象（如果是同一个表）
```