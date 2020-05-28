#1.LOG_FILE_HEADER

```cpp
// Code for log group is removed.
// Though the format of the checkpoint still depends on this constant.
// So keep the macro here only for redo log compatibility.
/* Offsets of a log file header */
#define LOG_GROUP_ID        0   /* log group number */
#define LOG_FILE_START_LSN  4   /* lsn of the start of data in this
     log file */
#define LOG_FILE_NO     12  /* 4-byte archived log file number;
     this field is only defined in an
     archived log file */
#define LOG_FILE_WAS_CREATED_BY_HOT_BACKUP 16
/* a 32-byte field which contains
the string 'ibbackup' and the
creation time if the log file was
created by mysqlbackup --restore;
when mysqld is first time started
on the restored database, it can
print helpful info for the user */
#define LOG_FILE_ARCH_COMPLETED OS_FILE_LOG_BLOCK_SIZE
/* this 4-byte field is TRUE when
the writing of an archived log file
has been completed; this field is
only defined in an archived log file */
#define LOG_FILE_END_LSN    (OS_FILE_LOG_BLOCK_SIZE + 4)
/* lsn where the archived log file
at least extends: actually the
archived log file may extend to a
later lsn, as long as it is within the
same log block as this lsn; this field
is defined only when an archived log
file has been completely written */
#define LOG_CHECKPOINT_1    OS_FILE_LOG_BLOCK_SIZE
/* first checkpoint field in the log
header; we write alternately to the
checkpoint fields when we make new
checkpoints; this field is only defined
in the first log file */
#define LOG_CHECKPOINT_2    (3 * OS_FILE_LOG_BLOCK_SIZE)
/* second checkpoint field in the log
header */
#define LOG_FILE_HDR_SIZE   (4 * OS_FILE_LOG_BLOCK_SIZE)
```