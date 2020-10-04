#1.page_cur_search_with_match

```cpp
page_cur_search_with_match （
    const buf_block_t* block,  /*!< in: buffer block */
    const dict_index_t* index,  /*!< in: record descriptor */
    const dtuple_t*     tuple,  /*!< in: data tuple */
    ulint           mode,   /*!< in: PAGE_CUR_L,
                    PAGE_CUR_LE, PAGE_CUR_G, or
                    PAGE_CUR_GE */
    ...)
{
    // 在索引页内查找对于指定的Tuple，满足某种条件（依赖于传入的mode，PAGE_CUR_L/PAGE_CUR_LE...）的Record
    // PAGE_CUR_G（>），PAGE_CUR_GE（>=），PAGE_CUR_L（<），PAGE_CUR_LE（<=）
    // 1. 二分查找
    // 在稀疏的Page Directory内使用二分查找
    low = 0;
    up = page_dir_get_n_slots(page) - 1;
 
    while (up - low > 1) {
        mid = (low + up) / 2;
        slot = page_dir_get_nth_slot(page, mid);
        mid_rec = page_dir_slot_get_rec(slot);
 
        // 比较mid和Tuple的大小
        cmp = cmp_dtuple_rec_with_match(tuple, mid_rec, offsets,
                        &cur_matched_fields,
                        &cur_matched_bytes);
         
        if (UNIV_LIKELY(cmp > 0))
            low = mid;
        else if (UNIV_EXPECT(cmp, -1)) {
            up = mid;
        ...
    }
 
    // 二分查找结束后，low和up是临近的两个slot，这两个slot指向的record记为low_rec和up_rec，满足：
    // low_rec <= tuple <= up_rec，切记tuple为待插入的（逻辑）记录
     
    // 2. 线性查找
    // 在两个相邻的Directory内，进行线性查找。线性查找的实现即不断"增大low"，"减小up"，渐渐夹逼tuple
    while (page_rec_get_next_const(low_rec) != up_rec) {
        cmp = cmp_dtuple_rec_with_match(tuple, mid_rec, offsets,
                        &cur_matched_fields,
                        &cur_matched_bytes);
    }
 
    // 线性查找结束后，low_rec和up_rec是临近的两个record，满足：
    //     low_rec <= tuple <= up_rec
    // cur_matched_fields、cur_matched_bytes是tuple与mid_rec匹配相等的列的个数与字节数
    // 注：btr_cur_t中的up_match、up_bytes是up_rec与tuple匹配相等的列的个数与字节数（同理于low_match、low_bytes）
    // 如果查找模式为PAGE_CUR_G/PAGE_CUR_GE，cursor"放于"low_rec（INSERT即为这个模式，可见cursor放于最后一个
    // 小于tuple的record位置处），否则（PAGE_CUR_L/PAGE_CUR_LE），cursor放于"up_rec"
}

```	