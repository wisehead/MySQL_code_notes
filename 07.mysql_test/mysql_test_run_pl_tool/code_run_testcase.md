#1. run_testcase

```cpp
run_testcase                      
--$tinfo->{bootstrap_master_opt} = find_bootstrap_opts($tinfo->{master_opt})
--$tinfo->{bootstrap_slave_opt} = find_bootstrap_opts($tinfo->{slave_opt})
--servers_need_reinitialization   
--servers_need_restart            
--if (started(all_servers()) == 0)     	 
----clean_datadir
----# Generate new config file from template                                          
----$config =                                                                         
      My::ConfigFactory->new_config(                                                  
                       { basedir             => $basedir,                             
                         baseport            => $baseport,                            
                         extra_template_path => $tinfo->{extra_template_path},        
                         mysqlxbaseport      => $mysqlx_baseport,                     
                         password            => '',                                   
                         template_path       => $tinfo->{template_path},              
                         testdir             => $glob_mysql_test_dir,                 
                         tmpdir              => $opt_tmpdir,                          
                         user                => $opt_user,                            
                         vardir              => $opt_vardir,                          
                       });                                                                            
   
----# Config shared dir for replica                                                             
----my $slave_group= $config->group('mysqld.2');                                                
----my $volume_id = sprintf('00000000-0000-0000-0000-1000%08d',                                 
----  $tinfo->{worker} * 100000 + $ncdb_node_baseid++);                                         
----my $ncdb_replication_port = $ncdb_baseport;                                                 
----my $ncdb_rw_node_id = $tinfo->{worker} * 100000 + $ncdb_node_baseid++;                      
----my $ncdb_rw_ncdb_port = $ENV{'RW_NCDB_PORT'};                                               
----$tinfo->{ncdb_volume_id} = $volume_id;                                                      
----$tinfo->{ncdb_rw_node_port} = $ncdb_baseport + 1;                                           
----$tinfo->{ncdb_rw_node_id} = $ncdb_rw_node_id;                                               
----$tinfo->{ncdb_rw_ncdb_port} = $ncdb_rw_ncdb_port;                                           
                                                                                                
----if ($opt_ncdb_test) {                                                                       
      $config->insert('mysqld.1', 'node_role', 'NODE_ROLE_RW');                                 
      $config->insert('mysqld.1', 'node_port', $ncdb_baseport + 1);                             
      $config->insert('mysqld.1', 'innodb_ncdb_node_id', $ncdb_rw_node_id);                     
      $config->insert('mysqld.1', 'innodb_ncdb_volume_id', $volume_id);                         
      $config->insert('mysqld.1', 'innodb_ncdb_port', $ncdb_rw_ncdb_port);                      
      $config->insert('mysqld.1', 'innodb_ncdb_master_port', $baseport);                        
      $config->insert('mysqld.1', 'innodb_ncdb_replication_port', $ncdb_replication_port);      
      $config->insert('mysqld.1', 'skip-innodb-validate-tablespace-paths');                     
----}  

----if (defined $slave_group)                                                                         
----{                                                                                                 
      mtr_report("[NCDB] [mysqld.2] is exist");                                                       
      $ncdb_share_dir= $config->value('mysqld.1', 'datadir');                                         
      mtr_error("can't find datadir in [mysqld.1]")                                                   
        if not defined  $ncdb_share_dir;                                                              
                                                                                                      
      if ( defined $slave_group->option('node_role') and                                              
           $config->value('mysqld.2', 'node_role') eq 'NODE_ROLE_RO')                                 
      {                                                                                               
        mtr_verbose("Configuring shared dir:$ncdb_share_dir for replica");                            
        my $datadir = $config->value('mysqld.2', 'datadir');                                          
        if (!$opt_ncdb_test) {                                                                        
          $config->remove('mysqld.2', 'datadir');                                                     
          $config->insert('mysqld.2', 'datadir', $ncdb_share_dir);                                    
          $config->insert('mysqld.2', 'tmpdir', $datadir);                                            
        } else {                                                                                      
          $config->insert('mysqld.2', 'innodb_ncdb_volume_id', $volume_id);                           
          $config->insert('mysqld.2', 'innodb_ncdb_replication_port', $ncdb_replication_port);        
          $config->insert('mysqld.2', 'node_port', $ncdb_baseport + 2);                               
          $config->insert('mysqld.2', 'innodb_ncdb_node_id', $ncdb_rw_node_id + 1);                   
        }                                                                                             
      }                                                                                               
----} 
    # Write the new my.cnf                                                         
----$config->save($path_config_file);                                              
                                                                                   
    # Remember current config so a restart can occur when a test need              
    # to use a different one                                                       
----$current_config_name = $tinfo->{template_path};                                
                                                                                   
    # Set variables in the ENV section                                             
----foreach my $option ($config->options_in_group("ENV")) {                        
      # Save old value to restore it before next time                              
      $old_env{ $option->name() } = $ENV{ $option->name() };                       
      mtr_verbose($option->name(), "=", $option->value());                         
      $ENV{ $option->name() } = $option->value();                                  
----}                                                                              
                                                                                
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

#3. start_mysqltest

```cpp
start_mysqltest
--my $proc = My::SafeProcess->new(name   => "mysqltest",
                                  path   => $exe,
                                  args   => \$args,
                                  append => 1,
                                  @redirect_output,
                                  error   => $path_current_testlog,
                                  verbose => $opt_verbose,);
```