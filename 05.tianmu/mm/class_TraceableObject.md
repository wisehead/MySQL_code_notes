#1.class TraceableObject

```cpp
class TraceableObject {
  friend class core::DataCache;  // from core
  friend class TraceableAccounting;
  friend class ReleaseTracker;
  friend class ReleaseStrategy;
 protected:
  // For release tracking purposes, used by ReleaseTracker and ReleaseStrategy
  TraceableObject *next, *prev;
  ReleaseTracker *tracker;
  static MemoryHandling *m_MemHandling;

  bool m_preUnused;

  static std::atomic_size_t globalFreeable;
  static std::atomic_size_t globalUnFreeable;

  size_t m_sizeAllocated;

  core::DataCache *owner = nullptr;

  std::recursive_mutex &m_locking_mutex;
  core::TOCoordinate m_coord;

 private:
  short m_lock_count = 1;
  static int64_t MemScale2BufSizeLarge(int ms);
  static int64_t MemScale2BufSizeSmall(int ms);
};
    
```