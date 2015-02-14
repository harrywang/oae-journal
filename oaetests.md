#OAE Testing

This documentation will cover both frontend and backend development of tests for OAE.

1. Back-end
  - Overview
  - Running back-end tests
  - Writing back-end tests
2. Front-end
  - Overview
  - Running front-end tests
  - Writing front-end tests
3. Pushing to Master (Continuous Integration)

##Back-end (Hilary)

Back end testing leverages Mocha.js.

Each file in a `tests` directory under your `Hilary/node_modules/oae-*` module will be executed through mocha and will have the option to run tests.

On the backend we mainly write integration tests that test functionality through the REST API. Each module should have a rest.js file that will contain REST endpoints. Each rest endpoint present in the module's rest.js file should have a counterpart in node_modules/oae-rest/lib/*.js

*Ideally, all tests should execute workflows through the REST api as that is how all applications (UI, mobile apps, cli, etc..) will interact with the backend.*

###Running Back-end tests

Install grunt command line tools globally
```
npm install -g grunt-cli
```

After grunt is installed, boot up all the necessary services to run OAE (cassandra, elastic search, redis, rabbitmq, etc) but not Hilary itself. Next, navigate to your Hilary directory and perform one of the following options (each will start Hilary and perform tests):

- Run the entire test suite + linting + style checkers by running: ```grunt```
- Run the entire test suite by running: ```grunt test```
- Run the entire test suite AND generate a code coverage report: ```grunt test-coverage```
- Run the tests for a specific module: grunt ```test-module:"oae-module-name"```
- Run one or more specific tests: ```MOCHA_GREP=“a substring from a testcase” grunt test```

###Writing back-end tests

Modules implement tests in a tests directory under each module, for example: ```Hilary/node-modules/oae-following/tests```. However, common functionality that could be useful for multiple tests (both tests within the current module and tests in other modules) is usually wrapped in a test utility file such as : ```Hilary/node-modules/oae-following/lib/test/util.js```

To write tests, its common to require other useful packages. For example, the oae-following module's test-following.js:

```javascript
var _ = require('underscore'); //provides many helper functions for performing actions on arrays
var assert = require('assert'); //performs tests

var ConfigTestsUtil = require('oae-config/lib/test/util'); //utility functions from the oae-config module
var RestAPI = require('oae-rest'); //used to make REST requests that tests are ran against
var RestContext = require('oae-rest/lib/model').RestContext; //used to execute rest requests in the context of various users
var TestsUtil = require('oae-tests/lib/util'); //utility functions from the oae-tests module

var FollowingTestsUtil = require('oae-following/lib/test/util'); //utility functions from the oae-tests module
```

Making use of utility functions from other testing modules makes for cleaner code and faster testing. In the above example, ConigTestsUtil contains functions for creating multiple tenants that this test suite uses to test following users between multiple tenants.

After the import statements, we begin with a Mocha describe function and pass it what we want to name this particular group of tests. All of our test/assert statements reside within this function.

```javascript
describe('Following', function() {
```

Next we create convenience variables to be used throughout our tests and assign them values through a before function. The before function is executed before any tests are run. In the oae-following module test snippet below, the before function is used to setup REST contexts and login as the global admin.

```javascript  
  var globalAdminOnTenantRestContext = null;
  var camAnonymousRestContext = null;
  var camAdminRestContext = null;
  var gtAdminRestContext = null;

  /**
  * Function that will fill up the anonymous and admin REST context
  */
  before(function(callback) {
    camAnonymousRestContext = TestsUtil.createTenantRestContext(global.oaeTests.tenants.cam.host);
    camAdminRestContext = TestsUtil.createTenantAdminRestContext(global.oaeTests.tenants.cam.host);
    gtAdminRestContext = TestsUtil.createTenantAdminRestContext(global.oaeTests.tenants.gt.host);

    // Authenticate the global admin into a tenant so we can perform user-tenant requests with a global admin to test their access
    RestAPI.Admin.loginOnTenant(TestsUtil.createGlobalAdminRestContext(), 'localhost', null, function(err, ctx) {
      assert.ok(!err);
      globalAdminOnTenantRestContext = ctx;
      return callback();
      });
      });
```

After the before function is executed, a number of tests are run. Tests are wrapped in it( ) calls that are passed with the name of the test. In the oae-following module test snippet below, mocha watches for errors to be thrown from the assert functions to determine whether or not a test has passed.

```javascript
/**
* Test that verifies following a user results in both the follower and following lists getting updated
*/
it('verify following and unfollowing', function(callback) {
  // Create 2 users, one following the other
  FollowingTestsUtil.createFollowerAndFollowed(camAdminRestContext, function(follower, followed) {

    // Ensure the follower and following feeds indicate they are indeed following
    FollowingTestsUtil.assertFollows(follower.user.id, follower.restContext, followed.user.id, followed.restContext, function() {

      // Unfollow the user and verify that they are no longer in the following and followers lists
      RestAPI.Following.unfollow(follower.restContext, followed.user.id, function(err) {
        assert.ok(!err);

        // Ensure the follower and following feeds indicate they are no longer following
        FollowingTestsUtil.assertDoesNotFollow(follower.user.id, follower.restContext, followed.user.id, followed.restContext, callback);
      });
    });
  });
});
```



##Front-end (3akai)

Front-end testing leverages Casper.js.

Casper will spin up a headless web-browser and simulate a user navigating through the UI. The tests have to tell casper which button or link to click, wait till something is rendered and then assert the correct things are displayed to the user.

Each widget can have its own set of tests by adding files into a directory called `3akai/node_modules/*modulename*/tests` in its widget folder.

###Running front-end tests

Install grunt command line tools globally
```
npm install -g grunt-cli
```

Navigate to your Hilary directory and perform one of the following options:

- Run all the tests by running: ```grunt test```       (this will spin up a Hilary server for you)
- Run just the unit tests: ```grunt qunit:test.oae.com``` (test.oae.com should point to an existing tenant on an already running system) *I create a special unused tenant just for testing, I'm not sure if running tests on a live tenant can cause issues*
- Run a specific functional test: ```grunt test-file --path node_modules/oae-core/preferences/tests/preferences.js```

Each casper test file begins with a casper test function that the test name is passed to. The rest of the testing is held within this function. Below is a snippet from the editprofile widget test.

```javascript
casper.test.begin('Widget - Edit profile', function(test) {
```

Next, multiple testing functions are declared. Below is a function that is used to test if the view profile box is properly displayed in the editprofile widget. Casper uses DOM selectors to navigate through the webpage.

```javascript
var openEditProfile = function() {
  casper.waitForSelector('#me-clip-container .oae-clip-content > button', function() {
    casper.click('#me-clip-container .oae-clip-content > button');
    test.assertExists('.oae-trigger-editprofile', 'Edit profile trigger exists');
    casper.click('.oae-trigger-editprofile');
    casper.waitUntilVisible('#editprofile-modal', function() {
      test.assertVisible('#editprofile-modal', 'Edit profile pane is showing after trigger');
      casper.click('#me-clip-container .oae-clip-content > button');
      });
      });
    };
```

Finally a call to casper.start() that configUtil.tenantUI is passed to (configUtil.tenantUI is essentially the url of the webpage). Within this function we call our previously defined functions. We can also make use of the userUtil library as shown below in the editprofile widget tests to handle activity like account authentication for testing purposes.

```javascript
casper.start(configUtil.tenantUI, function() {
  // Create a couple of users to test editprofile with
  userUtil.createUsers(1, function(user1) {
    // Login with that user
    userUtil.doLogIn(user1.username, user1.password);

    uiUtil.openMe();

    // Open the editprofile modal
    casper.then(function() {
      casper.echo('# Verify open edit profile modal', 'INFO');
      openEditProfile();
    });

    // Edit the profile
    casper.then(function() {
      casper.echo('# Verify edit profile', 'INFO');
      verifyEditProfile();
    });
```


##Pushing to Master

Whenever someone sends a PR or a commit gets merged into the master branch, all the tests in the respective repository will be run on OAE's Continuous Integration environment (Travis CI). We try to avoid mocking as much as possible! Lines that don’t get executed are obviously not covered by a test and could indicate a potential bug.


1. PR or commit gets merged into master branch
2. Travis CI will start an entire environment (incl Cassandra, Redis, ElasticSearch..) and run the test suites against a live system
3. Once the integration tests are finished, a “code coverage report” is uploaded to coveralls (https://coveralls.io/r/oaeproject/Hilary)
4. Additional code quality checkers are run to ensure that the codebase is of a consistent quality
