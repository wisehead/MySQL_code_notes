#1. class Session_tracker

```cpp
/**
  Session_tracker
  ---------------
  This class holds an object each for all tracker classes and provides
  methods necessary for systematic detection and generation of session
  state change information.
*/

class Session_tracker
{
private:
  State_tracker *m_trackers[SESSION_TRACKER_END + 1];



};
  
```