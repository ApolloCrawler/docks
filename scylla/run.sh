docker run -p $(hostname -i):9042:9042 -i -t scylladb/scylla

./tools/bin/cassandra-stress write -mode cql3 native