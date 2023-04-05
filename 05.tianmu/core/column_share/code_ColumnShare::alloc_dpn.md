#1.ColumnShare::alloc_dpn

```
ColumnShare::alloc_dpn
--for (uint32_t i = 0; i < capacity; i++) {
----if (start[i].used == 1) {
------if (!(start[i].xmax < ha_tianmu_engine_->MinXID()))//newer
--------continue
------ha_tianmu_engine_->cache.DropObject(PackCoordinate(owner->TabID(), col_id, i));
------segs.remove_if([i](const auto &s) { return s.idx == i; });
```