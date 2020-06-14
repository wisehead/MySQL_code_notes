#1.creat table sbtest1


```
mysql> show create table sbtest1;

| sbtest1 | CREATE TABLE `sbtest1` (
  `id` int(10) unsigned NOT NULL DEFAULT '0',
  `k` int(10) unsigned NOT NULL DEFAULT '0',
  `c` char(120) COLLATE utf8_bin NOT NULL DEFAULT '',
  `pad` char(60) COLLATE utf8_bin NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `k_1` (`k`)
) ENGINE=TokuDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin MAX_ROWS=1000000 KEY_BLOCK_SIZE=8 |


-rw-rw---- 1 chenhui chenhui     524288 Jun 13 21:25 _hi_sbtest1_key_k_1_ca83ef3_1_1d_B_1.tokudb
-rw-rw---- 1 chenhui chenhui   20185088 Jun 13 21:25 _hi_sbtest1_main_ca83ef3_1_1d_B_0.tokudb
-rw-rw---- 1 chenhui chenhui      65536 Jun 13 21:24 _hi_sbtest1_status_ca83eed_1_1d.tokudb

```

###