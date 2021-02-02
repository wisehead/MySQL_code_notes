#1.tidb_code_trx_apply_commit_log

```cpp
tidb_code_trx_apply_commit_log
--trx_id = mach_read_from_8(ptr)
--trx_no = mach_read_from_6(ptr) + trx_id;
--min_no = trx_no - mach_read_from_2(ptr);//这个min_no什么意思？？？？
--trx_sys->trx_end_ids.push_back(trx_id);
--trx_sys->trx_end_ids.push_back(trx_no);
--trx_sys->slave_max_trx_id = trx_no;
--trx_sys->slave_dyn_low_limit_no = min_no;

```

#2. slave_max_trx_id

#3. slave_dyn_low_limit_no//low limit no, 以上全部commit

