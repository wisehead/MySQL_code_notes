#1.class Table_map_log_event

```cpp
/**
  @class Table_map_log_event

  Table_map_log_event which maps a table definition to a number.

  @internal
  The inheritance structure in the current design for the classes is
  as follows:

        Binary_log_event
               ^
               |
               |
    Table_map_event  Log_event
                \       /
                 \     /
                  \   /
           Table_map_log_event
  @endinternal
*/
class Table_map_log_event : public binary_log::Table_map_event, public Log_event
{
#ifdef MYSQL_SERVER
  TABLE         *m_table;
#endif
};
```