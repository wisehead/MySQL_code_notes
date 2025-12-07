#1.st_select_lex::add_table_to_list

```cpp

/**
Add a table to list of used tables.
    @param table          Table to add  //指明表对象
    @param alias          alias for table (or null if no alias)
    @param table_options        A set of the following bits:
                           - TL_OPTION_UPDATING : Table will be updated
                           - TL_OPTION_FORCE_INDEX : Force usage of index
                           - TL_OPTION_ALIAS : an alias in multi table DELETE
    @param lock_typeHow table should be locked   //表中元组上应当施加的锁，这是对数据的修改
    @param mdl_typeType of metadata lock to acquire on the table.
    //表的元数据上应当施加的锁，这是对表结构的修改
    @param use_index      List of indexed used in USE INDEX
    @param ignore_indexList of indexed used in IGNORE INDEX
    @retval
            0             Error
    @retval
        \#      Pointer to TABLE_LIST element added to the total table list
*/
TABLE_LIST *st_select_lex::add_table_to_list(THD *thd,  
//对SQL语句做Parser的阶段，即确定应当施加什么样的锁，这是由SQL语句的语义确定的
        Table_ident *table,
        LEX_STRING *alias,
        ulong table_options,
        thr_lock_type lock_type,  //参数：表中元组上应当施加的锁，这是对数据的修改
        enum_mdl_type mdl_type, //参数：表的元数据上应当施加的锁，这是对表结构的修改
        List<Index_hint> *index_hints_arg,
        List<String> *partition_names,
        LEX_STRING *option)
{
    TABLE_LIST *ptr;     //表对象
...
    ptr->lock_type= lock_type;  //表中元组上应当施加的锁，这是对数据的修改
...
    // Pure table aliases do not need to be locked:
    if (!MY_TEST(table_options & TL_OPTION_ALIAS))
    {
        MDL_REQUEST_INIT(& ptr->mdl_request,
                     MDL_key::TABLE, ptr->db, ptr->table_name, mdl_type,
//表的元数据上应当施加的锁，这是对表结构的修改
                     MDL_TRANSACTION);
    }
...
}

```