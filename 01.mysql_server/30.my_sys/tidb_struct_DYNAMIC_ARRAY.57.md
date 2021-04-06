#1.DYNAMIC_ARRAY

```cpp
typedef struct st_dynamic_array
{
  uchar *buffer;
  uint elements,max_element;
  uint alloc_increment;
  uint size_of_element;
  PSI_memory_key m_psi_key;
} DYNAMIC_ARRAY;
```