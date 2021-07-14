#1.struct subnet

```cpp
/**
  Subnetwork address in CIDR format, e.g
  192.168.1.0/24 or 2001:db8::/32
*/
struct subnet
{
  char addr[16]; /* Binary representation of the address, big endian*/
  unsigned short family; /* Address family, AF_INET or AF_INET6 */
  unsigned short bits; /* subnetwork size */
};

```