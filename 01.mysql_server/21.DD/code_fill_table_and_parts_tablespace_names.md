#1.fill_table_and_parts_tablespace_names

```cpp
fill_table_and_parts_tablespace_names
--Dictionary_client::acquire//dd::cache::Dictionary_client::acquire<dd::Table>
----Dictionary_client::acquire//dd::cache::Dictionary_client::acquire<dd::Schema>
------Dictionary_client::acquire//dd::cache::Dictionary_client::acquire<dd::Item_name_key, dd::Schema>
--------Dictionary_client::acquire_uncommitted//acquire_uncommitted(key, &uncommitted_object, &dropped);
--------m_registry_committed.get(key, &element);
--------Shared_dictionary_cache::get
----dd::cache::Dictionary_client::acquire<dd::Item_name_key, dd::Abstract_table>

```