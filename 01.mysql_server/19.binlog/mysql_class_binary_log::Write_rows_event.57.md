#1.Write_rows_event

```cpp
/**
  @class Write_rows_event

  Log row insertions. The event contain several  insert/update rows
  for a table. Note that each event contains only  rows for one table.

  @section Write_rows_event_binary_format Binary Format
*/
class Write_rows_event : public virtual Rows_event
{
public:

  Write_rows_event(const char *buf, unsigned int event_len,
                   const Format_description_event *description_event)
    : Rows_event(buf, event_len, description_event)
  {
    this->header()->type_code= m_type;
  };

  Write_rows_event()
    : Rows_event(WRITE_ROWS_EVENT)
  {}
};
```