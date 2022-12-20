#<center>JOIN</center>

#1.class JOIN

```cpp
//sql_optimizer.h

class JOIN :public Sql_alloc
{
}
```

#2.JOIN::optimize

```cpp
/**
  global select optimisation.

  @note
    error code saved in field 'error'

  @retval
    0   success
  @retval
    1   error
*/

int
JOIN::optimize()
```

