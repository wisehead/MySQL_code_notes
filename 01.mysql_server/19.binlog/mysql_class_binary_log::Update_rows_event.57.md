#1.Update_rows_event

```cpp
/**
  @class Update_rows_event

  Log row updates with a before image. The event contain several
  update rows for a table. Note that each event contains only rows for
  one table.

  Also note that the row data consists of pairs of row data: one row
  for the old data and one row for the new data.

  @section Update_rows_event_binary_format Binary Format
*/
class Update_rows_event : public virtual Rows_event
{
public:

  Update_rows_event(const char *buf, unsigned int event_len,
                    const Format_description_event *description_event)
    : Rows_event(buf, event_len, description_event)
  {
    this->header()->type_code= m_type;
  }

  Update_rows_event()
    : Rows_event(UPDATE_ROWS_EVENT)
  {}
};
```