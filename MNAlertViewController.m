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
	
	alertHeader = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 250 , 40)];
	alertHeader.text = dataObj.header;
	alertHeader.font = [UIFont fontWithName:@"Helvetica" size:12];
	alertHeader.backgroundColor = [UIColor clearColor];

	sendAway = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	sendAway.frame = CGRectMake(275, 13, 33, 33);
	[sendAway setBackgroundImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/dismiss_retina.png"] forState:UIControlStateNormal];
	takeAction = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[takeAction setTitle:dataObj.text forState:UIControlStateNormal];
	[takeAction setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[takeAction setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	//Negative frame, because of centered UIButton text. Gross.
	takeAction.frame = CGRectMake(20, 20, 250, 40);
	
	alertBackground = [[UIImageView alloc] init];
	[alertBackground setFrame:CGRectMake(0,0,320,60)];
	
	if(dataObj.type == kSMSAlert)
	{
		alertBackground.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/greenAlert_retina.png"];
	}
	if(dataObj.type == kPushAlert)
	{
		alertBackground.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/blueAlert_retina.png"];
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
	NSLog(@"Action!");
	[_delegate alertViewController:self hadActionTaken:kAlertSentAway];

	//And that's it! The delegate will take care of everything else.
}

-(void)takeAction:(id)sender
{
	//Notify the delegate
	NSLog(@"Action!");
	[_delegate alertViewController:self hadActionTaken:kAlertTakeAction];
}

@end
