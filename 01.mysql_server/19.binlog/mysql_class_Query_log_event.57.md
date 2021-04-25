#1.Query_log_event

```cpp
/**
  A @Query event is written to the binary log whenever the database is
  modified on the master, unless row based logging is used.

  Query_log_event is created for logging, and is called after an update to the
  database is done. It is used when the server acts as the master.

  Virtual inheritance is required here to handle the diamond problem in
  the class Execute_load_query_log_event.
  The diamond structure is explained in @Excecute_load_query_log_event

  @internal
  The inheritance structure is as follows:

            Binary_log_event
                   ^
                   |
                   |
            Query_event  Log_event
                   \       /
         <<virtual>>\     /
                     \   /
                Query_log_event
  @endinternal
*/
class Query_log_event: public virtual binary_log::Query_event, public Log_event
{
protected:
  Log_event_header::Byte* data_buf;
public:

  /*
    For events created by Query_log_event::do_apply_event (and
    Load_log_event::do_apply_event()) we need the *original* thread
    id, to be able to log the event with the original (=master's)
    thread id (fix for BUG#1686).
  */
  my_thread_id slave_proxy_id;
};
```