#import "MNAlertManager.h"

@implementation MNAlertManager

@synthesize pendingAlerts, sentAwayAlerts, dismissedAlerts;

-(id)init
{
	self = [super init];
	//Let's hope the NSObject init doesn't fail!
	if(self != nil)
	{
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
	
		for(int i = 0; i < [pendingAlerts count]; i++)
		{
			[sentAwayAlerts addObject:[pendingAlerts objectAtIndex:i]];
		}

		//Somewhere, these should be arranged by time...

		//Init the pendingAlertViews array
	
		pendingAlertViews = [[NSMutableArray alloc] init];

	}
	return self;
}

-(void)newAlertWithData:(MNAlertData *)data
{
	//It would be a good idea to create a new alert here with the data that was passed in
	
	//This, also, I will do later.	
}

-(void)saveOut
{
	[NSKeyedArchiver archiveRootObject:pendingAlerts toFile:@"/var/mobile/Library/MobileNotifier/pending.plist"];
	[NSKeyedArchiver archiveRootObject:sentAwayAlerts toFile:@"/var/mobile/Library/MobileNotifier/sentaway.plist"];
	[NSKeyedArchiver archiveRootObject:dismissedAlerts toFile:@"/var/mobile/Library/MobileNotifier/dismissed.plist"];

}

@end
