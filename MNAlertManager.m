#import "MNAlertManager.h"

@implementation MNAlertManager

@synthesize pendingAlerts, sentAwayAlerts, dismissedAlerts, pendingAlertViews;
@synthesize delegate = _delegate;
@synthesize alertWindow;
-(id)init
{	
	self = [super init];
	
	//Let's hope the NSObject init doesn't fail!
	if(self != nil)
	{
		alertWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0,0,320,20)]; //Measured to be zero, we don't want to mess up interaction with views below! Also, we live below the status bar
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
		[pendingAlerts removeObject:data];
		[sentAwayAlerts addObject:data];
		//Redraw alerts
		[self redrawPendingAlerts];
	}
	if(action == kAlertTakeAction)
	{
		MNAlertData *data = viewController.dataObj;
		//Launch the bundle
		[_delegate launchAppInSpringBoardWithBundleID:data.bundleID];
		//Move alert into dismissedAlerts from pendingAlerts
		[pendingAlerts removeObject:data];
		[dismissedAlerts addObject:data];
		//Redraw alerts
		[self redrawPendingAlerts];
	}
}
-(void)redrawPendingAlerts
{
	for (UIView *view in alertWindow.subviews) 
	{
		[view removeFromSuperview];
	}
}
@end