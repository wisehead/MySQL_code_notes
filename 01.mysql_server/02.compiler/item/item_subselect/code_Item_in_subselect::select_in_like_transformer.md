#1.Item_in_subselect::select_in_like_transformer

```cpp
/*
select_in_like_transformer函数用于对带有IN谓词的子查询进行优化。

对于没有FROM子句的简单SELECT，MySQL交给Item_singlerow_subselect类的select_transformer函数处理，这不在本函数的处理范围之内。
*/

Item_subselect::trans_res
Item_in_subselect::select_in_like_transformer(JOIN *join, Comp_creator *func)
{...
        if (!optimizer)//如果子查询对应的优化类不存在,创建一个对应的优化类型对象
        {
                Prepared_stmt_arena_holder ps_arena_holder(thd);
                optimizer= new Item_in_optimizer(left_expr, this);
                if (!optimizer)
                        goto err;
        }
        thd-＞lex-＞current_select= current-＞outer_select();
        result= (!left_expr-＞fixed && left_expr-＞fix_fields(thd, optimizer-＞arguments()));
...
        if (left_expr-＞cols() == 1)/* 如果IN谓词的左操作数只有一列,则认为是标量IN子查询(MySQL称为：Scalar IN Subquery) */
                res= single_value_transformer(join, func);
        else
        {
                /* we do not support row operation for ALL/ANY/SOME */
                if (func != &eq_creator)
                {…
                        my_error(ER_OPERAND_COLUMNS, MYF(0), 1);
                        DBUG_RETURN(RES_ERROR);
                }
                res= row_value_transformer(join); /* 如果IN谓词的左操作数不是只有一列,则认为是行式IN子查询(MySQL称为：Row IN Subquery) */
}
...
}

```

