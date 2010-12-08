#import "MNAlertViewController.h"

@implementation MNAlertViewController

@synthesize dataObj;

@synthesize alertHeader, alertText, sendAway, takeAction, alertBackground;

@synthesize delegate = _delegate;

-(id)init
{
	self = [super init];
	alertHeader = [[UILabel alloc] init];
	alertText = [[UILabel alloc] init];
	sendAway = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	alertBackground = [[UIImageView alloc] init];

	//Wire up sendAway!
	[sendAway addTarget:self action:@selector(sendAway:) forControlEvents:UIControlEventTouchUpInside];
	//Wire up the takeAction!
	[takeAction addTarget:self action:@selector(takeAction:) forControlEvents:UIControlEventTouchUpInside];
	
	return self;
}

-(id)initWithMNData:(MNAlertData*) data
{
	self = [super init];
	dataObj = data;
	
	alertHeader = [[UILabel alloc] init];
	alertHeader.text = data.header;
	alertHeader.font = [UIFont fontWithName:@"Helvetica" size:10];

	alertText = [[UILabel alloc] init];
	alertText.text = data.text;
	alertText.font = [UIFont fontWithName:@"Helvetica" size:16];

	sendAway = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	takeAction = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	
	alertBackground = [[UIImageView alloc] init];

	//Wire up sendAway!
	[sendAway addTarget:self action:@selector(sendAway:) forControlEvents:UIControlEventTouchUpInside];
	//Wire up the takeAction!
	[takeAction addTarget:self action:@selector(takeAction:) forControlEvents:UIControlEventTouchUpInside];
	
	return self;
}

-(void)sendAway:(id)sender
{
	//Notify the delegate
	[_delegate alertViewController:self hadActionTaken:kAlertSentAway];

	//And that's it! The delegate will take care of everything else.
}

-(void)takeAction:(id)sender
{
	//Notify the delegate
	[_delegate alertViewController:self hadActionTaken:kAlertTakeAction];
}

@end
