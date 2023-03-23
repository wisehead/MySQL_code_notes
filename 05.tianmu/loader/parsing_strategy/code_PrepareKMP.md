#1.PrepareKMP

```
PrepareKMP
--kmp_next.resize(pattern.length() + 1);
--int b = kmp_next[0] = -1;
--for (int i = 1, lenpat(static_cast<int>(pattern.length())); i <= lenpat; ++i) {
    while ((b > -1) && (pattern[b] != pattern[i - 1])) b = kmp_next[b];
    ++b;
    kmp_next[i] = (pattern[i] == pattern[b]) ? kmp_next[b] : b;
--}
```