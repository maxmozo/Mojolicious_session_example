# LDAP

We've made sure that the passwords are sent securely.  How about checking them
against a common authentication method, like LDAP?  Start with a new app
```
mojo generate app LDAP	# I've already done this bit
cd ldap
```

## lib/LDAP/Controller/Login.pm

I'm going to rip out the example stuff from the `check_credentials` method
and replace it with an LDAP authorization call.

### ldap_config.yml
I put all my LDAP server config values in a file called `ldap_config.yml` and
put it in the top level of the app.
`baseDN` is the DN of the tree where you search for users, `username` is the name of 
the attribute that you'll be filtering on and `id` is the name of the identifier
of the LDAP entry (usually `dn`).

This gets loaded into the file and populates the `$config` hashref on line 23.
I used YAML because it's included in the Perl core.

### `check_credentials()`
The first thing I do is make sure there's a `$username`.  An empty return is good for
indicating a failed login.
Line 30 is just there so that the test passes and should be removed from a production
system, unless you want the backdoor there.
`Net::LDAP->new` makes a connection to an LDAP server and `search`, searches the `base_DN`
for `username=$username` and returns the `id` attribute for the user, if one exists.
`return` if you don't have an `id` (line 40) or non-existant people can login.
Finally, bind to LDAP as the user with the password (line 43) and check the result.
I imported the constant `LDAP_INVALID_CREDENTIALS` from Net::LDAP and checked 
the return code of the bind.

On line 39 when I pop the first entry off the search results, I am assuming that
there's only one match for the username because I only check the first result.
This feels right, but perhaps not for everyone.

# Try it out
First copy the file `ldap_config.sample.yml` to `ldap_config.yml` and edit
the values to connect to your LDAP server.

Start the server with
```
morbo -l 'https://*:3000?cert=./server.crt&key=./server.key' script/ldap
```
and click through the Login link on [localhost:3000/](https://localhost:3000/)
to get to the [Login page](https://localhost:3000/login)

# Test the app

Of course, the tests for and requiring logins will fail using pure LDAP authentication
because my example logins aren't in your LDAP.  Nothing stopping you from removing
the dummy login and using a test account of your own to make sure that the
app is connecting to your LDAP correctly.

```
script/ldap test 
```


# Future Work

This tutorial finishes here, but if you're serious about security, you will start
to consider logging access to your app.  There are a number of blogs and pages that
will get you going with logging.  Perhaps the quickest is
[Mojolicious::Plugin::AccessLog](https://metacpan.org/pod/Mojolicious::Plugin::AccessLog),
a plugin to easily generate an access log.  You only need to consider where the
log will be and whether you want to customize the log format.  It's a one line command
in both Mojolicious and Mojolicious::Lite.

For more control with a little more work, take a look at
[Mojo::Log](https://metacpan.org/pod/Mojo::Log).
I've been using it on one of my projects and it's not difficult.
There are a number of other solutions, such as log4perl, the ConsoleLogger plugin, etc

## More information

* [Mojo::Log](http://mojolicious.org/perldoc/Mojo/Log)
* [Nyble's blog](http://pseudopoint.net/wp/?p=190)
* [Logging and Testing](https://groups.google.com/forum/#!topic/mojolicious/X09J7ms7MQw)
* [tempire's blog](http://blogs.perl.org/users/tempire/2011/02/logginz-ur-console-with-mojolicious.html)

And in various examples in the [Mojolicious::Guides::Cookbook]
(http://mojolicio.us/perldoc/Mojolicious/Guides/Cookbook)