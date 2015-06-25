$TTL 60
@	IN SOA ns.n14009.com. ewe.n14009.com. (
	2015052601;
	60;
	900;
	3600;
	60)

	IN	NS	ns.n14009.com.
	IN	MX	10	aspmx.l.google.com.
	IN	NS	ns2.n14009.com.
www	IN	A	172.16.40.70
ns	IN	A	172.16.40.70
ns2	IN	A	172.16.40.71


