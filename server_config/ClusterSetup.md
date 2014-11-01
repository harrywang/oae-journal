I forgot to add that all queries we execute to Cassandra are performed
with QUORUM consistency.

Thanks,
Branden

On Fri, Nov 22, 2013 at 6:14 AM, Branden Visser <mrvisser@gmail.com> wrote:
If you're running 2 nodes with a replication factor of 1, and one node
fails, then half of the queries you make to Cassandra (reads and
writes) will fail, and half will succeed.

If you're running 2 nodes with a replication factor of 2, and one node
fails, then all queries you make to Cassandra will fail ("full cluster
failure").

If you're running 3 nodes with a replication factor of 3, and one node
fails, the Cassandra cluster continues to operate successfully.

I highly recommend having an understanding of Cassandra replication
[1] and consistency [2] if you are venturing towards running OAE in
production.

Thanks,
Branden

[1] http://www.datastax.com/docs/1.0/cluster_architecture/replication
[2] http://www.datastax.com/docs/1.0/dml/data_consistency#tunable-consistency


On Fri, Nov 22, 2013 at 5:56 AM, Kabelo Letsoalo
<kabelo@opencollab.co.za> wrote:
Thanks Branden.

This question is in the context of a 2-node setup.

Does full cluster failure mean the one node left will continue operating
without replication or cassandra as a whole will fail (along with the
healthy node)?

Thanks alot!


On 22 November 2013 12:38, Branden Visser <mrvisser@gmail.com> wrote:

Hi Kabelo, glad you got it up and running! You should add all
available cassandra nodes to the list of cassandra hosts. This avoids
a single point of failure.

In general, it's recommended that your smallest setup be 3 cassandra
nodes and a "replication factor" of 3. This allows for one node to
fail and still retain availability. Any setup smaller than this will
result in a full cluster failure if one node goes down.

Cheers,
Branden

On Fri, Nov 22, 2013 at 5:18 AM, Kabelo Letsoalo
<kabelo@opencollab.co.za> wrote:
Hello.

The Hilary cluster setup is a breeze. nicely done.

I'm unsure about config.cassandra  in Hilary/config.js. I setup a
cassandra
node on another server and run it in a cluster with the cassandra node
running on the same server as the application server/Hilary.

Even with the cassandra cluster and its replication setup done, do I
still
need to add the remote server (server not running on same server as
Hilary)
to the config.cassandra.hosts list?

Thanks for the help!


On 15 November 2013 14:18, Branden Visser <mrvisser@gmail.com> wrote:

Hi Kabelo,

We don't have formal detailed documentation on this, however there are
bootcamp slides available which give a high-level overview of a
clustered application setup [1].

For all components other than Hilary, I would recommend becoming
familiar with their own clustering abilities and reference their
documentation for setup.

For Hilary, it's important to note the "specialization" of Hilary
nodes into one or more of the following roles:

1. Application Request Handler
2. Activity Processor
3. Search Indexer
4. Preview Processor

For #1, you'll see that Nginx proxies web requests to the application
nodes. You simply need to configure Nginx appropriately to use all
your application request handler nodes into the backend pools in
Nginx. Every Hilary node will always be prepared to handle web
requests after startup.

For #2-4, they receive their requests through RabbitMQ messages, so as
long as they are configured to talk to RabbitMQ (config.mq in
config.js), they are capable of being distributed and handling these
tasks. Therefore, in order to deploy a specialized node, you simply
need to configure its RabbitMQ connection (*all* Hilary nodes should
have this configured any way), and enable / disable the type of work
you would like that node to handle in config.js:

2. Set "config.search.processIndexJobs" to true to indicate the node
should subscribe to search indexing tasks
3. Set "config.activity.processActivityJobs" to true to indicate the
node should subscribe to activity routing tasks and to aggregate
activity
4. Set "config.previews.enabled" to true to indicate the node should
subscribe to preview processing tasks

Note that our puppet scripts for deploying and configuring Hilary
clusters are available [2]. Feel free to look into those to get
specific configuration templates for setting up an OAE cluster.

Hope that helps,
Branden

[1] http://www.slideshare.net/nicolaasmatthijs/apereo-oae-bootcamp
(Slide #18)
[2] https://github.com/oaeproject/puppet-hilary

On Fri, Nov 15, 2013 at 6:19 AM, Kabelo Letsoalo
<kabelo@opencollab.co.za> wrote:
Hi all. where can I find documentation for OAE 2.0.0 cluster setup
and/or
running multiple instances?
