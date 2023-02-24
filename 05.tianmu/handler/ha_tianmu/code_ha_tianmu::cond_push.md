#1.ha_tianmu::cond_push

```
ha_tianmu::cond_push
--std::shared_ptr<core::TianmuTable> rctp;
--ha_tianmu_engine_->GetTableIterator(table_name_, table_new_iter_, table_new_iter_end_, rctp,
                                          GetAttrsUseIndicator(table), table->in_use);
--query_.reset(new core::Query(current_txn_));
--query_->AddTable(rctp);
--cq_->TableAlias(t_out, core::TabID(0));   
--query_->table_alias2index_ptr.insert(std::make_pair(ext_alias, std::make_pair(t_out.n, table)));
--for (Field **field = table->field; *field; field++) {
----if (bitmap_is_set(table->read_set, col_no)) 
------col.n = col_no++;
------cq_->CreateVirtualColumn(vc.n, tmp_table_, t_out, col);
------cq_->AddColumn(at, tmp_table_, core::CQTerm(vc.n), common::ColOperation::LISTING, (*field)->field_name,
                         false);                                        
--Query::BuildConditions
```