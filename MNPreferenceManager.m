#import "MNPreferenceManager.h"

@implementation MNPreferenceManager

@synthesize preferences;

-(id)init
{
	self = [super init];
	if(self)
	{
		preferences = [[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.peterhajassoftware.mobilenotifier.plist"] retain];
	}
	return self;
}

-(void)reloadPreferences
{
	if(preferences)
	{
		[preferences release];
	}
	preferences = [[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.peterhajassoftware.mobilenotifier.plist"] retain];
}

@end