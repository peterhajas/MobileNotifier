#import "MNAlertViewController.h"

@synthesize alertHeader, alertText, sendAway, alertBackground;

@synthesize delegate = _delegate;

-(id)init
{
	alertHeader = [[UILabel alloc] init];
	alertText = [[UILabel alloc] init];
	sendAway = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	alertBackground = [[UIImageView alloc] init];

	//Wire up sendAway!
	
	[sendAway addTarget:self action:@selector(sendAway:) forControlEvents:UIControlEventTouchDown;
}
