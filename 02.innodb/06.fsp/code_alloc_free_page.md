#1.在Segment中申请一个Page


以用户表空间的 Segement 为例，为 Segement 分配空间主要发生在两处：

*   为 B-tree 结构的 Segement 的分裂时分配 Page（fseg\_alloc\_free\_page\_low）
*   为 Rollback Segement 分配 Page

以前者为例（复杂的过程 ...）。有多种分配策略，下图中的起点到终点的任意路径都是可能的方式

  

![](notes_TableSpace/assets/1591436359-3ab2b10a432db770d82d32a0c94442a5.png)

有一个问题，在这个过程中前置条件是一个索引中需要新分配一个Page（给待分裂的节点），那么如果这个索引如何知道它保存了哪些Extent？

1.  在SYS\_INDEXES系统表中找到该索引的根节点位置（SYS\_INDEXES系统表记录了表，索引，及根节点对应的Page no）
2.  在根节点的Segment Header中找到该 Segment 占有的 INODE entry 位置
3.  在INODE entry中即可找到一系列的关于 Extent 的链表

**在为Segment分配Page / Extent之前，往往需要****【预留空间】，防止如在****B+ Tree分裂的过程中出现空间不足**

*   预留空间的大小是tree\_height / 16 + 3（通常都是3个Extents）

从 Segment 申请 Page 时，有一个参数叫 Hint Page no，通常是当前需要分裂 Page 的前一个（direction = FSP\_DOWN）或者后一个 Page (direction = FSP\_UP)，其目的是将逻辑上相邻的 Page 在物理文件中上也尽量相邻

```cpp
// 在 Segment 中申请一个 Page
fseg_alloc_free_page_low(
    // 调用者希望被分配的 Page。通常是当前需要分裂 Page 的前一个（direction = FSP_DOWN）或者后一个 Page(direction = FSP_UP)
    // 其目的是将逻辑上相邻的 Page 在物理文件中上也尽量相邻
    ulint      hint
)
{
    // 计算 Segment 当前占用的 Page 总数和使用的 Page 总数
    // 1）占用总数：FSEG_FREE上 Page 总数（链表长度 * 64） + FSEG_NOT_FULL上的 Page 总数
    //           +FSEG_FULL上 Page 总数 + FRAG_ARRY中的已使用的 Page 数
    // 2）使用总数：FSEG_NOT_FULL 链表上使用的 Page 总数（保存在 XDES Entry FSEG_NOT_FULL_N_USED 域）
    //           +FSEG_FULL 链表上的 Page 总数（链表长度 * 64）+ FRAG_ARRY 中的已使用的 Page 数
    reserved = fseg_n_reserved_pages_low();
 
    // 计算 hint 所在的 XDES Entry
    //   * 先计算 hint 所属的 XDES page no，即用 ut_2pow_round (hint_page_no, 16K)
    //     因为每 256 extents（256*64=16K pages）有一个 XDES
    hint_XDES_entry = xdes_get_descriptor_with_space_hdr();
     
    if (hint Extent 属于 Segment
        && hint 尚未被使用)
        // Situation 1
        return hint
    else if (hint_XDES_entry在FSP_FREE上
        && 空间使用率大于7/8
        && FRAG_ARRAY 已被用完)
        // Situation 2
        // 分配 hint_XDES_entry给Segment，拿到 hint
        // 注意这里的条件，即使 hint_XDES_entry 在FSP_FREE上，但比如空间使用率不大于7/8
        // 也不会分配新的 Extent，这里可以阻止碎片的产生
        return hint
    else if (是 B-tree 的分裂（direction != FSP_NO_DIR）
        && 空间使用率不大于7/8 
        && 当前 Segment 已经使用了超过32个 frag page)
        // Situation 3
        // 到这里已经说明无法获得hint
        // 尝试从Segment获取一个Extent（如果没有，则从Tablespace分配一个Extent给Segment）**
        // 返回该Extent最后一个Page（direction == FSP_DOWN）或第一个Page（direction == FSP_UP）
    else if (hint Extent属于Segment
        && hint Extent未被用完)
        // Situation 4
        return any_free_page (in hint Extent)
    else if (空间使用率不是100%)
        // Situation 5
        return any_free_page (in Segment)
    else if (已经使用的 Page < 32)
        // Situation 6
        // 从表空间中分配一个 Page 给 Segment，并加入到 Segment FRAG_ARRAY
    else
        // Situation 7
        // 以上情况都不满足
        // 从Tablespace直接分配一个 Extent**，并返回其中一个 Page
}
```

上述过程复杂，但总结起来优先级由高至低为：

1.  尽力申请 Hint Page
2.  申请 Segment 中 Extent 的 Page
1. 1. 1. 3.  Segment 从 Tablespace 中申请一个 Extent，返回 PageE

#2. 从表空间申请单独的 Page / Extent

上述的代码步骤里出现两个操作：**从表空间申请碎片的 Page / Extent（Situation 3 / 7）**

*   碎片的Page是从 **FSP\_FREE\_FRAG** 链表中分配
*   Extent是从 **FSP\_FREE** 链表中分配  
      
    

 ![](notes_TableSpace/assets/1591436359-9bb8f6134b16e0b00498066a4ec9a035.png) 

**TODO：释放Segment / 回收Page**