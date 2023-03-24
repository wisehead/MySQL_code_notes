#TianmuTable::LoadDataInfile

```
TianmuTable::LoadDataInfile
--FunctionExecutor fe(std::bind(&TianmuTable::LockPackInfoForUse, this),
                      std::bind(&TianmuTable::UnlockPackInfoFromUse, this));
--if (iop.LoadDelayed()) 
----current_txn_->SetLoadSource(common::LoadSource::LS_MemRow);
----no_loaded_rows = MergeMemTable(iop);
--else
----current_txn_->SetLoadSource(common::LoadSource::LS_File);
----no_loaded_rows = ProceedNormal(iop);
------TianmuTable::ProceedNormal
```

