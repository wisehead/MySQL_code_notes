#1.Engine::ProcessDeltaStoreMerge

```
Engine::ProcessDeltaStoreMerge
--DistributeLoad
----for (auto &it : tm) {
------res.insert(ha_tianmu_engine_->bg_load_thread_pool.add_task(HandleDelayedLoad, it.first, std::ref(it.second)));
```

#2.caller

```
Engine::Init
--m_load_thread = std::thread([this] { ProcessInsertBufferMerge(); });
--m_merge_thread = std::thread([this] { ProcessDeltaStoreMerge(); });
```