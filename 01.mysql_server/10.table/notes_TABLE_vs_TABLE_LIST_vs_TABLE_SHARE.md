#1.比较三者


```cpp
在 MySQL 的源码中，TABLE_LIST、TABLE 和 TABLE_SHARE 是与表操作相关的核心数据结构，它们从不同层面描述了表的元信息、实例状态和共享属性，三者的关系如下：
1. 核心作用与定位
TABLE_SHARE：存储表的共享元数据（全局唯一），所有会话共享同一份，描述表的结构定义（如字段、索引、表类型等），不包含会话相关的状态信息。
TABLE：存储单个会话中表的实例状态（会话私有），基于 TABLE_SHARE 初始化，包含当前会话对表的操作状态（如锁、游标、临时数据等）。
TABLE_LIST：存储查询语句中的表引用信息（如 JOIN 中的表关系），是 SQL 解析阶段生成的逻辑结构，用于描述表在查询中的角色（如别名、连接类型、查询条件等）。
2. 三者的关系
（1）TABLE_SHARE ← TABLE：一对多关系
TABLE_SHARE 是基础：每个表在 MySQL 中对应唯一的 TABLE_SHARE 实例，包含表的静态元数据（如 create_time、字段定义 Field 数组、索引信息 key_info 等）。
TABLE 是 TABLE_SHARE 的会话实例：当会话需要操作表时（如执行 SELECT、UPDATE），会基于 TABLE_SHARE 复制元数据，创建 TABLE 实例。
一个 TABLE_SHARE 可以被多个会话的多个 TABLE 实例引用（例如多个会话同时查询同一张表）。
TABLE 中通过 s 字段指向其对应的 TABLE_SHARE（struct TABLE_SHARE *s;）。
（2）TABLE_LIST ← TABLE：逻辑引用关系
TABLE_LIST 是查询中的表逻辑描述：SQL 解析时，MySQL 会为查询中涉及的每个表（包括别名、子查询表等）创建 TABLE_LIST 节点，记录表名、别名、连接类型（如 INNER JOIN）、关联条件等。
TABLE_LIST 关联 TABLE 实例：查询执行阶段，TABLE_LIST 通过 table 字段指向实际的 TABLE 实例（struct TABLE *table;），即逻辑表引用与物理表实例的绑定。
一个 TABLE_LIST 对应一个 TABLE 实例，但一个 TABLE 实例可能被多个 TABLE_LIST 引用（如自连接查询中，同一张表的两个 TABLE_LIST 节点指向不同的 TABLE 实例）。
3. 数据结构简化示意
c
运行
// 简化的 TABLE_SHARE 结构（全局共享元数据）
struct TABLE_SHARE {
  char *table_name;        // 表名
  char *db;                // 数据库名
  Field **field;           // 字段定义数组
  Key_info *key_info;      // 索引信息
  uint fields;             // 字段数量
  uint keys;               // 索引数量
  // ... 其他静态元数据
};

// 简化的 TABLE 结构（会话私有实例）
struct TABLE {
  TABLE_SHARE *s;          // 指向共享的 TABLE_SHARE
  uint table_flags;        // 表状态标志（如是否加锁）
  THR_LOCK thr_lock;       // 表级锁
  File file;               // 表文件句柄
  // ... 其他会话相关的动态状态
};

// 简化的 TABLE_LIST 结构（查询中的表引用）
struct TABLE_LIST {
  char *alias;             // 表的别名（如 SELECT t1.id FROM t AS t1）
  char *db;                // 数据库名
  char *table_name;        // 表名
  TABLE *table;            // 指向对应的 TABLE 实例
  TABLE_LIST *next_local;  // 下一个关联表（如 JOIN 中的表链）
  enum join_type join_type;// 连接类型（如 INNER_JOIN）
  // ... 其他查询相关的逻辑信息
};
4. 典型流程示例
当执行 SELECT a.id, b.name FROM t1 AS a JOIN t2 AS b ON a.id = b.t1_id; 时：
加载 TABLE_SHARE：MySQL 从数据字典中加载 t1 和 t2 的 TABLE_SHARE（全局唯一）。
创建 TABLE 实例：会话为 t1 和 t2 分别创建 TABLE 实例，每个 TABLE 的 s 字段指向对应的 TABLE_SHARE。
解析生成 TABLE_LIST：解析器生成两个 TABLE_LIST 节点（别名 a 和 b），分别记录表名、别名、连接类型等，并通过 table 字段绑定到步骤 2 创建的 TABLE 实例。
执行查询：通过 TABLE_LIST 找到对应的 TABLE 实例，再通过 TABLE 访问 TABLE_SHARE 中的元数据，完成数据读取和连接操作。
总结
TABLE_SHARE：全局共享的表结构定义，是 “模板”。
TABLE：基于模板创建的会话级实例，包含动态状态，是 “实例”。
TABLE_LIST：查询中对表的逻辑引用，关联实例与查询逻辑，是 “逻辑指针”。
三者协作支撑了 MySQL 对表的解析、访问和并发控制，确保元数据共享的同时，隔离不同会话的操作状态。
```