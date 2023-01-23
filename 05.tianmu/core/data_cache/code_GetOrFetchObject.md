#1.GetOrFetchObject

```
GetOrFetchObject
--auto &c(cache<U>());
----DataCache::cache
------return _packs
--auto &w(waitIO<U>());
----DataCache::waitIO
------return (_packPendingIO);
--auto &cond(condition<U>());
----DataCache::condition<PackCoordinate>()
------return (_packWaitIO);
--auto it = c.find(coord_);
--auto rit = w.find(coord_);
--while (rit != w.end()) {
----cond.wait(m_obj_guard);
----rit = w.find(coord_);
--it = c.find(coord_);
--w.insert(coord_);
--fetcher_->Fetch(coord_);
----TianmuAttr::Fetch
------dpn = m_share->get_dpn_ptr(pc_dp(pc));
--obj->SetOwner(this);
--c.insert(std::make_pair(coord_, obj));
--w.erase(coord_);
--cond.notify_all();
--return obj;
```

#2.caller

```
TianmuAttr::LockPackForUse
```

#3. PackCoordinate
```cpp
using PackCoordinate = ObjectId<COORD_TYPE::PACK, 3>;
//table, column, data pack
```

#4. PackContainer
```cpp
using PackContainer = std::unordered_map<PackCoordinate, TraceableObjectPtr, PackCoordinate>;
```

#5. IOPackReqSet
```cpp
using IOPackReqSet = std::unordered_set<PackCoordinate, PackCoordinate>;
```