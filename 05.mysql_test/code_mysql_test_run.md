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

#2.