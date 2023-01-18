#1.TianmuTable::LockPackInfoForUse

```
TianmuTable::LockPackInfoForUse
--for (auto &attr : m_attrs) 
----TraceableObject::Lock
----attr->TrackAccess();
------TraceableObject:: TrackAccess
--------Instance()->TrackAccess(this);
----------MemoryHandling::TrackAccess
------------_releasePolicy->Access(o);
--------------
```