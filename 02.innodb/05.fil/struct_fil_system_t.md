#1.struct fil_system_t


```cpp
/** The tablespace memory cache; also the totality of logs (the log
data space) is stored here; below we talk about tablespaces, but also
the ib_logfiles form a 'space' and it is handled here */
struct fil_system_t {
#ifndef UNIV_HOTBACKUP
    ib_mutex_t      mutex;      /*!< The mutex protecting the cache */
#endif /* !UNIV_HOTBACKUP */
    hash_table_t*   spaces;     /*!< The hash table of spaces in the
                    system; they are hashed on the space
                    id */
    hash_table_t*   name_hash;  /*!< hash table based on the space
                    name */
    UT_LIST_BASE_NODE_T(fil_node_t) LRU;
                    /*!< base node for the LRU list of the
                    most recently used open files with no
                    pending i/o's; if we start an i/o on
                    the file, we first remove it from this
                    list, and return it to the start of
                    the list when the i/o ends;
                    log files and the system tablespace are
                    not put to this list: they are opened
                    after the startup, and kept open until
                    shutdown */
    UT_LIST_BASE_NODE_T(fil_space_t) unflushed_spaces;
                    /*!< base node for the list of those
                    tablespaces whose files contain
                    unflushed writes; those spaces have
                    at least one file node where
                    modification_counter > flush_counter */
    ulint       n_open;     /*!< number of files currently open */
    ulint       max_n_open; /*!< n_open is not allowed to exceed
                    this */
    ib_int64_t  modification_counter;/*!< when we write to a file we
                    increment this by one */
    ulint       max_assigned_id;/*!< maximum space id in the existing
                    tables, or assigned during the time
                    mysqld has been up; at an InnoDB
                    startup we scan the data dictionary
                    and set here the maximum of the
                    space id's of the tables there */
    ib_int64_t  tablespace_version;
                    /*!< a counter which is incremented for
                    every space object memory creation;
                    every space mem object gets a
                    'timestamp' from this; in DISCARD/
                    IMPORT this is used to check if we
                    should ignore an insert buffer merge
                    request */
    UT_LIST_BASE_NODE_T(fil_space_t) space_list;
                    /*!< list of all file spaces */
    ibool       space_id_reuse_warned;
                    /* !< TRUE if fil_space_create()
                    has issued a warning about
                    potential space_id reuse */
};
                    
```