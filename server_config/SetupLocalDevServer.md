### ****Install cassandra****
cassandra 2.0.10 was installed, just extract to the same folder.

DO NOT USE HOMEBREW, BUT THE NOTE IS: See the note about Homebrew way in the end.
### ****install node****
Node was installed at
   /usr/local/bin/node
npm was installed at
   /usr/local/bin/npm
Make sure that /usr/local/bin is in your $PATH.

### ****Install redis****
download redis, extract the fold,

    cd [redis-stable folder]
    make
    src/redis-server

### ****Install elasticsearch****
    Harrys-MacBook-Pro:oae-dev harrywang$ cd elasticsearch-1.1.2/

    Harrys-MacBook-Pro:elasticsearch-1.1.2 harrywang$ bin/elasticsearch -f

getopt: illegal option -- f

### ****Install rabbimq****
extract files and then run

    sbin/rabbitmq-server

### ****Install graphicsmagick****
    brew install graphicsmagick

    brew install ghostscript

When installing GraphicsMagick manually, make sure you have at least libpng, libjpeg and Ghostscript installed.

### ****Insatll Preview Processor (after Hilary and 3akai)****
Click to download PDFtk Server for the Mac OS X 10.6 (Snow Leopard), 10.7 (Lion) and 10.8 (Mountain Lion): see installation folder for the file, double click to install

Open the Terminal, then enter:

    pdftk --version

download XQuartz dmg and install that - needs a reboot
    brew install pdf2htmlex

download and install LibreOffice: dmg and install


Make changes in Hilary config.js:

need to change tmp folder:

    var tmpDir = '../tmp';

then

    chmod 777 tmp

and then

    config.previews = {
      'enabled': true,
      'tmpDir': tmpDir + '/previews',
      'office': {
        'binary': '/Applications/LibreOffice.app/Contents/MacOS/soffice',
        'timeout': 120000
        },
        'pdftk': {
          'binary': '/opt/pdflabs/pdftk/bin/pdftk',
          'timeout': 120000
          },
          'pdf2htmlEX': {
            'binary': '/usr/local/Cellar/pdf2htmlex/0.12/bin/pdf2htmlEX',
            'timeout': 120000
            },
            'link': {
              'renderDelay': 7500,
              'renderTimeout': 30000,
              'embeddableCheckTimeout': 15000
              },
              'credentials': {
                'username': 'administrator',
                'password': 'administrator'
              }
            };


### **** Install Etherpad (after Hilary and 3akai)****

**Note**: use 1.4.0 not 1.4.1 for now - you have to follow the instruciton below to make it work.

- Download/Clone Etherpad 1.4.0 from the 1.4.0 tag on github: https://github.com/ether/etherpad-lite/tree/1.4.0

- Edit the bin/installDeps script and comment out line 41 (the exit 1 line) and Run ./bin/installDeps.sh

- Install oae and ep-headings plugin, go to etherpad folder:


    Harrys-MacBook-Pro:node_modules harrywang$git clone    https://github.com/oaeproject/ep_oae
    Harrys-MacBook-Pro:node_modules harrywang$ cd ep_oae/
    Harrys-MacBook-Pro:ep_oae harrywang$ npm install
    Harrys-MacBook-Pro:etherpad-lite harrywang$ npm install ep_headings
    ep_headings@0.1.6 node_modules/ep_headings

You can copy or symlink the static/css/pad.css in the ep_oae module to your-etherpad-dir/src/static/custom/pad.css in order to apply the OAE skin on etherpad. I choose to copy and replace the file.

In order to have custom titles for headers, copy or symlink the static/templates/editbarButtons.ejs file in the ep_oae module to your-etherpad-directory/node_modules/ep_headings/templates/editbarButtons.ejs. I choose copy and replace the file

- You need to run Etherpad once to generate the API key and setting.json file: ./etherpad-lite/bin/run.sh the API is in the APIKEY.txt in etherpad-lite folder

- Lastly, you need to edit the setting.json file and Hilary config.js as follows:

  - Go to Hilary folder, and open config.js file, edit the API in the following section:

        config.etherpad = {
          'apikey': '485eef7fe52994288736d4c5174ce61c9eb6f96905136ccfb70f03be8616a05e',
          'hosts': [
          {
            'host': '127.0.0.1',
            'port': 9001
          }
          ]
        };

  - Go to Etherpad folder and open setting.json, edit the following sections:
    set the requireSession and editOnly values to true in etherpad's settings.json file.
  - It's recommended to also add in a sessionKey. This can be any random value, but should be the same across the cluster.

          "sessionKey" : "1234567890",

  - change the database setting:

          //The Type of the database. You can choose between dirty, postgres, sqlite and mysql
          //You shouldn't use "dirty" for for anything else than testing or development
          "dbType": "cassandra",
          //the database specific settings
          "dbSettings" : {
            "hosts": ["127.0.0.1:9160"],
            "keyspace": "oae",
            "cfName": "Etherpad",
            "user": "",
            "pass": "",
            "timeout": 3000,
            "replication": 1,
            "strategyClass": "SimpleStrategy"
            },

  - change default text
          "defaultPadText" : "",
  - add the websocket protocol. It's important to add this as the first element of the array.
          "socketTransportProtocols" : ["websocket", "xhr-polling", "jsonp-polling", "htmlfile"]

  - add toolbar setting:
          "toolbar": {
          "left": [
          ["bold", "italic", "underline", "strikethrough"],
          ["orderedlist", "unorderedlist", "indent", "outdent"]
          ],
          "right": [
          ["showusers"]
          ]
          },


Other useful references:

Simon's comments
>The latest etherpad versions (1.4.1) hardcoded a path. I have a fix pending, that addresses this.
The older etherpad versions don’t have this problem, BUT they can not be installed through
the installer script if you have npm 2 (or newer), which most people have by now. Annoyingly, you should be able to solve this by doing the following:
- Check out the 1.4.0 tag
- Edit the bin/installDeps script and comment out line 41 (the exit 1 line)
- Run ./bin/installDeps.sh
- Start the etherpad server
I’ll be sending them a fix for the hardcoded path so everyone can use their latest versions again.


by default, you make the standalone etherpad work as follows

  Harrys-MacBook-Pro:oae-dev harrywang$ cd etherpad-lite/
  Harrys-MacBook-Pro:etherpad-lite harrywang$ cd node_modules/
  Harrys-MacBook-Pro:node_modules harrywang$ git clone
you should see the local version running at http://127.0.0.1:9001 in your browser.- close terminal and continue


You also need to change the API key in config.js in Hilary to the API key of your local copy of etherpad:

>Authentication works via a token that is sent with each request as a post parameter. There is a single token per Etherpad-Lite deployment. This token will be random string, generated by Etherpad-Lite at the first start. It will be saved in APIKEY.txt in the root folder of Etherpad Lite. Only Etherpad Lite and the requesting application knows this key. Token management will not be exposed through this API."

### Install nginx and pcre

    Harrys-MacBook-Pro:oae-dev harrywang$ cd nginx-1.7.6/
    Harrys-MacBook-Pro:nginx-1.7.6 harrywang$ ./configure --with-pcre=../pcre-8.36/
    Harrys-MacBook-Pro:nginx-1.7.6 harrywang$ sudo make install

Configure Nginx

The following is how to get your id and group for you local mac:

    Harrys-MacBook-Pro:~ harrywang$ id
    uid=501(harrywang) gid=20(staff) groups=20(staff),401(com.apple.sharepoint.group.1),12(everyone),61(localaccounts),79(_appserverusr),80(admin),81(_appserveradm),98(_lpadmin),33(_appstore),100(_lpoperator),204(_developer),398(com.apple.access_screensharing),399(com.apple.access_ssh)

    Change all Nginx (see attached file)

    sudo /usr/local/nginx/sbin/nginx -c /Users/harrywang/code/oae-dev/3akai-ux/nginx/nginx.conf

    Harrys-MacBook-Pro:Hilary harrywang$ npm install -d

    Harrys-MacBook-Pro:Hilary harrywang$ node app.js | node_modules/.bin/bunyan

### Install Hilary and 3akai-ux

    Harrys-MacBook-Pro:oae-dev harrywang$ git clone git://github.com/oaeproject/Hilary.git
    Harrys-MacBook-Pro:oae-dev harrywang$ git clone git://github.com/oaeproject/3akai-ux.git


Configure Hilary
create files folder at the same level as Hilary

no need to: Configure the config.files.uploadDir property to point to a directory that exists. The reference to this directory should not have a trailing slash. This directory is used to store files such as profile pictures, content bodies, previews, etc...


### Configure hosts file
add the following entries to your /etc/hosts file:

127.0.0.1   admin.oae.com
127.0.0.1   tenant1.oae.com

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
