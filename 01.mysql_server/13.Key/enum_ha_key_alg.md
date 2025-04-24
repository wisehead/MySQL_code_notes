#1.enum ha_key_alg

```cpp
	/* Key algorithm types */

enum ha_key_alg {
  HA_KEY_ALG_UNDEF=	0,		/* Not specified (old file) */
  HA_KEY_ALG_BTREE=	1,		/* B-tree, default one          */
  HA_KEY_ALG_RTREE=	2,		/* R-tree, for spatial searches */
  HA_KEY_ALG_HASH=	3,		/* HASH keys (HEAP tables) */
  HA_KEY_ALG_FULLTEXT=	4		/* FULLTEXT (MyISAM tables) */
};

```