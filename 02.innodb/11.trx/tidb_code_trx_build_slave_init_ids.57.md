#1.trx_build_slave_init_ids

```cpp
trx_build_slave_init_ids
--for (trx_ids_t::iterator it = trx_sys->rw_trx_ids.begin();it != trx_sys->rw_trx_ids.end();it++)
----trx = trx_get_rw_trx_by_id(*it);
------trx_sys->rw_trx_sets[partition].find(TrxTrack(trx_id));
----if (trx == NULL)//The trx id has been reserved just right now, 还没来得及创建trx对象，只是分配了trx_id
------ids->insert(*it);
----else//trx != NULL
------if (trx->phy_commit) // True if the transaction finish its commit log and ready to write it to log buffer */
--------if (trx->phy_commit_lsn > start_lsn)//后面回放的时候会去掉
----------ids->insert(*it);
----------trx_no = trx->no;
--------else //trx->phy_commit_lsn <= start_lsn
----------if (!gtid_trx || trx->phy_commit_lsn > gtid_trx->phy_commit_lsn)
------------gtid_persister_sys->get_gtid_info(gtid_trx, gtid_desc);
------------memcpy(gtid, &gtid_desc.m_info[0], TRX_UNDO_LOG_GTID_LEN);
------else // /*if (trx->phy_commit)*/ phy_commit=false，日志还没有准备好，肯定是active
--------ids->insert(*it);
--------trx_no = trx->no;//trx_no只要最新值
                /* The trx_no has three possible candidates:
                1. "TRX_ID_MAX" means the trx->no is not assigned or
                trx id should not be added into the initial ids.
                2. "trx->id" means the trx may come from the recovery phase.
                3. "trx->no" means it is an assigned no. */
----if (trx_no != TRX_ID_MAX)
------ids->insert(trx_no);
```

#2.ncdb_get_info_for_slave_startup

```cpp
caller: ncdb_get_info_for_slave_startup
```