

# [InnoDB（十八）：Data Dictionary]


## 概念介绍

MySQL data dictionary （简称 DD）是一些列表的统称，是 MySQL system tables 的一部分。data dictionary 包含的是 SQL 执行需要的 metadata，而其他 system table 多种多样，见 [5.3 The mysql System](https://dev.mysql.com/doc/refman/8.0/en/system-schema.html#system-schema-data-dictionary-tables) Schema。data dictionary 里的表默认是隐藏的，查看方法在 [14.1 Data Dictionary Schema](https://dev.mysql.com/doc/refman/8.0/en/data-dictionary-schema.html)

### DDSE

data dictionary 使用事务型存储引擎来存储（Data Dictionary Storage Engine，简称 DDSE），当前只有 InnoDB。data dictionary 的表位于一个独立的 InnoDB tablespace，是 mysql.ibd（名字不能被修改或作他用）

### DOC

因为 data dictionary 主要是用于支持 Server 层 SQL 执行，因此在 Server 层通过维护 cache 来降低访问的开销（Dictionary Object Cache，简称 DOC）。DOC 由 cache partitions 组成，每个 partition 包含不同的 object 类型，例如 tablespace definition cache partition / schema definition cache partition ...

## 实现

在 [The mysql System Schema](https://dev.mysql.com/doc/refman/8.0/en/system-schema.html#system-schema-data-dictionary-tables) 里可以看到 DD 里所有的表（e.g indexes / collations ...），我们以 indexes 举例来说明 DD 的实现

### 表的定义

indexes 表的定义在 dd / impl / tables / indexes.h 中

```plain
class Indexes : public Object_table_impl {
    // 表定义
    enum enum_fields {
    FIELD_ID,
    FIELD_TABLE_ID,
    FIELD_NAME,
    FIELD_TYPE,
    FIELD_ALGORITHM,
    FIELD_IS_ALGORITHM_EXPLICIT,
    FIELD_IS_VISIBLE,
    FIELD_IS_GENERATED,
    FIELD_HIDDEN,
    FIELD_ORDINAL_POSITION,
    FIELD_COMMENT,
    FIELD_OPTIONS,
    FIELD_SE_PRIVATE_DATA,
    FIELD_TABLESPACE_ID,
    FIELD_ENGINE,
    NUMBER_OF_FIELDS  // Always keep this entry at the end of the enum
  };
  ...
}
```

### 序列化 / 反序列化

indexes 表中每一行从磁盘存储格式 / 内存存储格式的 序列化和反序列化在 dd / impl / types / indexes\_impl.h 中

```plain
bool Index_impl::store_attributes(Raw_record *r)
bool Index_impl::restore_attributes(const Raw_record &r)
```

  

