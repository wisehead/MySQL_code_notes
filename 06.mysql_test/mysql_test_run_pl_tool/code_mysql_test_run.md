#1.main

```perl
main
--command_line_setup
----collect_mysqld_features
----main::set_vardir
----executable_setup
--create_unique_id_dir
--mtr_cases::collect_test_cases
--initialize_servers
--new IO::Socket::INET
--read_plugin_defs
----find_plugin
--My::SafeProcess::Base::_safe_fork
--run_test_server//main thread word server
----IO::Select::add	
----run_testcase_check_skip_test
----$next->write_test($sock, 'TESTCASE');
--run_worker
----environment_setup
----setup_vardir
------mkpath("$opt_vardir/log");
------mkpath("$opt_vardir/run");
------mkpath("$opt_vardir/tmp");
------copytree("$glob_mysql_test_dir/std_data", "$opt_vardir/std_data", "0022");
----print $server "START\n";//进入状态机
----run_testcase
----$test->write_test($server, 'TESTRESULT')
--mtr_report_test

```

#2.initialize_servers

```perl
main
--initialize_servers
----using_extern
----kill_leftovers
----remove_stale_vardir
----setup_vardir
----gaia_manager_start
------My::SafeProcess::new
--------My::SafeProcess::Base::create_process
----------IO::Pipe::new
----------My::SafeProcess::Base::_safe_fork
----registe_service
----gaia_log_service_start
------My::SafeProcess::new
----gaia_page_server_start
------My::SafeProcess->new
----default_mysqld
------My::ConfigFactory->new_config
------$config->group
----mysql_install_db
------My::SafeProcess::run
--------My::SafeProcess::new
----------My::SafeProcess::Base::create_process
```

#3. run_testcase

```cpp
----run_testcase
------find_bootstrap_opts//for opt files
------servers_need_reinitialization
------servers_need_restart
------started(all_servers()
------clean_datadir
------My::ConfigFactory::new_config
------start_servers
------do_before_run_mysqltest
------start_mysqltest
```

#4.start_servers

```cpp
run_testcase
--start_servers
----get_bootstrap_opts//获取opt启动参数
----//if datadir exist
----My::SafeProcess::shutdown(0, $mysqld->{'ps_proc'});
----My::SafeProcess::shutdown(0, $mysqld->{'ls_proc'});
----My::SafeProcess::shutdown(0, $mysqld->{'psm_proc'});
----rmtree("$group/ls_data");
----rmtree("$group/ps_data");
----rmtree("$group/psm_data");
----rmtree($datadir);
----//初始化datadir，拷贝gaiadb_data，不需要自己初始化。
----My::SafeProcess::shutdown(0, $mysqld->{'ps_proc'})
----My::SafeProcess::shutdown(0, $mysqld->{'ls_proc'});
----My::SafeProcess::shutdown(0, $mysqld->{'psm_proc'});
----rmtree("$group/ls_data");
----rmtree("$group/ps_data");
----rmtree("$group/psm_data");
----copytree("$path/gaia_data/ls_data", "$group/ls_data")
----copytree("$path/gaia_data/ps_data", "$group/ps_data")
----copytree("$path/gaia_data/psm_data", "$group/psm_data")
----gaia_manager_start
----gaia_log_service_start
----gaia_page_server_start
----rmtree($datadir);
----copytree($install_db, $datadir)
----//if ($mysqld->{need_reinitialization}) or opt
----My::SafeProcess::shutdown(0, $mysqld->{'ps_proc'});
----My::SafeProcess::shutdown(0, $mysqld->{'ls_proc'});
----My::SafeProcess::shutdown(0, $mysqld->{'psm_proc'});
----rmtree("$group/ls_data");
----rmtree("$group/ps_data");
----rmtree("$group/psm_data");
----rmtree($datadir);
----mkpath("$group/psm_data");
----mkpath("$group/ls_data");
----mkpath("$group/ps_data");
----mkpath("$group/ps_data/data");
----mkpath("$group/ps_data/tmp");
----gaia_manager_start
----gaia_log_service_start
----gaia_page_server_start
----mysql_install_db
----unlink("$opt_vardir/tmp/bootstrap.sql")
----mkpath($tmpdir)
----mark_log($mysqld->value('#log-error'), $tinfo)
----mysqld_start
------My::SafeProcess->new//mysqld
----sleep_until_pid_file_created
```

#5.clean_datadir

```
run_testcase
--clean_datadir
----My::SafeProcess::shutdown(0, $mysqld->{'ps_proc'});
----My::SafeProcess::shutdown(0, $mysqld->{'ls_proc'});
----My::SafeProcess::shutdown(0, $mysqld->{'psm_proc'});
----rmtree("$group/ls_data");
----rmtree("$group/ps_data");
----rmtree("$group/psm_data");
----rmtree($mysqld_dir);
----clean_dir("$opt_vardir/tmp");
```

#3.mysqltest tool

```perl
2434   if (defined $ENV{'MYSQL_TEST'}) {                      
2435     $exe_mysqltest = $ENV{'MYSQL_TEST'};                 
2436     print "===========================================================\n";
2437     print "WARNING:The mysqltest binary is fetched from $exe_mysqltest\n";
2438     print "===========================================================\n";
2439   } else {                                               
2440     $exe_mysqltest = mtr_exe_exists("$path_client_bindir/mysqltest");                                                                                                                                                                                      
2441   }                                                      
2442 } 
```








#8. mysql_install_db

```
caller:
--initialize_servers
--start_servers
```

#todo

run_testcase
