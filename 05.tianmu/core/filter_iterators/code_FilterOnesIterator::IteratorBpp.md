#1.FilterOnesIterator::IteratorBpp

```
FilterOnesIterator::IteratorBpp
--prev_iterator_b = iterator_b;
--if (buffer.Empty()) {
----iterator_b++;
----if (iterator_b >= f->no_blocks)
------return false;
```