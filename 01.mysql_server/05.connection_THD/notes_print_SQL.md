#1.print SQL

```cpp
p thd->m_query_string

(gdb) p thd->m_query_string
$16 = {str = 0x7f3cf02dae78 "alter table \345\220\215\345\255\227 add fulltext index con5 (c2) with parser ngram", length = 65}

```