Ensure that you've disabled reCaptcha for the tenant where you're loading in users. It can be disabled in the admin UI under the Principals module.

this is 

go to model loader folder and run the following

    node generate.js -b 1 -t tenant1 -u 50 -g 50 -c 100 -d 100 -f 50
    node loaddata.js -b -h http://tenant1.oae.com

You can check the current index using:

    curl 'localhost:9200/_cat/indices?v'
    health index pri rep docs.count docs.deleted store.size pri.store.size
    yellow oae     5   1       1157           81      1.7mb          1.7mb


the default number for users, contents, folders, etc. are very large - if the number is big - it breaks the search (don't know why) the health turns to red after loading a large number of items:

    .alias('u', 'users')
    .describe('u', 'Number of users per batch')
    .default('u', 1000)

    .alias('g', 'groups')
    .describe('g', 'Number of groups per batch')
    .default('g', 2000)

    .alias('c', 'content')
    .describe('c', 'Number of content items per batch')
    .default('c', 5000)

    .alias('f', 'folders')
    .describe('f', 'Number of folders per batch')
    .default('f', 2500)

    .alias('d', 'discussions')
    .describe('d', 'Number of discussion items per batch')
    .default('d', 5000)
    .argv;
