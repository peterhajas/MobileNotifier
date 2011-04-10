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
//Commented out to avoid compilation warnings when linking against 3.1.3 private headers
//#import <SpringBoard/SBStatusBarDataManager.h>
#import <ChatKit/ChatKit.h>

#import <objc/runtime.h>

#import "MNAlertData.h"
#import "MNAlertManager.h"
#import "MNAlertViewController.h"

%class SBUIController;
%class SBIconModel;
%class SBIcon;
%class SBAppSwitcherController;
%class SBAwayController;
%class SBStatusBarDataManager;

@interface SBUIController (peterhajas)
-(void)activateApplicationFromSwitcher:(SBApplication *) app;
-(void)dismissSwitcher;
-(BOOL)activateSwitcher;
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
{
	NSArray* ignoredApplications;	
}

-(BOOL)isApplicationIgnored:(NSString*)bundleID;

@end

@implementation PHACInterface

-(BOOL)isApplicationIgnored:(NSString*)bundleID
{
	if([ignoredApplications indexOfObject:bundleID] != NSNotFound)
	{
		return YES;
	}
	else
	{
		return NO;
	}
}

-(id)init
{
	self = [super init];
	if(self)
	{
		ignoredApplications = [[NSArray alloc] initWithContentsOfFile:@"/Library/Application Support/MobileNotifier/ignoredApplications.plist"];
	}
	return self;
}

-(void)launchBundleID:(NSString *)bundleID
{
	//TODO: switch to URL for this
    SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
    SBApplicationController *appcontroller = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
    if([[appcontroller applicationsWithBundleIdentifier:bundleID] count] == 0)
    {
        //We can't do anything!
        //Inform the user, then return out
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't find application"
                                                  message:[NSString stringWithFormat:@"MobileNotifier can't find the application with bundle ID of %@. Has it been uninstalled or removed?", bundleID]
                                                  delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
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

-(void)launchAppInSpringBoardWithBundleID:(NSString *)bundleID
{
    [self launchBundleID:bundleID];
}

-(UIImage*)iconForBundleID:(NSString *)bundleID;
{
	if([bundleID isEqualToString:@"com.apple.MobileSMS"])
	{
		return [[UIImage imageWithContentsOfFile:@"/Applications/MobileSMS.app/icon.png"] retain];
	}
	if([bundleID isEqualToString:@"com.apple.mobilephone"])
	{
		return [[UIImage imageWithContentsOfFile:@"/Applications/MobilePhone.app/icon.png"] retain];
	}
	
	SBApplicationController* sbac = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
	//Let's grab the application's icon using some awesome NSBundle stuff!
	
	//If we can't grab the app from the SBApplicationController, then bummer. We can't launch.
    if([[sbac applicationsWithBundleIdentifier:bundleID] count] < 1)
    {
        //Just return nothing. It's better than something!
        return nil;
    }
	
	//Next, grab the app's bundle:
	NSBundle *appBundle = (NSBundle*)[[[sbac applicationsWithBundleIdentifier:bundleID] objectAtIndex:0] bundle];
	//Next, ask the dictionary for the IconFile name
	NSString *iconName = [[appBundle infoDictionary] objectForKey:@"CFBundleIconFile"];
	NSString *iconPath = @"";
	
	if(iconName != nil)
	{
		//Finally, query the bundle for the path of the icon minus its path extension (usually .png)
		iconPath = [appBundle pathForResource:[iconName stringByDeletingPathExtension] 
												 ofType:[iconName pathExtension]];
	}
	else
	{
		//Some apps, like Boxcar, prefer an array of icons. We need to deal with that appropriately.
		NSArray *iconArray = [[appBundle infoDictionary] objectForKey:@"CFBundleIconFiles"];
		//Interate through the array first
		int count = [iconArray count];
		if(count != 0)
		{
			int i;
			for(i = 0; i < count; i++)
			{
				//With some preliminary testing, the highest-up item in the iconArray is the highest resolution image
				iconPath = [appBundle pathForResource:[[iconArray objectAtIndex:i] stringByDeletingPathExtension] 
														 ofType:[[iconArray objectAtIndex:i] pathExtension]];
			}
		}
	}
	
	//Prefer retina images over non retina images
	
	if([UIImage imageWithContentsOfFile:iconPath] == nil)
	{
		iconPath = [appBundle pathForResource:@"Icon@2x" ofType:@"png"];
	}
	
	if([UIImage imageWithContentsOfFile:iconPath] == nil)
	{
		iconPath = [appBundle pathForResource:@"icon@2x" ofType:@"png"];
	}
	
	if([UIImage imageWithContentsOfFile:iconPath] == nil)
	{
		iconPath = [appBundle pathForResource:@"Icon" ofType:@"png"];
	}
	
	if([UIImage imageWithContentsOfFile:iconPath] == nil)
	{
		iconPath = [appBundle pathForResource:@"icon" ofType:@"png"];
	}
	
	//Return our UIImage!
	if(iconPath != nil)
	{
		return [[UIImage imageWithContentsOfFile:iconPath] retain];
	}
	else
	{
		//We don't have an image. Let's return one with the MobileNotifier logo.
		return [[UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/lockscreen-logo.png"] retain];
	}
}

-(void)dismissSwitcher
{
    SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
    [uicontroller dismissSwitcher];
}

-(void)wakeDeviceScreen
{
    SBAwayController* awayController = (SBAwayController *)[%c(SBAwayController) sharedAwayController];
    [awayController undimScreen];
    [awayController restartDimTimer:5.0];
}

-(void)toggleDoubleHighStatusBar
{
	NSLog(@".........................................................Toggling doublehigh statusbar");
	id statusBarDataManager = [%c(SBStatusBarDataManager) sharedDataManager];
    [statusBarDataManager toggleSimulatesInCallStatusBar];
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
}

%end;

//Experimental: Hook SBAlertItemsController for skipping the alert grabbing and going right for the built-in manager

%hook SBAlertItemsController

-(void)activateAlertItem:(id)item
{
    //Build the alert data part of the way
    MNAlertData* data;    

	if([item isKindOfClass:%c(SBSMSAlertItem)])
	{
        //It's an SMS/MMS!
        data = [[MNAlertData alloc] init];
        data.type = kSMSAlert;
        data.time = [[NSDate date] retain];
    	data.status = kNewAlertForeground;
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
		if(![phacinterface isApplicationIgnored:[app bundleIdentifier]])
		{
			NSString* _body = MSHookIvar<NSString*>(item, "_body");
			data = [[MNAlertData alloc] init];
			data.time = [[NSDate date] retain];
        	data.status = kNewAlertForeground;
			data.type = kPushAlert;
			data.bundleID = [app bundleIdentifier];
			data.header = [app displayName];
			data.text = _body;
			[manager newAlertWithData:data];
		}
		else
		{
			//We do not want to intercept ignored application events.
			%orig;
		}
    }
    
    else if([item isKindOfClass:%c(SBVoiceMailAlertItem)])
    {
        //It's a voicemail alert!
        data = [[MNAlertData alloc] init];
        data.time = [[NSDate date] retain];
    	data.status = kNewAlertForeground;
        data.type = kPhoneAlert;
        data.bundleID = @"com.apple.mobilephone";
        data.header = [item title];
        data.text = [item bodyText];
		[manager newAlertWithData:data];
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
	//Hide the pending alert if the manager is showing one
	[manager hidePendingAlert];
	//Show our lockscreen view
    [manager showLockscreen];
	[manager fadeDashboardDown];
}

-(void)_finishedUnlockAttemptWithStatus:(BOOL)status
{
	%orig;
	//Hide our lockscreen view
	[manager hideLockscreen];
}

-(void)noteSyncStateChanged
{
    %orig;
    if(![self isSyncing])
    {
        //Hide our lockscreen view
        [manager hideLockscreen];
    }
}

-(void)undimScreen
{
	%orig;
	SBTelephonyManager *telephonyManager = (SBTelephonyManager *)[%c(SBTelephonyManager) sharedTelephonyManager];
	//If someone's calling us, let's hide the lockscreen view and any pending alerts
	if([telephonyManager incomingCallExists])
	{
		[manager hideLockscreen];
		[manager hidePendingAlert];
	}
	
	if([self isLocked])
	{
		[manager hidePendingAlert];
	}
}

-(BOOL)toggleMediaControls
{
    BOOL returnValue = %orig;
    if([self isShowingMediaControls])
    {
        [manager hideLockscreen];
    }
    else
    {
        [manager showLockscreen];
    }
    return returnValue;
}

%end

%hook SBUIController

-(void)dismissSwitcher
{
    %orig;
    [manager fadeDashboardDown];
}

-(BOOL)activateSwitcher
{
    [manager showDashboardFromSwitcher];
    return %orig;
}

-(void)activateApplicationAnimated:(id)animated
{
    %orig;
    [manager fadeDashboardDown];
}

-(void)activateApplicationFromSwitcher:(id)switcher
{
    %orig;
    [manager fadeDashboardDown];
}

-(BOOL)clickedMenuButton
{
    [manager fadeDashboardDown];
    return %orig;
}

%end

//Don't do anything for alerts we already intercept
%hook SBAwayModel

-(void)populateWithMissedSMS:(id)missedSMS
{
	NSNumber *antiqueEnabled = [manager.preferenceManager.preferences valueForKey:@"antiqueLockAlertsEnabled"];
	bool shouldShow = antiqueEnabled ? [antiqueEnabled boolValue] : YES;
	if(shouldShow)
	{
        %orig;
    }
}
-(void)populateWithMissedEnhancedVoiceMails:(id)missedEnhancedVoiceMails
{
	NSNumber *antiqueEnabled = [manager.preferenceManager.preferences valueForKey:@"antiqueLockAlertsEnabled"];
	bool shouldShow = antiqueEnabled ? [antiqueEnabled boolValue] : YES;
	if(shouldShow)
	{
        %orig;
	}
}

%end

//Hook AutoFetchRequestPrivate for getting new mail
/*
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
        data.time = [[NSDate date] retain];
		data.status = kNewAlertForeground;

	    data.type = kSMSAlert;
		data.bundleID = [[NSString alloc] initWithString:@"com.apple.MobileMail"];
		
		data.header = [[NSString alloc] initWithFormat:@"Mail"];
		data.text = [[NSString alloc] initWithFormat:@"%d new messages", [self messageCount]];
		
		[manager newAlertWithData:data];
	}
}

%end
*/
static void reloadPrefsNotification(CFNotificationCenterRef center,
									void *observer,
									CFStringRef name,
									const void *object,
									CFDictionaryRef userInfo) {
	[manager reloadPreferences];
}

%ctor
{
	//Register for the preferences-did-change notification
	CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterAddObserver(r, NULL, &reloadPrefsNotification, CFSTR("com.peterhajassoftware.mobilenotifier/reloadPrefs"), NULL, 0);
}

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
