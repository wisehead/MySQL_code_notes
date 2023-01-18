#1.TraceableObject::Lock

```
TraceableObject::Lock
--if (TraceableType() == TO_TYPE::TO_PACK) {
----clearPrefetchUnused();
----if (!IsLocked()) {
------globalFreeable -= m_sizeAllocated;
------globalUnFreeable += m_sizeAllocated;
----m_lock_count++;
    // Locking is done externally
    // if(!((Pack*) this)->IsEmpty() && IsCompressed()) Uncompress();
--} else {
----std::scoped_lock locking_guard(m_locking_mutex);
----m_lock_count++;
--if (m_lock_count == 32766) {
    std::string message =
        "TraceableObject locked too many times. Object type: " + std::to_string((int)this->TraceableType());
    tianmu_control_ << system::lock << message << system::unlock;
    TIANMU_ERROR(message.c_str());
  }
```