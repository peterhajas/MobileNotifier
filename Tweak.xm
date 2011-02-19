/*
MobileNotifier, by Peter Hajas
iOS Notifications. Done right. Like 2010 right.

Copyright 2010 Peter Hajas, Peter Hajas Software
This code is licensed under the BSD license
*/

/*
Copyright (c) 2010-2011, Peter Hajas
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Peter Hajas nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL PETER HAJAS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <SpringBoard/SpringBoard.h>
#import <ChatKit/ChatKit.h>

#import <objc/runtime.h>

#import "MNAlertData.h"
#import "MNAlertManager.h"
#import "MNAlertViewController.h"

%class SBUIController;
%class SBIconModel;
%class SBIcon;

@interface SBUIController (peterhajas)
-(void)activateApplicationFromSwitcher:(SBApplication *) app;
-(void)dismissSwitcher;
-(BOOL)_revealSwitcher:(double)switcher;
@end

@interface SBIconModel (peterhajas)
+(id)sharedInstance;
-(id)applicationIconForDisplayIdentifier:(id)displayIdentifier;
@end

@interface SBIcon (peterhajas)
-(id)iconImageView;
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

-(UIImage*)iconForBundleID:(NSString *)bundleID;
{
	if([bundleID isEqualToString:@"com.apple.MobileSMS"])
	{
		return [[UIImage imageWithContentsOfFile:@"/Applications/MobileSMS.app/icon@2x.png"] retain];
	}
	
	SBApplicationController* sbac = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
	//Let's grab the application's icon using some awesome NSBundle stuff!
	//First, grab the app's bundle:
	NSBundle *appBundle = (NSBundle*)[[[sbac applicationsWithBundleIdentifier:bundleID] objectAtIndex:0] bundle];
	//Next, ask the dictionary for the IconFile name
	NSString *iconName = [[appBundle infoDictionary] objectForKey:@"CFBundleIconFile"];
	//Finally, query the bundle for the path of the icon minus its path extension (usually .png)
	NSString *iconPath = [appBundle pathForResource:[iconName stringByDeletingPathExtension] 
											 ofType:[iconName pathExtension]];
	//Return our UIImage!
	return [[UIImage imageWithContentsOfFile:iconPath] retain];
}
@end

//Mail class declaration for fetched messages

@interface AutoFetchRequestPrivate

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
			data.header = [[NSString alloc] initWithFormat:@"%@", [item name]];
			data.text = [[NSString alloc] initWithFormat:@"%@", [item messageText]];
		}
	    else
	    {
			data.header = [[NSString alloc] initWithFormat:@"%@", [item name]];
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
		//Filter out clock alerts
		if([[item alertItemNotificationSender] rangeOfString:@"Clock"].location == NSNotFound)
		{
			NSString* _body = MSHookIvar<NSString*>(item, "_body");
			data.type = kPushAlert;
			data.bundleID = [app bundleIdentifier];
			data.header = [item alertItemNotificationSender];
			data.text = _body;
			[manager newAlertWithData:data];
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
}

-(void)_finishedUnlockAttemptWithStatus:(BOOL)status
{
	%orig;
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
		//Build the alert data part of the way
		MNAlertData* data = [[MNAlertData alloc] init];
		//Current date + time
		data.time = [[NSDate alloc] init];
		data.status = kNewAlertForeground;

	    data.type = kSMSAlert;
		data.bundleID = [[NSString alloc] initWithString:@"com.apple.MobileMail"];
		
		data.header = [[NSString alloc] initWithFormat:@"Mail"];
		data.text = [[NSString alloc] initWithFormat:@"%d new messages", [self messageCount]];
		
		[manager newAlertWithData:data];
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
