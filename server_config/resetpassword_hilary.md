Back-end:Hilary
===

### 1. Interal API - Authentication
##### Find the following file
```
vi Hilary/node_modules/oae-authentication/lib/api.js
```

##### Create New API For generating secret token
```javascript
var getResetPasswordSecret =module.exports.getResetPasswordSecret  = function(ctx, tenantAlias, username, callback){...}
```
##### Create New API For reseting password with token
```javascript
var resetPassword = module.exports.resetPassword = function(ctx, tenantAlias, username, secret, newPassword, callback){...}
```

### 2. REST API - Authentication
##### Find the following file
```
vi Hilary/node_modules/oae-authentication/lib/rest.js
```

##### New API For getting secret
```
### a method to call internal api
var _getResetPasswordSecret = function(req, res){...}

### setting the rest api address
OAE.globalAdminRouter.on('get', '/api/auth/local/reset/init/:username', _getResetPasswordSecret);
OAE.tenantRouter.on('get', '/api/auth/local/reset/init/:username', _getResetPasswordSecret);
```

##### New API For reseting password
```
### a method to call internal api
var _resetPassword = function(req, res){...}

### setting the rest api address
OAE.globalAdminRouter.on('post', '/api/auth/local/reset/change/:username/:secret', _resetPassword);
OAE.tenantRouter.on('post', '/api/auth/local/reset/change/:username/:secret', _resetPassword);
```
### 3. Email Templates

##### Creating the following Email template files

```
### create a new folder for templates, name matters
mkdir Hilary/node_modules/oae-authentication/emailTemplates/

### create following files under the folder, name matters
$ touch reset.html.jst
$ touch reset.meta.json.jst
$ touch reset.txt.jst
$ touch reset.shared.js
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
