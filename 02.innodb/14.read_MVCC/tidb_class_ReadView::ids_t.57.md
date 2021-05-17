#1.class  ReadView::ids_t

```cpp
        /** This is similar to a std::vector but it is not a drop
        in replacement. It is specific to ReadView. */
        class ids_t {
                typedef trx_ids_t::value_type value_type;
        private:
                // Prevent copying
                ids_t(const ids_t&);
                ids_t& operator=(const ids_t&);

        private:
                /** Memory for the array */
                value_type*     m_ptr;

                /** Number of active elements in the array */
                ulint           m_size;

                /** Size of m_ptr in elements */
                ulint           m_reserved;

                friend class ReadView;
        };
```