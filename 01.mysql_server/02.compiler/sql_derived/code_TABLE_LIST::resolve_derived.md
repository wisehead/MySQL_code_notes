#1.TABLE_LIST::resolve_derived

```
TABLE_LIST::resolve_derived
--derived_result= new (thd->mem_root) Query_result_union
--derived->prepare
----st_select_lex_unit::prepare
--check_duplicate_names
--if (is_derived())
    set_privileges(SELECT_ACL);
```