Front-end:3akai-ux
===

##### Add resetpassword link under signin window.
    vi /3akai-ux/node_modules/oae-core/topnavigation/toptopnavigation.html

    ### Find __MSG__NO_ACCOUNT_YET__ in the html file, add the following html code above it.

    <span>__MSG__FORGET_PASSWORD__
      <button
        id="topnavigation-signin-signup"
        type="button"
        class="btn btn-link oae-trigger-resetpassword">
        __MSG__RESET_PASSWORD__
      </button>
    </span>

##### Create resetpassword popup modal after click the resetpassword link

```
mkdir /3akai-ux/node_modules/oae-core/resetpassword
mkdir /3akai-ux/node_modules/oae-core/resetpassword/bundles
touch /3akai-ux/node_modules/oae-core/resetpassword/css/resetpassword.css
touch /3akai-ux/node_modules/oae-core/resetpassword/js/resetpassword.js
touch /3akai-ux/node_modules/oae-core/resetpassword/manifest.json
touch /3akai-ux/node_modules/oae-core/resetpassword/resetpassword.html
```

#####resetpassword.css
```css
/*!
* Copyright 2014 Apereo Foundation (AF) Licensed under the
* Educational Community License, Version 2.0 (the "License"); you may
* not use this file except in compliance with the License. You may
* obtain a copy of the License at
*
*     http://opensource.org/licenses/ECL-2.0
*
* Unless required by applicable law or agreed to in writing,
* software distributed under the License is distributed on an "AS IS"
* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
* or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

#resetpassword-modal .modal-dialog {
  width: 0px;
}

@media (max-width: 991px) {
  #resetpassword-modal .modal-dialog {
    margin: 10px;
  }

  #resetpassword-modal .modal-dialog,
  #resetpassword-modal .modal-content {
    width: auto;
  }
}

#resetpassword-form {
  margin: 0;
}

#resetpassword-form .control-label {
  padding-right: 5px;
}

#resetpassword-username-controls {
  position: relative;
}

#resetpassword-username-available {
  font-size: 18px;
  position: absolute;
  right: 10px;
  top: 8px;
}

#resetpassword-username-available.fa-times {
  color: #8F0222;
}

#resetpassword-usercheck-container {
  display: -webkit-box;
  display: -moz-box;
  display: -ms-flexbox;
  display: -webkit-flex;
  display: flex;
  margin-top: 15px;
}

.ie-lt10 #resetpassword-usercheck-container {
  display: table;
  width: 100%;
}

#resetpassword-accept-and-create-column,
#resetpassword-captcha-column {
  align-items: stretch;
  float: none;
  margin: 0;
  vertical-align: top;
}

.ie-lt10 #resetpassword-accept-and-create-column,
.ie-lt10 #resetpassword-captcha-column {
  display: table-cell;
  padding-right: 0;
}

.ie-lt10 #resetpassword-accept-and-create-column {
  right: -25px;
}

#resetpassword-captcha-container {
  padding-right: 0;
  padding-left: 10px;
}

#resetpassword-captcha-error {
  margin-top: 3px;
}

#resetpassword-accept-and-create-column {
  position: relative;
}

#resetpassword-accept-container {
  margin-bottom: 45px;
}

#resetpassword-accept-container label {
  text-align: left;
}

#resetpassword-create-account {
  bottom: 0;
  margin: 0 15px 7px 0;
  position: absolute;
  right: 0px;
}

#resetpassword-terms-and-conditions {
  font-weight: bold;
  padding: 0px 0 0 3px;
}

#resetpassword-terms-and-conditions-container .well {
  margin-bottom: 0;
  overflow: auto;
}

#resetpassword-accept-container .has-error.help-block {
  margin-bottom: 0;
}

#recaptcha_image,
#recaptcha_image img {
  height: auto !important;
  width: 100% !important;
}

#recaptcha_image img {
  border-style: solid;
  border-width: 1px;
}

#resetpassword-captcha-container {
  margin-top: 5px;
}

#resetpassword-captcha-container a.btn {
  margin: 2px 0 7px;
}

#resetpassword-captcha-container a.btn i {
  font-size: 14px;
}

#resetpassword-captcha-container .form-group,
.resetpassword-captcha-buttons {
  margin: 7px 0 0 0;
}

.resetpassword-captcha-input-container {
  padding-right: 87px; /* Make enough space for the floated captcha buttons to sit alongside this container */
}

/* Align the T&C label and input element with the other input elements in the resetpassword form */
#resetpassword-accept-terms-button {
  margin-top: -5px;
}

#resetpassword-accept-terms-button label {
  padding-left: 19px;
}

#resetpassword-accept-terms-button input[type="checkbox"] {
  margin-left: -19px;
  margin-top: 4px;
}

@media (max-width: 767px) {
  #resetpassword-usercheck-container,
  #resetpassword-accept-and-create-column,
  #resetpassword-captcha-column {
    display: block;
  }

  #resetpassword-username-container {
    margin-top: 15px;
  }

  #resetpassword-captcha-container {
    padding: 15px 0 0 0;
  }

  #resetpassword-accept-container {
    margin-top: 10px;
    padding: 0;
  }

  #resetpassword-form   #resetpassword-usercheck-container {
    margin-top: 7px;
  }

  .ie-lt10 #resetpassword-accept-and-create-column,
  .ie-lt10 #resetpassword-captcha-column,
  .ie-lt10 #resetpassword-usercheck-container {
    display: block;
  }
  .ie-lt10 #resetpassword-accept-and-create-column,
  .ie-lt10 #resetpassword-captcha-column {
    margin-right: -15px;
  }
  .ie-lt10 #resetpassword-accept-and-create-column {
    right: 0;
  }
  .ie-lt10 #resetpassword-create-account {
    margin-right: 0;
  }
}

```
#####resetpassword.js

```js
/*!
* Copyright 2014 Apereo Foundation (AF) Licensed under the
* Educational Community License, Version 2.0 (the "License"); you may
* not use this file except in compliance with the License. You may
* obtain a copy of the License at
*
*     http://opensource.org/licenses/ECL-2.0
*
* Unless required by applicable law or agreed to in writing,
* software distributed under the License is distributed on an "AS IS"
* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
* or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

define(['jquery','underscore','oae.core'], function($, _, oae) {

  return function(uid, showSettings) {

    // The widget container
    var $rootel = $('#' + uid);
    /**
    * Get Secret: A start point for reseting passord
    */
    var getSecret = function(){
      $(document).on('submit','#resetpassword-input-username', function(event){

        // disable redirect to other page
        event.preventDefault();

        var username = $.trim($('#resetpassword-username', $(this)).val());

        $.ajax({
          'url': '/api/auth/local/reset/init/oae/'+username,
          'type': 'POST',
          'data': null,
          'success': function(data) {
            //callback(null, data);
            oae.api.util.notification('Congratulations!','A Email has been sent to your Email address.');

            ////// An alternative solution for notification.
            //$('#resetpassword-input-username', $rootel).hide();
            //$('.modal-body').html("<p class='text-center'>Congratulations! A Email has been sent to your Email address.</p>");
            },
            'error': function(data) {
              oae.api.util.notification('Sorry!','The Email has not been sent out!');
            }
            });
            });
          };

          /**
          * Show the resetpassword form
          */
          var showResetForm = function() {
            $('#resetpassword-input-username', $rootel).show();
          };

          /**
          * Set focus to input text-box
          */
          var setFocus = function(){
            $('#resetpassword-modal').on('shown.bs.modal', function () {
              $('#resetpassword-username').focus()
              });
            };

            /**
            * Initialize the resetpassword modal dialog
            */
            var initResetpassword = function() {
              $(document).on('click', '.oae-trigger-resetpassword', function() {
                // Show the register form and hide the Terms and Conditions
                showResetForm();

                // set focus
                setFocus();

                // Trigger the modal dialog
                $('#resetpassword-modal', $rootel).modal({
                  'toggle':'show',
                  'backdrop': 'static'
                  });
                  });
                };
                initResetpassword();
                getSecret();
              };
              });
```

#####resetpassword.html

```html
<!-- CSS -->
<link rel="stylesheet" type="text/css" href="css/resetpassword.css" />

<!-- MODAL -->
<div id="resetpassword-modal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="resetpassword-modal-title" aria-hidden="true">
<div class="modal-dialog modal-sm">
<div class="modal-content">
<div class="modal-header">
<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&#215;</button>
<h3 id="resetpassword-modal-title">__MSG__RESET_PASSWORD__</h3>
</div>
<div class="modal-body">
<form id="resetpassword-input-username" class="form-horizontal" role="form">
<div class="form-group">
<label class="control-label col-lg-5" for="resetpassword-new-password">__MSG__USERNAME_COLON__</label>
<div class="col-lg-7">
<input type="text" id="resetpassword-username" name="username" placeholder="username" class="form-control required maxlength-short">
</div>
</div>
<div class="text-center">
<button type="submit" class="btn btn-primary">Submit</button>
</div>
</form>
</div>
</div>
</div>
</div>

<!-- JAVASCRIPT -->
<script type="text/javascript" src="js/resetpassword.js"></script>

```
##### Create a html page for reseting password page
```
touch 3akai-ux/ui/resetpassword.html
```

##### Create a js file for reseting password page
```
touch 3akai-ux/ui/js/resetpassword.js
```

##### Configure **nginx** configuration file
```
vi /Users/Steven/oae/3akai-ux/nginx/nginx.conf
```

Add following to **nginx.conf** file after `rewrite ^/user`
```
rewrite ^/resetpassword$	/ui/resetpassword.html last;
rewrite ^/resetpassword/(.*)	/ui/resetpassword.html last;
```

DB: Cassandra
=======
##### Add a new column for User to store secret token
```
$ cd apache-cassandra-2.0.1/bin
$ ./cqlsh

### select column family
cqlsh> USE OAE;

### check the current schema for table
cqlsh> DESCRIBE TABLE "AuthenticationLoginId";

### check the details for table
cqlsh> SELECT * FROM "AuthenticationLoginId";

### add a new column to table
cqlsh> ALTER TABLE "AuthenticationLoginId" ADD "secret" text;

### set the consistency to table
cqlsh> CONSISTENCY QUORUM;

```

Email Server Config
========
##### Modify your own user and pass under the following file for smtpTransport.
```
vi Hilary/config.js
```
