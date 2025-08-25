#1.Key vs KEY(st_key)

```cpp
在 MySQL 源码中，Key（通常写为KEY，大写形式，是结构体名）和st_key（小写前缀st_表示 “struct”，是另一种结构体）是与索引相关的两个不同数据结构，分别用于描述索引的元信息和索引键值的临时存储，核心区别如下：
1. KEY（Key）结构体
核心作用：描述索引的元数据（即索引本身的定义信息），是索引在 MySQL 中的 “蓝图”。
存储内容：记录索引的名称、类型（如主键、普通索引、唯一索引）、包含的字段（索引列）、索引长度、是否允许 NULL 值等静态属性。
生命周期：随表结构（TABLE_SHARE）一同创建，在表加载时从数据字典（如.frm文件或数据字典表）中读取，全局共享，表结构不变则KEY信息不变。
关联对象：属于TABLE_SHARE的一部分，一个表的所有索引通过KEY数组（key_info）存储在TABLE_SHARE中。
2. st_key结构体
核心作用：作为索引键值的临时存储容器，用于在查询执行过程中临时存放索引键的具体值（如查询条件中的索引键、排序时的索引键等）。
存储内容：包含一个字节数组（key）用于存储键值的二进制数据，以及键值的长度（length）、类型（type）等动态信息。
生命周期：临时创建于查询执行阶段（如解析 WHERE 条件、执行索引扫描时），用于临时缓存或比较索引键值，查询结束后释放。
关联对象：常用于JOIN_TAB、QEP_TAB等执行阶段的结构体中，作为临时变量参与索引键的比较、排序等操作。
3. 数据结构简化对比
KEY（索引元数据）
c
运行
struct KEY {
  char *name;               // 索引名称（如"PRIMARY"）
  uint key_length;          // 索引总长度（字节）
  uint user_defined_key_parts; // 用户定义的索引列数量
  KEY_PART_INFO *key_part;  // 索引列信息数组（每个元素对应一个索引列）
  enum key_type type;       // 索引类型（如HA_KEYTYPE_PRIMARY、HA_KEYTYPE_UNIQUE）
  bool nullable;            // 是否允许NULL值
  // ... 其他索引定义相关属性
};
st_key（索引键值临时存储）
c
运行
struct st_key {
  uchar *key;               // 存储索引键值的二进制数据
  uint length;              // 键值的实际长度（字节）
  enum key_part_type type;  // 键值类型（如STRING、INT）
  // ... 其他键值相关的临时属性
};
4. 典型使用场景对比
KEY的使用场景：
当 MySQL 加载表时，会解析表的索引定义，为每个索引创建KEY结构体，并存储在TABLE_SHARE->key_info中。例如，查询SHOW INDEX FROM table时，MySQL 会读取KEY结构体中的信息返回（如索引名称、列名、类型等）。
st_key的使用场景：
当执行SELECT * FROM table WHERE index_col = 10时，MySQL 会将条件值10转换为st_key结构体（存储10的二进制形式和长度），再用它在索引中进行查找比较；或在索引排序时，用st_key临时存储待排序的键值。
总结
维度	KEY（Key）	st_key
本质	索引的元数据定义（静态蓝图）	索引键值的临时存储容器（动态值）
存储内容	索引名称、类型、列信息等	键值的二进制数据、长度等
生命周期	随表结构创建，长期存在	随查询执行临时创建，用完释放
核心作用	描述索引 “是什么”	存储索引键 “值是什么”
简单来说，KEY是 “索引的说明书”，st_key是 “索引键值的临时快递盒”，前者定义索引本身，后者用于操作索引的具体值。

```