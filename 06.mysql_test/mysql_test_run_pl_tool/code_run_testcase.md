#1. run_testcase

```cpp
run_testcase                      
--$tinfo->{bootstrap_master_opt} = find_bootstrap_opts($tinfo->{master_opt})
--$tinfo->{bootstrap_slave_opt} = find_bootstrap_opts($tinfo->{slave_opt})
--servers_need_reinitialization   
--servers_need_restart            
--started(all_servers()          	 
--clean_datadir                   
--My::ConfigFactory::new_config   
--start_servers                   
--do_before_run_mysqltest         
--start_mysqltest
```

#2.caller

```
main
--run_worker
----run_testcase
```