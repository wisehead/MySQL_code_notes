#1.class Session_state_change_tracker

```cpp
/*
  Session_state_change_tracker
  ----------------------------
  This is a boolean tracker class that will monitor any change that contributes
  to a session state change.
  Attributes that contribute to session state change include:
     - Successful change to System variables
     - User defined variables assignments
     - temporary tables created, altered or deleted
     - prepared statements added or removed
     - change in current database
*/

class Session_state_change_tracker : public State_tracker
{
private:

  void reset();

public:
  Session_state_change_tracker();
  bool enable(THD *thd);
  bool check(THD *thd, set_var *var)
  { return false; }
  bool update(THD *thd);
  bool store(THD *thd, String &buf);
  void mark_as_changed(THD *thd, LEX_CSTRING *tracked_item_name);
  bool is_state_changed(THD*);
  void ensure_enabled(THD *thd)
  {}
};
```