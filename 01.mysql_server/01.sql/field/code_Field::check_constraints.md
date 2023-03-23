#1.Field::check_constraints

```
Field::check_constraints
--if (real_maybe_null())
----return TYPE_OK; 
--if (!m_is_tmp_null)
----return TYPE_OK; // If the field was not NULL, we're Ok.
```