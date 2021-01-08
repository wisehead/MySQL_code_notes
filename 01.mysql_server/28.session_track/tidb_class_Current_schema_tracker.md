#1.class Current_schema_tracker

```cpp
/**
  Current_schema_tracker
  ----------------------
  This is a tracker class that enables & manages the tracking of current
  schema for a particular connection.
*/

class Current_schema_tracker : public State_tracker
{
private:
  bool schema_track_inited;
  void reset();

public:

  /** Constructor */
  Current_schema_tracker()
  {
    schema_track_inited= false;
  }

  bool enable(THD *thd)
  { return update(thd); }
  bool check(THD *thd, set_var *var)
  { return false; }
  bool update(THD *thd);
  bool store(THD *thd, String &buf);
  void mark_as_changed(THD *thd, LEX_CSTRING *tracked_item_name);
};
```


#2.Current_schema_tracker::store

```cpp
/**
  @brief Store the schema name as length-encoded string in the specified
         buffer.  Once the data is stored, we reset the flags related to
         state-change (see reset()).


  @param thd [IN]           The thd handle.
  @paran buf [INOUT]        Buffer to store the information to.

  @return
    false                   Success
    true                    Error
*/
Current_schema_tracker::store
--to= (uchar *) buf.prep_append(net_length_size(length) + 1,EXTRA_ALLOC);
--net_store_length(to, (ulonglong)SESSION_TRACK_SCHEMA);
--net_store_length(to, length);
--net_store_length(to, db_length);
--store_lenenc_string(buf, thd->db().str, thd->db().length);
```