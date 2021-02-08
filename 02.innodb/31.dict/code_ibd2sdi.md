#1.ibd2sdi main

```cpp
main
--ibd2sdi::process_files
----tablespace_creator::create
------my_open(filename, O_RDONLY, MYF(0))
------my_read(file_in, buf, UNIV_ZIP_SIZE_MIN, MYF(0))
------ib_tablespace::add_data_file
------ib_tablespace::check_sdi
--------fetch_page
--------ib_tablespace::get_sdi_root_page_num
----------fsp_header_get_sdi_offset
------ib_tablespace::add_sdi
--ibd2sdi::dump
----ibd2sdi::process_sdi_from_copy 
------ibd2sdi::dump_all_recs_in_leaf_level
--------ibd2sdi::reach_to_leftmost_leaf_level
----------read_page_and_return_level
----------ibd2sdi::get_first_user_rec
----------ibd2sdi::parse_fields_in_rec
--------ibd2sdi::check_and_dump_record
----------ibd2sdi::dump_sdi_rec
```