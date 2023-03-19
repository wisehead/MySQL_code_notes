#3.scan_fields

```
scan_fields
--while ((item = li++)) 
----item_type = item->type();
----buf_lens[item_id] = 0;
----switch (item_type) {
------case Item::FIELD_ITEM: {  // regular select
--------ifield = (Item_field *)item;
--------f = ifield->result_field;
--------auto iter_uf = used_fields.find((size_t)f);
--------if (iter_uf == used_fields.end()) {
          used_fields.insert((size_t)f);
          field_length = f->pack_length();
          buf_lens[item_id] = field_length;
          total_length += field_length;
----item_id++;
--while ((item = li++)) 
----item_type = item->type();
```