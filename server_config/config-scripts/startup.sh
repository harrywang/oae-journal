sandbox/oae-dev/apache-cassandra-2.0.10/bin/cassandra -f &

sandbox/oae-dev/redis-2.8.17/src/redis-server &

sandbox/oae-dev/elasticsearch-1.1.2/bin/elasticsearch -d

sandbox/oae-dev/rabbitmq_server-3.4.0/sbin/rabbitmq-server &

sudo /usr/local/nginx/sbin/nginx -c /Users/harrywang/sandbox/oae-dev/3akai-ux/nginx/nginx.conf &

sandbox/oae-dev/etherpad-lite/bin/run.sh &

cd sandbox/oae-dev/Hilary

node app.js | node_modules/.bin/bunyan
