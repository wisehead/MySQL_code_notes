#1.TianmuAttr::UnlockPackFromUse

```
TianmuAttr::UnlockPackFromUse
--dpn = &get_dpn(pn);
--v = dpn->GetPackPtr();
--do {
----newv = v - tag_one;
----if ((v & ~tag_mask) == tag_one)
------newv = 0;
--while (!dpn->CAS(v, newv));
--if (newv == 0) {
----auto ap = reinterpret_cast<Pack *>(v & tag_mask);
----ap->Unlock();
------TraceableObject::Unlock
```

#2.TraceableObject::Unlock

```
TraceableObject::Unlock
--m_lock_count--;
--if (m_lock_count < 0) {
----m_lock_count = 0;
```