#1.st_mysql_xid

```cpp

/**
  struct st_mysql_xid is binary compatible with the XID structure as
  in the X/Open CAE Specification, Distributed Transaction Processing:
  The XA Specification, X/Open Company Ltd., 1991.
  http://www.opengroup.org/bookstore/catalog/c193.htm

  @see XID in sql/handler.h
*/
struct st_mysql_xid {
  long formatID;
  long gtrid_length;
  long bqual_length;
  char data[MYSQL_XIDDATASIZE];  /* Not \0-terminated */
};
typedef struct st_mysql_xid MYSQL_XID;
```