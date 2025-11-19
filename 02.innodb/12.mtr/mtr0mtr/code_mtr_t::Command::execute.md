#1.mtr_t::Command::execute

```cpp
mtr_t::Command::execute()  //写REDO日志并释放资源
{...
    if (const ulint len = prepare_write()) {  //准备写
        finish_write(len);                  //写到日志缓存中，注意REDO日志数据还没有落盘
    }
...
    release_blocks();        //释放Mini-Transaction中的blocks（blocks是一个动态的、内
                               存缓存区，这个区域包括多个单独的block）
...
    release_latches();       //释放latch
    release_resources();    //清理日志区m_log、清理memo区，标识Mini-Transaction完成（设置
    Mini-Transaction状态的值为MTR_STATE_COMMITTED）
}

```