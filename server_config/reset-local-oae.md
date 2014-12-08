When things don't work, you can "reset" oae by doing the following:

###1. Reset Cassandra

deleted cassandra data - it is in the following location:

/var/lib/cassandra/

to reset cassandra would be to delete the contents of the  <data dir>/data/* <data dir>/commitlog/* <data dir>/saved_caches/*

###2. Reset ElasticSearch

Delete ElasticSearch folder and extract it from the zip file again. The data and log folder in ES are populated when Hilary is started.
