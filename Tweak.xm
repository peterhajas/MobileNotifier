/*

MobileNotifier, by Peter Hajas

Copyright 2010 Peter Hajas, Peter Hajas Software

This code is licensed under the GPL. The full text of which is available in the file "LICENSE"
which should have been included with this package. If not, please see:

http://www.gnu.org/licenses/gpl.txt

and notify Peter Hajas

iOS Notifications. Done right. Like 2010 right.

This is an RCOS project for the Fall 2010, Spring 2011 semester. The website for RCOS is at rcos.cs.rpi.edu/

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

To build this, use "make" in the directory.
This project utilizes Theos as its makefile system and Logos as its hooking preprocessor.

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

#import "MNAlertData.h"
#import "MNAlertManager.h"
#import "MNAlertViewController.h"

%class SBUIController;

@interface SBUIController (peterhajas)
-(void)activateApplicationFromSwitcher:(SBApplication *) app;
-(void)dismissSwitcher;
-(BOOL)_revealSwitcher:(double)switcher;
@end

@interface SBRemoteLocalNotificationAlert : SBAlertItem
-(id)alertItemNotificationSender;
@end

@interface PHACInterface : NSObject <MNAlertManagerDelegate>
@end

@implementation PHACInterface
- (void)launchBundleID:(NSString *)bundleID
{
	//TODO: switch to URL for this
    SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
    SBApplicationController *appcontroller = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
	if([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
	{
		//Do the awesome, animated switch to the new app
		[uicontroller activateApplicationFromSwitcher:[[appcontroller applicationsWithBundleIdentifier:bundleID] objectAtIndex:0]];
	}
	else
	{
		//Boring old way (which still doesn't work outside of Springboard)
		[uicontroller activateApplicationAnimated:[[appcontroller applicationsWithBundleIdentifier:bundleID] objectAtIndex:0]];
	}
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
MNAlertManager *manager;

//SB Interface
PHACInterface *phacinterface;

//Hook into Springboard init method to initialize our window

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application
{    
    %orig;
   

    phacinterface = [[PHACInterface alloc] init];

	manager = [[MNAlertManager alloc] init];
    manager.delegate = phacinterface;

    //Connect up to Activator
	//Commented out for now
    //[[LAActivator sharedInstance] registerListener:manager forName:@"com.peterhajassoftware.mobilenotifier"];
}

%end;

//Experimental: Hook SBAlertItemsController for skipping the alert grabbing and going right for the built-in manager

%hook SBAlertItemsController

-(void)activateAlertItem:(id)item
{
    //Build the alert data part of the way
	MNAlertData* data = [[MNAlertData alloc] init];
	//Current date + time
	data.time = [[NSDate alloc] init];
	data.status = kNewAlertForeground;

	if([item isKindOfClass:%c(SBSMSAlertItem)])
	{
        //It's an SMS/MMS!
        data.type = kSMSAlert;
		data.bundleID = [[NSString alloc] initWithString:@"com.apple.MobileSMS"];
		if([item alertImageData] == NULL)
		{
			data.header = [[NSString alloc] initWithFormat:@"SMS from %@:", [item name]];
			data.text = [[NSString alloc] initWithFormat:@"%@", [item messageText]];
		}
	    else
	    {
			data.header = [[NSString alloc] initWithFormat:@"MMS from %@:", [item name]];
			data.text = [[NSString alloc] initWithFormat:@"%@", [item messageText]];
	    }
		[manager newAlertWithData:data];
	}
    else if(([item isKindOfClass:%c(SBRemoteNotificationAlert)]) || 
			([item isKindOfClass:%c(SBRemoteLocalNotificationAlert)]))
    {
        //It's a push notification!
        
		//Get the SBApplication object, we need its bundle identifier
		SBApplication *app(MSHookIvar<SBApplication *>(item, "_app"));
		if(([[app bundleIdentifier] rangeOfString:@"mobiletimer"].location == NSNotFound) || 
		   ([[app bundleIdentifier] rangeOfString:@"MobileTimer"].location == NSNotFound))
		{
			[[item alertSheet] retain];
			data.type = kPushAlert;
			data.bundleID = [app bundleIdentifier];
			data.header = [[item alertItemNotificationSender] retain];
			data.text = [[[item alertSheet] bodyText] retain];
			[manager newAlertWithData:data];
			[[item alertSheet] release];
		}
		else
		{
			//We do not want to intercept MobileTimer events.
			%orig;
		}
    }
    else
    {
        //It's a different alert (power/app store, for example)

		//Let's run the original function for now
		%orig;
    }
}

-(void)deactivateAlertItem:(id)item
{
    %log;
    %orig;
}

%end

//Hook SBAwayController for showing our lockscreen view.

%hook SBAwayController

-(void)lock
{
	%orig;
	//Move down the frame
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	manager.dashboard.window.frame = CGRectMake(10 ,80,screenBounds.size.width,(screenBounds.size.height / 2) + 55);
	[manager.dashboard showDashboard];
}

-(void)_finishedUnlockAttemptWithStatus:(BOOL)status
{
	%orig;
	//Move up the frame
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	manager.dashboard.window.frame = CGRectMake(10 ,20,screenBounds.size.width,(screenBounds.size.height / 2) + 55);
	[manager.dashboard hideDashboard];
}

%end;

//Hook SBUIController for fun stuff related to the switcher coming out and going away
/*
%hook SBUIController

-(void)dismissSwitcher
{
	%orig;
	//Hide the dashboard
	[manager.dashboard hideDashboard];
}

-(BOOL)_revealSwitcher:(double)switcher
{
	BOOL ans = %orig;
	//Show the dashboard
	[manager.dashboard showDashboard];
	return ans;
}

%end
*/
//Hook AutoFetchRequestPrivate for getting new mail

%hook AutoFetchRequestPrivate

-(void)run //This works! This is an appropriate way for us to display a new mail notification to the user
{
	%orig;
    %log;
	if([self gotNewMessages])
	{
		//Message count corresponds to maximum storage in an inbox (ie 200), /not/ to the count of messages received...
		NSLog(@"Attempted fetch with %d new mail!", [self messageCount]);
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
