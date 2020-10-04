#1.btr_page_split_and_insert


nnoDB 结合了这两种算法，数据页的分裂的函数是 btr_page_split_and_insert，大概有8个流程:

* 从要分裂的 page 中, 找到要分裂的 record，分裂的时候要保证分裂的位置是 record 的边界
* 分配一个新的 index page
* 分别计算 page, 和 new page 的边界 record
* 在父节点添加新的 index page 的 node ptr record（索引项），如果父节点没有足够的空间, 那么就触发父节点的分裂操作
* 连接当前索引页, 当前索引页 prev_page, next_page, father_page，新创建的 page。当前的连接顺序是先连接父节点, 然后是 prev_page/next_page, 最后是 page 和 new page
* 将当前索引页上的部分 record 移动到新的索引页
* SMO 操作已经结束, 计算本次 insert 要插入的 page 位置
* 进行 insert 操作, 如果insert 失败, 通过 reorgination page 重新尝试插入

```cpp

btr_page_split_and_insert (
    ...
    btr_cur_t* cursor /*上文的Cursor Record*/
    const dtuple_t*    tuple /*待插入的记录*/)
{
    // 1. 选择作为分裂点的记录，以及分裂方向（向左或向右）
 
    // 1.1 如果该数据页已经分裂一次（n_iterations），仍无法插入成功，则继续分裂
    if (n_iterations > 0)
        // 向右分裂
        direction = FSP_UP;
        ...
    // 1.2 如果是顺序插入（本次插入记录在上次插入记录的右侧），采用0%-100%算法。这里需要将旧页中后面的部分记录移动到新页
    //  1）上次插入记录的下条或下下条记录是 supremum record，从本次插入记录开始分裂
    //  2）上次插入记录的下条或下下条记录都不是 supremum record，从下下条记录开始分裂（保留一条记录，在注释中有解释说是
    //     为了在连续插入的情景下使用自适应哈希索引，尚存疑 ...）
    else if (btr_page_get_split_rec_to_right(cursor/* 即上文的 cursor record */, &split_rec))
        // 向右分裂
        direction = FSP_UP;
    // 1.3 如果是顺序插入（本次插入记录在上次插入记录的左侧），采用0%-100%算法。这里需要将旧页中前面的部分记录移动到新页
    //  1）cursor record 是数据页的第一条记录（infimum record 的下一条），从 cursor record 开始分裂
    //  2）否则从 cursor record 的下一条记录开始分裂
    else if (btr_page_get_split_rec_to_left(cursor, &split_rec))
        // 向左分裂
        direction = FSP_DOWN;
    else
    // 1.4 不是顺序插入的话，50%-50%算法向右分裂
        direction = FSP_UP;
 
    // 2. 建立一个新的数据页
    new_block = btr_page_alloc(cursor->index, hint_page_no, direction,
                   btr_page_get_level(page, mtr), mtr, mtr);
    new_page = buf_block_get_frame(new_block);
 
    // 3. 获得在第一步中确定的分裂记录
    if (split_rec)
        first_rec = move_limit = split_rec;
    else
        first_rec = rec_convert_dtuple_to_rec(buf, cursor->index,
                              tuple, n_ext);
    // 4. 修改 B-tree 的结构：
    //   1）将新页加入到对应的层次
    //   2）修改上一层次（中间节点）数据页的记录的Key+Value
    // 注：中间节点的 key 指向的子节点中最小的 key，value 子节点的 page no，
    //     指向子节点Page（可能是中间节点，可能是叶子节点）
    // 具体的行为是，数据页中保存着该页的层次（PAGE_LEVEL），采用 btr_cur_search_to_nth_level 可以查找到该层次
    btr_attach_half_pages(flags, cursor->index, block,
                  first_rec, new_block, direction, mtr);
     
    // 5. 逐个的将记录从旧页拷贝到新页
    page_move_rec_list_start ...
 
    // 6. 数据页分裂完毕，插入新纪录
    ...
}

```