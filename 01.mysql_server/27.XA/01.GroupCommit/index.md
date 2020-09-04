---
title: MySQL5.7 核心技术揭秘：MySQL Group Commit-云栖社区-阿里云
category: default
tags: 
  - yq.aliyun.com
created_at: 2020-04-29 21:43:44
original_url: https://yq.aliyun.com/articles/618471?utm_content=m_1000008698
---


# MySQL5.7 核心技术揭秘：MySQL Group Commit-云栖社区-阿里云

## MySQL5.7 核心技术揭秘：MySQL Group Commit


## 一、大纲

*   一阶段提交
*   二阶段提交
*   三阶段提交
*   组提交总结

## 二、一阶段提交

### 2.1 什么是一阶段提交

先了解下含义，其实官方并没有定义啥是一阶段，这里只是我为了上下文和好理解，自己定义的一阶段commit流程。

好了，这里的一阶段，其实是针对MySQL没有开启binlog为前提的，因为没有binlog，所以MySQL commit的时候就相对简单很多。

![commit_1](assets/1588167824-593bd2f4c6cdf568cc515bddfe432c0d.png "commit_1")

解释几个概念：

*   execution state做什么事情呢

```plain
在内存修改相关数据，比如：DML的修改
```

*   prepare stage做什么事情呢

```sql
1. write() redo  日志
    1.1 最重要的操作，记住这个时候就开始刷新redo了（依赖操作系统sync到磁盘），很多同学在这个地方都不太清楚，以为flush redo在最后commit阶段才开始
    1.2 这一步可以进行多事务的prepare，也就意味着可以多redo的flush，sync到磁盘，这里是redo的组提交. 在此说明MySQL5.6+ redo是可以进行组提交的，之后我们讨论的重点是binlog，就不在提及redo的组提交了
2. 更新undo状态
3. 等等
```

*   innodb commit stage做什么事情呢

```markdown
1. 更新undo的状态
2. fsync redo & undo(强制sync到磁盘)
3. 写入最终的commit log，代表事务结束
4. 等等
```

由于这里面只对应到redo日志，所以我们称之为一阶段commit

### 2.2 为什么要有一阶段提交

一阶段提交，主要是为了crash safe。

*   如果在 execution stage mysql crash

```perl
当MySQL重启后，因为没有记录redo，此事务回滚
```

*   如果在 execution stage mysql crash

```perl
当MySQL重启后，因为没有记录redo，此事务回滚
```

*   如果 prepare stage

```perl
1. redo log write()了，但是还没有fsync()到磁盘前，mysqld crash了
    此时：事务回滚

2. redo log write()了，fsync()也落盘了，mysqld crash了
    此时：事务还是回滚
```

*   如果 commit stage

```sql
1. commit log fsync到磁盘了
    此时：事务提交成功，否则事务回滚
```

### 2.3 一阶段提交的弊端

缺点也很明显：

*   缺点一

```markdown
1. 为什么redo fsync到磁盘后，还是要回滚呢？
```

*   缺点二

```markdown
1. 没有开启binlog，性能非常高，但是binlog是用来搭建slave的，否则就是单节点，不适合生产环境
```

## 三、二阶段提交

### 3.1 什么是二阶段提交

![commit_2](assets/1588167824-d60b796286f5aa6c2835b6954b7f8204.png "commit_2")

继续解释几个概念：

*   execution state做什么事情呢

```plain
在内存修改相关数据，比如：DML的修改
```

*   prepare stage做什么事情呢

```perl
1. write() redo  日志  --最重要的操作，记住这个时候就开始刷新redo了（依赖操作系统sync到磁盘），很多同学在这个地方都不太清楚，以为flush redo在最后commit阶段才开始
2. 更新undo状态
3. 等等
```

*   binlog stage做什么事情呢

```sql
1. write binlog
    flush binlog 内存日志到磁盘缓存
2. fsync binlog
    sync磁盘缓存的binlog日志到磁盘持久化
```

*   innodb commit stage做什么事情呢

```markdown
1. 更新undo的状态
2. fsync redo & undo(强制sync到磁盘)
3. 写入最终的commit log，代表事务结束
4. 等等
```

由于这里的流程中包含了binlog和redo日志刷新的协调一致性，我们称之为二阶段

### 3.2 为什么要有二阶段提交

当binlog开启的情况下，我们需要引入另一套流程来保证redo和binlog的一致性 ， 以及crash safe，所以我们用这套二阶段来实现

*   在prepare阶段，如果mysqld crash，由于事务未写入binlog且innodb 存储引擎未提交，所以将该事务回滚掉
*   当binlog阶段

```sql
1. binlog flush 到磁盘缓存，但是没有永久fsync到磁盘
    如果mysqld crash，此事务回滚

2. binlog永久fsync到磁盘，但是innodb commit log还未提交
    如果mysqld crash，MySQL 进行recover，从binlog的xid提取提交的事务进行重做并commit，来保证binlog和redo保持一致
```

*   当commit阶段

```sql

 如果innodb commit log已经提交，事务成功结束
```

那为什么要保证redo和binlog的一致性呢？

*   物理热备的问题

1.  多事务中，如果无法保证多事务的redo和binlog一致性，则会有如下问题

```sql
commit提交阶段包含的事情：
    1. prepare
    2. write binlog  & fsync binlog
    3. commit


T1 (---prepare-----write 100[pos1]-------fsync 100--------------------------------------online-backup[pos3:因为热备取的是最近的提交事务位置]-------commit)

T2 (------prepare------write 200[pos2]---------fsync 200------commit)

T3 (-----------prepare-------write 300[pos3]--------fsync 300--------commit)


解析：
    事务的开始顺序： T1 -》T2 -》T3
    事务的提交结束顺序：  T2 -》T3 -》T1
    binlog的写入顺序： T1 -》 T2 -》T3

结论：
    T2 ， T3 引擎层提交结束，T1 fsync binlog 100 也已经结束，但是T1引擎成没有提交成功，所以这时候online-backup记录的binlog位置是pos3（也就是T3提交后的位置）
    如果拿着备份重新恢复slave，由于热备是不会备份binlog的，所以事务T1会回滚掉，那么change master to pos3的时候，因为T1的位置是pos1（在pos3之前），所以T1事务被slave完美的漏掉了
```

1.  多事务中，可以通过三阶段提交（下面一节讲）保证redo和binlog的一致性，则备份无问题. 接下来看一个多事务中，事务日志和binlog日志一致的情况

```sql
commit提交阶段包含的事情：
    1. prepare
    2. write binlog  & fsync binlog
    3. commit


T1 (---prepare-----write 100[pos1]-------fsync 100-------------commit)

T2 (------prepare------write 200[pos2]---------fsync 200----------------online-backup[pos2:因为热备取的是最近的提交事务位置]---commit)

T3 (-----------prepare-------write 300[pos3]--------fsync 300----------------------------------------------------------------------------commit)


解析：
    事务的开始顺序： T1 -》T2 -》T3
    事务的提交结束顺序：  T1 -》T2 -》T3
    binlog的写入顺序： T1 -》 T2 -》T3
    ps：以上的事务和binlog完全按照顺序一致运行

结论：
    T1 引擎层提交结束，T2 fsync binlog 200 也已经结束，但是T2引擎成没有提交成功，所以这时候online-backup记录的binlog位置是pos1（也就是T1提交后的位置）
    如果拿着备份重新恢复slave，由于热备是不会备份binlog的，所以事务T2会回滚掉，那么change master to pos1的时候，因为T1的位置是pos1（在pos2之前），所以T2、T3事务会被重做，最终保持一致
```

总结：

```sql
以上的问题，主要原因是热备份工具无法备份binlog导致的根据备份恢复的slave回滚导致的，产生这样的原因最后还是要归结于最后引擎层的日志没有提交导致
所以，xtrabackup意识到了这一点，最后多了这一步flush no_write_to_binlog engine logs，表示将innodb层的redo全部持久化到磁盘后再进行备份，在通俗的说，就是图例上的T2一定成功后，才会再继续进行拷贝备份
那么如果是这样，图例上的T2在恢复的时候，就不会被回滚了，所以就自然不会丢失事务啦
```

*   主从数据不一致问题

如果redo和binlog不是一致的，那么有可能就是master执行事务的顺序和slave执行事务顺序不一样，那么不一样会导致什么问题呢？  
在一些依赖事务顺序的场景，尤其重要，比如我们看一个例子

master节点提交T1和T2事务按照以下顺序

```markdown
1.  State0: x= 1, y= 1  --初始值

2.  T1: { x:= Read(y);

3.          x:= x+1;

4.          Write(x);

5.          Commit; }



State1: x= 2, y= 1

7.  T2: { y:= Read(x);

8.            y:=y+1;

9.           Write(y);

10.          Commit; }

State2: x= 2, y= 3



以上两个事务顺序在master为 T1 -> T2
最终结果为
    State1: x= 2, y= 1
    State2: x= 2, y= 3
```

如果slave的事务执行顺序与master相反，会怎么样呢？

```markdown
1.  State0: x= 1, y= 1 --初始值

2.  T2: { y:= Read(x);

3.            y:= y+1;

4.            Write(y);

5.            Commit; }

6.
State1: x= 1, y= 2

7.  T1: { x:= Read(y);

8.            x:=x+1;

9.            Write(x);

10.           Commit; }

11.
State2: x= 3, y= 2

以上两个事务顺序在master为 T2 -> T1
最终结果为
    State1: x= 1, y= 2
    State2: x= 3, y= 2
```

结论：

1.  为了保证主备数据一致性，slave节点必须按照同样的顺序执行，如果顺序不一致容易造成主备库数据不一致的风险。
2.  而redo 和 binlog的一致性，在单线程复制下是master和slave数据一致性的另一个保证， 多线程复制需要依赖MTS的设置
3.  所以，MySQL必须要保证redo 和 binlog的一致性，也就是：引擎层提交的顺序和server层binlog fsync的顺序必须一致，那么二阶段提交就是这样的机制

### 3.3 二阶段提交的弊端

二阶段提交能够保证同一个事务的redo和binlog的顺序一致性问题，但是无法解决多个事务提交顺序一致性的问题

## 四、三阶段提交

### 4.1 什么是三阶段提交

![commit_3](assets/1588167824-b8f562440b66b81f7db55d845fc758c9.png "commit_3")

继续解释几个概念：

*   execution state做什么事情呢

```plain
在内存修改相关数据，比如：DML的修改
```

*   prepare stage做什么事情呢

```perl
1. write() redo  日志  --最重要的操作，记住这个时候就开始刷新redo了（依赖操作系统sync到磁盘），很多同学在这个地方都不太清楚，以为flush redo在最后commit阶段才开始
2. 更新undo状态
3. 等等
```

*   binlog stage做什么事情呢

```sql
1. write binlog  --一组有序的binlog
    flush binlog 内存日志到磁盘缓存
2. fsync binlog  --一组有序的binlog
    sync磁盘缓存的binlog日志到磁盘持久化
```

*   innodb commit stage做什么事情呢

```markdown
1. 更新undo的状态
2. fsync redo & undo(强制sync到磁盘)
3. 写入最终的commit log，代表事务结束  --一组有序的commit日志,按序提交
4. 等等
```

这里将整个事务提交的过程分为了三个大阶段

```sql
InnoDB, Prepare
    SQL已经成功执行并生成了相应的redo日志
Binlog, Flush Stage(group)  -- 一阶段
    写入binlog缓存；
Binlog, Sync Stage(group)  -- 二阶段
    binlog缓存将sync到磁盘
InnoDB, Commit stage(group) -- 三阶段
    leader根据顺序调用存储引擎提交事务；


重要参数：

binlog_group_commit_sync_delay=N ： 等待N us后，开始刷盘binlog
binlog_group_commit_sync_no_delay_count=N : 如果队列的事务数达到N个后，就开始刷盘binlog
```

### 4.2 为什么要有三阶段提交

目的就是保证多事务之间的redo和binlog顺序一致性问题, 以及加入组提交机制，让redo和binlog都可以以组的形式（有序集合）进行fsync来提高并发性能

### 4.3 再来聊聊MySQL组提交

#### 队列相关

![commit_4](assets/1588167824-206a3271a165b47c2b341ce969f86c09.png "commit_4")

#### 组提交举例

![commit_5](assets/1588167824-f88179a058e3169940b0693b9825ffce.png "commit_5")

（一）、T1事务第一个进入第一阶段 FLUSH ， 由于是第一个，所以是leader，然后再等待（按照具体算法）  
（二）、T2事务第二个进行第一阶段 FLUSH ， 由于是第二个，所以是follower，然后等待leader调度  
（三）、FLUSH队列等待结束后，开始进入下一阶段SYNC阶段，此时T1带领T2进行一次fsync操作,之后进入commit阶段，按序提交完成，这就是一次组提交的简要过程了  
（四）、prepare可以并行，说明两个事务没有任何冲突。有冲突的prepare无法进行进入同一队列  
（五）、每个队列之间都是可以并行运行的

## 五、总结

*   组提交的核心思想就是：一次fsync（）调用，可以刷新N个事务的redo log(redo的组提交) & binlog(binlog的组提交)
*   组提交的最终目的就是为了减少IO的频繁刷盘，来提高并发性能,当然也是之后多线程复制的基础
*   组提交中：sync\_binlog=1 & innodb\_trx\_at\_commit=1 代表的不再是1个事务，而是一组事务和一个事务组的binlog
*   组提交中：binlog是顺序fsync的，事务也是按照顺序进行提交的，这都是有序的，MySQL5.7 并对这些有序的事务进行打好标记（last\_committed，sequence\_number ）

### 六、思考问题

*   如何保证slave执行的同一组binlog的事务顺序跟master的一致
    
    ```plain
    如果slave上同一组事务中的后面的事务先执行，那么slave的gtid该如何表示
    如何保证slave上同一组事务中的事务是按照顺序执行的
    ```
    
*   如果slave突然挂了，那么执行到一半的一组事务，是全部回滚？还是部分回滚？
    
    ```plain
    如果是部分回滚，那么如何知道哪些回滚了，哪些没有回滚，mysql如何自动修复掉回滚的那部分事务
    ```
    




