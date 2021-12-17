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

#6.advance_tail_until(Stop_condition stop_condition)

```cpp
advance_tail_until(Stop_condition stop_condition)
--position = m_tail.load();
--while (true)
----stop = next_position(position, next);
----if (stop || stop_condition(position, next))
------break;
----claim_position(position);
----position = next;
--if (position > m_tail.load())
----m_tail.store(position);
----return true;
--else
----return false;
```

#7.advance_tail()

```cpp
advance_tail()
--auto stop_condition = [](Position from, Position to) { return (to == from); };
--advance_tail_until(stop_condition);
```

#8.has_space(Position position)

```cpp
has_space
--return tail() + m_capacity > position;
```

#9.validate_no_links(Position begin, Position end)

```cpp
validate_no_links(Position begin, Position end)
--end = std::min(end, begin + m_capacity);
--for (; begin < end; ++begin)
----index = slot_index(begin);
----&slot = m_links[index];
----ut_a(slot.load() == 0);

```
#10.validate_no_links()

```cpp
validate_no_links()
--validate_no_links(0, m_capacity);
```







