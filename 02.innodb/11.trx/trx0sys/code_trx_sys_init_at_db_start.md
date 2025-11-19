#1.trx_sys_init_at_db_start

```cpp
/*****************************************************************//**
Creates and initializes the central memory structures for the transaction
system. This is called when the database is started.
@return min binary heap of rsegs to purge */
purge_pq_t*
trx_sys_init_at_db_start(void)  //从外存获得存储的事务ID，生成新的事务ID，新的事务ID总比
上次系统启动时候的事务ID大，确保事务ID不重复
/*==========================*/
{...
    mtr_start(&mtr);
    sys_header = trx_sysf_get(&mtr);  //从外存获得系统页的页头信息，从这个页头上要找出存
    储的事务ID
...
    trx_sys->max_trx_id = 2 * TRX_SYS_TRX_ID_WRITE_MARGIN  //增加出一段空余值
        + ut_uint64_align_up(mach_read_from_8(sys_header   //从页头上要找出存储的事
        务ID，然后增加出一段空余值，作为新的事务ID
                           + TRX_SYS_TRX_ID_STORE),
                     TRX_SYS_TRX_ID_WRITE_MARGIN);
...
}

```