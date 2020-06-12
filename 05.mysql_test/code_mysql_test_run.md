#1.initialize_servers

```perl
sub initialize_servers
--//if (!$opt_gaia_skip_init)
      if (!$opt_gaia_skip_init) { 
        remove_stale_vardir();
        setup_vardir();
        mkpath("$opt_vardir/gaia_data");
        mkpath("$opt_vardir/gaia_data/psm_data");
        my $psm_proc = gaia_manager_start("$opt_gaia_manager_basedir/bin/manager", $opt_local_host, $opt_start_port, "$opt_vardir/gaia_data/psm_data");
        sleep 10; 
        registe_service($opt_local_host, $opt_start_port, $opt_start_port+1, $opt_start_port+2, $opt_start_port+3);
        sleep 3; 
        mkpath("$opt_vardir/gaia_data/ls_data");
        my $ls_proc = gaia_log_service_start("$opt_gaia_log_service_basedir/bin/log_service", $opt_local_host, $opt_start_port+1, $opt_start_port, "$opt_vardir/gaia_data/ls_data");
        sleep 3; 
        mkpath("$opt_vardir/gaia_data/ps_data");
        mkpath("$opt_vardir/gaia_data/ps_data/data");
        mkpath("$opt_vardir/gaia_data/ps_data/tmp");
        my $ps_proc = gaia_page_server_start("$opt_gaia_page_server_basedir/libexec/mysqld", $opt_local_host, $opt_start_port+2, $opt_start_port, "$opt_vardir/gaia_data/ps_data", "false");
        sleep 30; 

        mysql_install_db(default_mysqld(), "$opt_vardir/gaia_data/data/");
        sleep 60;
        My::SafeProcess::shutdown(0, $ps_proc);
        sleep 3;
        My::SafeProcess::shutdown(0, $ls_proc);
        sleep 3;
        My::SafeProcess::shutdown(0, $psm_proc);

      }

```

#2.start_servers

```perl
caller
--run_testcase

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

#4.main

```perl
main
--command_line_setup
--collect_test_cases
--initialize_servers
--new IO::Socket::INET
--run_test_server
----main::run_worker
------environment_setup
------setup_vardir
------run_testcase
--------started(all_servers()
--------clean_datadir
--------start_servers
--------do_before_run_mysqltest
--------start_mysqltest
--mtr_report_test

```
#important variables

```cpp

```


#todo

run_testcase
