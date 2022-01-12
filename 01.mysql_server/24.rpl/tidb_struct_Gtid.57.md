#1.struct Gtid

```cpp
/**
  TODO: Move this structure to libbinlogevents/include/control_events.h
        when we start using C++11.
  Holds information about a GTID: the sidno and the gno.

  This is a POD. It has to be a POD because it is part of
  Gtid_specification, which has to be a POD because it is used in
  THD::variables.
*/
struct Gtid
{
  /// SIDNO of this Gtid.
  rpl_sidno sidno;
  /// GNO of this Gtid.
  rpl_gno gno;
};  
```
