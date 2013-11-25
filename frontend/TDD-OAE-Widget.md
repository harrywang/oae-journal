From https://github.com/sathomas/3akai-ux.wiki.git

This page documents a step-by-step example of [test driven development](http://en.wikipedia.org/wiki/Test-driven_development) ([TDD](http://www.agiledata.org/essays/tdd.html)). In particular, it walks through the development of a simple OAE widget (the footer widget) using TDD methodology.

* Initial Setup: Installing the necessary tools
* Starting Development: Live testing during development
* Writing the First Tests: Initial tests for an OAE widget
* The `widget` Test Object: Using the special test object
* Complete Test Suite: A full test suite for a widget
* CLI Version: Running tests from the command line
* Next Steps: Future enhancements for more advanced unit testing

### Initial Setup

As of this writing, the TDD tool chain has not been integrated into the main OAE project. But it's simple enough to add outside of the project. In the parent folder to `3akai-ux` simply add the following `package.json` file. This file identifies the tools TDD needs.

```json
{
  "name": "oae-test",
  "description": "Open Academic Environment (OAE) Test Environment",
  "version": "0.0.0",
  "homepage": "http://www.oaeproject.org",
  "author": {
    "name": "The Apereo Foundation",
    "email": "oae-dev@collab.sakaiproject.org"
  },
  "devDependencies": {
    "grunt": "~0.4.1",
    "matchdep": "~0.1.2",
    "grunt-open": "~0.2.2",
    "grunt-contrib-watch": "~0.5.3",
    "grunt-contrib-connect": "~0.5.0",
    "grunt-mocha-phantomjs": "~0.3.0"
  },
  "engines": {
    "node": ">=0.8"
  }
}
```

The node package manager can then install these tools with a single command:

```
npm install
```

If you haven't already done so, you'll also need to install the command line interface (cli) for grunt, probably as a super user to ensure it's available everywhere.

```
sudo npm install -g grunt-cli
```

Next up is a configuration file for grunt. Here's the required Gruntfile.js

```javascript
module.exports = function(grunt) {

  grunt.initConfig({

    connect: {
      mock: {
        options: {
          port: 9000,
          hostname: 'localhost',
          base: '3akai-ux',
          livereload: true
        }
      },
      mockdev: {
        options: {
          port: 9001,
          hostname: 'localhost',
          base: '3akai-ux',
          keepalive: false
        }
      }
    },
    
    mocha_phantomjs: {
      options: {
        'setting': 'localToRemoteUrlAccessEnabled=true',
        'agent':   ''
      },
      mock: ['<%= connect.mock.options.base%>/tests/mocked/index.html']
    },
    
    watch: {
      mock: {
        files: [
          '<%= connect.mock.options.base%>/**/*.html',
          '<%= connect.mock.options.base%>/**/*.js',
          '<%= connect.mock.options.base%>/**/*.json'
        ],
        options: {
          interrupt: true,
          event: ['added', 'changed'],
          livereload: true
        }
      }
    },

    open: {
      mock: {
        path: 'http://localhost:<%= connect.mock.options.port%>/tests/mocked/index.html'
      },
      mockdev: {
        path: 'http://localhost:<%= connect.mockdev.options.port%>/tests/mocked/dev.html'
      }
    }
  });

  // Load Grunt tasks declared in the package.json file
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);
  
  grunt.registerTask('mock', '', function(name) {
    if (name) {
      grunt.config.set('open.mock.path', grunt.config.get('open.mock.path')+'?widget='+name);
    }
    grunt.task.run('connect:mock', 'open:mock', 'watch:mock');
  });
  grunt.registerTask('mockcli', '', function(name) {
    if (name) {
      grunt.config.set('mocha_phantomjs.options.agent', 'widget='+name);
    }
    grunt.task.run('mocha_phantomjs:mock');
  });
  grunt.registerTask('mockdev', '', function(name) {
    if (name) {
      grunt.config.set('open.mockdev.path', grunt.config.get('open.mockdev.path')+'?widget='+name);
    }
    grunt.task.run('connect:mockdev', 'open:mockdev', 'watch:mock');
  })
};
```

Eventually these steps may be integrated into the main OAE branch, in which case they'll already be set up for you.

### Starting Development

To start development, simply enter the directory containing the above files and run the command `grunt mock:widgetname` where `widgetname` is the name of the widget being developed. Here, for example is what happens when starting development on a `footer` widget:

```shell
bash-3.2$ grunt mock:footer
Running "mock:footer" (mock) task

Running "connect:mock" (connect) task
Started connect web server on 127.0.0.1:9000.

Running "open:mock" (open) task

Running "watch:mock" (watch) task
Waiting...OK
```

This command starts a local web server and opens the default browser to a test results page. To terminate the server and return to the command line prompt, press `Ctrl-C`. Since we've just started development, there won't be any tests to run. As a result, the web page will be empty and its title will indicate that a test file is missing.

![TDD browser window showing no test file](http://cl.ly/image/3c0z2402063T/tdd-01.png)

To fix that, we need to create a test file. Change to the widgets directory; create a subdirectory for the new widget, and, within that subdirectory, create a `mock` subdirectory. That's where the test file, in this case `footer.js` goes.

```shell
bash-3.2$ cd 3akai-ux/node_modules/oae-core/
bash-3.2$ mkdir footer
bash-3.2$ cd footer
bash-3.2$ mkdir mock
bash-3.2$ cd mock
bash-3.2$ touch footer.js
bash-3.2$ 
```

As soon as we create the (empty) test file, the browser window updates. Now there's no error, but there aren't any tests either:

![TDD browser window showing no test](http://cl.ly/image/2X0q0s1E1j25/tdd-02.png)

The browser tells us the number of tests passing and failing, and it summarizes both counts in the title bar.

Open the footer.js file in your favorite editor to start the development process.

### Writing the First Tests

Following the precepts of test driven development, we always write a test before we develop any code. The first requirement for an OAE widget is that it have a `manifest.json` file, so let's write a test to verify that.

> Note: In this example we're writing tests in the "should" style of [behavior driven development](http://en.wikipedia.org/wiki/Behavior-driven_development) ([BDD](http://blog.codeship.io/2013/04/22/from-tdd-to-bdd.html)) which focusses on the users' perspectives rather than the developers', and is usually considered a more readable variation of TDD. The tools we're using also support the "expect" style and the more traditional "assert" style as well, if you're more comfortable with those approaches.

Using that style, our first test might be written as

```javascript
define(function(require) {

  var footer = require('widget!footer');

  describe('Footer Widget', function(){
    describe('Manifest', function(){
      it('should exist', function(){
        footer.manifest.should.be.ok;
      })
    })
  })

})
```

There are a couple of points to note right from the start:

1. Like all OAE modules, the test code relies on [RequireJS](http://requirejs.org) to manage dependencies. The first line of code, therefore, defines the test module. Even though the test module uses other libraries (such as `mocha` and `chai`) there is no need to declare them explicitly. Those modules must exist in the global name space to function, and the test infrastructure takes care of that setup.
2. The third line in the example, `var footer = require('widget!footer');` loads an object that holds the widget under test. As we'll see, that object is used extensively in the tests that follow.

As soon as we write our first test and save the file, the browser re-runs the test file. Since we haven't written a `manifest.json` for the footer widget yet, we don't expect our first test to pass. Indeed, it does not.

![TDD browser window with first test failing](http://cl.ly/image/3g1W3R2X3H37/tdd-03.png)

We can see that in several ways from the browser window.

* The main window clearly indicates that the test has failed.
* The test summary in the upper right shows "passes: 0 failures: 1".
* The window's title bar (which Chrome displays in the tab) shows "0/1" indicating that 0 tests are passing out of a total of 1 test(s).

These last two indications let us move the browser window into an unobtrusive corner of our display, letting us keep track of the test status without consuming significant "real estate" on our screen.

To make our first test pass, we have to create a `manifest.json` file. That's simple enough:

```shell
bash-3.2$ cd 3akai-ux/node_modules/oae-core/footer/
bash-3.2$ touch manifest.json
bash-3.2$ 
```

As soon as the manifest file exists, our test results update to show that we're now passing all tests.

![TDD browser window with first test passing](http://cl.ly/image/2A1H0X3n1o3l/tdd-04.png)

The next step in the development process is filling in the content of `manifest.json`. We're using TDD, though, so we need a test before we can write any code. That's simple enough:

```javascript
define(function(require) {

  var footer = require('widget!footer');

  describe('Footer Widget', function(){
    describe('Manifest', function(){
      it('should exist', function(){
        footer.manifest.should.be.ok;
      })
      it('should not be empty', function(){
        footer.manifest.should.not.be.empty;
      })
    })
  })

})
```

As expected, that test initially fails.

![TDD browser window failing second test](http://cl.ly/image/1o3p110a303s/tdd-05.png)

Providing a valid JSON object in `manifest.json` makes this test pass, letting us move on the next step. The manifest should also include a relative URL for the widget's HTML template as the `.src` property. When we've completed all the tests for the manifest, our test file might look like:

```javascript
define(function(require) {

  var footer = require('widget!footer');

  describe('Footer Widget', function(){
    describe('Manifest', function(){
      it('should exist', function(){
        footer.manifest.should.be.ok;
      })
      it('should not be empty', function(){
        footer.manifest.should.not.be.empty;
      })
      it('should include a URL for the HTML template', function(){
        footer.manifest.src.should.be.ok;
      })
    })
  })

})
```

We can now move on to testing other aspects of our widget.

### The `widget` Test Object

A key tool for unit testing widgets is the `widget` object. Our test code gets a reference to a widget object when it requires a widget, e.g.

```
var footer = require('widget!footer');
```

The resulting object has several important properties and methods, some of which we've already seen and others that are helpful for more advanced testing. The static properties let our test code directly access the widget's assets. Those properties include:

* `.manifest`: The widget's `manifest.json` file as a parsed JavaScript object.
* `.html`: The HTML template for the widget as a JavaScript string. (External references to style sheets and JavaScript files are removed from this property, so it can safely be inserted into the DOM or an isolated HTML  element without triggering requests for external resources.)
* `.cssStyleSheets`: An array of all CSS style sheets in the HTML template. Each element in the array is an object with `.path` and `.content` properties. The `.content` property is a string.
* `.jsScripts`: An array of all external JavaScript files in the HTML template. Each element in the array is an object with `.path` and .`content` properties. The `.content` property is JavaScript.

Other than trivial checks for their existence, unit test code will generally not have to manipulate these static properties directly. Instead, they can use two key widget methods.

* `.load()`: Loads the widget into a container in the DOM. This function inserts the HTML template into the container, adds any CSS style sheets to the DOM, and executes any JavaScript modules. If a container with the id `widget-container` already exists in the DOM, `.load()` inserts the HTML into that container. If no such container exists, `.load()` creates a hidden one. Using a pre-existing container allows the widget to remain visible during testing.
* `.unload()`: Removes a widget from the DOM, _**but only if `.load()` was used to add it and its container**_. If the widget was inserted into a previously existing container (or not inserted at all), this method has no effect.

The widget object also supports mocking the OAE API during tests. The methods that support mocking include

* `.clear()`: Removes any previously established mocked responses.
* `.mock()`: Defines a mocked response. Parameters are method (e.g. `"GET"` or `"POST"`), a URL (either a string or a RegExp object), and a response. The response parameter follows the same syntax as a [Sinon.JS](http://sinonjs.org) [response](http://sinonjs.org/docs/#responses).
* `.restart()`: Restarts the fake server after all mocks have been defined.

The mock methods are typically used in the above order, so, for example:

```javascript
var w = require('widget!example');
w.clear()
  .mock({
    method:   'GET',
    url:      '/api/ex1',
    response: [200, {'Content-Type': 'application/json'}, '{"prop1":"value1"}']
  })
  .mock({
    method:   'GET',
    url:      '/api/ex2',
    response: [200, {'Content-Type': 'application/json'}, '{"prop2":"value2"}']
  })
  .restart();
```

### Complete Test Suite

The complete test suite for the footer widget can be found in this [gist](https://gist.github.com/sathomas/6672477). The tests ensure that the footer widget is installed and operating correctly.

![TDD browser window showing all tests passing](http://cl.ly/image/3N2J1Z2c1k1I/tdd-06.png)

### A Command Line Version

The test scaffolding can also be run from the command line without a browser. The exitlevel from the command line execution will indicate the number of failing tests, so the CLI implementation may be used for pre-commit hooks into version control or as part of a deployment script. To run the tests from the command line, just use the `mockcli:` option instead of the `mock:` option, e.g.:

```shell
bash-3.2$ grunt mockcli:footer
Running "mockcli:footer" (mockcli) task

Running "mocha_phantomjs:mock" (mocha_phantomjs) task


  Footer Widget
    Manifest
      ✓ should exist 
      ✓ should not be empty 
      ✓ should include a URL for the HTML template 
    HTML Template
      ✓ should exist 
      ✓ should not be empty 
      ✓ should include exactly one CSS style sheet 
      ✓ should include exactly one external JavaScript file 
    CSS Style Sheet
      ✓ should not be empty 
      Formatting
        ✓ should have a space before opening braces 
        ✓ should put opening braces on selector lines 
        ✓ should put expressions on a new line 
        ✓ should end expressions with a semicolon 
        ✓ should put closing braces on a new line 
        ✓ should put a space after expression colons 
        ✓ should put only one space after expression colons 
        ✓ should put only one expression per line 
        ✓ should indent expressions 4 spaces 
    JavaScript Module
      ✓ should not be empty 
      ✓ should return a function 
      Formatting
        ✓ should have no console.(log|warn|error|debug|trace) statements 
        ✓ should have no alert() calls 
        ✓ should have no double quotation marks other than within single quotation marks 
        ✓ should use "var <functionName> = function() {" 
        ✓ should put opening braces on the same line as the statement 
        ✓ should use exactly one space before an opening brace 
        ✓ should not put whitespace after an opening brace 
        ✓ should not put whitespace after a closing brace 
        ✓ should use literal notation 
        ✓ should use "===" instead of "==" 
        ✓ should use "!==" instead of "!=" 
        ✓ should use "var <ALLCAPS>" instead of "const" 
        ✓ should use ".on()" and ".off()" to attach event handlers 
        ✓ should not extend prototypes 
        - should avoid using Object.freeze, Object.preventExtensions, Object.seal, with, eval
        ✓ should use jquery or underscore for type checking 
    Static Rendering
      ✓ should insert a footer container on the page 
      ✓ should include a link to the Apero website 
      ✓ should open link in new window/tab 
    JavaScript Execution
      ✓ should insert current year in copyright notice 


  38 passing (60ms)
  1 pending


Done, without errors.
bash-3.2$
```

Comparing the command line output with the browser screen shot above shows that all tests run in either environment.

### Next Steps

To date, the unit test framework provides tools and libraries for minimal unit testing of OAE widgets. Future work will enhance these tools to support additional features, including:

* **Internationalization and Localization.** The ability to ensure that widgets are appropriately internationalized and that localization operates correctly.
* **Macros.** Testing the operation of standard and custom trimpath macros within the widget templates.* 