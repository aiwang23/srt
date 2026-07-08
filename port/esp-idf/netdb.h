#ifndef SRT_PORT_ESP_IDF_NETDB_H
#define SRT_PORT_ESP_IDF_NETDB_H

#include_next <netdb.h>

#ifndef NI_NUMERICHOST
#define NI_NUMERICHOST 1
#endif

#ifndef NI_NUMERICSERV
#define NI_NUMERICSERV 2
#endif

#ifndef NI_NOFQDN
#define NI_NOFQDN 4
#endif

#ifndef NI_NAMEREQD
#define NI_NAMEREQD 8
#endif

#ifndef NI_DGRAM
#define NI_DGRAM 16
#endif

#ifndef NI_MAXHOST
#define NI_MAXHOST 1025
#endif

#ifndef NI_MAXSERV
#define NI_MAXSERV 32
#endif

#endif // SRT_PORT_ESP_IDF_NETDB_H