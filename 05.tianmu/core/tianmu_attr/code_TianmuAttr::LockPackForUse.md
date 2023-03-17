#1.TianmuAttr::LockPackForUse

```
TianmuAttr::LockPackForUse
--dpn = &get_dpn(pn);
--if (dpn->Trivial() && !dpn->IsLocal())
----return;
--while (true) 
----if (dpn->IncRef())
------return
----if (dpn->CAS(v, loading_flag)) 
------sp = ha_tianmu_engine_->cache.GetOrFetchObject<Pack>(get_pc(pn), this);
------uint64_t newv = reinterpret_cast<unsigned long>(sp.get()) + tag_one;
------uint64_t expected = loading_flag;
------dpn->CAS(expected, newv)
```

#2.IncRef

```cpp
    auto v = tagged_ptr.load();
    while (v != 0 && v != loading_flag)
      if (tagged_ptr.compare_exchange_weak(v, v + tag_one))
        return true;
    return false;
```