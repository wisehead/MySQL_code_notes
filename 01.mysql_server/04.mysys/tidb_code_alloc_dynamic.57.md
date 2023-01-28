#1.alloc_dynamic

```cpp
alloc_dynamic
--if (array->elements == array->max_element)
----new_ptr= (char *) my_malloc(array->m_psi_key,(array->max_element+array->alloc_increment) * array->size_of_element,MYF(MY_WME))))
----memcpy(new_ptr, array->buffer,array->elements * array->size_of_element);
----array->buffer= (uchar*) new_ptr;、
----array->max_element+=array->alloc_increment;
--else
----return array->buffer+(array->elements++ * array->size_of_element);
```