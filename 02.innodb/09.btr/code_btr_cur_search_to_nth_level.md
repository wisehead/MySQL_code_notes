#1. btr_cur_search_to_nth_level notes

```cpp
btr_cur_search_to_nth_level（
    dict_index_t*  index,  /*!< in: index */
    ulint      level,  /*!< in: the tree level of search */
    ulint      mode,   /*!< in: PAGE_CUR_L, ...;
                Inserts should always be made using
                PAGE_CUR_LE to search the position! */
    ...)
{
    // 初始的，获得索引的根节点（space_id，page_no）
    space = dict_index_get_space(index);
    page_no = dict_index_get_page(index);
 
search_loop:
    // 循环、逐层的查找，直至达到传入的层数「level」，一般是0（即叶子节点）
    // 此处的分析忽略Change Buffer的部分
    // 从Buffer Pool或磁盘中得到索引页   
    block = buf_page_get_gen(
        space, zip_size, page_no, rw_latch, guess, buf_mode,
        file, line, mtr);
     
    // 在索引页中中查找对于指定的Tuple，满足某种条件（依赖于传入的mode，PAGE_CUR_L/PAGE_CUR_LE...）的Record
    // 将查找结果保存在page_cursor中，page_cursor结构也很简单：
    //     struct page_cur_t{
    //        byte*       rec;    /*!< pointer to a record on page */
    //        buf_block_t*    block;  /*!< pointer to the block containing rec */
    //     };
    page_cur_search_with_match(
        block, index, tuple, page_mode, &up_match, &up_bytes,
        &low_match, &low_bytes, page_cursor);
 
    if (level != height) {
        // 如果没到达指定层数，获得page_cursor（中间节点）内保存的下层节点的索引页page_no
        //注意：中间节点的Value是一个Pointer（page_no），指向子节点（中间节点或叶子节点）
        node_ptr = page_cur_get_rec(page_cursor);
        /* Go to the child node */
        page_no = btr_node_ptr_get_child_page_no(node_ptr, offsets);
         
        // 在下一层继续查找
        goto search_loop;
    }
 
    // 达到指定层数，函数退出
}

```

#2. btr_cur_search_to_nth_level

```cpp
btr_cur_search_to_nth_level
--mtr_set_savepoint
--mtr_s_lock(dict_index_get_lock(index), mtr);//lock index->lock
--btr_cur_latch_for_root_leaf
--dict_index_get_space(index)
--dict_index_get_page(index)
--tree_savepoints[n_blocks] = mtr_set_savepoint(mtr)
--buf_page_get_gen//index root
--page_cur_search_with_match//从根节点一直到叶子节点
--mtr_block_x_latch_at_savepoint
--btr_node_ptr_get_child_page_no
--btr_cur_latch_leaves//left_page, right page, and current leaf page
--btr_search_info_update
----btr_search_info_update_slow
```