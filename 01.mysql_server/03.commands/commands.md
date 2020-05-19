#1.mysql_execute_command

```cpp
int mysql_execute_command(THD *thd) {
    LEX  *lex= thd->lex;  // 解析过后的SQL语句的语法结构
    TABLE_LIST *all_tables = lex->query_tables;   // 该语句要访问的表的列表
    switch (lex->sql_command) {
        ...
        case SQLCOM_INSERT:
            insert_precheck(thd, all_tables);
            mysql_insert(thd, all_tables, lex->field_list, lex->many_values, lex->update_list, lex->value_list, lex->duplicates, lex->ignore);
            break; ...
        case SQLCOM_SELECT:
            check_table_access(thd, lex->exchange ? SELECT_ACL | FILE_ACL :  SELECT_ACL,  all_tables, UINT_MAX, FALSE);    // 检查用户对数据表的访问权限
            execute_sqlcom_select(thd, all_tables);     // 执行select语句
            break;
    }
}
```