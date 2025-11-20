#1.LOCK Type

```cpp

/* Precise modes */
#define LOCK_ORDINARY    0
//普通锁，与LOCK_GAP或LOCK_REC_NOT_GAP没有关联，但是包括了间隙锁
#define LOCK_GAP    512    /*!< when this bit is set, it means that the  //间隙锁
                lock holds only on the gap before the record;
                //记录之前的间隙被锁定，阻止记录被修改，也阻止记录前的间歇被插入
                for instance, an x-lock on the gap does not
                give permission to modify the record on which
                the bit is set; locks of this type are created
                when records are removed from the index chain
                of records */
#define LOCK_REC_NOT_GAP 1024    /*!< this bit means that the lock is only on
//记录被锁定，记录之前的间隙不被锁定
                the index record and does NOT block inserts
//即阻止记录被修改，不阻止记录前的间歇插入
                to the gap before the index record;
//使用场景是当查询语句条件带有唯一键时施加的锁不带有间隙锁故不阻塞插入操作
                this is used in the case when we retrieve a record
                with a unique key, and is also used in
                locking plain SELECTs (not part of UPDATE
                or DELETE) when the user has set the READ
//只用于READ COMMITTED隔离级别，以模仿Oracle的读已提交级别的行为
                COMMITTED isolation level */
#define LOCK_INSERT_INTENTION 2048 /*!< this bit is set when we place a waiting
//插入意向锁，专门用于插入操作
                gap type record lock request in order to let
                an insert of an index record to wait until
                there are no conflicting locks by other
                transactions on the gap; note that this flag
                remains set when the waiting lock is granted,
                or if the lock is inherited to a neighboring
                record */
#define LOCK_PREDICATE    8192    /*!< Predicate lock */  //谓词锁，用于空间索引
#define LOCK_PRDT_PAGE    16384    /*!< Page lock */      //谓词锁相关的页锁
```