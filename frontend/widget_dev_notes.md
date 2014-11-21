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

    define(['jquery', 'underscore', 'oae.core', ‘./d3.js'], function($, _, oae, D3)...)

That will allow you to keep things a bit more modular and will remove the need to maintain a patch to the core codebase.


# Useful Commands

Find string in files in the current directory:

    grep -rl jquery .
