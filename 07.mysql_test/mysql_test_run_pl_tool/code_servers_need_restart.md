#1.servers_need_restart

```cpp
servers_need_restart
--foreach my $server (mysqlds())
----if (is_slave($server))
------push(@slaves, $server);
----else
------push(@masters, $server);

--# Check masters                                                              
--my $master_restarted = 0;                                                    
--foreach my $master (@masters) {                                              
    if (server_need_restart($tinfo, $master, $master_restarted)) {             
      $master_restarted = 1;                                                   
      push(@restart_servers, $master);                                         
    }                                                                          
--}                                                                            
                                                                               
--# Check slaves                                                               
--foreach my $slave (@slaves) {                                                
    if (server_need_restart($tinfo, $slave, $master_restarted)) {              
      push(@restart_servers, $slave);                                          
    }                                                                          
--}                                                                            
                                                                               
--# Check if any remaining servers need restart                                
--foreach my $server (ndb_mgmds(), ndbds(), memcacheds()) {                    
    if (server_need_restart($tinfo, $server, $master_restarted)) {             
      push(@restart_servers, $server);                                         
    }                                                                          
--}                                                                            
```

#2.server_need_restart

```cpp
server_need_restart
  if ($tinfo->{template_path} ne $current_config_name) {
    mtr_verbose_restart($server, "using different config file");
    return 1;
  }

  if ($tinfo->{'master_sh'} || $tinfo->{'slave_sh'}) {
    mtr_verbose_restart($server, "sh script to run");
    return 1;
  }
```