#1.fsp_alloc_free_extent

Tablespace 自动扩展
如果*.ibd剩余空间不足（e.g 在 B-tree 分裂时有时会预留 2 Extent，如果此时剩余空间不足，则需要 Tablespace 自动扩展），自动扩展文件（fsp_try_extend_data_file）

	Tablespace < 1 Extent（1MB），则扩展到1 Extent
	Tablespace < 32MB，每次扩展1 Extent
	Tablespace > 大于32MB时，每次扩展4 Extent（fsp_get_pages_to_extend_ibd）
但扩展的空间不会立即加入到FSP_FREE中（即并不初始化），等到FSP_FREE为空时，再批量的加入


```cpp
// 从 Tablespace 中分配一个 Extent（给某个 Segment）
fsp_alloc_free_extent {
  // FSP_FREE 的第一个 Extent（所属的 XDES entry 的地址）
  first = flst_get_first(header + FSP_FREE, mtr);
  // 该 Extent 所属的 XDES entry 的地址为空，表明 FSP_FREE 为空（为何不直接判断 FSP_FREE 为空？）
  if (fil_addr_is_null(first)) {
    // 将在 FSP_FREE_LIMIT 之外的空间以 Extent 为单位分割，并加入到 FSP_FREE 中
    fsp_fill_free_list(false, space, header, mtr);
 
    first = flst_get_first(header + FSP_FREE, mtr);
  }
}
```