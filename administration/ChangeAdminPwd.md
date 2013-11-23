# How to change the username/password for the global admin UI

To do it manually, I'd recommend using one of firefox or chrome's
javascript console.

1. Log in to the global admin UI
2. Visit the "/api/me" endpoint for your admin user by going to
https://<myadminuihost>/api/me
3. Record the "id" field of that response, this is your admin user's
internal user id
4. Go back to the admin ui main page (don't log out)
5. Bring up the JavaScript console and run this command:

$.post('/api/user/u:admin:eye5PG2Q_7/password', {'oldPassword':
'administrator', 'newPassword': 'newpassword'});

While replacing "u:admin:eye5PG2Q_7" with the id of your own global
admin user, and replacing the value of "newPassword" with the password
you would like to assign. This command essentially performs an HTTP
POST request to the application as the admin user, using jQuery (which
is provided by the admin UI).