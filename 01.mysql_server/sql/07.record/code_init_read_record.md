#1.caller

```cpp
caller:
--join_init_read_record
```

#2. init_read_record
``` 
init_read_record
--table= qep_tab->table();
--new (info) READ_RECORD;
  info->thd=thd;
  info->table=table;
  info->forms= &info->table;
--empty_record(table);
    info->record= table->record[0];
    info->ref_length= table->file->ref_length;
--tempfile= table->sort.io_cache;
--info->read_record=rr_sequential;
--handler::ha_rnd_init
----ha_tianmu::rnd_init
--handler::extra_opt
--if (thd->optimizer_switch_flag(OPTIMIZER_SWITCH_ENGINE_CONDITION_PUSHDOWN) &&
      qep_tab && qep_tab->condition() && table->pos_in_table_list &&
      (qep_tab->condition()->used_tables() & table->pos_in_table_list->map()) &&
      !table->file->pushed_cond)
----table->file->cond_push(qep_tab->condition());
```

