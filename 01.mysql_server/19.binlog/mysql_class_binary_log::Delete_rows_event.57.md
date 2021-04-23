#1.Delete_rows_event

```cpp
/**
  @class Delete_rows_event

  Log row deletions. The event contain several delete rows for a
  table. Note that each event contains only rows for one table.

  RESPONSIBILITIES

    - Act as a container for rows that has been deleted on the master
      and should be deleted on the slave.

   @section Delete_rows_event_binary_format Binary Format
*/
class Delete_rows_event : public virtual Rows_event
{
public:
  Delete_rows_event(const char *buf, unsigned int event_len,
                    const Format_description_event *description_event)
    : Rows_event(buf, event_len, description_event)
  {
    this->header()->type_code= m_type;
  }

  Delete_rows_event()
    : Rows_event(DELETE_ROWS_EVENT)
  {}
};
```