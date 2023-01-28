#1.LF_PINS

```cpp
typedef struct st_lf_pins {
  void * volatile pin[LF_PINBOX_PINS];
  LF_PINBOX *pinbox;
  void  *purgatory;
  uint32 purgatory_count;
  uint32 volatile link;
/* we want sizeof(LF_PINS) to be 64 to avoid false sharing */
#if SIZEOF_INT*2+SIZEOF_CHARP*(LF_PINBOX_PINS+2) != 64
  char pad[64-sizeof(uint32)*2-sizeof(void*)*(LF_PINBOX_PINS+2)];
#endif
} LF_PINS;
```