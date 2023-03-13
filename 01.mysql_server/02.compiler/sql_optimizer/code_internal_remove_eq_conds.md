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
------if (new_item == NULL)
--------case Item::Type::FUNC_ITEM:
----------const Item_func::Functype& func_type = item_func->functype();
----------switch (func_type)
------------case Item_func::Functype::EQ_FUNC:
          case Item_func::Functype::EQUAL_FUNC:
          case Item_func::Functype::NE_FUNC:
          case Item_func::Functype::GT_FUNC:
          case Item_func::Functype::GE_FUNC:
          case Item_func::Functype::LT_FUNC:
          case Item_func::Functype::LE_FUNC:
--------------check_value = true;
--------------Item_bool_func2* func = down_cast<Item_bool_func2*>(item);
--------------Item** args = func->arguments();
--------------args[0]->val_str(&left_value);
--------------args[1]->val_str(&right_value);
--------------break;
------------switch (func_type)
--------------case Item_func::Functype::EQ_FUNC:
----------------cond_replace = true;
----------------cond_value_equivalent = !stringcmp(&left_value, &right_value);
------------if (cond_replace)
        {
          if ((or_level && cond_value_equivalent)
            || (and_level && (!cond_value_equivalent)))
          {
            *cond_value = Item::COND_OK;
            *retcond = NULL;
            return false;
------//end if (new_item == NULL)
------else if (item != new_item)
--------//do nothing
------switch (tmp_cond_value)
--------case Item::COND_OK:                       // Not TRUE or FALSE
        if (and_level || *cond_value == Item::COND_FALSE)
          *cond_value= tmp_cond_value;
        break;
--else if (cond->type() == Item::FUNC_ITEM &&
           down_cast<Item_func *>(cond)->functype() == Item_func::ISNULL_FUNC)
----//do nothing
--else if (cond->const_item() && !cond->is_expensive())
----if (eval_const_cond(thd, cond, &value))
      return true;
----*cond_value= value ? Item::COND_TRUE : Item::COND_FALSE;
----*retcond= NULL;
----return false;
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