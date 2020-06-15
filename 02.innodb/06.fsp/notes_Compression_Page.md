# 1.内核月报压缩索引页

InnoDB当前存在两种形式的压缩页，一种是Transparent Page Compression，还有一种是传统的压缩方式，下文分别进行阐述。

### Transparent Page Compression

这是MySQL5.7新加的一种数据压缩方式，其原理是利用内核Punch hole特性，对于一个16kb的数据页，在写文件之前，除了Page头之外，其他部分进行压缩，压缩后留白的地方使用punch hole进行 “打洞”，在磁盘上表现为不占用空间 （但会产生大量的磁盘碎片）。 这种方式相比传统的压缩方式具有更好的压缩比，实现逻辑也更加简单。

对于这种压缩方式引入了新的类型`FIL_PAGE_COMPRESSED`，在存储格式上略有不同，主要表现在从`FIL_PAGE_FILE_FLUSH_LSN`开始的8个字节被用作记录压缩信息：

| Macro | bytes | Desc |
| --- | --- | --- |
| FIL\_PAGE\_VERSION | 1 | 版本，目前为1 |
| FIL\_PAGE\_ALGORITHM\_V1 | 1 | 使用的压缩算法 |
| FIL\_PAGE\_ORIGINAL\_TYPE\_V1 | 2 | 压缩前的Page类型，解压后需要恢复回去 |
| FIL\_PAGE\_ORIGINAL\_SIZE\_V1 | 2 | 未压缩时去除FIL\_PAGE\_DATA后的数据长度 |
| FIL\_PAGE\_COMPRESS\_SIZE\_V1 | 2 | 压缩后的长度 |

打洞后的page其实际存储空间需要是磁盘的block size的整数倍。

这里我们不展开阐述，具体参阅我之前写的这篇文章：[MySQL · 社区动态 · InnoDB Page Compression](http://mysql.taobao.org/monthly/2015/08/01/)

### 传统压缩存储格式

当你创建或修改表，指定`row_format=compressed key_block_size=1|2|4|8` 时，创建的ibd文件将以对应的block size进行划分。例如`key_block_size`设置为4时，对应block size为4kb。

压缩页的格式可以描述如下表所示：

| Macro | Desc |
| --- | --- |
| FIL\_PAGE\_HEADER | 页面头数据，不做压缩 |
| Index Field Information | 索引的列信息，参阅函数`page_zip_fields_encode`及`page_zip_fields_decode`，在崩溃恢复时可以据此恢复出索引信息 |
| Compressed Data | 压缩数据，按照heap no排序进入压缩流，压缩数据不包含系统列(trx\_id, roll\_ptr)或外部存储页指针 |
| Modification Log(mlog) | 压缩页修改日志 |
| Free Space | 空闲空间 |
| External\_Ptr (optional) | 存在外部存储页的列记录指针数组，只存在**聚集索引叶子节点**，每个数组元素占20个字节(`BTR_EXTERN_FIELD_REF_SIZE`)，参阅函数`page_zip_compress_clust_ext` |
| Trx\_id, Roll\_Ptr(optional) | 只存在于**聚集索引叶子节点**，数组元素和其heap no一一对应 |
| Node\_Ptr | 只存在于**索引非叶子节点**，存储节点指针数组，每个元素占用4字节(REC\_NODE\_PTR\_SIZE) |
| Dense Page Directory | 分两部分，第一部分是有效记录，记录其在解压页中的偏移位置，n\_owned和delete标记信息，按照**键值顺序**；第二部分是空闲记录；每个slot占两个字节。 |

在内存中通常存在压缩页和解压页两份数据。当对数据进行修改时，通常先修改解压页，再将DML操作以一种特殊日志的格式记入压缩页的mlog中。以减少被修改过程中重压缩的次数。主要包含这几种操作：

*   Insert: 向mlog中写入完整记录
*   Update:
    *   Delete-insert update，将旧记录的dense slot标记为删除，再写入完整新记录
    *   In-place update，直接写入新更新的记录
*   Delete: 标记对应的dense slot为删除

页压缩参阅函数 `page_zip_compress` 页解压参阅函数 `page_zip_decompress`
