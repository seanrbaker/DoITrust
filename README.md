This is a simple project demonstrating access for iOS applications to profile-installed trust stores (not Apple-default trust).

To get started:
 - Clone the repo.
 - Open in XCode (6 or newer).
 - Run

At first you'll only be able to trust certificates found in the default iOS keychain (http://support.apple.com/en-us/HT5012).  In order to demonstrate trust in third party apps of other roots, you'll need to install them via mobile profiles on the device.  This can be done with the Apple Configurator, available free from the Mac App Store (no more Windows versions).  Just add the root certificate to the profile and export, then transfer the .mobileconfig file to your device (or the simulator) however is easiest in your environment (file transfer, online file store, email, etc.).  Simply attempting to open the file will allow it to be installed, after which you can test with as many private CAs as you like.  Have fun!

A few notes:

 - If like me you were thinking you could test easily by going to https://www.CAcert.org and using them as your test bed, you would be as wrong as I was.  MD5 hashes are verboten in iOS it would seem, so the root will never work.  You have to make your own / use another private which you have access to.
 - The certificates obviously require that you do all the normal things right: validity period, usage constraints, naming, etc.  Messing that up will of course cause you to fail.
 - I don't program day in and out anymore. This is released under a CC license, but is definitely not a model for successful or well-written iOS apps.  It was spare time between chores.
