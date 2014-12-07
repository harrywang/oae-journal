# Third Party Libraries

3akai-ux/shared/oae/api/oae.bootstrap.js shows all the libraies.


## About jQuery-UI

In 3akai-ux/shared/oae/api/oae.bootstrap.js:

    'jquery-ui': 'vendor/js/jquery-ui/jquery-ui-1.10.4.custom’

The jQuery UI build that’s included in OAE only contains the Core and Widget modules. We try to only include the modules that are required by OAE, as a full jQuery UI build adds significantly to the total size of the page.

If you want to include the Draggable module (and its dependencies), you can create a custom build at [2] and replace the current jquery-ui file.

[1] https://github.com/oaeproject/3akai-ux/blob/master/shared/vendor/js/jquery-ui/jQuery%20UI%20Build%20README.txt
[2] http://jqueryui.com/download/


## About d3.js

If you’re just trying to include a 3rd party library into your widget, there’s no need to change the core `oae.bootstrap.js` file. You can add the library to the `js` folder in your widget and add the path to the library in the `define` line of your widget javascript file:

    define(['jquery', 'oae.core', ‘./d3.js'], function($, oae, D3)...)

That will allow you to keep things a bit more modular and will remove the need to maintain a patch to the core codebase.


# Useful Commands

Find string in files in the current directory:

    grep -rl jquery .

# Useful Tools

Clear Cache for Chrome :https://chrome.google.com/webstore/detail/clear-cache/cppjkneekbjaeellbfkmgnhonkkjfpdn?hl=en

Assign Command + R to reload after clearning the cache

# Reset Cassandra

deleted cassandra data - it is in the following location:

/var/lib/cassandra/

to reset cassandra would be to delete the contents of the  <data dir>/data/* <data dir>/commitlog/* <data dir>/saved_caches/*

# Landing page customization

Can each tenant have a different landing page?

The mechanism that is currently in place does allow each tenant to have its own custom landing page. However, I would recommend against using this mechanism, as it uses a completely new HTML file for each landing page, which will then need to be maintained going forward. The only reason why the current mechanism is in place was to get around a deadline to allow us to launch 2 tenants that wouldn’t have been able to launch otherwise.

Having said all of that, one of the features that will be present in the next major OAE release is customisable tenant landing pages. For each tenant, you will be able to define a number of blocks, what the responsive widths of those blocks should be and what their content (custom text, image, video, etc.) and colours should be. In attachment, you can find a screenshot of such a configured landing page.

I see two customized landing pages files in 3akai-ux/custom and want to know how to configure OAE to show those pages instead of the default one.

The current mechanism is Nginx based, and can be found in the `location = /` block under the `Main UI resources` in the Nginx config file. When a request comes in, Nginx will first try to find the custom landing page for that tenant based on the hostname. If it can’t be found, the default landing page will be used.

All of this will be removed in the upcoming OAE 10 release.

all tenants share the same HTML templates, so there is no
built-in way to provide each tenant with their own unique UI. The mechanisms OAE provide to customize are the skinning and branding from
the admin UI. The file to update for the landing page is ui/index.html.

There is one CSS file that changes based on the tenant and that is the one accessed at /api/ui/skin, which you can see referenced in our HTML files. The values for the colours/images are pulled from our configuration module (oae-config module) which is stored in cassandra.
It knows your tenant based on the host name you are accessing (as specified when creating a tenant through the tenant administrator).

Simon wrote an awesome system that parses a LESS [1] file and uses that to determine what values are configurable through the Admin UI. The file that gets parsed is located in the 3akai-ux code [2], where you can see the LESS variables (prefixed with @) are the values that can be configured in the admin UI. The values for these variables are stored in Cassandra on a per-tenant basis when modified in the Admin UI, then Hilary combines the variables with a less module [3] to generate the CSS skin and output it in the /api/ui/skin call.

As for tenant users, they are all stored in the Principals column family, and the tenant is discriminated in the internal id of the user (e.g., u:oae:mrvisser, where "oae" is the tenant alias of the tenant). For files, different storage strategies can be configured in the administration UI per tenant. The file paths are discriminated by tenant in the path.

1. http://lesscss.org/
2.  https://github.com/oaeproject/3akai-ux/blob/master/shared/oae/css/oae.skin.less
3. https://npmjs.org/package/less


The skinning / branding on the admin console will only let you update colours and images/logos. To change the layout and page contents you will need to update the templates in the 3akai-ux source.

There is the /ui directory which holds all the static assets for the regular user tenant interface, and an /admin directory which holds the assets for the tenant administration interface.

For mapping specific pages to an HTML file in those directories, the nginx.conf file can help you identify which HTML page is being used if the naming convention isn't immediately obvious.
