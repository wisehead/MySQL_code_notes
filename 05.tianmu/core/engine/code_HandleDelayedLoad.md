#1.HandleDelayedLoad

```
HandleDelayedLoad
--std::string addr = std::to_string(reinterpret_cast<long>(&vec));
--std::string table_path(vec[0].get() + sizeof(int32_t));
--std::tie(db_name, tab_name) = GetNames(table_path);

--std::string load_data_query = "LOAD DELAYED INSERT DATA INTO TABLE " + db_name + "." + tab_name;
--LEX_CSTRING dbname, tabname, loadquery;
  dbname.str = const_cast<char *>(db_name.c_str());
  dbname.length = db_name.length();
  loadquery.str = const_cast<char *>(load_data_query.c_str());
  loadquery.length = load_data_query.length();
--tabname.length = filename_to_tablename(const_cast<char *>(tab_name.c_str()), t_tbname, sizeof(t_tbname));
  tabname.str = t_tbname;
--Global_THD_manager *thd_manager = Global_THD_manager::get_instance();  // global thread manager
--
```