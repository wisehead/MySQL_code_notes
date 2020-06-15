## MySQL5.7新数据页：加密页及R-TREE页

MySQL 5.7版本引入了新的数据页以支持表空间加密及对空间数据类型建立R-TREE索引。本文对这种数据页不做深入讨论，仅仅简单描述下，后面我们会单独开两篇文章分别进行介绍。

**数据加密页** 从MySQL5.7.11开始InnoDB支持对单表进行加密，因此引入了新的Page类型来支持这一特性，主要加了三种Page类型：

*   `FIL_PAGE_ENCRYPTED`：加密的普通数据页
*   `FIL_PAGE_COMPRESSED_AND_ENCRYPTED`：数据页为压缩页(transparent page compression) 并且被加密（先压缩，再加密）
*   `FIL_PAGE_ENCRYPTED_RTREE`：GIS索引R-TREE的数据页并被加密

对于加密页，除了数据部分被替换成加密数据外，其他部分和大多数表都是一样的结构。

加解密的逻辑和Transparent Compression类似，在写入文件前加密(`os_file_encrypt_page --> Encryption::encrypt`)，在读出文件时解密数据(`os_file_io_complete --> Encryption::decrypt`)

秘钥信息存储在ibd文件的第一个page中（`fsp_header_init --> fsp_header_fill_encryption_info`），当执行SQL `ALTER INSTANCE ROTATE INNODB MASTER KEY`时，会更新每个ibd存储的秘钥信息(`fsp_header_rotate_encryption`)

默认安装时，一个新的插件`keyring_file`被安装并且默认Active，在安装目录下，会产生一个新的文件来存储秘钥，位置在$MYSQL\_INSTALL\_DIR/keyring/keyring，你可以通过参数[keyring\_file\_data](http://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_keyring_file_data)来指定秘钥的存放位置和文件命名。 当你安装多实例时，需要为不同的实例指定keyring文件。

开启表加密的语法很简单，在CREATE TABLE或ALTER TABLE时指定选项ENCRYPTION=‘Y’来开启，或者ENCRYPTION=‘N’来关闭加密。

关于InnoDB表空间加密特性，参阅该[commit](https://github.com/mysql/mysql-server/commit/9340eb1146fedc538cc54e96a45f95a58b345fbf)及[官方文档](http://dev.mysql.com/doc/refman/5.7/en/innodb-tablespace-encryption.html)。

**R-TREE索引页** 在MySQL 5.7中引入了新的索引类型R-TREE来描述空间数据类型的多维数据结构，这类索引的数据页类型为`FIL_PAGE_RTREE`。

R-TREE的相关设计参阅官方[WL#6968](http://dev.mysql.com/worklog/task/?id=6968)， [WL#6609](http://dev.mysql.com/worklog/task/?id=6609), [WL#6745](http://dev.mysql.com/worklog/task/?id=6745)
