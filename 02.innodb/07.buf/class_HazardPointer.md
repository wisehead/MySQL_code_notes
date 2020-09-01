#1.class HazardPointer

```cpp
/** A "Hazard Pointer" class used to iterate over page lists
inside the buffer pool. A hazard pointer is a buf_page_t pointer
which we intend to iterate over next and we want it remain valid
even after we release the buffer pool mutex. */
class HazardPointer {
 public:
  /** Constructor
  @param buf_pool buffer pool instance
  @param mutex  mutex that is protecting the hp. */
  HazardPointer(const buf_pool_t *buf_pool, const ib_mutex_t *mutex)
      : m_buf_pool(buf_pool)
#ifdef UNIV_DEBUG
        ,
        m_mutex(mutex)
#endif /* UNIV_DEBUG */
        ,
        m_hp() {
  }

  /** Destructor */
  virtual ~HazardPointer() {}

  /** Get current value */
  buf_page_t *get() const {
    ut_ad(mutex_own(m_mutex));
    return (m_hp);
  }

  /** Set current value
  @param bpage  buffer block to be set as hp */
  void set(buf_page_t *bpage);

  /** Checks if a bpage is the hp
  @param bpage  buffer block to be compared
  @return true if it is hp */
  bool is_hp(const buf_page_t *bpage);

  /** Adjust the value of hp. This happens when some
  other thread working on the same list attempts to
  remove the hp from the list. Must be implemented
  by the derived classes.
  @param bpage  buffer block to be compared */
  virtual void adjust(const buf_page_t *bpage) = 0;

 protected:
  /** Disable copying */
  HazardPointer(const HazardPointer &);
  HazardPointer &operator=(const HazardPointer &);

  /** Buffer pool instance */
  const buf_pool_t *m_buf_pool;
#ifdef UNIV_DEBUG
  /** mutex that protects access to the m_hp. */
  const ib_mutex_t *m_mutex;
#endif /* UNIV_DEBUG */

  /** hazard pointer. */
  buf_page_t *m_hp;
};
  
```


#2.class LRUHp : public HazardPointer

```cpp
/** Class implementing buf_pool->LRU hazard pointer */
class LRUHp : public HazardPointer {
 public:
  /** Constructor
  @param buf_pool buffer pool instance
  @param mutex  mutex that is protecting the hp. */
  LRUHp(const buf_pool_t *buf_pool, const ib_mutex_t *mutex)
      : HazardPointer(buf_pool, mutex) {}

  /** Destructor */
  virtual ~LRUHp() {}

  /** Adjust the value of hp. This happens when some
  other thread working on the same list attempts to
  remove the hp from the list.
  @param bpage  buffer block to be compared */
  void adjust(const buf_page_t *bpage);
};
```