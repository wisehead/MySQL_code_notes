#1.query cache

```cpp
/*
  Description of the query cache:

1. Query_cache object consists of
    - query cache memory pool (cache)
    - queries hash (queries)
    - tables hash (tables)
    - list of blocks ordered as they allocated in memory
(first_block)
    - list of queries block (queries_blocks)
    - list of used tables (tables_blocks)

2. Query cache memory pool (cache) consists of
    - table of steps of memory bins allocation
    - table of free memory bins
    - blocks of memory

3. Memory blocks

Every memory block has the following structure:

+----------------------------------------------------------+
|      Block header (Query_cache_block structure)          |
+----------------------------------------------------------+
|Table of database table lists (used for queries & tables) |
+----------------------------------------------------------+
|         Type depended header                             |
|(Query_cache_query, Query_cache_table, Query_cache_result)|
+----------------------------------------------------------+
|           Data ...                                       |
+----------------------------------------------------------+

Block header consists of:
- type:
  FREE      Free memory block
  QUERY     Query block
  RESULT    Ready to send result
  RES_CONT  Result's continuation
  RES_BEG   First block of results, that is not yet complete,
        written to cache
  RES_INCOMPLETE  Allocated for results data block
  TABLE     Block with database table description
  INCOMPLETE    The destroyed block
- length of block (length)
- length of data & headers (used)
- physical list links (pnext/pprev) - used for the list of
  blocks ordered as they are allocated in physical memory
- logical list links (next/prev) - used for queries block list, tables block
  list, free memory block lists and list of results block in query
- number of elements in table of database table list (n_tables)

4. Query & results blocks

Query stored in cache consists of following blocks:

more                  more
recent+-------------+ old
<-----|Query block 1|------> double linked list of queries block
 prev |             | next
      +-------------+
    <-|  table 0    |-> (see "Table of database table lists" description)
    <-|  table 1    |->
      |  ...        |           +--------------------------+
      +-------------+    +-------------------------+       |
NET   |             |    |      V                  V       |
struct|             |    +-+------------+   +------------+ |
<-----|query header |----->|Result block|-->|Result block|-+ doublelinked
writer|             |result|            |<--|            |   list of results
      +-------------+      +------------+   +------------+
      |charset      |      +------------+   +------------+ no table of dbtables
      |encoding +   |      |   result   |   |   result   |
      |query text   |<-----|   header   |   |   header   |------+
      +-------------+parent|            |   |            |parent|
            ^              +------------+   +------------+      |
            |              |result data |   |result data |      |
            |              +------------+   +------------+      |
            +---------------------------------------------------+

First query is registered. During the registration query block is
allocated. This query block is included in query hash and is linked
with appropriate database tables lists (if there is no appropriate
list exists it will be created).

Later when query has performed results is written into the result blocks.
A result block cannot be smaller then QUERY_CACHE_MIN_RESULT_DATA_SIZE.

When new result is written to cache it is appended to the last result
block, if no more  free space left in the last block, new block is
allocated.

5. Table of database table lists.

For quick invalidation of queries all query are linked in lists on used
database tables basis (when table will be changed (insert/delete/...)
this queries will be removed from cache).

Root of such list is table block:

     +------------+       list of used tables (used while invalidation of
<----|  Table     |-----> whole database)
 prev|  block     |next                      +-----------+
     |            |       +-----------+      |Query block|
     |            |       |Query block|      +-----------+
     +------------+       +-----------+      | ...       |
  +->| table 0    |------>|table 0    |----->| table N   |---+
  |+-|            |<------|           |<-----|           |<-+|
  || +------------+       | ...       |      | ...       |  ||
  || |table header|       +-----------+      +-----------+  ||
  || +------------+       | ...       |      | ...       |  ||
  || |db name +   |       +-----------+      +-----------+  ||
  || |table name  |                                         ||
  || +------------+                                         ||
  |+--------------------------------------------------------+|
  +----------------------------------------------------------+

Table block is included into the tables hash (tables).

6. Free blocks, free blocks bins & steps of freeblock bins.

When we just started only one free memory block  existed. All query
cache memory (that will be used for block allocation) were
containing in this block.
When a new block is allocated we find most suitable memory block
(minimal of >= required size). If such a block can not be found, we try
to find max block < required size (if we allocate block for results).
If there is no free memory, oldest query is removed from cache, and then
we try to allocate memory. Last step should be repeated until we find
suitable block or until there is no unlocked query found.

If the block is found and its length more then we need, it should be
split into 2 blocks.
New blocks cannot be smaller then min_allocation_unit_bytes.

When a block becomes free, its neighbor-blocks should be tested and if
there are free blocks among them, they should be joined into one block.

Free memory blocks are stored in bins according to their sizes.
The bins are stored in size-descending order.
These bins are distributed (by size) approximately logarithmically.

First bin (number 0) stores free blocks with
size <= query_cache_size>>QUERY_CACHE_MEM_BIN_FIRST_STEP_PWR2.
It is first (number 0) step.
On the next step distributed (1 + QUERY_CACHE_MEM_BIN_PARTS_INC) *
QUERY_CACHE_MEM_BIN_PARTS_MUL bins. This bins allocated in interval from
query_cache_size>>QUERY_CACHE_MEM_BIN_FIRST_STEP_PWR2 to
query_cache_size>>QUERY_CACHE_MEM_BIN_FIRST_STEP_PWR2 >>
QUERY_CACHE_MEM_BIN_STEP_PWR2
...
On each step interval decreases in 2 power of
QUERY_CACHE_MEM_BIN_STEP_PWR2
times, number of bins (that distributed on this step) increases. If on
the previous step there were N bins distributed , on the current there
would be distributed
(N + QUERY_CACHE_MEM_BIN_PARTS_INC) * QUERY_CACHE_MEM_BIN_PARTS_MUL
bins.
Last distributed bin stores blocks with size near min_allocation_unit
bytes.

For example:
        query_cache_size>>QUERY_CACHE_MEM_BIN_FIRST_STEP_PWR2 = 100,
        min_allocation_unit = 17,
        QUERY_CACHE_MEM_BIN_STEP_PWR2 = 1,
        QUERY_CACHE_MEM_BIN_PARTS_INC = 1,
        QUERY_CACHE_MEM_BIN_PARTS_MUL = 1
        (in followed picture showed right (low) bound of bin):

      |       100>>1     50>>1        |25>>1|
      |          |         |          |  |  |
      | 100  75 50  41 33 25  21 18 15| 12  | -  bins right (low) bounds

      |\---/\-----/\--------/\--------|---/ |
      |  0     1        2          3  |     | - steps
       \-----------------------------/ \---/
        bins that we store in cache     this bin showed for example only


Calculation of steps/bins distribution is performed only when query cache
is resized.

When we need to find appropriate bin, first we should find appropriate
step, then we should calculate number of bins that are using data
stored in Query_cache_memory_bin_step structure.

Free memory blocks are sorted in bins in lists with size-ascending order
(more small blocks needed frequently then bigger one).

7. Packing cache.

Query cache packing is divided into two operation:
        - pack_cache
        - join_results

pack_cache moved all blocks to "top" of cache and create one block of free
space at the "bottom":

 before pack_cache    after pack_cache
 +-------------+      +-------------+
 | query 1     |      | query 1     |
 +-------------+      +-------------+
 | table 1     |      | table 1     |
 +-------------+      +-------------+
 | results 1.1 |      | results 1.1 |
 +-------------+      +-------------+
 | free        |      | query 2     |
 +-------------+      +-------------+
 | query 2     |      | table 2     |
 +-------------+ ---> +-------------+
 | table 2     |      | results 1.2 |
 +-------------+      +-------------+
 | results 1.2 |      | results 2   |
 +-------------+      +-------------+
 | free        |      | free        |
 +-------------+      |             |
 | results 2   |      |             |
 +-------------+      |             |
 | free        |      |             |
 +-------------+      +-------------+

pack_cache scan blocks in physical address order and move every non-free
block "higher".

pack_cach remove every free block it finds. The length of the deleted block
is accumulated to the "gap". All non free blocks should be shifted with the
"gap" step.

join_results scans all complete queries. If the results of query are not
stored in the same block, join_results tries to move results so, that they
are stored in one block.

 before join_results  after join_results
 +-------------+      +-------------+
 | query 1     |      | query 1     |
 +-------------+      +-------------+
 | table 1     |      | table 1     |
 +-------------+      +-------------+
 | results 1.1 |      | free        |
 +-------------+      +-------------+
 | query 2     |      | query 2     |
 +-------------+      +-------------+
 | table 2     |      | table 2     |
 +-------------+ ---> +-------------+
 | results 1.2 |      | free        |
 +-------------+      +-------------+
 | results 2   |      | results 2   |
 +-------------+      +-------------+
 | free        |      | results 1   |
 |             |      |             |
 |             |      +-------------+
 |             |      | free        |
 |             |      |             |
 +-------------+      +-------------+

If join_results allocated new block(s) then we need call pack_cache again.

8. Interface
The query cache interfaces with the rest of the server code through 7
functions:
 1. Query_cache::send_result_to_client
       - Called before parsing and used to match a statement with the stored
         queries hash.
         If a match is found the cached result set is sent through repeated
         calls to net_write_packet. (note: calling thread doesn't have a regis-
         tered result set writer: thd->net.query_cache_query=0)
 2. Query_cache::store_query
       - Called just before handle_select() and is used to register a result
         set writer to the statement currently being processed
         (thd->net.query_cache_query).
 3. query_cache_insert
       - Called from net_write_packet to append a result set to a cached query
         if (and only if) this query has a registered result set writer
         (thd->net.query_cache_query).
 4. Query_cache::invalidate
    Query_cache::invalidate_locked_for_write
       - Called from various places to invalidate query cache based on data-
         base, table and myisam file name. During an on going invalidation
         the query cache is temporarily disabled.
 5. Query_cache::flush
       - Used when a RESET QUERY CACHE is issued. This clears the entire
         cache block by block.
 6. Query_cache::resize
       - Used to change the available memory used by the query cache. This
         will also invalidate the entrie query cache in one free operation.
 7. Query_cache::pack
       - Used when a FLUSH QUERY CACHE is issued. This changes the order of
         the used memory blocks in physical memory order and move all avail-
         able memory to the 'bottom' of the memory.


TODO list:

  - Delayed till after-parsing qache answer (for column rights processing)
  - Optimize cache resizing
      - if new_size < old_size then pack & shrink
      - if new_size > old_size copy cached query to new cache
  - Move MRG_MYISAM table type processing to handlers, something like:
        tables_used->table->file->register_used_filenames(callback,
                                                          first_argument);
  - QC improvement suggested by Monty:
    - Add a counter in open_table() for how many MERGE (ISAM or MyISAM)
      tables are cached in the table cache.
      (This will be trivial when we have the new table cache in place I
      have been working on)
    - After this we can add the following test around the for loop in
      is_cacheable::

      if (thd->temp_tables || global_merge_table_count)

    - Another option would be to set thd->lex->safe_to_cache_query to 0
      in 'get_lock_data' if any of the tables was a tmp table or a
      MRG_ISAM table.
      (This could be done with almost no speed penalty)
*/
```