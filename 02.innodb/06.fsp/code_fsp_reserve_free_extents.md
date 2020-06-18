#1.btr_cur_pessimistic_insert

```cpp
btr_cur_pessimistic_insert
--fsp_reserve_free_extents
--fil_space_release_free_extents
```


#2.fsp_reserve_free_extents


#3.fil_space_release_free_extents

```cpp
fil_space_release_free_extents
--
```

#4.Fil_shard::space_create

```cpp
SysTablespace::open_or_create
--gaia_fil_space_create
----Fil_shard::space_create
```