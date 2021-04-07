#1.my_hash_insert

```cpp
my_hash_insert
--empty=(HASH_LINK*) alloc_dynamic(&info->array)
--data=dynamic_element(&info->array,0,HASH_LINK*);//放在array【0】
--halfbuff= info->blength >> 1;
--idx=first_index=info->records-halfbuff;
--if (idx != info->records)
----do
------pos=data+idx;
------rec_hashnr//取得是idx位置的key的hashnr
--------my_hash_key
----------query_cache_query_get_key
--------calc_hash(hash,key,length)
------if (flag == 0)
--------if (my_hash_mask(hash_nr, info->blength, info->records) != first_index)
----------break;
------if (!(hash_nr & halfbuff))//第二条逻辑
--------if (!(flag & LOWFIND))
----------if (flag & HIGHFIND)
----------else
------------flag=LOWFIND | LOWUSED;//第二条逻辑
------------gpos=pos;
------------ptr_to_rec=pos->data;
--------else//第三条逻辑
----------if (!(flag & HIGHFIND))
----------else
------------if (!(flag & HIGHUSED))
------------gpos2=pos;
------------ptr_to_rec2=pos->data;
----while ((idx=pos->next) != NO_RECORD);
----if ((flag & (LOWFIND | LOWUSED)) == LOWFIND)
----if ((flag & (HIGHFIND | HIGHUSED)) == HIGHFIND)
--idx= my_hash_mask(rec_hashnr(info, record), info->blength, info->records + 1);
----if ((hashnr & (buffmax-1)) < maxlength) return (hashnr & (buffmax-1));
----return (hashnr & ((buffmax >> 1) -1));
--if (pos == empty)//第一条插入走这个逻辑
----pos->data=(uchar*) record;
----pos->next=NO_RECORD;
--else
----empty[0]=pos[0];//拷贝
----gpos= data + my_hash_rec_mask(info, pos, info->blength, info->records + 1);
------key= (uchar*) my_hash_key(hash, pos->data, &length, 0)
------my_hash_mask(calc_hash(hash, key, length), buffmax, maxlength)
----if (pos == gpos)//第二条SQL走这个逻辑，头插法。
------pos->data=(uchar*) record;
------pos->next=(uint) (empty - data);
----else
------pos->data=(uchar*) record;
------pos->next=NO_RECORD;
------movelink(data,(uint) (pos-data),(uint) (gpos-data),(uint) (empty-data))
--if (++info->records == info->blength)
----info->blength+= info->blength;
```

