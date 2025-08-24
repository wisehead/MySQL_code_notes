#1.class SQL_I_List

```cpp
/**
  Simple intrusive linked list.

  @remark Similar in nature to base_list, but intrusive. It keeps a
          a pointer to the first element in the list and a indirect
          reference to the last element.
*/
template <typename T>
class SQL_I_List :public Sql_alloc
{
public:
  uint elements;
  /** The first element in the list. */
  T *first;
  /** A reference to the next element in the list. */
  T **next;

  SQL_I_List() { empty(); }

  SQL_I_List(const SQL_I_List &tmp) : Sql_alloc()
  {
    elements= tmp.elements;
    first= tmp.first;
    next= elements ? tmp.next : &first;
  }

  inline void empty()
  {
    elements= 0;
    first= NULL;
    next= &first;
  }

  inline void link_in_list(T *element, T **next_ptr)
  {
    elements++;
    (*next)= element;
    next= next_ptr;
    *next= NULL;
  }

  inline void save_and_clear(SQL_I_List<T> *save)
  {
    *save= *this;
    empty();
  }

  inline void push_front(SQL_I_List<T> *save)
  {
    /* link current list last */
    *save->next= first;
    first= save->first;
    elements+= save->elements;
  }

  inline void push_back(SQL_I_List<T> *save)
  {
    if (save->first)
    {
      *next= save->first;
      next= save->next;
      elements+= save->elements;
    }
  }
};



```