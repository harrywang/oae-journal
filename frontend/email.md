Hi Simon,

That makes lots of sense - I just triggered another following event and received an email after 15 minutes (screenshot: https://www.dropbox.com/s/nt7386tkvvsco1l/Screenshot%202014-12-02%2013.35.52.png?dl=0).

Google blocks the sign-in attempt first (https://www.dropbox.com/s/qkmt97zidlu0zp1/Screenshot%202014-12-02%2013.37.15.png?dl=0) - I had to change Gmail security setting to make it work.

We are working on the reset password feature, which needs to send users password reset emails - that’s the use case. Any general suggestion on how to implement that feature with existing OAE modules? Maybe I should start another separate email thread for that.

Thanks again for explaining the email services to me.

Harry


On Dec 2, 2014, at 5:17 AM, Simon Gaeremynck <gaeremyncks@gmail.com> wrote:

Doh, I just realised what’s going on. So in that 1-15 minute period before the email is sent out,
if you open up your notification stream (as you’re doing in the screenshot) no email will be sent.
Although maybe a bit counter-intuitive, the idea is that Alice is on the system and she gets an
email worthy activity BUT she sees it happening live, there’s no reason to send her an email
as she already saw it happen.

So if you’re debugging email notifications, you don’t want to open the notification toggle.


As far as source code goes, the following files are relevant:

1. Hilary/node_modules/oae-activity/lib/internal/email.js
This file will queue email in the `DELIVERED_ACTIVITIES` event handler and do the actual sending.

2. Hilary/node_modules/oae-activity/emailTemplates/mail.*
These files contain the templates. There is only 1 template for all the activity-related emails

3. Hilary/node_modules/oae-email/lib/api.js
This module is responsible for actually sending out the emails

4. 3akai-ux/shared/oae/js/activityadapter.js
Contains logic to adapt an activity to an object that can be used in the email templates (and in the UI)

As you can see, activity emails are really complex in OAE. Depending on what you’re trying to
do though, you might not need all of this. Maybe the oae-email module will suffice. Can you give
some more info about your use-case?


Kind regards,

Simon

On 2 Dec 2014, at 04:48, Harry Wang <harryjwang@gmail.com> wrote:

Hi Simon,

Thanks again for providing such detailed explanations and spending time helping me.

I have restarted everything including Hilary and had another user following me (screenshot: https://www.dropbox.com/s/nb7fuisl4sehsx7/Screenshot%202014-12-01%2023.35.13.png?dl=0). I also made sure my account has a valid email address.

The event shows up in the notification but I still did not receive any email.

The Hilary log is at https://gist.github.com/harrywang/7f78822ecd03453ddb3b

Could you please also let me know where is the source code for sending out emails? in which module/widget? We want to understand how to send out emails via OAE and how the current email templates are incorporated.

Thanks!

Harry


On Dec 1, 2014, at 5:27 PM, Simon Gaeremynck <gaeremyncks@gmail.com> wrote:

Hi Harry,

Ok, so here’s some more information. (You’ve probably picked the most complex subject in the entire OAE stack)

Sending emails is hooked into the activity processor, so activities need to be collected first.
This happens every `config.activity.collectionPollingFrequency` seconds (if `config.activity.processActivityJobs` is set to true).
Since you got the activity in your notification stream, this is clearly the case.

The system then checks whether emails needs to be sent out every `config.activity.mail.pollingFrequency` seconds.
This artificial delay is introduced so that if a user goes into the system and generates a ton of activities, your inbox isn’t flooded
but you get a single email that aggregates all activities nicely. This means that there can be a delay up to 15 minutes.
You can reduce this value, but it needs to be at least 60 seconds.

There is an additional complexity involved where we won’t send an email if the activity happened `config.activity.mail.gracePeriod`
(or less) seconds ago. This is to avoid the situation where someone is uploading 10 files and email collection happens
somewhere between the 7th and 8th file being uploaded and resulting in 2 emails (one with 7 new content items, one with 3 new content items.)
So, if the activity happened less than the configured gracePeriod seconds ago, we wait a bit (`config.activity.mail.pollingFrequency` seconds).

Now, all of this is to say that “immediate” emails are actually not really *immediate*, but rather anything from within a few seconds
to up-to half an hour.

All that said, it looks like you’ve configured everything correctly though so something else must be going on. Can you:
1. Restart your Hilary service
2. tail the logs into a file
3. Trigger an email worthy activity (ie, another user following you)
4. Send that log to this list (please include everything from the point the app server starts up)

Also, ensure that your user actually has a valid email address configured. If you log in through Twitter for example,
the user will not have an email address.

The error that you pasted has to do with ElasticSearch and seems unrelated. It might screw up with the event cycle though
so you should probably check out whats happening. I haven’t personally seen that error before. OOTB, ElasticSearch will
try to cluster with any other ElasticSearch instance it can find on the network. Maybe something is going wrong there?

I hope any of the above helps.

Kind regards,
Simon

On 1 Dec 2014, at 18:44, Harry Wang <harryjwang@gmail.com> wrote:

Hi Simon,

Thanks a lot for your reply - it is very useful.

However, I have changed ‘debug’ to false, and had configured the smtp using my Gmail account but still cannot get any emails - I tried to login as another user and followed myself - the following event shows in my notifications as shown below:

https://www.dropbox.com/s/dob1234hj1cwqd1/Screenshot%202014-12-01%2013.40.22.png?dl=0

But I am not getting any email for that event. Could you please help with the following questions:

1. where is the source code for sending out emails? in which module/widget?
2. how to check the log to see what went wrong for email services? The Hilary console has the following error:

[2014-12-01T18:38:05.033Z] ERROR: oae-search/1370 on Harrys-MacBook-Pro.local: Error indexing a document (id=u:tenant1:Zy1Ey5ULr#resource_followers#)
err: {
  "error": "UnavailableShardsException[[oae][2] [2] shardIt, [0] active : Timeout waiting for [1m], request: index {[oae][resource_followers][u:tenant1:Zy1Ey5ULr#resource_followers#], source[{\"followers\":[\"u:tenant1:-ye21k4MuU\",\"u:tenant1:-ynP9g5vU\",\"u:tenant1:WyIRqlcDL\"],\"_type\":\"resource_followers\"}]}]",
  "status": 503
}
--
doc: {
  "followers": [
  "u:tenant1:-ye21k4MuU",
  "u:tenant1:-ynP9g5vU",
  "u:tenant1:WyIRqlcDL"
  ],
  "_type": "resource_followers"
}
--
opts: {
  "parent": "u:tenant1:Zy1Ey5ULr"
}


Thanks!

Harry


On Dec 1, 2014, at 8:44 AM, Simon Gaeremynck <gaeremyncks@gmail.com> wrote:

Hi Harry,

Apologies for not responding earlier.

1. Configuration
You’ll need to set `debug` to false in the `config.email` section.

2. SMTP / Sendmail
OAE supports a couple of methods of sending email. By either opening a direct
SMTP connection with your mail provider (for example gmail) or by using sendmail
and making use of the mailserver running on the box (for example postfix).
For development purposes, the default of smtp and gmail is probably fine.

3. Tenant-specific email templates are no longer supported.  E-mails re-use the tenant
skinning values so they are customisable for each tenant in that regard. If you wish to
edit the default activity email template, it can be found in
Hilary/node-modules/oae-activity/emailTemplates. I would strongly advise you to not
make this change lightly as debugging email and getting them right in all mail clients
has been a massive pain.

4. Email immediateness
This is a slightly complicated area. There is no difference in regards to which emails
get delivered between a user with the “immediate” preference and a user with the “daily” preference.
Immediate just means that the user will receive an e-mail within ~15 minutes of an “email-worthy” activity
occurring.

“Email-worthy” activities are defined when registering an activity type [1]. When you define
an activity type, you have to specify to which streams it should be delivered. In the case of following,
we’d like to send an activity to activity, notification and email streams. The `router` object
determines to whose streams they will be delivered for each activity entity (actor, object & target).

For example, when a following activity occurs, it consists out of:
- an actor (the user who follows another user)
- an object (the user who is being followed)
The router for the `email ` stream defines:
'email': {
  'router': {
    'object': ['self']
  }
}
This means the activity will be delivered to the email stream of the object entity. Thus we will
send an email to the user who is being followed.

All activity types are defined in `<oae-module>/lib/activity.js` files. [2]

I hope that helps,

Kind regards,
Simon


[1] https://github.com/oaeproject/Hilary/blob/master/node_modules/oae-following/lib/activity.js#L33
[2] https://github.com/oaeproject/Hilary/blob/master/node_modules/oae-content/lib/activity.js
https://github.com/oaeproject/Hilary/blob/master/node_modules/oae-discussions/lib/activity.js
https://github.com/oaeproject/Hilary/blob/master/node_modules/oae-folders/lib/activity.js
https://github.com/oaeproject/Hilary/blob/master/node_modules/oae-following/lib/activity.js
https://github.com/oaeproject/Hilary/blob/master/node_modules/oae-preview-processor/lib/activity.js
https://github.com/oaeproject/Hilary/blob/master/node_modules/oae-principals/lib/activity.js

On 1 Dec 2014, at 13:24, Harry Wang <harryjwang@gmail.com> wrote:

Hi,

I sent the following email during the holidays and want to know whether someone can help.

Thanks,

Harry

Sent from my iPhone

On Nov 28, 2014, at 11:19 AM, Harry Wang <harryjwang@gmail.com> wrote:

Hi Everyone,

Happy thanksgiving!

I tried to configure the email service for OAE but cannot make it work. I tested a local copy of OAE and changed the email section in the config.js in Hilary folder (attached at the end of this email).

I have a few questions:

1. Any other configuration I should change to make emails work? (I have changed the Gmail username and pwd to real ones)
2. What’s the difference between SMTP and sendmail? Which one to use and why?
3. Where is the "tenant-specific email template” located and how to change the templates?
4. In preferences, email preference says "Receive an immediate email when something important happens” - how “something important” is defined and where to change that?

Thanks a lot!

Harry

/**
* `config.email`
*
* Configuration namespace for emails.
*
* @param  {Boolean}    [debug]                     Determines whether or not email is in debug mode. If in debug mode, email messages are logged, not actually sent through any service.
* @param  {String}     transport                   Which method of e-mail transport should be used. Either `SMTP` or `sendmail`.
* @param  {String}     deduplicationInterval       Specifies the interval in seconds in which the same email can't be sent out again
* @param  {Object}     throttling                  The throttling configuration
* @param  {Number}     throttling.count            Specifies the number of emails a user can receive in `throttling.timespan` seconds before throttling takes effect
* @param  {Number}     throttling.timespan         Specifies the throttling timespan in seconds
* @param  {String}     [customEmailTemplatesDir]   Specifies a directory that holds the tenant-specific email template overrides
* @param  {Object}     [sendmailTransport]         The sendmail information for sending emails.
* @param  {String}     [sendmailTransport.path]    The path that points to the sendmail binary.
* @param  {Object}     [smtpTransport]             The SMTP connection information for sending emails. This is the settings object that will be used by nodemailer to form an smtp connection: https://github.com/andris9/Nodemailer
*/
config.email = {
  'debug': false,
  'customEmailTemplatesDir': null,
  'deduplicationInterval': 7 * 24 * 60 * 60,   //  7 days
  'throttling': {
    'count': 10,
    'timespan': 2 * 60                       //  2 minutes
    },
    'transport': 'SMTP',
    'sendmailTransport': {
      'path': '/usr/sbin/sendmail'
      },
      'smtpTransport': {
        'service': 'Gmail',
        'auth': {
          'user': ‘mygmailaccount@gmail.com',
          'pass': ‘mygmailpwd'
        }
      }
    };

    --
    You received this message because you are subscribed to the Google Groups "Open Academic Environment (OAE)" group.
    To unsubscribe from this group and stop receiving emails from it, send an email to oae+unsubscribe@apereo.org.
    To post to this group, send email to oae@apereo.org.
    Visit this group at http://groups.google.com/a/apereo.org/group/oae/.
