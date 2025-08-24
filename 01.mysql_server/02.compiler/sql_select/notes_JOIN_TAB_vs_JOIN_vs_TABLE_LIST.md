#1.JOIN_TAB vs JOIN vs TABLE_LIST

```cpp
在 MySQL 源码中，JOIN、JOIN_TAB 和 TABLE_LIST 是支撑查询语句（尤其是关联查询）执行的核心数据结构，它们从不同层面描述查询的逻辑结构、执行计划和表关联关系，三者的关系如下：
1. 核心作用与定位
TABLE_LIST：逻辑层面的表引用结构，用于描述 SQL 语句中涉及的表（包括表名、别名、连接条件、子查询等），是 SQL 解析阶段的产物。
JOIN：执行层面的查询对象，代表整个关联查询的执行计划，包含查询的所有表、连接顺序、条件、排序等核心执行信息。
JOIN_TAB：单表执行单元，是JOIN的组成部分，每个JOIN_TAB对应查询中的一个表（或子查询），存储该表的执行状态、数据读取方式等。
2. 三者的关系
（1）TABLE_LIST → JOIN_TAB：逻辑到执行的映射
TABLE_LIST 是 SQL 解析后生成的逻辑表结构，记录了表的原始信息（如别名、连接类型、关联条件等）。
在查询优化阶段，TABLE_LIST 会被转换为 JOIN_TAB 结构：
一个 TABLE_LIST 通常对应一个 JOIN_TAB（除非表被物化或特殊处理）。
JOIN_TAB 中的 table 字段指向该表对应的 TABLE 实例（物理表），table_list 字段则反向关联到原始的 TABLE_LIST（保持逻辑引用）。
（2）JOIN → JOIN_TAB：聚合与管理
JOIN 是整个关联查询的 “管理者”，内部通过一个 JOIN_TAB 数组（join_tab）管理所有参与关联的表。
数组的顺序代表了表的关联顺序（由优化器决定），JOIN 负责协调这些 JOIN_TAB 的执行（如先读取哪个表，如何通过连接条件关联）。
一个 JOIN 包含多个 JOIN_TAB（数量等于查询中表的数量），即 1:N 关系。
（3）整体关系链
plaintext
SQL语句 → 解析 → TABLE_LIST（逻辑表结构）  
                          ↓  
查询优化 → JOIN（执行计划）包含多个 JOIN_TAB（单表执行单元）  
                          ↑  
                    TABLE（物理表实例）
3. 数据结构简化示意
c
运行
// 简化的 TABLE_LIST（逻辑表引用）
struct TABLE_LIST {
  char *table_name;       // 表名
  char *alias;            // 别名（如 t1）
  TABLE_LIST *next_local; // 下一个关联表（如 JOIN 中的其他表）
  Item *on_expr;          // 连接条件（如 ON t1.id = t2.t1_id）
  enum join_type join_type; // 连接类型（INNER_JOIN / LEFT_JOIN 等）
  // ... 其他逻辑信息
};

// 简化的 JOIN_TAB（单表执行单元）
struct JOIN_TAB {
  TABLE *table;           // 指向物理表实例
  TABLE_LIST *table_list; // 关联到逻辑表描述（TABLE_LIST）
  enum scan_type scan;    // 扫描方式（全表扫描 / 索引扫描等）
  bool is_loose_scan;     // 是否松散扫描（用于索引优化）
  // ... 其他单表执行状态
};

// 简化的 JOIN（整个关联查询的执行计划）
struct JOIN {
  JOIN_TAB *join_tab;     // JOIN_TAB 数组，存储所有参与关联的表
  uint tables;            // 表的数量（join_tab 数组长度）
  Item *where;            // WHERE 条件
  Item *order;            // ORDER BY 条件
  uint best_pos;          // 最优关联顺序（优化器选择的表顺序）
  // ... 其他查询执行信息
};
4. 典型流程示例
以查询 SELECT * FROM t1 JOIN t2 ON t1.id = t2.t1_id WHERE t1.a > 10; 为例：
解析阶段：生成 TABLE_LIST 结构，包含 t1 和 t2 的表名、别名、JOIN 类型、ON 条件等逻辑信息。
优化阶段：
优化器决定关联顺序（如先 t1 后 t2）。
将 TABLE_LIST 转换为 JOIN_TAB 数组（join_tab[0] 对应 t1，join_tab[1] 对应 t2），每个 JOIN_TAB 关联到对应的 TABLE 实例和 TABLE_LIST。
执行阶段：JOIN 结构协调 JOIN_TAB 数组的执行：
按 join_tab 顺序读取表数据（先 t1 过滤 a > 10，再通过 ON 条件关联 t2）。
最终聚合结果返回。
总结
TABLE_LIST 是 “逻辑描述”，记录 SQL 中表的原始信息；
JOIN_TAB 是 “执行单元”，将逻辑表映射到物理表，并存储单表执行细节；
JOIN 是 “全局管理者”，聚合所有 JOIN_TAB，控制整个关联查询的执行流程。
三者从逻辑到物理、从个体到整体，共同支撑了 MySQL 对关联查询的解析、优化和执行。
```