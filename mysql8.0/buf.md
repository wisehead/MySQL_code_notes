以下是MySQL8.0

# 1.buf\_page_get

	buf_page_get
	--buf_page_get_gen
	
	example:
	
	 9030 /** Print the extent descriptor pages of this tablespace into
	 9031 the given file.              
	 9032 @param[in]  out the output file name.
	 9033 @return the output stream. */
	 9034 std::ostream &fil_space_t::print_xdes_pages(std::ostream &out) const {
	 9035   mtr_t mtr;        
	 9036   const page_size_t page_size(flags);
	 9037         
	 9038   mtr_start(&mtr);  
	 9039         
	 9040   for (page_no_t i = 0; i < 100; ++i) {
	 9041     page_no_t xdes_page_no = i * UNIV_PAGE_SIZE;
	 9042         
	 9043     if (xdes_page_no >= size) {                                   
	 9044       break;
	 9045     }   
	 9046         
	 9047     buf_block_t *xdes_block =                                     
	 9048         buf_page_get(page_id_t(id, xdes_page_no), page_size, RW_S_LATCH, &mtr);
	 9049         
	 9050     page_t *page = buf_block_get_frame(xdes_block);
	 9051         
	 9052     ulint page_type = fil_page_get_type(page);
	 9053         
	 9054     switch (page_type) {
	 9055       case FIL_PAGE_TYPE_ALLOCATED:
	 9056         
	 9057         ut_ad(xdes_page_no >= free_limit);
	 9058         
	 9059         mtr_commit(&mtr);
	 9060         return (out);
	 9061         
	 9062       case FIL_PAGE_TYPE_FSP_HDR:
	 9063       case FIL_PAGE_TYPE_XDES:
	 9064         break;
	 9065       default:
	 9066         ut_error;
	 9067     }   
	 9068         
	 9069     xdes_page_print(out, page, xdes_page_no, &mtr);
	 9070   }     
	 9071         
	 9072   mtr_commit(&mtr);
	 9073   return (out);
	 9074 }  
 
# 2.buf\_page\_init\_for_read


	caller:
	--buf_read_page_low
	----buf_page_init_for_read
	
# 3.buf_read_page_low

caller:

* Buf_fetch<T>::read_page()
* buf_read_ahead_random
* buf_read_page
* buf_read_page_background
* buf_phy_read_ahead
* buf_read_ahead_linear
* buf_read_ibuf_merge_pages
* buf_read_recv_pages
	
		
		buf_read_page_low
		--buf_page_io_complete
	
	
# 4.Buf_fetch<T>::read_page()

	Buf_fetch<T>::read_page()
	--buf_read_page(const page_id_t &page_id, const page_size_t &page_size)
	----
	
	caller:
	--Buf_fetch_normal::get
	--Buf_fetch_other::get


# 5.Buf_fetch_normal::get

	caller:
	Buf_fetch<T>::single_page()
	
	Buf_fetch_normal::get
	--Buf_fetch<T>::lookup
	----buf_page_hash_lock_get
	----buf_page_hash_get_low
	--Buf_fetch<T>::read_page
	----buf_read_page
	----buf_read_page_low
	------buf_page_io_complete


***
---
# 6.Buf_fetch<T>::single\_page()
	
	caller:
	buf_page_get_gen
	
	Buf_fetch<T>::single_page()
	--Buf_fetch_normal::get
	--buf_wait_for_read(block);
	--mtr_add_page(block);


# 7.buf_page_get_gen
caller:

	--PageBulk::latch
	--btr_cur_search_to_nth_level
	--btr_cur_search_to_nth_level_with_no_latch
	--btr_cur_open_at_index_side_func
	--btr_cur_open_at_index_side_with_no_latch_func
	--btr_cur_open_at_rnd_pos_func
	--btr_estimate_n_rows_in_range_on_level
	--btr_search_drop_page_hash_when_freed
	--Clone_Snapshot::get_page_for_write
	--dict_stats_analyze_index_below_cur
	--mark_all_page_dirty_in_tablespace
	--rtr_pcur_getnext_from_path
	--rtr_cur_restore_position
	--ibuf_bitmap_get_map_page_func
	--buf_page_get
	--buf_page_get_with_no_latch
	--lock_rec_fetch_page
	--lock_rec_block_validate
	--Parallel_reader::Scan_ctx::block_get_s_latched
	--PCursor::move_to_next_block
	--sel_set_rtr_rec_lock
	--row_sel_store_row_id_to_prebuilt
	--trx_undo_report_row_operation
	
# 8.buf_zip_decompress

	caller:
	--Buf_fetch<T>::zip_page_handler
	--buf_page_io_complete
	--meb_apply_log_record	
	--PageConverter::update_page
	
	code_flow:
	buf_zip_decompress
	--page_zip_decompress

# 9.buf\_page\_get_zip


	caller:
	zReader::fetch_page()

	buf_page_get_zip
	--buf_page_get_io_fix
	----buf_page_get_io_fix_unlocked

# 10.zip.data读相关
## 10.1 buf_read_page_low

	--buf_read_page_low  //fil_io会将磁盘数据读到 bpage->zip.data
	110   if (page_size.is_compressed()) {  
	111     dst = bpage->zip.data;         
	112   } else {                         
	113     ut_a(buf_page_get_state(bpage) == BUF_BLOCK_FILE_PAGE);
	114                                                                  
	115     dst = ((buf_block_t *)bpage)->frame;                                                                                                                                                                                                                    
	116   } 
		
## 10.2 buf_page_init_for_read
//分配zip.data内存，初始化。

	4706     if (page_size.is_compressed()) {
	4707       block->page.zip.data = (page_zip_t *)data;
	4708  
	4709       /* To maintain the invariant
	4710       block->in_unzip_LRU_list
	4711       == buf_page_belongs_to_unzip_LRU(&block->page)
	4712       we have to add this block to unzip_LRU
	4713       after block->page.zip.data is set. */
	4714       ut_ad(buf_page_belongs_to_unzip_LRU(&block->page));
	4715       buf_unzip_LRU_add_block(block, TRUE);
	4716     }	


##10.3 buf\_page\_create

	4884   if (page_size.is_compressed()) {
	4885     mutex_exit(&buf_pool->LRU_list_mutex);
	4886                                  
	4887     auto data = buf_buddy_alloc(buf_pool, page_size.physical());
	4888                                  
	4889     mutex_enter(&buf_pool->LRU_list_mutex);
	4890                                  
	4891     buf_page_mutex_enter(block); 
	4892     block->page.zip.data = (page_zip_t *)data;
	4893     buf_page_mutex_exit(block);  
	4894                                  
	4895     /* To maintain the invariant 
	4896     block->in_unzip_LRU_list     
	4897     == buf_page_belongs_to_unzip_LRU(&block->page)
	4898     we have to add this block to unzip_LRU after
	4899     block->page.zip.data is set. */
	4900     ut_ad(buf_page_belongs_to_unzip_LRU(&block->page));
	4901     buf_unzip_LRU_add_block(block, FALSE);
	4902   }  


## 10.4 buf\_page\_io_complete
//IO读上来的时候，就会解压。

	buf_page_io_complete
	
	5125     if (bpage->size.is_compressed()) {
	5126       frame = bpage->zip.data;      
	5127       os_atomic_increment_ulint(&buf_pool->n_pend_unzip, 1);
	5128       if (uncompressed && !buf_zip_decompress((buf_block_t *)bpage, FALSE)) {                                                                                                                                                                              
	5129         os_atomic_decrement_ulint(&buf_pool->n_pend_unzip, 1);
	5130                                     
	5131         compressed_page = false;    
	5132         goto corrupt;               
	5133       }                             
	5134       os_atomic_decrement_ulint(&buf_pool->n_pend_unzip, 1);
	5135     } else {                        
	5136       ut_a(uncompressed);           
	5137       frame = ((buf_block_t *)bpage)->frame;
	5138     }  



# 11. zip.data写相关
## 11.1 buf_flush_write_block_low

	1174   switch (buf_page_get_state(bpage)) {
	1175     case BUF_BLOCK_POOL_WATCH:
	1176     case BUF_BLOCK_ZIP_PAGE: /* The page should be dirty. */
	1177     case BUF_BLOCK_NOT_USED:
	1178     case BUF_BLOCK_READY_FOR_USE:
	1179     case BUF_BLOCK_MEMORY:
	1180     case BUF_BLOCK_REMOVE_HASH:
	1181       ut_error;       
	1182       break;          
	1183     case BUF_BLOCK_ZIP_DIRTY: {
	1184       frame = bpage->zip.data;
	1185       BlockReporter reporter =
	1186           BlockReporter(false, frame, bpage->size,
	1187                         fsp_is_checksum_disabled(bpage->id.space()));
	1188                       
	1189       mach_write_to_8(frame + FIL_PAGE_LSN, bpage->newest_modification);
	1190                       
	1191       ut_a(reporter.verify_zip_checksum());                                                                                                                                                                                                                
	1192       break;          
	1193     }                 
	1194     case BUF_BLOCK_FILE_PAGE:
	1195       frame = bpage->zip.data;
	1196       if (!frame) {   
	1197         frame = ((buf_block_t *)bpage)->frame;
	1198       }               
	1199                       
	1200       buf_flush_init_for_writing(
	1201           reinterpret_cast<const buf_block_t *>(bpage),
	1202           reinterpret_cast<const buf_block_t *>(bpage)->frame,
	1203           bpage->zip.data ? &bpage->zip : NULL, bpage->newest_modification,
	1204           fsp_is_checksum_disabled(bpage->id.space()),
	1205           false /* do not skip lsn check */);    
	1206       break;          
	1207   }   


# 12. zip.data free相关
## 12.1 buf_LRU_block_free_non_file_page

	1930   data = block->page.zip.data;                                                                                                                                                                                                                             
	1931                       
	1932   if (data != NULL) { 
	1933     block->page.zip.data = NULL;
	1934                       
	1935     ut_ad(block->page.size.is_compressed());
	1936                                
	1937     buf_buddy_free(buf_pool, data, block->page.size.physical());
	1938                       
	1939     page_zip_set_size(&block->page.zip, 0);
	1940                       
	1941     block->page.size.copy_from(page_size_t(block->page.size.logical(),
	1942                                            block->page.size.logical(), false));
	1943   } 


## 12.2 buf_LRU_block_remove_hashed

	2003   switch (buf_page_get_state(bpage)) {
	2004     case BUF_BLOCK_FILE_PAGE: {
	2005       UNIV_MEM_ASSERT_W(bpage, sizeof(buf_block_t));
	2006       UNIV_MEM_ASSERT_W(((buf_block_t *)bpage)->frame, UNIV_PAGE_SIZE);
	2007                   
	2008       buf_block_modify_clock_inc((buf_block_t *)bpage);
	2009                   
	2010       if (bpage->zip.data != NULL) {
	2011         const page_t *page = ((buf_block_t *)bpage)->frame;
	2012                   
	2013         ut_a(!zip || bpage->oldest_modification == 0);
	2014         ut_ad(bpage->size.is_compressed());
	2015                   
	2016         switch (fil_page_get_type(page)) {
	2017           case FIL_PAGE_TYPE_ALLOCATED:
	2018           case FIL_PAGE_INODE:
	2019           case FIL_PAGE_IBUF_BITMAP:
	2020           case FIL_PAGE_TYPE_FSP_HDR:
	2021           case FIL_PAGE_TYPE_XDES:
	2022           case FIL_PAGE_TYPE_ZLOB_FIRST:
	2023           case FIL_PAGE_TYPE_ZLOB_DATA:
	2024           case FIL_PAGE_TYPE_ZLOB_INDEX:
	2025           case FIL_PAGE_TYPE_ZLOB_FRAG:
	2026           case FIL_PAGE_TYPE_ZLOB_FRAG_ENTRY:
	2027             /* These are essentially uncompressed pages. */
	2028             if (!zip) {
	2029               /* InnoDB writes the data to the
	2030               uncompressed page frame.  Copy it
	2031               to the compressed page, which will
	2032               be preserved. */
	2033               memcpy(bpage->zip.data, page, bpage->size.physical());
	2034             }     
	2035             break;
	
	
	2129   switch (buf_page_get_state(bpage)) {   
	2130     case BUF_BLOCK_ZIP_PAGE:             
	2131       ut_ad(!bpage->in_free_list);       
	2132       ut_ad(!bpage->in_flush_list);      
	2133       ut_ad(!bpage->in_LRU_list);        
	2134       ut_a(bpage->zip.data);             
	2135       ut_a(bpage->size.is_compressed()); 
	2136                                          
	2137 #if defined UNIV_DEBUG || defined UNIV_BUF_DEBUG
	2138       UT_LIST_REMOVE(buf_pool->zip_clean, bpage);
	2139 #endif /* UNIV_DEBUG || UNIV_BUF_DEBUG */
	2140                                          
	2141       mutex_exit(&buf_pool->zip_mutex);  
	2142       rw_lock_x_unlock(hash_lock);       
	2143                                          
	2144       buf_buddy_free(buf_pool, bpage->zip.data, bpage->size.physical());


	2149     case BUF_BLOCK_FILE_PAGE:
	....
	....
	2179       if (zip && bpage->zip.data) {      
	2180         /* Free the compressed page. */  
	2181         void *data = bpage->zip.data;    
	2182         bpage->zip.data = NULL;          
	2183                             
	2184         ut_ad(!bpage->in_free_list);     
	2185         ut_ad(!bpage->in_flush_list);    
	2186         ut_ad(!bpage->in_LRU_list);      
	2187                             
	2188         buf_buddy_free(buf_pool, data, bpage->size.physical());
	2189                             
	2190         page_zip_set_size(&bpage->zip, 0);
	2191                             
	2192         bpage->size.copy_from(           
	2193             page_size_t(bpage->size.logical(), bpage->size.logical(), false));
	2194       } 







