#1.handle_query//debug select version()

```cpp
handle_query
--single_query= unit->is_simple
--st_select_lex::set_query_result
--st_select_lex::make_active_options
--st_select_lex::prepare
----st_select_lex::get_table_list
----st_select_lex::setup_tables
------make_leaf_tables
----st_select_lex::check_view_privileges
----st_select_lex::setup_ref_array
----setup_fields
------Item_func_set_user_var::set_entry
------while ((item= it++))
------//end while
--st_select_lex::optimize
--JOIN::exec

```