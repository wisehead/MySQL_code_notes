#1.buf_dblwr_create

```cpp
buf_dblwr_create
--buf_dblwr_get
----buf_page_get(page_id_t(TRX_SYS_SPACE, TRX_SYS_PAGE_NO),
----buf_block_get_frame(block) + TRX_SYS_DOUBLEWRITE
----#define TRX_SYS_DOUBLEWRITE (UNIV_PAGE_SIZE - 200)
--//if 已经初始化
----buf_dblwr_init
--//else
--fseg_create
----fseg_create_general
--fseg_alloc_free_page
--
```

#todo

开关
