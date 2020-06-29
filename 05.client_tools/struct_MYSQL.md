#1.struct MYSQL

```cpp
typedef struct MYSQL {
  NET net;                     /* Communication parameters */
  unsigned char *connector_fd; /* ConnectorFd for SSL */
  char *host, *user, *passwd, *unix_socket, *server_version, *host_info;
  char *info, *db;
  struct CHARSET_INFO *charset;
  MYSQL_FIELD *fields;
  struct MEM_ROOT *field_alloc;
  uint64_t affected_rows;
  uint64_t insert_id;      /* id if insert on table with NEXTNR */
  uint64_t extra_info;     /* Not used */
  unsigned long thread_id; /* Id for connection in server */
  unsigned long packet_length;
  unsigned int port;
  unsigned long client_flag, server_capabilities;
  unsigned int protocol_version;
  unsigned int field_count;
  unsigned int server_status;
  unsigned int server_language;
  unsigned int warning_count;
  struct st_mysql_options options;
  enum mysql_status status;
  enum enum_resultset_metadata resultset_metadata;
  bool free_me;   /* If free in mysql_close */
  bool reconnect; /* set to 1 if automatic reconnect */

  /* session-wide random string */
  char scramble[SCRAMBLE_LENGTH + 1];

  LIST *stmts; /* list of all statements */
  const struct MYSQL_METHODS *methods;
  void *thd;
  /*
    Points to boolean flag in MYSQL_RES  or MYSQL_STMT. We set this flag
    from mysql_stmt_close if close had to cancel result set of this object.
  */
  bool *unbuffered_fetch_owner;
  void *extension;
} MYSQL;
```