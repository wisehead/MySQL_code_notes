#1.BString::PersistentCopy

```
BString::PersistentCopy
--null_ = tianmu_s.null_;
--if (null_) {
----//null
--else 
----if (!persistent_ || tmp_len > len_ + pos_) {
------if (persistent_)
        delete[] val_;
------val_ = new char[tmp_len];
----std::memcpy(val_, tianmu_s.val_, len_ + pos_);
--persistent_ = true;
```