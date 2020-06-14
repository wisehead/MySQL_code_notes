#1.Create Segment(fseg_create_general)

```cpp
这是每个表空间内创建Segment的通用流程（fseg_create_general）：

【预留空间】即观察 Tablespace 中剩余空间是否足够（fsp_reserve_free_extents），通常是 2 Extent（如果*.ibd小于1个Extent，预留2 Page）

【分配INODE Entry】在 FSP_SEG_INODES_FREE 链表的第一个 INODE Page，并在 INODE Page 中寻找未使用的 INODE Entry（FSED_ID == 0）

【初始化INODE Entry】初始化INODE Entry的域

【保存INODE Page】将 INODE Page 的引用（Page no + INODE Entry no）保存到 Root Page 内（PAGE_BTR_SEG_LEAF / PAGE_BTR_SEG_TOP）
```

#2.