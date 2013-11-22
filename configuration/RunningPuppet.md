Hi Harry, if you're setting up a machine for QA/test purposes for
example, you can do the same thing as you did with vagrant, except you
use the "qa" environment  and "qa0" certname instead of "local" and
"dev". Note that you won't have to clone Hilary, the "qa0" node
configuration will handle all that for you. You just need to get
puppet and the puppet-hilary code on the machine, then puppet can take
it from there once you've run the appropriate command.

Another way is to install the "puppet master" software on a dedicated
machine, this is how we manage nodes. We have one machine that runs a
server called the "puppet master" and it contains the puppet manifests
(puppet-hilary repository). Then when we install a new node, we tell
the node who the puppet master is and it automatically installs the
required software based on its hostname (e.g., if the hostname is
"qa0", it takes that node's configuration).