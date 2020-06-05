
# [InnoDB（十一）：LSN]


这里假设你清楚InnoDB Redo日志的格式（包括Log File/Block的格式）

## LSN的计算

为了计算的简便，我们对Log File Header / Log Block Header等做重新的规定

```plain
// Log Block
#define LOG_BLOCK_HDR_SIZE 12(Bytes)
#define LOG_BLOCK_TRL_SIZE 4(Bytes)
#define OS_FILE_LOG_BLOCK_SIZE 32(Bytes)
 
// Log File
#define LOG_FILE_HDR_SIZE      OS_FILE_LOG_BLOCK_SIZE(Bytes)
innodb_log_file_size   128(Bytes) // 4 * OS_FILE_LOG_BLOCK_SIZE(Bytes)
 
// The counting of lsn's starts from this value
#define LOG_START_LSN 2 * OS_FILE_LOG_BLOCK_SIZE
 
// Log Sys
group->lsn = LOG_START_LSN; // 1*32
group->lsn_offset = LOG_FILE_HDR_SIZE; // 32
```

分情况对LSN的计算做出说明：

1.  当第一个Log Block尚未写满…
2.  当开始写第二个Log Block…
    
3.  当开始写第二个Log File…
    
4.  当循环再次写第一个Log File…
    

### 当第一个Log Block尚未写满…

这是最简单的情况，但要注意的是LSN的初始值（LOG\_START\_LSN）只是一个非零的、（似乎）没有什么意义的值

  

![](assets/1591358273-502601c720ec699bf3d80df78efa4fb7.png)

### 当开始写第二个Log Block…

这时有两种情况：

1.  Record「跨越」Block
2.  Record「未跨越」Block

但无论哪种情况，Log Block2的第一个Record的LSN都是一样的计算：

*   LSN将HDR和TRL计算在内

**显然的，不存在Record的LSN在（88，110）的开区间内**

```plain
lsn(Rec4) = lsn(Rec3) + len(Rec3) + Block 1's TRL(4) + Block 2's HRD(23)
```

  
![](assets/1591358273-af44b95b99fd18655881f605bc06a7e9.png)

  

### 当开始写第二个Log File…

规则是：

*   OFFSET就是从Log File1开始的「物理偏移量」
*   LSN不将FILE\_HDR计算在内

```plain
lsn(Rec20) = lsn(Rec19) + len(Rec3) + (File1)Block 3's TRL(4) + (File1)Block 1's HRD(12) // 不包含File2's FILE_HRD
```

  
![](assets/1591358273-bad6a063af5163597d66220dc8d95624.png)

  

### 当循环再次写第一个Log File…

Rec N覆盖了「旧的Record」

![](assets/1591358273-670a4595b9697cf93a8ef346690998c6.png)

## Log Buffer的Log File联系

Log Buffer默认值是8MB，但是Log File往往有几GB，都采用「循环写」的方式。那么InnoDB如何知道Log Buffer里的一个Log Block要写在Log File中的哪个位置？

InnoDB并不记录每个Record的LSN

1. 是在内存中（针对于Log Buffer）构建数个LSN和OFFSET的映射关系：

*   （LSN）**lsn** / （OFFSET）**buf\_free**
*   （LSN）**write\_lsn** / （OFFSET）**write\_end\_offset**
*   （LSN）**write\_to\_all\_lsn** / （OFFSET）**buf\_next\_to\_write**

2\. 时刻维护Log File中日志的LSN和OFFSET的映射关系：

*   （LSN）group→ lsn / （OFFSET）group→ lsn\_offset

回答之前的问题，当要将处于**buf\_next\_to\_write**的Log Block写入到Log File中时：

1.  获取该Block的LSN（**write\_to\_all\_lsn**）
2.  计算该Block需要写入到Log File的偏移处：（write\_to\_all\_lsn - group→ lsn）+ group→ lsn\_offset（这里的计算并不严谨，未考虑「循环写」）

  

![](assets/1591358273-71f954f9edcebf0d8adbffe13f97c16e.png)

## InnoDB Start LSN

当InnoDB Start，LSN（log\_sys→ lsn）是多少？由以上易知，确定一个Record的LSN离不开这个映射<**group→ lsn**, **group→ lsn\_offset**\>

### First Start

```plain
group->lsn = LOG_START_LSN;
group->lsn_offset = LOG_FILE_HDR_SIZE;
```

### Normal Shutdown

LSN = **Checkpoint LSN**（ib\_logfile0's HDR）

```plain
group->lsn = <Checkpoint LSN>;
group->lsn_offset = <Checkpoint LSN's offset>;
 
其中 ...
/* Offsets for a checkpoint field */
#define LOG_CHECKPOINT_NO       0
#define LOG_CHECKPOINT_LSN      8
#define LOG_CHECKPOINT_OFFSET_LOW32 16
#define LOG_CHECKPOINT_LOG_BUF_SIZE 20
#define LOG_CHECKPOINT_ARCHIVED_LSN 24
#define LOG_CHECKPOINT_GROUP_ARRAY  32
```

### Crash

如果在Crash之后再Start，首先LSN的初始值同「Normal Shutdown」

```plain
group->lsn = <Checkpoint LSN>;
group->lsn_offset = <Checkpoint LSN's offset>;
```

*   Redo阶段完成：LSN = Recovered LSN（扫描完Redo日志后得到的LSN）
*   Undo阶段完成：回滚或提交「Pending Transaction」，再MTR提交时会更新LSN（log\_sys→ lsn）

因此LSN指示的总是当前InnoDB中的「日志量」

