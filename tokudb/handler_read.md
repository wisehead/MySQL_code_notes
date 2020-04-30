#1 ha_tokudb::get_next

```CPP
ha_tokudb::get_next
--c_getf_next
----toku_ft_cursor_next
------ft_search_init
------ft_cursor_search
--------toku_ft_search//?????
------ft_search_finish

```

#2 toku_ft_search(tokuFT kv interface)

```cpp
    //
    // Here is how searches work
    // At a high level, we descend down the tree, using the search parameter
    // to guide us towards where to look. But the search parameter is not
    // used here to determine which child of a node to read (regardless
    // of whether that child is another node or a basement node)
    // The search parameter is used while we are pinning the node into
    // memory, because that is when the system needs to ensure that
    // the appropriate partition of the child we are using is in memory.
    // So, here are the steps for a search (and this applies to this function
    // as well as ft_search_child:
    //  - Take the search parameter, and create a ftnode_fetch_extra, that will be used by toku_pin_ftnode
    //  - Call toku_pin_ftnode with the bfe as the extra for the fetch callback (in case the node is not at all in memory)
    //       and the partial fetch callback (in case the node is perhaps partially in memory) to the fetch the node
    //  - This eventually calls either toku_ftnode_fetch_callback or  toku_ftnode_pf_req_callback depending on whether the node is in
    //     memory at all or not.
    //  - Within these functions, the "ft_search search" parameter is used to evaluate which child the search is interested in.
    //     If the node is not in memory at all, toku_ftnode_fetch_callback will read the node and decompress only the partition for the
    //     relevant child, be it a message buffer or basement node. If the node is in memory, then toku_ftnode_pf_req_callback
    //     will tell the cachetable that a partial fetch is required if and only if the relevant child is not in memory. If the relevant child
    //     is not in memory, then toku_ftnode_pf_callback is called to fetch the partition.
    //  - These functions set bfe->child_to_read so that the search code does not need to reevaluate it.
    //  - Just to reiterate, all of the last item happens within toku_ftnode_pin(_holding_lock)
    //  - At this point, toku_ftnode_pin_holding_lock has returned, with bfe.child_to_read set,
    //  - ft_search_node is called, assuming that the node and its relevant partition are in memory.
    //
    
    
toku_ft_search
--toku_pin_ftnode
----toku_pin_ftnode_with_dep_nodes
------toku_ftnode_pf_callback//partial fetch callback function :
------toku_cachetable_get_and_pin_with_dep_pairs
--------pair_list::find_pair
--------try_pin_pair
----------do_partial_fetch
------------pf_callback//toku_ftnode_pf_callback
--------------toku_deserialize_bp_from_disk
----------------block_table::translate_blocknum_to_offset_size
----------------toku_os_pread
----------------read_compressed_sub_block
----------------toku_decompress
--------------toku_deserialize_bp_from_compressed//一般都会压缩
----------------SUB_BLOCK curr_sb = BSB(node, childnum);
----------------setup_available_ftnode_partition
----------------toku_decompress
--------------ft_status_update_partial_fetch_reason
------toku_move_ftnode_messages_to_stale
--------toku_ft_bnc_move_messages_to_stale
----------bnc->fresh_message_tree.delete_all_marked

```