/*

MobileNotifier, by Peter Hajas

Copyright 2010 Peter Hajas, Peter Hajas Software

This code is licensed under the GPL. The full text of which is available in the file "LICENSE"
which should have been included with this package. If not, please see:

http://www.gnu.org/licenses/gpl.txt

and notify Peter Hajas

iOS Notifications. Done right. Like 2010 right.

This is an RCOS project for the Spring 2010 semester. The website for RCOS is at rcos.cs.rpi.edu/
.h
Thanks to:

Mukkai Krishnamoorthy - cs.rpi.edu/~moorthy - for being the faculty sponsor
Sean O' Sullivan - for his financial contributions. Thanks so much Mr. Sullivan.

Dustin Howett - howett.net - for Theos and amazing help on IRC!
Ryan Petrich - github.com/rpetrich - for Activator and help on IRC
chpwn - chpwn.com - for his awesome tweaks and help on IRC
Aaron Ash - multifl0w.com - for his help on IRC and invaluable advice
KennyTM - github.com/kennytm - for his decompiled headers
Jay Freeman - saurik.com - for MobileSubstrate, Cydia, Veency and countless other gifts to the community

for all your help and mega-useful tools.

To build this, use "make" in the directory. This project utilizes Theos as its makefile system and Logos as its hooking preprocessor.

You will need Theos installed:
http://github.com/DHowett/theos
With the decompiled headers in /theos/include/:
http://github.com/kennytm/iphone-private-frameworks

I hope you enjoy! Questions and comments to peterhajas (at) gmail (dot) com

And, as always, have fun!

*/

#import <SpringBoard/SpringBoard.h>
#import <ChatKit/ChatKit.h>

#import <objc/runtime.h>


#import "AlertDataController.h"
#import "AlertDisplayController.h"
#import "AlertController.h"

%class SBUIController;

@interface PHACInterface : NSObject <AlertControllerDelegate>
{



}

- (void)launchBundleID:(NSString *)bundleID;

@end

@implementation PHACInterface
- (void)launchBundleID:(NSString *)bundleID
{
    SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
    SBApplicationController *appcontroller = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];

    [uicontroller activateApplicationAnimated:[[appcontroller applicationsWithBundleIdentifier:bundleID] objectAtIndex:0]];
}

- (void)launchAppInSpringBoardWithBundleID:(NSString *)bundleID
{
    [self launchBundleID:bundleID];
}
@end

//Mail class declaration. This was dumped with class dump z (by kennytm)
//and was generated with MobileMail.app

@protocol AFCVisibleMailboxFetch <NSObject>
-(void)setShouldCompact:(BOOL)compact;
-(void)setMessageCount:(unsigned)count;
-(void)setRemoteIDToPreserve:(id)preserve;
-(void)setDisplayErrors:(BOOL)errors;
-(id)mailbox;
@end

@interface AutoFetchRequestPrivate
{

}

-(void)run;
-(BOOL)gotNewMessages;
-(int)messageCount;

@end

//Alert Controller:
AlertController *controller;

//SB Interface
PHACInterface *phacinterface;

//Hook into Springboard init method to initialize our window

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application
{    
    %orig;
   

    phacinterface = [[PHACInterface alloc] init];


    controller = [[AlertController alloc] init];
    [controller loadArray];
    controller.delegate = phacinterface;

    //Connect up to Activator
    [[LAActivator sharedInstance] registerListener:controller forName:@"com.peterhajassoftware.mobilenotifier"];
}

%end;

//Experimental: Hook SBAlertItemsController for skipping the alert grabbing and going right for the built-in manager

%hook SBAlertItemsController

-(void)activateAlertItem:(id)item
{
    if([item isKindOfClass:%c(SBSMSAlertItem)])
    {
        //It's an SMS/MMS!
        if([item alertImageData] == NULL)
        {
            [controller newAlert: [NSString stringWithFormat:@"SMS from %@: %@", [item name], [item messageText]] ofType:@"SMS" withBundle:@"com.apple.MobileSMS"];
        }
        else
        {
            [controller newAlert: [NSString stringWithFormat:@"MMS from %@", [item name]] ofType: @"MMS" withBundle:@"com.apple.MobileSMS"];
        }
    }
    /*else if([item isKindOfClass:%c(SBRemoteNotificationAlert)])
    {
        //It's a push notification!
        SBApplication *app(MSHookIvar<SBApplication *>(self, "_app"));
        NSString *body(MSHookIvar<NSString *>(self, "_body"));
        [controller newAlert: [NSString stringWithFormat:@"%@: %@", [app displayName], body] ofType:@"Push" withBundle:[app bundleIdentifier]];
    }*/
    else
    {
        //It's a different alert (power, for example)
		%orig;
    }    
}

-(void)deactivateAlertItem:(id)item
{
    %log;
    %orig;
}

%end

//Hook SBAwayView for showing our lockscreen view.
//SBAwayView is released each time the phone is unlocked, and a new instance created when the phone is locked (thanks Limneos!)

%hook SBAwayView

-(void)viewDidLoad
{
    %orig;
}

- (void)viewWillDisappear:(BOOL)animated
{
     
    %orig;
}

%end;

//Hook AutoFetchRequestPrivate for getting new mail

%hook AutoFetchRequestPrivate

-(void)run //This works! This is an appropriate way for us to display a new mail notification to the user
{
	%orig;
    %log;
	if([self gotNewMessages])
	{
		NSLog(@"Attempted fetch with %d new mail!", [self messageCount]); //Message count corresponds to maximum storage in an inbox (ie 200), not to the count of messages received...
    
        //Display our alert! 
	}
	else
	{
		NSLog(@"Attempted fetch with no new mail.");
	}
}

%end

//Information about Logos for future reference:

/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.

%hook ClassName

// Hooking a class method
+ (id)sharedInstance {
	return %orig;
}

// Hooking an instance method with an argument.
- (void)messageName:(int)argument {
	%log; // Write a message about this call, including its class, name and arguments, to the system log.

	%orig; // Call through to the original function with its original arguments.
	%orig(nil); // Call through to the original function with a custom argument.

	// If you use %orig(), you MUST supply all arguments (except for self and _cmd, the automatically generated ones.)
}

// Hooking an instance method with no arguments.
- (id)noArguments {
	%log;
	id awesome = %orig;
	[awesome doSomethingElse];

	return awesome;
}

// Always make sure you clean up after yourself; Not doing so could have grave conseqeuences!
%end
*/

	//How to hook ivars!
	//MSHookIvar<ObjectType *>(self, "OBJECTNAME");



// vim:ft=objc
