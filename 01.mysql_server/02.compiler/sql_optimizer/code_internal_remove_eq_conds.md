#1.internal_remove_eq_conds

```
internal_remove_eq_conds
--if (cond->type() == Item::COND_ITEM)
----Item_cond *const item_cond= down_cast<Item_cond *>(cond);
    const auto& item_func_type = item_cond->functype();
    const bool and_level = Item_func::COND_AND_FUNC == item_func_type;
    const bool or_level = Item_func::COND_OR_FUNC == item_func_type;
----while ((item=li++))
------if (internal_remove_eq_conds(thd, item, &new_item, &tmp_cond_value, phase))
--------return true;
--else if (cond->type() == Item::FUNC_ITEM &&
           down_cast<Item_func *>(cond)->functype() == Item_func::ISNULL_FUNC)
----//do nothing
--else if (cond->const_item() && !cond->is_expensive())
----//do nothing
--else
----*cond_value= cond->eq_cmp_result();
------return COND_OK; 
----Item *left_item= down_cast<Item_func *>(cond)->arguments()[0];
----Item *right_item= down_cast<Item_func *>(cond)->arguments()[1];
----if (left_item->eq(right_item,1))//Item_field::eq
------Item *real_item= ((Item *) item)->real_item();
--*cond_value= Item::COND_OK;
--*retcond= cond;                               // Point at next and level
```