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

@synthesize pendingAlerts, sentAwayAlerts, dismissedAlerts, pendingAlertViews;
@synthesize delegate = _delegate;
@synthesize alertWindow;
@synthesize dashboard;

-(id)init
{	
	self = [super init];
	
	//Let's hope the NSObject init doesn't fail!
	if(self != nil)
	{
		alertWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0,20,320,0)]; //Measured to be zero, we don't want to mess up interaction with views below! Also, we live below the status bar
		alertWindow.windowLevel = 990; //Don't mess around with WindowPlaner or SBSettings if the user has it installed :)
		alertWindow.userInteractionEnabled = YES;
		alertWindow.hidden = NO;
		
		//If the directory doesn't exist, create it!
		if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/MobileNotifier/"])
		{
			[[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Library/MobileNotifier" withIntermediateDirectories:NO attributes:nil error:NULL];
		}

		//Load data from files on init (which runs on SpringBoard applicationDidFinishLaunching)
		pendingAlerts = [[NSKeyedUnarchiver unarchiveObjectWithFile:@"/var/mobile/Library/MobileNotifier/pending.plist"] retain] ?: [[NSMutableArray alloc] init];
		sentAwayAlerts = [[NSKeyedUnarchiver unarchiveObjectWithFile:@"/var/mobile/Library/MobileNotifier/sentaway.plist"] retain] ?: [[NSMutableArray alloc] init];
		dismissedAlerts = [[NSKeyedUnarchiver unarchiveObjectWithFile:@"/var/mobile/Library/MobileNotifier/dismissed.plist"] retain] ?: [[NSMutableArray alloc] init];

		//Move all elements from pendingAlerts into sentAwayAlerts
		int i;
		for(i = 0; i < [pendingAlerts count]; i++)
		{
			[sentAwayAlerts addObject:[pendingAlerts objectAtIndex:i]];
		}
		
		[pendingAlerts removeObjectsInArray:sentAwayAlerts];

		//Somewhere, these should be arranged by time...

		//Init the pendingAlertViews array
	
		pendingAlertViews = [[NSMutableArray alloc] init];
		
		//Alloc and init the dashboard
		dashboard = [[MNAlertDashboardViewController alloc] init];
		dashboard.delegate = self;
		
		//Register for libactivator events
		[[LAActivator sharedInstance] registerListener:self forName:@"com.peterhajassoftware.mobilenotifier"];
	}
	return self;
}

-(void)newAlertWithData:(MNAlertData *)data
{
	//New foreground alert!
	if(data.status == kNewAlertForeground)
	{
		//Build a new MNAlertViewController
		MNAlertViewController *viewController = [[MNAlertViewController alloc] initWithMNData:data];
		[viewController.view setFrame:CGRectMake(0,([pendingAlertViews count] * 60) ,320,60)];
		viewController.delegate = self;
		[pendingAlerts addObject:data];
		[pendingAlertViews addObject:viewController];
		//Change the window size
		[alertWindow setFrame:CGRectMake(0, 20, 320, 60 * ([pendingAlerts count]))];
		NSLog(@"New window height: %f", 60 * ([pendingAlerts count]));
		//Add the subview
		[alertWindow addSubview:viewController.view];
	}
	//Not a foreground alert, but a background alert
	else if(data.status == kNewAlertBackground)
	{
		[sentAwayAlerts addObject:data];
	}
	[self saveOut];
}

-(void)saveOut
{
	[NSKeyedArchiver archiveRootObject:pendingAlerts toFile:@"/var/mobile/Library/MobileNotifier/pending.plist"];
	[NSKeyedArchiver archiveRootObject:sentAwayAlerts toFile:@"/var/mobile/Library/MobileNotifier/sentaway.plist"];
	[NSKeyedArchiver archiveRootObject:dismissedAlerts toFile:@"/var/mobile/Library/MobileNotifier/dismissed.plist"];
}

//Delegate method for MNAlertViewController
-(void)alertViewController:(MNAlertViewController *)viewController hadActionTaken:(int)action
{
	if(action == kAlertSentAway)
	{
		//Move the alert from pendingAlerts into sentAwayAlerts
		MNAlertData *data = viewController.dataObj;
		int index = [pendingAlertViews indexOfObject:viewController];
		
		[sentAwayAlerts addObject:data];
		[pendingAlerts removeObject:data];
		[viewController.view removeFromSuperview];
		[pendingAlertViews removeObject:viewController];
		//Redraw alerts
		[self redrawAlertsBelowIndex:index];
		if([pendingAlertViews count] == 0)
		{
			alertWindow.frame = CGRectMake(0,20,320,0);
		}
	}
	else if(action == kAlertTakeAction)
	{
		MNAlertData *data = viewController.dataObj;
		int index = [pendingAlertViews indexOfObject:viewController];
		
		//Launch the bundle
		[_delegate launchAppInSpringBoardWithBundleID:data.bundleID];
		//Move alert into dismissedAlerts from pendingAlerts
		[dismissedAlerts addObject:data];
		[pendingAlerts removeObject:data];
		[viewController.view removeFromSuperview];
		[pendingAlertViews removeObject:viewController];
		//Redraw alerts
		[self redrawAlertsBelowIndex:index];
	}
}

-(void)takeActionOnAlertWithData:(MNAlertData *)data
{
	//Launch the bundle
	[_delegate launchAppInSpringBoardWithBundleID:data.bundleID];
	//Move alert into dismissed alerts from either pendingAlerts or sentAwayAlerts
	[dismissedAlerts addObject:data];
	[pendingAlerts removeObject:data];
	[sentAwayAlerts removeObject:data];
	//Cool! All done!
}

-(void)redrawAlertsBelowIndex:(int)index
{
	int i;
	for(i = index; i < [pendingAlertViews count]; i++)
	{
		UIViewController* temp = [pendingAlertViews objectAtIndex:i];
		[temp.view setFrame:CGRectMake(0,temp.view.frame.origin.y - 60,320,60)];
	}
	if([pendingAlertViews count] == 0)
	{
		alertWindow.frame = CGRectMake(0,20,320,0);
	}
}

//MNAlertDashboardViewControllerProtocol Methods:
- (void)actionOnAlertAtIndex:(int)index inArray:(int)array
{
	NSMutableArray *activeArray = nil;
	//Interpret the activeArray
	if(array == kPendingActive)
	{
		activeArray = pendingAlerts;
	}
	if(array == kSentActive)   
	{
		activeArray = sentAwayAlerts;
	}
	if(array == kDismissActive)
	{
		activeArray = dismissedAlerts;
	}
	//Create the data object
	MNAlertData *data;
	data = [activeArray objectAtIndex:index];
	//Take action on it
	[self takeActionOnAlertWithData:data];
	//Hide the dashboard
	[dashboard hideDashboard];
}
- (NSMutableArray *)getPendingAlerts
{
	return pendingAlerts;
}
- (NSMutableArray *)getSentAwayAlerts
{
	return sentAwayAlerts;
}
- (NSMutableArray *)getDismissedAlerts
{
	return dismissedAlerts;
}

//Libactivator methods
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	[dashboard toggleDashboard];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
	[dashboard hideDashboard];
}

@end