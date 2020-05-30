---
title: InnoDB redo log格式-物理log-yanzongshuai的专栏-51CTO博客
category: default
tags: 
  - blog.51cto.com
created_at: 2020-05-25 19:22:58
original_url: https://blog.51cto.com/yanzongshuai/2095349
---

原创

# InnoDB redo log格式-物理log

[![](assets/1590405778-a8d45dccac2b17cf14c316051588baa7.jpg)](https://blog.51cto.com/yanzongshuai)

[yzs的专栏](https://blog.51cto.com/yanzongshuai) 关注 0人评论 [1787人阅读](javascript:) [2018-04-07 13:04:57](javascript:)

在页面上修改N个字节，可以看做物理log。包括以下几种类型：MLOG\_WRITE\_STRING、MLOG\_8BYTES、MLOG\_2BYTES、MLOG\_1BYTES、MLOG\_4BYTES。各种页链表指针修改以及文件头、段页内容的修改都是以这几种方式记录日志。具体格式如下：

1、MLOG\_2BYTES、MLOG\_1BYTES、MLOG\_4BYTES：  
![InnoDB redo log格式-物理log](assets/1590405778-a0a12ce390426615fa1e2e084b97b1b8.png)  
2、MLOG\_8BYTES  
![InnoDB redo log格式-物理log](assets/1590405778-482dc65f3a0ece9b06752d2f4c57d63d.png)  
3、MLOG\_WRITE\_STRING  
![InnoDB redo log格式-物理log](assets/1590405778-6cc2e2fadc5de94246345bbad6bc0928.png)  
4、变长字节算法mach\_write\_compressed：

```ruby
if (n < 0x80UL) {  
    mach_write_to_1(b, n);  
    return(1);  
} else if (n < 0x4000UL) {  
    mach_write_to_2(b, n | 0x8000UL);  
    return(2);  
} else if (n < 0x200000UL) {  
    mach_write_to_3(b, n | 0xC00000UL);  
    return(3);  
} else if (n < 0x10000000UL) {  
    mach_write_to_4(b, n | 0xE0000000UL);  
    return(4);  
} else {  
    mach_write_to_1(b, 0xF0UL);  
    mach_write_to_4(b + 1, n);  
    return(5);  
}  
```

5、mlog\_write\_ulint、mlog\_write\_ull、mlog\_log\_string分别是写入1、2、4；8字节；字符串的日志写入函数。

©著作权归作者所有：来自51CTO博客作者yzs的专栏的原创作品，如需转载，请注明出处，否则将追究法律责任

[InnoDB](https://blog.51cto.com/search/result?q=InnoDB) [redo](https://blog.51cto.com/search/result?q=redo) [log](https://blog.51cto.com/search/result?q=log) [MySQL源码研究](https://blog.51cto.com/yanzongshuai/category1.html)

1

分享

收藏

[上一篇：InnoDB数据字典--字典表加...](https://blog.51cto.com/yanzongshuai/2095186 "InnoDB数据字典--字典表加载") [下一篇：InnoDB MVCC实现原理及...](https://blog.51cto.com/yanzongshuai/2103632 "InnoDB MVCC实现原理及源码解析")

 [![](assets/1590405778-a8d45dccac2b17cf14c316051588baa7.jpg)](https://blog.51cto.com/yanzongshuai) 

[yzs的专栏](https://blog.51cto.com/yanzongshuai)

### 88篇文章，39W+人气，24粉丝

#### 专注于MySQL、PostgreSQL

关注

---------------------------------------------------


原网址: [访问](https://blog.51cto.com/yanzongshuai/2095349)

创建于: 2020-05-25 19:22:58

目录: default

标签: `blog.51cto.com`

