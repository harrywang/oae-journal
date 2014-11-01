### ****install cassandra****
cassandra 2.0.10 was installed, just extract to the same folder.

DO NOT USE HOMEBREW, BUT THE NOTE IS: See the note about Homebrew way in the end.
### ****install node****
Node was installed at
   /usr/local/bin/node
npm was installed at
   /usr/local/bin/npm
Make sure that /usr/local/bin is in your $PATH.

### ****install redis****
download redis, extract the fold, 

cd [redis-stable folder]
make
src/redis-server 

### ****install elasticsearch****
Harrys-MacBook-Pro:oae-dev harrywang$ cd elasticsearch-1.1.2/

Harrys-MacBook-Pro:elasticsearch-1.1.2 harrywang$ bin/elasticsearch -f

getopt: illegal option -- f

### ****install rabbimq****
sbin/rabbitmq-server

### ****install graphicsmagick****
brew install graphicsmagick

### ****skipped Preview Processor****

### ****skipped Eitherpad****

### ****install nginx and pcre****

Harrys-MacBook-Pro:oae-dev harrywang$ cd nginx-1.7.6/

Harrys-MacBook-Pro:nginx-1.7.6 harrywang$ ./configure --with-pcre=../pcre-8.36/

Harrys-MacBook-Pro:nginx-1.7.6 harrywang$ sudo make install

### ****install Hilary and 3akai-ux****

Harrys-MacBook-Pro:oae-dev harrywang$ git clone git://github.com/oaeproject/Hilary.git

Harrys-MacBook-Pro:oae-dev harrywang$ git clone git://github.com/oaeproject/3akai-ux.git

### ****configure hosts file****
add the following entries to your /etc/hosts file:

127.0.0.1   admin.oae.com
127.0.0.1   tenant1.oae.com

### ****configure Hilary****
create files folder at the same level as Hilary

### ****configure Nginx****

The following is how to get your id and group for you local mac:
Harrys-MacBook-Pro:~ harrywang$ id
uid=501(harrywang) gid=20(staff) groups=20(staff),401(com.apple.sharepoint.group.1),12(everyone),61(localaccounts),79(_appserverusr),80(admin),81(_appserveradm),98(_lpadmin),33(_appstore),100(_lpoperator),204(_developer),398(com.apple.access_screensharing),399(com.apple.access_ssh)

Change all Nginx (see attached file)

sudo /usr/local/nginx/sbin/nginx -c /Users/harrywang/code/oae-dev/3akai-ux/nginx/nginx.conf

Harrys-MacBook-Pro:Hilary harrywang$ npm install -d

Harrys-MacBook-Pro:Hilary harrywang$ node app.js | node_modules/.bin/bunyan

### ****NOTE**** 

no need to:
Configure the config.files.uploadDir property to point to a directory that exists. The reference to this directory should not have a trailing slash. This directory is used to store files such as profile pictures, content bodies, previews, etc...

Not done:
Etherpad setup

Configure the config.etherpad.apikey property to the API Key that can be found in your-etherpad-dir/APIKEY.txt

### ****nginx.conf****

user                    harrywang staff;
worker_processes        5;
error_log               logs/error.log;
worker_rlimit_nofile    8192;

events {
    worker_connections    4096;
}

http {

    # Allows us to have "server_name" strings up to 32 characters
    server_names_hash_bucket_size  64;


    ####################
    ## PROXY SETTINGS ##
    ####################

    proxy_next_upstream error timeout http_502;
    # Only give the app server 5 seconds for a request before assuming it's down and retrying
    proxy_connect_timeout   5;
    proxy_read_timeout      5;

    # Rewrite http headers to upstream servers
    proxy_http_version 1.1;
    proxy_redirect off;
    proxy_set_header Connection "";
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header X-NginX-Proxy true;


    ###################
    ## GZIP SETTINGS ##
    ###################

    gzip on;
    gzip_min_length 1000;
    gzip_http_version 1.1;
    gzip_comp_level 5;
    gzip_proxied any;
    gzip_types text/css text/plain text/xml application/xml application/xml+rss text/javascript application/javascript application/x-javascript application/json;


    ##########################
    ## MAXIMUM REQUEST SIZE ##
    ##########################

    # Determines the maximum filesize that a user can upload.
    client_max_body_size 4096M;


    ##################
    ##################
    ## GLOBAL ADMIN ##
    ##################
    ##################

    ####################
    ## LOAD BALANCING ##
    ####################

    upstream globaladminworkers {
        server 127.0.0.1:2000;
        # Add extra app nodes here.
    }

    server {
        listen       80;
        server_name  admin.oae.com;


        ######################
        ## SHARED RESOURCES ##
        ######################

        # Enable CORS support for the font-awesome webfont
        # so we can load it from our CDN
        location /shared/vendor/css/font-awesome/fonts/ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/shared/vendor/css/font-awesome/fonts/;
            add_header Access-Control-Allow-Origin "*";
            expires max;
        }

        location /shared/ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/shared/;
            autoindex off;
            expires max;
        }

        # HTML files under /shared/oae/errors are not hashed and should not be cached
        location ~* /shared/oae/errors/([^\.]+).html$ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/shared/oae/errors/$1.html;
            expires -1;
        }

        rewrite ^/accessdenied      /shared/oae/errors/accessdenied.html last;
        rewrite ^/noscript          /shared/oae/errors/noscript.html last;
        rewrite ^/notfound          /shared/oae/errors/notfound.html last;
        rewrite ^/servermaintenance /shared/oae/errors/servermaintenance.html last;
        rewrite ^/unavailable       /shared/oae/errors/unavailable.html last;

        rewrite ^/favicon.ico       /shared/oae/img/favicon.ico last;
        rewrite ^/robots.txt        /shared/oae/robots.txt last;


        #####################
        ## ADMIN RESOURCES ##
        #####################

        location /ui/ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/ui/;
            autoindex off;
            expires max;
        }

        location /admin/ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/admin/;
            autoindex off;
            expires max;
        }

        # HTML files under /admin are not hashed and should not be cached
        location ~* /admin/([^\.]+).html$ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/admin/$1.html;
            expires -1;
        }

        rewrite ^/$                     /admin/index.html last;
        rewrite ^/configuration         /admin/index.html last;
        rewrite ^/maintenance           /admin/index.html last;
        rewrite ^/skinning              /admin/index.html last;
        rewrite ^/tenant/(.*)$          /admin/index.html last;
        rewrite ^/tenants               /admin/index.html last;
        rewrite ^/usermanagement        /admin/index.html last;


        ######################
        ## WIDGET RESOURCES ##
        ######################

        location /node_modules/ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/node_modules/;
            autoindex off;
            expires max;
        }


        ####################
        ## DOCS RESOURCES ##
        ####################

        location /docs/ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/docs/;
            autoindex off;
        }

        # HTML files under /docs are not hashed and should not be cached
        location ~* /docs/([^\.]+).html$ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/docs/$1.html;
            expires -1;
        }

        rewrite ^/docs$                     /docs/index.html last;
        rewrite ^/docs/internal$            /docs/internal/index.html last;
        rewrite ^/docs/internal/backend     /docs/internal/index.html last;
        rewrite ^/docs/internal/frontend    /docs/internal/index.html last;
        rewrite ^/docs/rest$                /docs/rest/index.html last;


        #################
        ## ERROR PAGES ##
        #################

        error_page      401     /shared/oae/errors/accessdenied.html;
        error_page      404     /shared/oae/errors/notfound.html;
        error_page      502     /shared/oae/errors/unavailable.html;
        error_page      503     /shared/oae/errors/servermaintenance.html;


        #########################
        ## APP SERVER REQUESTS ##
        #########################

        location /api/ui/skin {
            expires 15m;
            proxy_pass http://globaladminworkers;
        }

        location /api/ui/staticbatch {
            expires max;
            proxy_pass http://globaladminworkers;
        }

        location /api/ui/widgets {
            expires 15m;
            proxy_pass http://globaladminworkers;
        }

        # Explicitly don't cache any other API requests
        location /api/ {
            expires -1;
            proxy_pass http://globaladminworkers;
        }

        # This can be cached indefinitely because we use signatures that change over time to control invalidation
        location /api/download/signed {
            expires max;
            proxy_pass http://globaladminworkers;
        }

        location /api/user/create {
            expires -1;
            proxy_next_upstream error http_502;
            proxy_pass http://globaladminworkers;
        }

        location /api/user/createGlobalAdminUser {
            expires -1;
            proxy_next_upstream error http_502;
            proxy_pass http://globaladminworkers;
        }

        location /api/user/createTenantAdminUser {
            expires -1;
            proxy_next_upstream error http_502;
            proxy_pass http://globaladminworkers;
        }

        location /api/user/import {
            expires -1;
            proxy_read_timeout 300;
            proxy_next_upstream error http_502;
            proxy_pass http://globaladminworkers;
        }


        ####################
        ## FILE DOWNLOADS ##
        ####################

        # An internal endpoint that is used by the local file storage backend.
        # Change the alias so that it points to the directory that will contain the file bodies.
        # This should match with the oae-content/storage/local-dir config value as configured
        # in the admin UI.
        location /files {
            internal;
            alias /Users/harrywang/code/oae-dev/files;
        }

    }


    ###################
    ###################
    ## TENANT SERVER ##
    ###################
    ###################

    ####################
    ## LOAD BALANCING ##
    ####################

    upstream tenantworkers {
        server 127.0.0.1:2001;
        # Add extra app nodes here.
    }

    server {
        listen   80 default_server;


        ######################
        ## SHARED RESOURCES ##
        ######################

        # Enable CORS support for the font-awesome webfont
        # so we can load it from our CDN
        location /shared/vendor/css/font-awesome/fonts/ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/shared/vendor/css/font-awesome/fonts/;
            add_header Access-Control-Allow-Origin "*";
            expires max;
        }

        location /shared/ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/shared/;
            autoindex off;
            expires max;
        }

        # HTML files under /shared/oae/errors are not hashed and should not be cached
        location ~* /shared/oae/errors/([^\.]+).html$ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/shared/oae/errors/$1.html;
            expires -1;
        }

        rewrite ^/accessdenied      /shared/oae/errors/accessdenied.html last;
        rewrite ^/noscript          /shared/oae/errors/noscript.html last;
        rewrite ^/notfound          /shared/oae/errors/notfound.html last;
        rewrite ^/servermaintenance /shared/oae/errors/servermaintenance.html last;
        rewrite ^/unavailable       /shared/oae/errors/unavailable.html last;

        rewrite ^/favicon.ico       /shared/oae/img/favicon.ico last;
        rewrite ^/robots.txt        /shared/oae/robots.txt last;


        #####################
        ## ADMIN RESOURCES ##
        #####################

        location /admin/ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/admin/;
            autoindex off;
            expires max;
        }

        # HTML files under /admin are not hashed and should not be cached
        location ~* /admin/([^\.]+).html$ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/admin/$1.html;
            expires -1;
        }

        rewrite ^/admin$                 /admin/index.html last;
        rewrite ^/admin/configuration    /admin/index.html last;
        rewrite ^/admin/tenants          /admin/index.html last;
        rewrite ^/admin/skinning         /admin/index.html last;
        rewrite ^/admin/usermanagement   /admin/index.html last;


        #######################
        ## MAIN UI RESOURCES ##
        #######################

        # TODO: Remove this custom landing page strategy and /custom handling when we have configurable landing pages
        location = / {
            autoindex off;
            expires -1;

            # Tell Nginx that the root is the UI directory so custom files can be located with try_files
            root /Users/harrywang/code/oae-dev/3akai-ux;

            try_files /custom/$host/index.html /ui/index.html;
        }

        location /ui/ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/ui/;
            autoindex off;
            expires max;
        }

        location /custom/ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/custom/;
            autoindex off;
            expires max;
        }

        # HTML files under /ui are not hashed and should not be cached
        location ~* /ui/([^\.]+).html$ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/ui/$1.html;
            expires -1;
        }

        rewrite ^/content           /ui/content.html last;
        rewrite ^/discussion        /ui/discussion.html last;
        rewrite ^/folder            /ui/folder.html last;
        rewrite ^/group             /ui/group.html last;
        rewrite ^/me                /ui/me.html last;
        rewrite ^/search            /ui/search.html last;
        rewrite ^/user              /ui/user.html last;


        ######################
        ## WIDGET RESOURCES ##
        ######################

        location /node_modules/ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/node_modules/;
            autoindex off;
            expires max;
        }


        ####################
        ## DOCS RESOURCES ##
        ####################

        location /docs/ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/docs/;
            autoindex off;
        }

        # HTML files under /docs are not hashed and should not be cached
        location ~* /docs/([^\.]+).html$ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/docs/$1.html;
            expires -1;
        }

        rewrite ^/docs$                     /docs/index.html last;
        rewrite ^/docs/internal$            /docs/internal/index.html last;
        rewrite ^/docs/internal/backend     /docs/internal/index.html last;
        rewrite ^/docs/internal/frontend    /docs/internal/index.html last;
        rewrite ^/docs/rest$                /docs/rest/index.html last;


        ####################
        ## TEST RESOURCES ##
        ####################

        location /tests/ {
            alias /Users/harrywang/code/oae-dev/3akai-ux/tests/;
            autoindex off;
            expires -1;
        }

        rewrite ^/tests$  /tests/index.html last;


        #################
        ## ERROR PAGES ##
        #################

        error_page      401     /shared/oae/errors/accessdenied.html;
        error_page      404     /shared/oae/errors/notfound.html;
        error_page      502     /shared/oae/errors/unavailable.html;
        error_page      503     /shared/oae/errors/servermaintenance.html;


        #########################
        ## APP SERVER REQUESTS ##
        #########################

        location /api/auth/shibboleth/callback {
            expires -1;
            proxy_read_timeout 120;
            proxy_next_upstream error http_502;
            proxy_pass http://tenantworkers;
        }

        location /api/config {
            expires 15m;
            proxy_pass http://tenantworkers;
        }

        location /api/content/create {
            expires -1;
            proxy_read_timeout 300;
            proxy_next_upstream error http_502;
            proxy_pass http://tenantworkers;
        }

        location ~* /api/content/([^\/]+)/messages {
            expires -1;
            proxy_next_upstream error http_502;
            proxy_pass http://tenantworkers;
        }

        location ~* /api/content/([^\/]+)/newversion {
            expires -1;
            proxy_read_timeout 300;
            proxy_next_upstream error http_502;
            proxy_pass http://tenantworkers;
        }

        location ~* /api/content/([^\/]+)/publish {
            expires -1;
            proxy_read_timeout 300;
            proxy_next_upstream error http_502;
            proxy_pass http://tenantworkers;
        }

        location ~* /api/content/([^\/]+)/revisions/([^\/]+)/previews {
            expires -1;
            proxy_read_timeout 1200;
            proxy_next_upstream error http_502;
            proxy_pass http://tenantworkers;
        }

        location ~* /api/content/([^\/]+)/revisions/([^\/]+)/restore {
            expires -1;
            proxy_read_timeout 300;
            proxy_next_upstream error http_502;
            proxy_pass http://tenantworkers;
        }

        location /api/discussion/create {
            expires -1;
            proxy_next_upstream error http_502;
            proxy_pass http://tenantworkers;
        }

        location ~* /api/discussion/([^\/]+)/messages {
            expires -1;
            proxy_next_upstream error http_502;
            proxy_pass http://tenantworkers;
        }

        # This can be cached indefinitely because we use signatures that change over time to control invalidation
        location /api/download/signed {
            expires max;
            proxy_pass http://tenantworkers;
        }

        location /api/folder {
            expires -1;
            proxy_next_upstream error http_502;
            proxy_pass http://tenantworkers;
        }

        location /api/group/create {
            expires -1;
            proxy_next_upstream error http_502;
            proxy_pass http://tenantworkers;
        }

        location ~* /api/group/([^\/]+)/picture {
            expires -1;
            proxy_read_timeout 60;
            proxy_next_upstream error http_502;
            proxy_pass http://tenantworkers;
        }

        location /api/ui/skin {
            expires 15m;
            proxy_pass http://tenantworkers;
        }

        location ~* /api/group/([^\/]+)/picture {
            expires -1;
            proxy_read_timeout 60;
            proxy_next_upstream error http_502;
            proxy_pass http://tenantworkers;
        }

        location /api/ui/staticbatch {
            expires max;
            proxy_pass http://tenantworkers;
        }

        location /api/ui/widgets {
            expires 15m;
            proxy_pass http://tenantworkers;
        }

        location /api/user/create {
            expires -1;
            proxy_next_upstream error http_502;
            proxy_pass http://tenantworkers;
        }

        location /api/user/createTenantAdminUser {
            expires -1;
            proxy_next_upstream error http_502;
            proxy_pass http://tenantworkers;
        }

        location /api/user/import {
            expires -1;
            proxy_read_timeout 300;
            proxy_next_upstream error http_502;
            proxy_pass http://tenantworkers;
        }

        location ~* /api/user/([^\/]+)/picture {
            expires -1;
            proxy_read_timeout 60;
            proxy_next_upstream error http_502;
            proxy_pass http://tenantworkers;
        }


        ########################
        ## PUSH NOTIFICATIONS ##
        ########################

        location /api/push/ {
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_pass http://tenantworkers;
            proxy_redirect off;
            proxy_buffering off;
            proxy_read_timeout 3600;
        }


        # Explicitly don't cache any other API requests
        location /api/ {
            expires -1;
            proxy_pass http://tenantworkers;
        }


        ####################
        ## FILE DOWNLOADS ##
        ####################

        # An internal endpoint that is used by the local file storage backend.
        # Change the alias so that it points to the directory that will contain the file bodies.
        # This should match with the oae-content/storage/local-dir config value as configured
        # in the admin UI.
        location /files {
            internal;
            alias /Users/harrywang/code/oae-dev/files;
        }


        ######################
        ## ETHERPAD SERVERS ##
        ######################

        location /etherpad/0 {
            expires 15m;

            rewrite ^/etherpad/0(.*)$ $1 break;

            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
            proxy_set_header X-NginX-Proxy true;
            proxy_pass http://127.0.0.1:9001;
            proxy_buffering off;
            proxy_read_timeout 60;
        }

        location /etherpad/0/socket.io/1/websocket/ {
            rewrite ^/etherpad/0(.*)$ $1 break;

            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_pass http://127.0.0.1:9001;
            proxy_buffering off;
            proxy_read_timeout 60;
        }
    }

    include /Users/harrywang/code/oae-dev/3akai-ux/nginx/mime.conf;
}

#### ****homebrew cassandra****
brew install cassandra 2.0.9, the new 2.1.x does not work
brew tap homebrew/boneyard
brew versions cassandra
cd $(brew --prefix)
git checkout a9e856c /usr/local/Library/Formula/cassandra.rb
brew install cassandra

********
Simple Workflow for install older version formula in Homebrew
Step 1:

Navigate to your homebrew base directory (usually this is /usr/local) Example:

cd /usr/local
Or, you can do

cd `brew --prefix`
Step 2:

Enter brew versions <formula> ( is the formula you want to install).

You will then get something like:

1.0.1 git checkout 1234567 Library/Formula/<formula>.rb
1.0.0 git checkout 0123456 Library/Formula/<formula>.rb
...
Step 3:

Choose the desired version and check it out via copy and paste of the desired version line (leave out the version number in the beginning).

Example for getting 1.0.0:

git checkout 0123456 Library/Formula/<formula>.rb
Step 3.5 (maybe necessary)

Do this if you already have another version installed.

brew unlink <formula>
Step 4:

brew install <formula>
Step 5:

DONE, you can now use brew switch <formula> <version> to switch between versions.
*****************
