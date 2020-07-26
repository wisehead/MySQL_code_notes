#1.struct TABLE

```cpp
//sql/table.h

struct TABLE
{
  TABLE_SHARE   *s;
  handler   *file;
  TABLE *next, *prev;

public:

  THD   *in_use;                        /* Which thread uses this */
  Field **field;            /* Pointer to fields */
 ...
 ... 
}
```