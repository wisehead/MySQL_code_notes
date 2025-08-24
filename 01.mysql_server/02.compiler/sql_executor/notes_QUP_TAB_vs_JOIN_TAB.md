#1.QEP_TAB vs JOIN_TAB

```cpp
在 MySQL 源码中，QEP_TAB 和 JOIN_TAB 是与查询执行计划（Query Execution Plan）相关的核心数据结构，主要用于支撑关联查询的执行过程。两者既存在关联又有明确分工，具体关系如下：
1. 核心定位与作用
JOIN_TAB：更偏向于执行阶段的表操作管理，存储单个表在关联查询中的执行状态、数据读取方式（如扫描类型、临时表信息等），是执行器实际操作的单元。
QEP_TAB：全称为 “Query Execution Plan Tab”，更偏向于优化阶段的执行计划描述，存储优化器为表选择的执行策略（如访问方法、索引使用、过滤条件等），是优化结果的载体。
2. 两者的关联关系
（1）QEP_TAB 是 JOIN_TAB 的 “计划来源”
在查询优化阶段，优化器会为每个参与关联的表生成 QEP_TAB 实例，记录该表的最优执行计划（如使用哪个索引、如何过滤数据、是否需要排序等）。
进入执行阶段时，JOIN_TAB 会基于 QEP_TAB 中的计划信息初始化，即 QEP_TAB 的优化结果会被 JOIN_TAB 继承并用于实际执行。
（2）JOIN_TAB 包含 QEP_TAB 的引用
JOIN_TAB 结构体中包含一个 QEP_TAB 类型的成员（通常命名为 qep_tab），用于关联到对应的优化计划。
这种设计使执行器在操作 JOIN_TAB 时，能随时访问优化器确定的执行策略（如通过 join_tab->qep_tab->key 获取选中的索引）。
（3）一对一对应关系
对于查询中的每个表（或子查询），通常存在一个 QEP_TAB 和一个 JOIN_TAB，两者一一对应：
一个 QEP_TAB 描述一个表的优化计划。
一个 JOIN_TAB 基于该计划管理表的实际执行（如数据读取、连接操作等）。
3. 数据结构简化示意
c
运行
// 简化的 QEP_TAB（优化阶段的执行计划）
struct QEP_TAB {
  TABLE *table;               // 关联的物理表
  KEY *key;                   // 选中的索引（优化器选择）
  uint key_parts;             // 使用的索引列数量
  Item *where;                // 表级过滤条件（WHERE 中该表的条件）
  enum access_method access;  // 访问方法（全表扫描/索引扫描等）
  // ... 其他优化相关的计划信息
};

// 简化的 JOIN_TAB（执行阶段的表操作单元）
struct JOIN_TAB {
  QEP_TAB qep_tab;            // 关联的优化计划
  TABLE *table;               // 物理表实例（通常与 qep_tab.table 一致）
  enum scan_type scan;        // 实际扫描类型（基于 qep_tab.access 初始化）
  bool is_ready;              // 表数据是否已读取就绪
  // ... 其他执行状态信息（如当前读取位置、临时结果等）
};
4. 典型流程中的协作
优化阶段：
优化器分析查询，为每个表生成 QEP_TAB，确定访问方法（如用哪个索引）、过滤条件等，并将 QEP_TAB 组织到查询计划中。
执行初始化：
执行器基于 QEP_TAB 创建 JOIN_TAB，将优化计划中的策略（如 QEP_TAB::key）转换为执行状态（如 JOIN_TAB::scan 设置为索引扫描）。
执行阶段：
执行器通过 JOIN_TAB 操作表数据，过程中参考 qep_tab 中的计划（如按 qep_tab->where 过滤数据），完成关联查询的执行。
总结
QEP_TAB 是 “计划者”，存储优化器为表确定的执行策略（what to do）。
JOIN_TAB 是 “执行者”，基于 QEP_TAB 的计划管理实际执行过程（how to do）。
两者通过一对一关联，实现了查询优化与执行的衔接，确保优化器的决策能被执行器正确落地。

```