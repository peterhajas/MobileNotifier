#import "MNAlertViewController.h"

@synthesize dataObj;

@synthesize alertHeader, alertText, sendAway, alertBackground;

@synthesize delegate = _delegate;

-(id)init
{
	alertHeader = [[UILabel alloc] init];
	alertText = [[UILabel alloc] init];
	sendAway = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	alertBackground = [[UIImageView alloc] init];

	//Wire up sendAway!
	
	[sendAway addTarget:self action:@selector(sendAway:) forControlEvents:UIControlEventTouchDown];
}

-(void)initWithData:(MNAlertData *data)
{
	dataObj = data;
	
	alertHeader = [[UILabel alloc] init];
	alertHeader.text = data.header;

	alertText = [[UILabel alloc] init];
	alertText.text = data.text;

	sendAway = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	alertBackground = [[UIImageView alloc] init];

	//Wire up sendAway!
	[sendAway addTarget:self action:@selector(sendAway:) forControlEvents:UIControlEventTouchUpInside];
	//Wire up the takeAction!
	[alertBackground addTarget:self action:@selector(takeAction:) forControlEvents:UIControlEventTouchUpInside];
	
}

-(void)sendAway:(id)sender
{
	//Notify the delegate
	[delegate alertViewController:self hadActionTaken:kAlertSentAway];

	//And that's it! The delegate will take care of everything else.
}

-(void)takeAction:(id)sender
{
	//Notify the delegate
	[delegate alertViewController:self hadActionTaken:kAlertTakeAction];
}
