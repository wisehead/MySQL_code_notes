#1.class PackStr

```cpp
class PackStr final : public Pack {
  // Make sure this is larger than the max length of CHAR/TEXT field of mysql.
  static const size_t DEFAULT_BUF_SIZE = 64_KB;

  struct buf {
    char *ptr;
    const size_t len;
    size_t pos;

    size_t capacity() const { return len - pos; }
    void *put(const void *src, size_t length) {
      ASSERT(length <= capacity());
      auto ret = std::memcpy(ptr + pos, src, length);
      pos += length;
      return ret;
    }
  };

  PackStrtate pack_str_state_ = PackStrtate::kPackArray;
  marisa::Trie marisa_trie_;
  UniquePtr compressed_data_;
  uint16_t *ids_array_;
  struct {
    std::vector<buf> v;
    size_t sum_len;
    char **index;
    union {
      void *lens;
      uint32_t *lens32;
      uint16_t *lens16;
    };
    uint8_t len_mode;
  } data_{};  
`

```