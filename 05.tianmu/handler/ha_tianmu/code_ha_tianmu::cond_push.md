#1.ha_tianmu::cond_push

```
ha_tianmu::cond_push
--std::shared_ptr<core::TianmuTable> rctp;
--ha_tianmu_engine_->GetTableIterator(table_name_, table_new_iter_, table_new_iter_end_, rctp,
                                          GetAttrsUseIndicator(table), table->in_use);
--query_.reset(new core::Query(current_txn_));
--query_->AddTable(rctp);
--cq_->TableAlias(t_out, core::TabID(0));                                           
```