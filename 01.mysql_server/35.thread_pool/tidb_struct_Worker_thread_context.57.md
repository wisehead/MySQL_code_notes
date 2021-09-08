#1.Worker_thread_context

```cpp
/*
  Worker threads contexts, and THD contexts.
  =========================================

  Both worker threads and connections have their sets of thread local variables
  At the moment it is PSI per-client structure, and THR_KEY_mysys variables.

  Whenever query is executed following needs to be done:

  1. Save worker thread context.
  2. Change TLS variables to connection specific ones using thread_attach(THD*).
     This function does some additional work, e.g setting up
     thread_stack/thread_ends_here pointers.
  3. Process query
  4. Restore worker thread context.

  Connection login and termination follows similar schema w.r.t saving and
  restoring contexts.
*/
struct Worker_thread_context
{
#ifdef HAVE_PSI_THREAD_INTERFACE
  PSI_thread *psi_thread;
#endif

#ifndef DBUG_OFF
  st_my_thread_var* mysys_var;
#endif

  void save()
  {
#ifdef HAVE_PSI_THREAD_INTERFACE
    psi_thread=  PSI_THREAD_CALL(get_thread)();
#endif

#ifndef DBUG_OFF
    mysys_var= (st_my_thread_var *) pthread_getspecific(THR_KEY_mysys);
#endif
  }

  void restore()
  {
#ifdef HAVE_PSI_THREAD_INTERFACE
    PSI_THREAD_CALL(set_thread)(psi_thread);
#endif

#ifndef DBUG_OFF
    pthread_setspecific(THR_KEY_mysys, mysys_var);
#endif
    pthread_setspecific(THR_THD, 0);
    pthread_setspecific(THR_MALLOC, 0);
  }
};


```