#1. ft_loader_s

```cpp
struct ft_loader_s {
    ...
    generate_row_for_put_func generate_row_for_put;
    CACHETABLE cachetable;
    bool did_reserve_memory;
    bool compress_intermediates;
    bool allow_puts;
    uint64_t reserved_memory;
    ...
}
generate_row_for_put：为每个索引生成索引key的callback函数
cachetable：全局buffer pool指针
did_reserve_memory：是否从cachetable里reserve内存
compress_intermediates：中间结果是否需要压缩
allow_puts：是否接收数据输入；设置成false，表示把directory重定向到空的FT
reserved_memory：did_reserve_memory为TRUE，表示从cachetable中reserve了多少内存；did_reserve_memory为FALSE时，使用是512M内存
struct ft_loader_s {
    ...
    DB *src_db;
    int N;
    DB **dbs; // N of these
    DESCRIPTOR *descriptors; // N of these.
    TXNID *root_xids_that_created; // N of these.
    const char **new_fnames_in_env; // N of these.
    ft_compare_func *bt_compare_funs; // N of these
    ...
}
N，src_db，dbs跟__toku_loader_internal里相应字段的是一样的
descriptors：descriptors[which_db]表示索引的descriptor
root_xids_that_created：root_xids_that_created[which_db]表示索引创建时的root txnid
new_fnames_in_env：new_fnames_in_env[which_db]表示索引的文件名
bt_compare_funs：bt_compare_funs[which_db]表示索引的比较函数
struct ft_loader_s {
    ...
    uint64_t n_rows;
    struct rowset primary_rowset;
    struct rowset primary_rowset_temp;
    QUEUE primary_rowset_queue;
    toku_pthread_t extractor_thread;
    bool extractor_live;
    struct rowset *rows;// N of these.
    uint64_t *extracted_datasizes; // N of these.
    DBT  *last_key;// N of these.
    struct file_infos file_infos;
    ...
}
n_rows：一共有多少行数据
primary_rowset：缓存<pk_key,pk_value>二元组的数组，loader->put的数据先被缓存到这里
primary_rowset_temp：没有被使用，怀疑是legacy code
primary_rowset_queue：当primary_rowset占用一定量的内存时，loader->put所在线程会调用函数enqueue_for_extraction，把当前primary_rowset克隆一份，然后挂到primary_rowset_queue队尾。后台extractor线程在不停取这个队列上的rowset，依次进行处理
extractor_thread：extractor线程
extractor_live：extractor线程是否正在工作
rows：rows[which_db]保存索引的key
extracted_datasizes：extracted_datasizes[which_db]表示索引缓存了多少数据
last_key：没有被使用，怀疑是legacy code
file_infos：记录打开文件的信息
struct ft_loader_s {
    ...
    LSN load_lsn;
    TXNID load_root_xid;
    struct merge_fileset *fs;// N of these.
    QUEUE *fractal_queues; // N of these.
    toku_pthread_t *fractal_threads;// N of these.
    bool *fractal_threads_live; // N of these.
    unsigned fractal_workers;
    ...
};
load_lsn：第一个loader->put之前的lsn位置
load_root_xid：创建ft_loader时，局部事务loader_txn的txnid
fs：fs[which_db]表示索引的merge信息
fractal_queues：fractal_queues[which_db]表示索引的fractal线程使用的队列
fractal_threads：fractal_threads[which_db]表示索引的fractal线程
fractal_threads_live：fractal_threads_live[which_db]索引的fractal线程是否正在运行
fractal_workers：是否有fractal线程正在构建索引FT，因为merge和构建FT的过程可能会并发，这个字段主要用来计算merge阶段可用的内存大小
```