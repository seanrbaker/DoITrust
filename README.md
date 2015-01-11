This is a simple project demonstrating access for iOS applications to profile-installed trust stores (not Apple-default trust).

A few notes:

 - If like me you were thinking you could test easily by going to https://www.CAcert.org and using them as your test bed, you would be as wrong as I was.  MD5 hashes are verboten in iOS it would seem, so the root will never work.  You have to make your own / use another private which you have access to.
 - This obviously requires that you do all the other things right: validity period, usage constraints, naming, etc.
 - But it is color coded for when it passes or fails!
 - I don't program day in and out anymore. This is released under a CC license, but is definitely not a model for successful or well-written iOS apps.  It was spare time between chores.
