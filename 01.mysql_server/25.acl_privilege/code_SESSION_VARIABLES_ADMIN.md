#1.SESSION_VARIABLES_ADMIN

```cpp
--3.1 check_session_admin_or_replication_applier
--3.2 check_session_admin
--3.3 dynamic_privilege_init
--3.4 Query_log_event::do_apply_event
```

```cpp
sql/log_event.cc:        !security_context.has_access({"SESSION_VARIABLES_ADMIN"})) {
sql/log_event.cc:                  "SUPER, SYSTEM_VARIABLES_ADMIN or SESSION_VARIABLES_ADMIN");
sql/sys_vars.cc:      !sctx->has_global_grant(STRING_WITH_LEN("SESSION_VARIABLES_ADMIN"))
sql/sys_vars.cc:             "SUPER, SYSTEM_VARIABLES_ADMIN, SESSION_VARIABLES_ADMIN or "
sql/sys_vars.cc:  Check if SESSION_VARIABLES_ADMIN granted. Throw SQL error if not.
sql/sys_vars.cc:      !sctx->has_global_grant(STRING_WITH_LEN("SESSION_VARIABLES_ADMIN"))
sql/sys_vars.cc:             "SUPER, SYSTEM_VARIABLES_ADMIN or SESSION_VARIABLES_ADMIN");
sql/auth/dynamic_privileges_impl.cc:          STRING_WITH_LEN("SESSION_VARIABLES_ADMIN"));
```

