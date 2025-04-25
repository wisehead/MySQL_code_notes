#1.Item_func_conv_charset::val_str

```
Item_func_conv_charset::val_str
--String *arg= args[0]->val_str(str);
--null_value= tmp_value.copy(arg->ptr(), arg->length(), arg->charset(),
                             conv_charset, &dummy_errors);
--return null_value ? 0 : check_well_formed_result(&tmp_value,
                                                   false, // send warning
                                                   true); // truncate                             
```