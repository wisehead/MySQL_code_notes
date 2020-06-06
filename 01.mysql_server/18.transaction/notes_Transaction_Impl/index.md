# [MySQL 5.6：事务实现]

## 几个概念

MySQL的事务有如下两种形式：

1\. **显式的事务**：由「BEGIN ... COMMIT」包围的事务都被视为一个显式的事务

```sql
BEGIN;
...
COMMIT;
```

2\. **自动的事务**：开启自动提交模式（即SET autocommit = 1）的Session：

*   每一个Statement都被视为一个隐式的事务
*   由「BEGIN ... COMMIT」包围的事务都被视为一个显式的事务

3\. **隐式的事务**：在未开启自动提交的Session中，由「隐式的开始」开启，或由「隐式的提交」提交的事务

*   Session当前没有活跃的事务，此时执行第一个Statement会被MySQL作为新事务的开启，被称为「**隐式的开始**」
*   在一些指定的[SQL Statement](https://dev.mysql.com/doc/refman/8.0/en/implicit-commit.html)执行时，MySQL会将此时该Session活跃的事务提交，称为**「隐式的提交」**

对于事务有几个共识的概念需要阐述

*   **Statement Transaction**：在显示的事务中，每一个Statement都被称为「Statement Transaction」，是一种不持久化（ACID中的D）的“非标准事务”
    
*   **Normal Transaction**：显示的事务，也被称为「Normal Transaction」
    
    *   **Multi-Statement Transaction**：在显示的事务中，包含多个Statement
    *   **One-Statement Transaction**：在显示的事务中，包含一个Statement

### Statement Transaction的必要性

（待补充）

## 附录

在handler.cc中有一大段讲述MySQL Server事务实现的注释

```plain
Transaction handling in the server ...
```
