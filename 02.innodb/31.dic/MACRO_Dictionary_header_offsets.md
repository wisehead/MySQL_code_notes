#1. Dictionary header offsets
```cpp
/*-------------------------------------------------------------*/
/* Dictionary header offsets */
#define DICT_HDR_ROW_ID     0   /* The latest assigned row id */
#define DICT_HDR_TABLE_ID   8   /* The latest assigned table id */
#define DICT_HDR_INDEX_ID   16  /* The latest assigned index id */
#define DICT_HDR_MAX_SPACE_ID   24  /* The latest assigned space id,or 0*/
#define DICT_HDR_MIX_ID_LOW 28  /* Obsolete,always DICT_HDR_FIRST_ID*/
#define DICT_HDR_TABLES     32  /* Root of SYS_TABLES clust index */
#define DICT_HDR_TABLE_IDS  36  /* Root of SYS_TABLE_IDS sec index */
#define DICT_HDR_COLUMNS    40  /* Root of SYS_COLUMNS clust index */
#define DICT_HDR_INDEXES    44  /* Root of SYS_INDEXES clust index */
#define DICT_HDR_FIELDS     48  /* Root of SYS_FIELDS clust index */

#define DICT_HDR_FSEG_HEADER    56  /* Segment header for the tab#lespace
                    segment into which the dictionary
                    header is created */
/*-------------------------------------------------------------*/
```
