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

#import "MNAlertManager.h"

@implementation MNAlertManager

@synthesize pendingAlerts, dismissedAlerts;
@synthesize delegate = _delegate;
@synthesize alertWindow, pendingAlertViewController;
@synthesize whistleBlower;
@synthesize dashboard;
@synthesize preferenceManager;

-(id)init
{	
	self = [super init];
	
	//Let's hope the NSObject init doesn't fail!
	if(self != nil)
	{
		alertWindow = [[MNAlertWindow alloc] initWithFrame:CGRectMake(0,0,320,0)]; //Measured to be zero, we don't want to mess up interaction with views below! Also, we live below the status bar
		alertWindow.windowLevel = UIWindowLevelAlert+500.0f; //Don't mess around with WindowPlaner or SBSettings if the user has it installed :)
		alertWindow.userInteractionEnabled = YES;
		alertWindow.hidden = NO;
		alertWindow.clipsToBounds = NO;
		alertWindow.backgroundColor = [UIColor clearColor];
		
		//If the directory doesn't exist, create it!
		if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/MobileNotifier/"])
		{
			[[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Library/MobileNotifier" withIntermediateDirectories:NO attributes:nil error:NULL];
		}

		//Load data from files
		pendingAlerts = [[NSKeyedUnarchiver unarchiveObjectWithFile:@"/var/mobile/Library/MobileNotifier/pending.plist"] retain] ?: [[NSMutableArray alloc] init];
		dismissedAlerts = [[NSKeyedUnarchiver unarchiveObjectWithFile:@"/var/mobile/Library/MobileNotifier/dismissed.plist"] retain] ?: [[NSMutableArray alloc] init];
		
		alertIsShowing = NO;
		
		//Allocate and init the whistle blower
		whistleBlower = [[MNWhistleBlowerController alloc] initWithDelegate:self];
		
		//Alloc and init the dashboard
		dashboard = [[MNAlertDashboardViewController alloc] initWithDelegate:self];
		
		//Alloc and init the lockscreen view controller
        lockscreen = [[MNLockScreenViewController alloc] initWithDelegate:self];

		//Alloc and init the preferences manager
		preferenceManager = [[MNPreferenceManager alloc] init];
		
		//Register for libactivator events
		[[LAActivator sharedInstance] registerListener:self forName:@"com.peterhajassoftware.mobilenotifier"];
	}
	return self;
}

-(void)newAlertWithData:(MNAlertData *)data
{
	//Add to pending alerts
    [pendingAlerts insertObject:data atIndex:0];
	
	//New foreground alert!
	if(data.status == kNewAlertForeground)
	{
		if(!pendingAlertViewController.alertIsShowingPopOver)
		{
			//Build a new MNAlertViewController
			if(alertIsShowing)
			{
				[pendingAlertViewController.view removeFromSuperview];
			}
            if(![dashboard isShowing] && ![lockscreen isShowing])
			{
			    MNAlertViewController *viewController = [[MNAlertViewController alloc] initWithMNData:data];
			    viewController.delegate = self;
			    pendingAlertViewController = viewController;
		    
			    alertIsShowing = YES;
		    
			    //Change the window size
			    [alertWindow setFrame:CGRectMake(0, 0, 320, 40)];
			    //Add the subview
			    [alertWindow addSubview:viewController.view];
			    [alertWindow setNeedsDisplay];
			    
			    //Expand the status bar
                [_delegate toggleDoubleHighStatusBar];
			}
		}
		else
		{
			//The user is interacting with an alert!
			//Let's send this to pending, and let them
			//continue with what they're doing
		}
		//Make noise
		[whistleBlower alertArrived];
		
		//Start the timer, if the user prefers it
		NSNumber *autoLaterEnabled = [preferenceManager.preferences valueForKey:@"autoLaterAlertsEnabled"];
    	bool shouldAutoLater = autoLaterEnabled ? [autoLaterEnabled boolValue] : YES;
    	
    	if(shouldAutoLater)
    	{
		    alertDismissTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(alertShouldGoLaterTimerFired:) userInfo:nil repeats:NO];
	    }
		
	}
	//Not a foreground alert, but a background alert
	else if(data.status == kNewAlertBackground)
	{
        //We do nothing currently (already in pending)
	}
	[self saveOut];
    [lockscreen refresh];
    [dashboard refresh];
}

-(void)saveOut
{
	[NSKeyedArchiver archiveRootObject:pendingAlerts toFile:@"/var/mobile/Library/MobileNotifier/pending.plist"];
	[NSKeyedArchiver archiveRootObject:dismissedAlerts toFile:@"/var/mobile/Library/MobileNotifier/dismissed.plist"];
}

-(void)showDashboardFromSwitcher
{
    NSNumber *switcherViewEnabled = [preferenceManager.preferences valueForKey:@"switcherViewEnabled"];
	bool shouldShow = switcherViewEnabled ? [switcherViewEnabled boolValue] : YES;

	if(!shouldShow)
	{
		return;
	}

	[self hidePendingAlert];
	[dashboard showDashboard];
	[_delegate toggleDoubleHighStatusBar];
}

-(void)showDashboard
{
    [self hidePendingAlert];
	[dashboard showDashboard];
	[_delegate toggleDoubleHighStatusBar];
}

-(void)fadeDashboardDown
{
	[dashboard fadeDashboardDown];
}

-(void)fadeDashboardAway
{
    [dashboard fadeDashboardAway];
}

-(void)showLockscreen
{
	NSNumber *lockscreenEnabled = [preferenceManager.preferences valueForKey:@"lockscreenEnabled"];
	bool shouldShow = lockscreenEnabled ? [lockscreenEnabled boolValue] : YES;
	
	if(!shouldShow)
	{
		return;
	}
		
	[self hidePendingAlert];
    if([pendingAlerts count] != 0)
    {
        [lockscreen show];
    }
}
-(void)hideLockscreen
{
    [lockscreen hide];
}

-(void)hidePendingAlert
{
    [pendingAlertViewController.view removeFromSuperview];
    alertWindow.frame = CGRectMake(0,0,320,0);
    alertIsShowing = YES;
    [_delegate toggleDoubleHighStatusBar];
}

//Delegate method for MNAlertViewController
-(void)alertViewController:(MNAlertViewController *)viewController hadActionTaken:(int)action
{
	[_delegate toggleDoubleHighStatusBar];
	if(action == kAlertSentAway)
	{
		alertIsShowing = NO;
	}
	else if(action == kAlertTakeAction)
	{
		alertIsShowing = NO;
		MNAlertData *data = viewController.dataObj;
		
		//Launch the bundle
		[_delegate launchAppInSpringBoardWithBundleID:data.bundleID];
		//Move alert into dismissedAlerts from pendingAlerts
		[dismissedAlerts addObject:data];
		[pendingAlerts removeObject:data];
	}
	alertWindow.frame = CGRectMake(0,0,320,0);
	[self saveOut];
    [dashboard refresh];
    [lockscreen refresh];
}

-(void)takeActionOnAlertWithData:(MNAlertData *)data
{
	//Launch the bundle
	[_delegate launchAppInSpringBoardWithBundleID:data.bundleID];
	//Move alert into dismissed alerts from either pendingAlerts or sentAwayAlerts
	[dismissedAlerts addObject:data];
	[pendingAlerts removeObject:data];
    [self saveOut];
    [dashboard refresh];
    [lockscreen refresh];
	//Cool! All done!
}

-(UIImage*)iconForBundleID:(NSString *)bundleID;
{
	return [_delegate iconForBundleID:bundleID];
}

-(void)alertShowingPopOver:(bool)isShowingPopOver;
{
	if(isShowingPopOver)
	{
		CGRect frame = alertWindow.frame;
		frame.size.height += 93;
		alertWindow.frame = frame;
	}
	else
	{
		CGRect frame = alertWindow.frame;
		frame.size.height -= 93;
		alertWindow.frame = frame;
	}
}

//MNAlertDashboardViewControllerProtocol Methods:
- (void)actionOnAlertAtIndex:(int)index
{
	//Create the data object
	MNAlertData *data;
	data = [pendingAlerts objectAtIndex:index];

	//Hide the dashboard
	[dashboard fadeDashboardAway];

	//Take action on it
	[self takeActionOnAlertWithData:data];
}

-(void)dismissedAlertAtIndex:(int)index
{
    MNAlertData *data = [pendingAlerts objectAtIndex:index];
	[dismissedAlerts addObject:data];
	[pendingAlerts removeObject:data];
}

-(void)clearPending
{
	if([pendingAlerts count] == 0)
    {
        return;
    }
    NSUInteger size = [pendingAlerts count];
    NSUInteger i;
    for(i = 0; i < size; i++)
    {
        MNAlertData* dataObj = [pendingAlerts lastObject];
        if(!dataObj)
        {
            break;
        }
        [dismissedAlerts addObject:dataObj];
        [pendingAlerts removeObject:dataObj];
    }
    [self saveOut];
    [dashboard refresh];
    [lockscreen refresh];
}

-(void)alertShouldGoLaterTimerFired:(id)sender
{
	if(!pendingAlertViewController)
    {
		return;
    }
	//If the alert is expanded, then let's not have the alert go to "later"
	if(pendingAlertViewController.alertIsShowingPopOver)
	{
		return;
	}
		
	[pendingAlertViewController laterPushed:nil];
}

-(void)reloadPreferences
{
	[preferenceManager reloadPreferences];
}

- (NSMutableArray *)getPendingAlerts
{
	return pendingAlerts;
}

- (NSMutableArray *)getDismissedAlerts
{
	return dismissedAlerts;
}

-(void)dismissSwitcher
{
    [_delegate dismissSwitcher];
}

//MNWhistleBlowerController delegate methods

-(void)wakeDeviceScreen
{
    [lockscreen refresh];
    [_delegate wakeDeviceScreen];
}

//Libactivator methods
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
    [self hideLockscreen];
	[dashboard toggleDashboard];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
	[dashboard fadeDashboardDown];
	[self alertViewController:pendingAlertViewController hadActionTaken: kAlertSentAway];
}

@end