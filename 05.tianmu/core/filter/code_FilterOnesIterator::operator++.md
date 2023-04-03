#1.FilterOnesIterator::operator++

```
FilterOnesIterator::operator++
--if (IsEndOfBlock()) {
----if (!IteratorBpp()) {
------valid = false;
------return *this;
```