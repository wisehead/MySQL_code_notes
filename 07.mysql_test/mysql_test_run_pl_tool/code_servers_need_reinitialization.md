#1.servers_need_reinitialization

```cpp
servers_need_reinitialization
--foreach my $mysqld (mysqlds()) {
    server_need_reinitialization($tinfo, $mysqld);
    if (defined $mysqld->{need_reinitialization} and
        $mysqld->{need_reinitialization} eq 1) {
      $server_need_reinit = 1;
      last if $tinfo->{rpl_test};
    } elsif (defined $mysqld->{need_reinitialization} and
             $mysqld->{need_reinitialization} eq 0) {
      $server_need_reinit = 0 if !$server_need_reinit;
    }
  }

--return $server_need_reinit;
```

#2.server_need_reinitialization

```cpp
# Determine whether the server needs to be reinitialized.
sub server_need_reinitialization {
  my ($tinfo, $server) = @_;
  my $bootstrap_opts = get_bootstrap_opts($server, $tinfo);
  my $started_boot_opts = $server->{'save_bootstrap_opts'};

  # If previous test and current test have the same bootstrap
  # options, do not reinitialize.
  if ($bootstrap_opts and $started_boot_opts) {
    if (My::Options::same($started_boot_opts, $bootstrap_opts)) {
      if (defined $test_fail and $test_fail eq 'MTR_RES_FAILED') {
        $server->{need_reinitialization} = 1;
      } else {
        $server->{need_reinitialization} = 0;
      }
    } else {
      $server->{need_reinitialization} = 1;
    }
  } elsif ($bootstrap_opts) {
    $server->{need_reinitialization} = 1;
  } else {
    $server->{need_reinitialization} = undef;
  }
}
```