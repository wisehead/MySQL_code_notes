#1.mtr_t::commit

```cpp

/** Commit a mini-transaction. */
void
mtr_t::commit()
{...
    m_impl.m_state = MTR_STATE_COMMITTING;
...
    if (m_impl.m_modifications
    //buffer里面的页面被修改，即有脏页存在，数据需要被刷出去
        && (m_impl.m_n_log_recs > 0 //被写到mtr日志的页面数，即存在被写到mtr的日志
            || m_impl.m_log_mode == MTR_LOG_NO_REDO)) {
        ut_ad(!srv_read_only_mode || m_impl.m_log_mode == MTR_LOG_NO_REDO);
        cmd.execute();              //执行提交，过程如下面的代码分析
    } else {                        //没有需要刷出的脏页，则只简单释放资源就行
        cmd.release_all();          //释放被Mini-Transaction获取到的latches和blocks
        cmd.release_resources();       //清理日志区m_log、清理memo区，标识
        Mini-Transaction完成（设置Mini-Transaction状态的值为MTR_STATE_COMMITTED）
    }
}
```