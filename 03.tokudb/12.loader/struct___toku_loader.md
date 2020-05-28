#1. __toku_loader

```cpp
typedef struct __toku_loader DB_LOADER;
struct __toku_loader {
  struct __toku_loader_internal *i;
  int (*set_error_callback)(DB_LOADER *loader, void (*error_cb)(DB *db, int i, int err, DBT *key, DBT *val, void *error_extra), void *error_extra);
  int (*set_poll_function)(DB_LOADER *loader, int (*poll_func)(void *extra, float progress), void *poll_extra);
  int (*put)(DB_LOADER *loader, DBT *key, DBT* val);
  int (*close)(DB_LOADER *loader);
  int (*abort)(DB_LOADER *loader);
};
```