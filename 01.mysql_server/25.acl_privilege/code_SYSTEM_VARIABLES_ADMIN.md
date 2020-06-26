#1.SYSTEM_VARIABLES_ADMIN

#1.1 functions
```cpp
--4.1 check_session_admin_or_replication_applier
--4.2 check_session_admin
--4.3 check_set_default_table_encryption_access
--4.4 Persisted_variables_cache::set_persist_options
--4.5 check_priv
--4.6 set_var::resolve
--4.7 set_var::light_check
--4.8 dynamic_privilege_init
--4.9 GRANT SYSTEM_VARIABLES_ADMIN ON *.* TO 'mysql.session'@localhost;
--4.10 INSERT INTO global_grants SELECT user, host, 'SYSTEM_VARIABLES_ADMIN', IF(grant_priv = 'Y', 'Y', 'N') FROM mysql.user WHERE super_priv = 'Y' AND @hadSystemVariablesAdminPriv = 0;
--4.11 INSERT IGNORE INTO mysql.global_grants VALUES ('mysql.session', 'localhost', 'SYSTEM_VARIABLES_ADMIN', 'N');
```

#1.2 contents

```cpp
scripts/mysql_system_users.sql:GRANT SYSTEM_VARIABLES_ADMIN ON *.* TO 'mysql.session'@localhost;
scripts/mysql_system_tables_fix.sql:-- Add the privilege SYSTEM_VARIABLES_ADMIN for every user who has the privilege SUPER
scripts/mysql_system_tables_fix.sql:-- provided that there isn't a user who already has the privilige SYSTEM_VARIABLES_ADMIN.
scripts/mysql_system_tables_fix.sql:SET @hadSystemVariablesAdminPriv = (SELECT COUNT(*) FROM global_grants WHERE priv = 'SYSTEM_VARIABLES_ADMIN');
scripts/mysql_system_tables_fix.sql:INSERT INTO global_grants SELECT user, host, 'SYSTEM_VARIABLES_ADMIN', IF(grant_priv = 'Y', 'Y', 'N')
scripts/mysql_system_tables_fix.sql:# SUPER, PERSIST_RO_VARIABLES_ADMIN, SYSTEM_VARIABLES_ADMIN, BACKUP_ADMIN,
scripts/mysql_system_tables_fix.sql:INSERT IGNORE INTO mysql.global_grants VALUES ('mysql.session', 'localhost', 'SYSTEM_VARIABLES_ADMIN', 'N');
sql/log_event.cc:        !security_context.has_access({"SYSTEM_VARIABLES_ADMIN"}) &&
sql/log_event.cc:                  "SUPER, SYSTEM_VARIABLES_ADMIN or SESSION_VARIABLES_ADMIN");
sql/log_event.cc:                {"SYSTEM_VARIABLES_ADMIN", "TABLE_ENCRYPTION_ADMIN"})) {
sql/log_event.cc:              "SUPER or SYSTEM_VARIABLES_ADMIN and TABLE_ENCRYPTION_ADMIN");
sql/sys_vars.cc:      !sctx->has_global_grant(STRING_WITH_LEN("SYSTEM_VARIABLES_ADMIN"))
sql/sys_vars.cc:             "SUPER, SYSTEM_VARIABLES_ADMIN, SESSION_VARIABLES_ADMIN or "
sql/sys_vars.cc:  We also accept SYSTEM_VARIABLES_ADMIN since it doesn't make a lot of
sql/sys_vars.cc:      !sctx->has_global_grant(STRING_WITH_LEN("SYSTEM_VARIABLES_ADMIN"))
sql/sys_vars.cc:             "SUPER, SYSTEM_VARIABLES_ADMIN or SESSION_VARIABLES_ADMIN");
sql/sys_vars.cc:    ROLE_ADMIN and the SYSTEM_VARIABLES_ADMIN.
sql/sys_vars.cc:             "SYSTEM_VARIABLES_ADMIN or SUPER privileges, as well as the "
sql/sys_vars.cc:  // Should own one of SUPER or both (SYSTEM_VARIABLES_ADMIN and
sql/sys_vars.cc:           ->has_global_grant(STRING_WITH_LEN("SYSTEM_VARIABLES_ADMIN"))
sql/sys_vars.cc:           "SUPER or SYSTEM_VARIABLES_ADMIN and TABLE_ENCRYPTION_ADMIN");
sql/persisted_variable.cc:      "ENCRYPTION_KEY_ADMIN", "ROLE_ADMIN", "SYSTEM_VARIABLES_ADMIN",
sql/set_var.cc:  /* for dynamic variables user needs SUPER_ACL or SYSTEM_VARIABLES_ADMIN */
sql/set_var.cc:        !(sctx->has_global_grant(STRING_WITH_LEN("SYSTEM_VARIABLES_ADMIN"))
sql/set_var.cc:               "SUPER or SYSTEM_VARIABLES_ADMIN");
sql/set_var.cc:     for static variables user needs both SYSTEM_VARIABLES_ADMIN and
sql/set_var.cc:    if (!(sctx->has_global_grant(STRING_WITH_LEN("SYSTEM_VARIABLES_ADMIN"))
sql/set_var.cc:               "SYSTEM_VARIABLES_ADMIN and PERSIST_RO_VARIABLES_ADMIN");
sql/set_var.cc:    /* Either the user has SUPER_ACL or she has SYSTEM_VARIABLES_ADMIN */
sql/set_var.cc:        sctx->has_global_grant(STRING_WITH_LEN("SYSTEM_VARIABLES_ADMIN"))
sql/set_var.cc:        sctx->has_global_grant(STRING_WITH_LEN("SYSTEM_VARIABLES_ADMIN"))
sql/sql_parse.cc:            ->has_global_grant(STRING_WITH_LEN("SYSTEM_VARIABLES_ADMIN"))
sql/auth/dynamic_privileges_impl.cc:          STRING_WITH_LEN("SYSTEM_VARIABLES_ADMIN"));

```
