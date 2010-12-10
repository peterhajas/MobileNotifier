#import "MNAlertViewController.h"

@implementation MNAlertViewController

@synthesize dataObj;

@synthesize alertHeader, sendAway, takeAction, alertBackground;

@synthesize delegate = _delegate;

-(id)init
{
	self = [super init];
	if(self != nil)
	{
		alertHeader = [[UILabel alloc] init];
		sendAway = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		alertBackground = [[UIImageView alloc] init];

		//Wire up sendAway!
		[sendAway addTarget:self action:@selector(sendAway:) forControlEvents:UIControlEventTouchUpInside];
		//Wire up the takeAction!
		[takeAction addTarget:self action:@selector(takeAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	return self;
}

-(id)initWithMNData:(MNAlertData*) data
{
	self = [super init];
	
	dataObj = data;
	
	return self;
}

-(void)loadView
{
	[super loadView];
	
	alertHeader = [[UILabel alloc] initWithFrame:CGRectMake(20, 4, 250 , 40)];
	alertHeader.text = data.header;
	alertHeader.font = [UIFont fontWithName:@"Helvetica" size:10];

	sendAway = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	takeAction = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[takeAction setTitle:data.text forState:UIControlStateNormal];
	takeAction.frame = CGRectMake(20, 30, 250, 40);
	
	alertBackground = [[UIImageView alloc] init];
	
	if(data.type == kSMSAlert)
	{
		alertBackground.image = [UIImage imageNamed:@"/Library/Application Support/MobileNotifier/greenAlert_retina.png"];
	}

	//Wire up sendAway!
	[sendAway addTarget:self action:@selector(sendAway:) forControlEvents:UIControlEventTouchUpInside];
	//Wire up the takeAction!
	[takeAction addTarget:self action:@selector(takeAction:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:alertBackground];
	[self.view addSubview:alertHeader];
	[self.view addSubview:sendAway];
	[self.view addSubview:takeAction];
	
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
