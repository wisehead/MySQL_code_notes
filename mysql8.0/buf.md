以下是MySQL8.0

1.buf\_page_get

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
 
2.buf\_page\_init\_for_read


	caller:
	--buf_read_page_low
	----buf_page_init_for_read
	
3.buf_read_page_low

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
	
	
4.Buf_fetch<T>::read_page()

	Buf_fetch<T>::read_page()
	--buf_read_page(const page_id_t &page_id, const page_size_t &page_size)
	----
	
	caller:
	--Buf_fetch_normal::get
	--Buf_fetch_other::get


5.Buf_fetch_normal::get

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

6.Buf_fetch<T>::single_page()
	
	caller:
	buf_page_get_gen
	--fetch.single_page()
	
	Buf_fetch<T>::single_page()
	--Buf_fetch_normal::get
	--buf_wait_for_read(block);
	--mtr_add_page(block);






























