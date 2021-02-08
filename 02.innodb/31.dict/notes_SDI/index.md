---
title: MySQL8.0: Serialized Dictionary Information(SDI) 文件浅析_技术杂萃__优化技巧,函数讲解,系统配置,开源介绍,实战讲解__我就上乐乐吧_乐在分享资源_电子书_图集_MV_
category: default
tags: 
  - www.593668.com
created_at: 2020-06-12 20:22:17
original_url: https://www.593668.com/7/6197.html
---


# MySQL8.0: Serialized Dictionary Information(SDI) 文件浅析_技术杂萃__优化技巧,函数讲解,系统配置,开源介绍,实战讲解__我就上乐乐吧_乐在分享资源_电子书_图集_MV_

最近升级了数据库MySQL到8.0，有次偶尔去察看数据库目录里面却发现多了一些sdi文件。记得以前没有这些文件的，有点警觉立马就打开这类文件察看了下，却发现内容就是一个JSON。  
  
内容如下：  
{"mysqld\_version\_id":80017,"dd\_version":80017,"sdi\_version":80016,"dd\_object\_type":"Table","dd\_object":{"name":"ss\_site","mysql\_version\_id":80017,"created":20191105032845,"last\_altered":20191105032845...}  
  
检察了下，发现就是描述表结构的一些元数据。不知道为啥产生了这些东西，[**上网**](https://www.593668.com/search-%E4%B8%8A%E7%BD%91.html)去搜索了下发现如下说明：  
  
sdi是Serialized Dictionary Infor[**MAT**](https://www.593668.com/search-MAT.html)ion的缩写，是MySQL8.0重新[**设计**](https://www.593668.com/search-%E8%AE%BE%E8%AE%A1.html)数据词典后引入的新产物。MySQL8.0已经开始统一使用InnoDB存储引擎来存储表的元数据信息，但对于非InnoDB引擎，MySQL还提供了另外一种可读的文件格式来描述表的元数据信息，在磁盘上以 $tbname.sdi的命名存储在数据库目录下。  
  
而对于InnoDB表就不会创建sdi文件，而是将sdi信息冗余存储到表[**空间**](https://www.593668.com/search-%E7%A9%BA%E9%97%B4.html)中（临时表空间和undo表空间除外）。  
  
那么问题就来了，既然已经有了新的数据词典系统，为什么还需要冗余的sdi信息呢，这主要从几个方面考虑：  
  
1）当数据词典损坏时，可能无法启动，在这种情况下可以通过冗余的sdi信息，将数据拷贝到另外一个实例上，并进行数据重建。  
2）可以离线的查看表的定义  
3）还可以基于此实现简单的数据转储  
4）MySQL Cluster/Ndb也依赖sdi信息来进行元数据同步  
  
官方提供了一个工具叫做ibd2sdi，可以离线的将ibd文件中的冗余存储的sdi信息提取出来，并以json的格式输出到终端。  
  
比如下例\[默认情况下打印所有信息包含所有的列，索引的各个属性\]：  
  
ibd2sdi data/test/t1.ibd  
  
当然也可以只查询部分元数据信息，更多的参数可以通过如下命令获取。  
ib2sdi --help  
  
知道这个并不是意外产生，那也就放心了，如果大家有感兴趣的话，可以自行去挖掘ibd2sdi的更多用法。

---------------------------------------------------


原网址: [访问](https://www.593668.com/7/6197.html)

创建于: 2020-06-12 20:22:17

目录: default

标签: `www.593668.com`

