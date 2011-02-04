MobileNotifier
==============
iOS Notifications Done Right.
----------------------------

by Peter Hajas
--------------
web: peterhajas.com

email: peterhajas (at) gmail (dot) com

Intro
-----

MobileNotifier is a complete rewrite, from the ground up, of the iOS Notification System. It strives to employ the core ideas of a well designed interface: it's accessible, discoverable, usable and as little design as possible (as Dieter Rams would say).

Due to the way the software functions, MobileNotifier requires a jailbroken iOS device running MobileSubstrate, Activator and Preference Loader. MobileNotifier will inform you of missing dependencies upon install.

MobileNotifier now includes a pretty awesome new companion app: MobileNukifier! MobileNukifier does what it sounds like - it deletes your MobileNotifier directory (/var/mobile/Library/MobileNotifier/) containing your notifications, and resprings the phone. This clears things out, and allows for easier testing once new versions are released.

Building
--------

To build MobileNotifier, you'll need Theos (the iOS makefile system by Dustin Howett) installable from:

http://iphonedevwiki.net/index.php/Theos/Getting_Started

Theos can be installed on Mac OS X, Linux and iOS. MobileNotifier has only been built on Mac OS X.

Then, you'll need the decompiled 3.x headers from rpetrich's fork of Kennytm in $THEOS/include/ with frameworks at top level (i.e. $THEOS/include/Springboard). You can find those here:

https://github.com/rpetrich/iphoneheaders

You'll then need a copy of libactivator.dylib (you can get this off your iOS device with Activator installed) at $THEOS/lib/

Once you have all that set up, run make and then make package to generate a .deb. scp this .deb to your device, and run dpkg -i thedeb.deb as root to install. Alternatively, you can run make package install with the "THEOS_DEVICE_IP" environment variable set (for example, iPhone.local).

Helping
-------

MobileNotifier is open source, and would greatly appreciate your help. Please submit any changes you'd like to see made either as GitHub pull requests, or as patchfiles emailed to me (GitHub preferred). If you'd like to contact me about helping out, email the address listed above.

Licence
-------

MobileNotifier is open source software and licensed under the BSD license, because I enjoy readability. You can read this license in the License file included with this source tree, and at the top of every file.

Credits
-------

MobileNotifier is the result of lots of people's help. Here's a non-exhaustive list in no particular order:


Mukkai Krishnamoorthy - cs.rpi.edu/~moorthy - for being the faculty sponsor

Sean O' Sullivan - for his financial contributions. Thanks so much Mr. Sullivan.

Dustin Howett - howett.net - for Theos and amazing help on IRC!

Ryan Petrich - github.com/rpetrich - for Activator and help on IRC

chpwn - chpwn.com - for his awesome tweaks and help on IRC

Aaron Ash - multifl0w.com - for his help on IRC and invaluable advice

KennyTM - github.com/kennytm - for his decompiled headers

Jay Freeman - saurik.com - for MobileSubstrate, Cydia, Cycript, Veency and countless other gifts to the community
