MobileNotifier
iOS Notifications Done Right.
==============
by Peter Hajas
--------------
web: peterhajas.com

email: peterhajas (at) gmail (dot) com

twitter: @peterhajas

UI Design and User Experience by Kyle Adams

web: kyleadams.org

twitter: @iamkyleadams

Intro
-----

MobileNotifier is a complete rewrite, from the ground up, of the iOS Notification System. It strives to employ the core ideas of a well designed interface: it's accessible, discoverable, usable and as little design as possible (as Dieter Rams would say).

Due to the way the software functions, MobileNotifier requires a jailbroken iOS device running MobileSubstrate, Activator and Preference Loader. MobileNotifier will inform you of missing dependencies upon install.

MobileNotifier now includes a pretty awesome new companion app: MobileNukifier! MobileNukifier does what it sounds like - it deletes your MobileNotifier directory (/var/mobile/Library/MobileNotifier/) containing your notifications, and resprings the phone. This clears things out, and allows for easier testing once new versions are released.

Download
-------------

Add http://cydia.myrepospace.com/timnovinger as a Cydia source. This
repository has the *latest* version of the project.

Project Setup
-------------

1. Install Git from [http://git-scm.com/](http://git-scm.com/).

2. Clone the repository into a folder on your local machine. This example is written using your home folder.

    - `mkdir ~/code`
    - `cd ~/code`
    - `git clone git://github.com/peterhajas/MobileNotifier.git`

3. Initialize and pull in the necessary Git sub-modules.

    - `cd ~/code/MobileNotifier`
    - `git submodule init`
    - `git submodule update`

Environment Setup
-----------------

MobileNotifier has only been built on Mac OS X. Theos can be installed on Mac OS X, Linux and iOS.

1. Install Xcode. A free developer account is required in order to download it. *note: MobileNotifier only compiles using iOS 4 SDK*

    [http://developer.apple.com/technologies/xcode.html](http://developer.apple.com/technologies/xcode.html)

2. Install MacPorts

    [http://www.macports.org/install.php](http://www.macports.org/install.php)

3. Install Theos *(the iOS makefile system by Dustin Howett)* using this guide:

    - [Mac Instructions](http://iphonedevwiki.net/index.php/Theos/Getting_Started#For_Mac_OS_X). Pay close attention to how your `SDKVERSION` environment variable is set.
    - [iPhone Instructions](http://iphonedevwiki.net/index.php/Theos/Getting_Started#On_iOS)

4. Download the decompiled 3.x headers from rpetrich's fork of Kennytm in `$THEOS/include/`. Be sure place the frameworks at top level *(i.e. $THEOS/include/Springboard)*.

    [https://github.com/rpetrich/iphoneheaders/archives/master](https://github.com/rpetrich/iphoneheaders/archives/master)

5. After copying the headers into ``$THEOS/include``, you'll need to run the following command to copy some required system files not included by default.

    `cp /System/Library/Frameworks/IOSurface.framework/Headers/IOSurfaceAPI.h $THEOS/include/IOSurface/.`

6. Copy libactivator.dylib to ``$THEOS/lib/`` *(you can get this off your iOS device with Activator installed)*

7. Install dpkg via MacPorts *(if not already installed)*

    `sudo port install dpkg`

8. Install gnutar via MacPorts *(if not already installed)*

    `sudo port install gnutar`

9. Symlink tar to gnutar by running the following command:

    `ln -sf /usr/bin/gnutar /usr/bin/tar`

Building
--------

Currently, MobileNotifier does not build without warnings. Please set the shell variable `GO_EASY_ON_ME` to `1` in your environment.

1. Run `make`

2. Run `make package` to generate a .deb.

Installation methods
--------------------

 - **Manual:** `scp` the resulting .deb file to your device, and run `dpkg -i thedeb.deb` as root to install.
 - **Automated:** run `make package install` with the **THEOS_DEVICE_IP** environment variable set (example: `export THEOS_DEVICE_IP=iPhone.local`).

Helping
-------

MobileNotifier is open source, and would greatly appreciate your help. Please submit any changes you'd like to see made either as GitHub pull requests, or as patchfiles emailed to me (GitHub preferred). If you'd like to contact me about helping out, email the address listed above.

Licence
-------

MobileNotifier is open source software and licensed under the BSD license, because I enjoy readability. You can read this license in the LICENSE file included with this source tree, and at the top of every file.

MobileNotifier's images and graphical content are licensed under a separate license, the Creative Commons Attribution-NoDerivs 3.0 Unported License. Please see the included ContentLicense.md file at the root of the repository.

Please note that all images and graphical content, unless noted otherwise, are Copyright Kyle Adams 2011. You can read more about the license Kyle has on his work in the ContentLicense.md file.

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

Kyle Adams - kyleadams.org - for his work on the user interface for the project and prerelease testing

Tim Novinger - timnovinger.com - for his work on modernizing animations, cleaning up the interface and tons of other improvements

Marc Easen - easen.co.uk - for implementing calendar invitation alerts

Tim Horton - hortont.com - for his help with debugging and testing

Frederik Vanggaard - github.com/Drudoo - for his help with debugging and testing

Sammargh - github.com/sammargh - for his help with fixing the SMS notification tones

Kristian Pennacchia - github.com/kristianpennacchia - for his work on sliding notifications

Derek Nicolas - github.com/derek-nicolas - for his help with fixing SMS notification bugs
