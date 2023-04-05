#1.DataCache::DropObject

```
DataCache::DropObject
--auto &c(cache<T>());
--it = c.find(coord_);
--if (it != c.end()) {
----removed = it->second;
----if constexpr (T::ID == COORD_TYPE::PACK) {
------removed->Lock();
----removed->SetOwner(nullptr);
----c.erase(it);
----++m_objectsReleased;
```