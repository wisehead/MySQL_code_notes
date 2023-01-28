#1.class ha_innobase

```cpp
/** The class defining a handle to an Innodb table */
class ha_innobase: public handler
{
    row_prebuilt_t* prebuilt;   /*!< prebuilt struct in InnoDB, used
                    to save CPU time with prebuilt data
                    structures*/
    THD*        user_thd;   /*!< the thread handle of the user
                    currently using the handle; this is
                    set in external_lock function */
    THR_LOCK_DATA   lock;
    INNOBASE_SHARE* share;      /*!< information for MySQL
                    table locking */

    uchar*      upd_buf;    /*!< buffer used in updates */
    ulint       upd_buf_size;   /*!< the size of upd_buf in bytes */
    Table_flags int_table_flags;
    uint        primary_key;
    ulong       start_of_scan;  /*!< this is set to 1 when we are
                    starting a table scan but have not
                    yet fetched any row, else 0 */
    uint        last_match_mode;/* match mode of the latest search:
                    ROW_SEL_EXACT, ROW_SEL_EXACT_PREFIX,
                    or undefined */
    uint        num_write_row;  /*!< number of write_row() calls */

    ha_statistics*  ha_partition_stats; /*!< stats of the partition owner
                    handler (if there is one) */

private:
    /** The multi range read session object */
    DsMrr_impl ds_mrr;
    /* @} */
};            
```