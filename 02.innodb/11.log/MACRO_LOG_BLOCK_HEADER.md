#1.LOG_BLOCK_HEADER

```cpp
/* Offsets of a log block header */
#define LOG_BLOCK_HDR_NO    0   /* block number which must be > 0 and
     is allowed to wrap around at 2G; the
     highest bit is set to 1 if this is the
     first log block in a log flush write
     segment */
#define LOG_BLOCK_FLUSH_BIT_MASK 0x80000000UL
/* mask used to get the highest bit in
the preceding field */
#define LOG_BLOCK_HDR_DATA_LEN  4   /* number of bytes of log written to
     this block */
#define LOG_BLOCK_FIRST_REC_GROUP 6 /* offset of the first start of an
     mtr log record group in this log block,
     0 if none; if the value is the same
     as LOG_BLOCK_HDR_DATA_LEN, it means
     that the first rec group has not yet
     been catenated to this log block, but
     if it will, it will start at this
     offset; an archive recovery can
     start parsing the log records starting
     from this offset in this log block,
     if value not 0 */
#define LOG_BLOCK_CHECKPOINT_NO 8   /* 4 lower bytes of the value of
     log_sys->next_checkpoint_no when the
     log block was last written to: if the
     block has not yet been written full,
     this value is only updated before a
     log buffer flush */
#define LOG_BLOCK_HDR_SIZE  12  /* size of the log block header in
     bytes */

/* Offsets of a log block trailer from the end of the block */
#define LOG_BLOCK_CHECKSUM  4   /* 4 byte checksum of the log block
     contents; in InnoDB versions
     < 3.23.52 this did not contain the
     checksum but the same value as
     .._HDR_NO */
#define LOG_BLOCK_TRL_SIZE  4   /* trailer size in bytes */
```