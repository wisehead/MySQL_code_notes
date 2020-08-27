#1.class Link_buf

```cpp
template <typename Position = uint64_t>
class Link_buf {
	public:
	/** Type used to express distance between two positions.
	It could become a parameter of template if it was useful.
	However there is no such need currently. */
	typedef Position Distance;

	/** Constructs the link buffer. Allocated memory for the links.
	Initializes the tail pointer with 0.

	@param[in]	capacity	number of slots in the ring buffer */
	explicit Link_buf(size_t capacity);

	Link_buf();

	Link_buf(Link_buf &&rhs);

	Link_buf(const Link_buf &rhs) = delete;

	Link_buf &operator=(Link_buf &&rhs);

	Link_buf &operator=(const Link_buf &rhs) = delete;

	/** Destructs the link buffer. Deallocates memory for the links. */
	~Link_buf();

	/** Add a directed link between two given positions. It is user's
	responsibility to ensure that there is space for the link. This is
	because it can be useful to ensure much earlier that there is space.

	@param[in]	from	position where the link starts
	@param[in]	to	position where the link ends (from -> to) */
	void add_link(Position from, Position to);

	/** Advances the tail pointer in the buffer by following connected
	path created by links. Starts at current position of the pointer.
	Stops when the provided function returns true.

	@param[in]	stop_condition	function used as a stop condition;
									(lsn_t prev, lsn_t next) -> bool;
									returns false if we should follow
									the link prev->next, true to stop

	@return true if and only if the pointer has been advanced */
	template <typename Stop_condition>
	bool advance_tail_until(Stop_condition stop_condition);

	/** Advances the tail pointer in the buffer without additional
	condition for stop. Stops at missing outgoing link.

	@see advance_tail_until()

	@return true if and only if the pointer has been advanced */
	bool advance_tail();

	/** @return capacity of the ring buffer */
	size_t capacity() const;

	/** @return the tail pointer */
	Position tail() const;

	/** Checks if there is space to add link at given position.
	User has to use this function before adding the link, and
	should wait until the free space exists.

	@param[in]	position	position to check

	@return true if and only if the space is free */
	bool has_space(Position position) const;

	/** Validates (using assertions) that there are no links set
	in the range [begin, end). */
	void validate_no_links(Position begin, Position end);

	/** Validates (using assertions) that there no links at all. */
	void validate_no_links();

	private:
	/** Translates position expressed in original unit to position
	in the m_links (which is a ring buffer).

	@param[in]	position	position in original unit

	@return position in the m_links */
	size_t slot_index(Position position) const;

	/** Computes next position by looking into slots array and
	following single link which starts in provided position.

	@param[in]	position	position to start
	@param[out]	next		computed next position

	@return false if there was no link, true otherwise */
	bool next_position(Position position, Position &next);

	/** Claims a link starting in provided position that has been
	traversed and is no longer required (reclaims the slot).

	@param[in]	position	position where link starts */
	void claim_position(Position position);

	/** Deallocated memory, if it was allocated. */
	void free();

	/** Capacity of the buffer. */
	size_t m_capacity;

	/** Pointer to the ring buffer (unaligned). */
	std::atomic<Distance> *m_links;

	/** Tail pointer in the buffer (expressed in original unit). */
	alignas(CACHE_LINE_SIZE) std::atomic<Position> m_tail;
};

```