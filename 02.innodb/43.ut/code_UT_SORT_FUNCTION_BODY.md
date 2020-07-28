#1.UT_SORT_FUNCTION_BODY

```cpp
#define UT_SORT_FUNCTION_BODY(SORT_FUN, ARR, AUX_ARR, LOW, HIGH, CMP_FUN)    \
  {                                                                          \
    ulint ut_sort_mid77;                                                     \
    ulint ut_sort_i77;                                                       \
    ulint ut_sort_low77;                                                     \
    ulint ut_sort_high77;                                                    \
                                                                             \
    ut_ad((LOW) < (HIGH));                                                   \
    ut_ad(ARR);                                                              \
    ut_ad(AUX_ARR);                                                          \
                                                                             \
    if ((LOW) == (HIGH)-1) {                                                 \
      return;                                                                \
    } else if ((LOW) == (HIGH)-2) {                                          \
      if (CMP_FUN((ARR)[LOW], (ARR)[(HIGH)-1]) > 0) {                        \
        (AUX_ARR)[LOW] = (ARR)[LOW];                                         \
        (ARR)[LOW] = (ARR)[(HIGH)-1];                                        \
        (ARR)[(HIGH)-1] = (AUX_ARR)[LOW];                                    \
      }                                                                      \
      return;                                                                \
    }                                                                        \
                                                                             \
    ut_sort_mid77 = ((LOW) + (HIGH)) / 2;                                    \
                                                                             \
    SORT_FUN((ARR), (AUX_ARR), (LOW), ut_sort_mid77);                        \
    SORT_FUN((ARR), (AUX_ARR), ut_sort_mid77, (HIGH));                       \
                                                                             \
    ut_sort_low77 = (LOW);                                                   \
    ut_sort_high77 = ut_sort_mid77;                                          \
                                                                             \
    for (ut_sort_i77 = (LOW); ut_sort_i77 < (HIGH); ut_sort_i77++) {         \
      if (ut_sort_low77 >= ut_sort_mid77) {                                  \
        (AUX_ARR)[ut_sort_i77] = (ARR)[ut_sort_high77];                      \
        ut_sort_high77++;                                                    \
      } else if (ut_sort_high77 >= (HIGH)) {                                 \
        (AUX_ARR)[ut_sort_i77] = (ARR)[ut_sort_low77];                       \
        ut_sort_low77++;                                                     \
      } else if (CMP_FUN((ARR)[ut_sort_low77], (ARR)[ut_sort_high77]) > 0) { \
        (AUX_ARR)[ut_sort_i77] = (ARR)[ut_sort_high77];                      \
        ut_sort_high77++;                                                    \
      } else {                                                               \
        (AUX_ARR)[ut_sort_i77] = (ARR)[ut_sort_low77];                       \
        ut_sort_low77++;                                                     \
      }                                                                      \
    }
    memcpy((void *)((ARR) + (LOW)), (AUX_ARR) + (LOW),                       \
           ((HIGH) - (LOW)) * sizeof *(ARR));                                \
  }
#endif  
```