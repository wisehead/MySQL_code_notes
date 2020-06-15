#1.Create Segment(fseg_create_general)

```cpp
这是每个表空间内创建Segment的通用流程（fseg_create_general）：

【预留空间】即观察 Tablespace 中剩余空间是否足够（fsp_reserve_free_extents），通常是 2 Extent（如果*.ibd小于1个Extent，预留2 Page）

【分配INODE Entry】在 FSP_SEG_INODES_FREE 链表的第一个 INODE Page，并在 INODE Page 中寻找未使用的 INODE Entry（FSED_ID == 0）

【初始化INODE Entry】初始化INODE Entry的域

【保存INODE Page】将 INODE Page 的引用（Page no + INODE Entry no）保存到 Root Page 内（PAGE_BTR_SEG_LEAF / PAGE_BTR_SEG_TOP）
```

#2.内核月报创建Segment

**创建Segment** 首先每个Segment需要从ibd文件中预留一定的空间(`fsp_reserve_free_extents`)，通常是2个Extent。但如果是新创建的表空间，且当前的文件小于1个Extent时，则只分配2个Page。

当文件空间不足时，需要对文件进行扩展(`fsp_try_extend_data_file`)。文件的扩展遵循一定的规则：如果当前小于1个Extent，则扩展到1个Extent满；当表空间小于32MB时，每次扩展一个Extent；大于32MB时，每次扩展4个Extent（`fsp_get_pages_to_extend_ibd`）。

在预留空间后，读取文件头Page并加锁（`fsp_get_space_header`），然后开始为其分配Inode Entry(`fsp_alloc_seg_inode`)。首先需要找到一个合适的inode page。

我们知道Inode Page的空间有限，为了管理Inode Page，在文件头存储了两个Inode Page链表，一个链接已经用满的inode page，一个链接尚未用满的inode page。如果当前Inode Page的空间使用完了，就需要再分配一个inode page，并加入到`FSP_SEG_INODES_FREE`链表上(`fsp_alloc_seg_inode_page`)。对于独立表空间，通常一个inode page就足够了。

当拿到目标inode page后，从该Page中找到一个空闲（`fsp_seg_inode_page_find_free`）未使用的slot（空闲表示其不归属任何segment，即FSEG\_ID置为0）。

一旦该inode page中的记录用满了，就从`FSP_SEG_INODES_FREE`链表上转移到`FSP_SEG_INODES_FULL`链表。

获得inode entry后，递增头page的`FSP_SEG_ID`，作为当前segment的seg id写入到inode entry中。随后进行一些列的初始化。

在完成inode entry的提取后，就将该inode entry所在inode page的位置及页内偏移量存储到其他某个page内（对于btree就是记录在根节点内，占用10个字节，包含space id, page no, offset）。

Btree的根节点实际上是在创建non-leaf segment时分配的，root page被分配到该segment的frag array的第一个数组元素中。

Segment分配入口函数： `fseg_create_general`

#3.内核月报释放Segment

**释放Segment** 当我们删除索引或者表时，需要删除btree（`btr_free_if_exists`），先删除除了root节点外的其他部分(`btr_free_but_not_root`)，再删除root节点(`btr_free_root`)

由于数据操作都需要记录redo，为了避免产生非常大的redo log，leaf segment通过反复调用函数`fseg_free_step`来释放其占用的数据页：

1.  首先找到leaf segment对应的Inode entry（`fseg_inode_try_get`）；
2.  然后依次查找inode entry中的`FSEG_FULL`、或者`FSEG_NOT_FULL`、或者`FSEG_FREE`链表，找到一个Extent，注意着里的链表元组所指向的位置实际上是描述该Extent的Xdes Entry所在的位置。因此可以快速定位到对应的Xdes Page及Page内偏移量(`xdes_lst_get_descriptor`)；
3.  现在我们可以将这个Extent安全的释放了(`fseg_free_extent`，见后文)；
4.  当反复调用`fseg_free_step`将所有的Extent都释放后，segment还会最多占用32个碎片页，也需要依次释放掉(`fseg_free_page_low`)
5.  最后，当该inode所占用的page全部释放时，释放inode entry：
    *   如果该inode所在的inode page中当前被用满，则由于我们即将释放一个slot，需要从`FSP_SEG_INODES_FULL`转移到`FSP_SEG_INODES_FREE`（更新第一个page）；
    *   将该inode entry的SEG\_ID清除为0，表示未使用；
    *   如果该inode page上全部inode entry都释放了，就从`FSP_SEG_INODES_FREE`移除，并删除该page。

non-leaf segment的回收和leaf segment的回收基本类似，但要注意btree的根节点存储在该segment的frag arrary的第一个元组中，该Page暂时不可以释放(`fseg_free_step_not_header`)

btree的root page在完成上述步骤后再释放，此时才能彻底释放non-leaf segment


