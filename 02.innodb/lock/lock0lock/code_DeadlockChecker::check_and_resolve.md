#1.DeadlockChecker::check_and_resolve

```cpp
/** Checks if a joining lock request results in a deadlock. If a deadlock isfound
this function will resolve the deadlockby choosing
a victim transactionand rolling it back. It will attempt to resolve all
deadlocks. The returnedtransaction idwill be the joining
transaction instance or NULL if some othertransaction was chosen as a victim and
rolled back or no deadlock found.
@param lock lock the transaction is requesting  //参数：准备申请的锁
@param trxtransaction requesting the lock       //参数：准备申请锁的事务
@return transaction instanace chosen as victim or 0 */
const trx_t*
DeadlockChecker::check_and_resolve(const lock_t* lock, const trx_t* trx)
{...
    /* Try and resolve as many deadlocks as possible. */
    do {
        DeadlockCheckerchecker(trx, lock, s_lock_mark_counter);
        //通用的死锁检测类，每轮循环都构造一个新的DeadlockChecker对象
        victim_trx = checker.search(); //从持锁者所在的锁队列中进行深度遍历，找出一个受害者。
        //search()内部实现是一个循环，自身又处于一个循环中，所以可能很耗时
        /* Search too deep, we rollback the joining transaction onlyif it is
          possible to rollback. Otherwise we rollback the
           transaction that is holding the lock that the joiningtransaction wants. */
        if (checker.is_too_deep()) { //如果暂时没有找到，而又陷入太深的层次（因深度遍
        历），则不再寻找，可能挑选当前事务为受害者
            ut_ad(trx == checker.m_start);
            victim_trx = trx_arbitrate(trx, checker.m_wait_lock->trx);
            //上一节对此函数有分析
            if (victim_trx == NULL) {
                victim_trx = trx;  //暂时没有找到受害者挑选当前事务为受害者
            }
            rollback_print(victim_trx, lock);
            MONITOR_INC(MONITOR_DEADLOCK);
            break;
        } else if (victim_trx != 0 && victim_trx != trx) {  //找到的受害者不是当前事务，则
            ut_ad(victim_trx == checker.m_wait_lock->trx);
            checker.trx_rollback();  //把受害者事务回滚掉
            lock_deadlock_found = true;
            MONITOR_INC(MONITOR_DEADLOCK);
        }
    } while (victim_trx != NULL && victim_trx != trx); //循环遍历，直到找到受害者为止
...
}

```