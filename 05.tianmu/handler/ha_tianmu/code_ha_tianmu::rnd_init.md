#1.ha_tianmu::rnd_init

```
ha_tianmu::rnd_init
--if (query_ && !result_ && table_ptr_->NumOfObj() != 0) {
----//
--else
----if (scan && filter_ptr_.get()) {
----else
------ha_tianmu_engine_->GetTableIterator(table_name_, table_new_iter_, table_new_iter_end_, rctp,
                                            GetAttrsUseIndicator(table), table->in_use);
------table_ptr_ = rctp.get();
------filter_ptr_.reset();

```