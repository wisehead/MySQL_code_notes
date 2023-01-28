#1.pick_table_access_method

```
pick_table_access_method
--switch (tab->type)
----case JT_REF:
    tab->read_first_record= join_read_always_key;
    tab->read_record.read_record= join_read_next_same;
    tab->read_record.unlock_row= rr_unlock_row;
    break;

----case JT_REF_OR_NULL:
    tab->read_first_record= join_read_always_key_or_null;
    tab->read_record.read_record= join_read_next_same_or_null;
    tab->read_record.unlock_row= rr_unlock_row;
    break;

----case JT_CONST:
    tab->read_first_record= join_read_const;
    tab->read_record.read_record= join_no_more_records;
    tab->read_record.unlock_row= rr_unlock_row;
    break;

----case JT_EQ_REF:
    tab->read_first_record= join_read_key;
    tab->read_record.read_record= join_no_more_records;
    tab->read_record.unlock_row= join_read_key_unlock_row;

----case JT_FT:
    tab->read_first_record= join_ft_read_first;
    tab->read_record.read_record= join_ft_read_next;
    tab->read_record.unlock_row= rr_unlock_row;
    break;

----case JT_SYSTEM:
    tab->read_first_record= join_read_system;
    tab->read_record.read_record= join_no_more_records;
    tab->read_record.unlock_row= rr_unlock_row;
    break;

----default:
    tab->read_record.unlock_row= rr_unlock_row;
    break;   
```

#2.caller

```
JOIN::optimize
--pick_table_access_method
```

#3.comments

```cpp
/**
  Pick the appropriate access method functions

  Sets the functions for the selected table access method

  @param      tab               Table reference to put access method
*/
```