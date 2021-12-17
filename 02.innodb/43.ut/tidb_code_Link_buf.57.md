#1.Link_buf<Position>::Link_buf

```cpp
template <typename Position>
Link_buf<Position>::Link_buf(size_t capacity)
    : m_capacity(capacity), m_tail(0) {
  if (capacity == 0) {
    m_links = nullptr;
    return;
  }

  ut_a((capacity & (capacity - 1)) == 0);

  m_links = UT_NEW_ARRAY_NOKEY(std::atomic<Distance>, capacity);

  for (size_t i = 0; i < capacity; ++i) {
    m_links[i].store(0);
  }
}

```

#2.add_link

```cpp
add_link
--index = slot_index(from);
--&slot = m_links[index];
--slot.store(to - from);
```

#3.slot_index

```cpp
slot_index(Position position)
--return position & (m_capacity - 1);
```

#4.next_position(Position position, Position &next)

```cpp
next_position(Position position, Position &next)
--index = slot_index(position);
--&slot = m_links[index];
--distance = slot.load();
--next = position + distance;
```

#5.claim_position(Position position)

```cpp
claim_position(Position position)
--index = slot_index(position);
--&slot = m_links[index];
--slot.store(0);
```