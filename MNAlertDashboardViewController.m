#import "MNAlertDashboardViewController.h"

@implementation MNAlertDashboardViewController

@synthesize picker, tableView, infoDisplay, window;
@synthesize delegate = _delegate;

-(id)init
{
	self = [super init];
	if(self)
	{
		CGRect screenBounds = [[UIScreen mainScreen] bounds];
		
		//Initialize ivars:
		//picker:
		NSArray *items = [NSArray arrayWithObjects:@"sent", "@pending", @"saved", nil];
		activeArray = 0;
		picker = [[UISegmentedControl alloc] initWithItems: items];
		picker.segmentedControlStyle = UISegmentedControlStyleBar;
		picker.frame = CGRectMake(0, 20, screenBounds.size.width, 20);
		[picker			  addTarget:self
		                     action:@selector(activeArrayChanged:)
		           forControlEvents:UIControlEventValueChanged];
		
		//tableView:
		tableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 40, screenBounds.size.width, screenBounds.size.height / 2) style: UITableViewStylePlain];
		tableView.dataSource = self;
		tableView.delegate = self;
		
		//infoDisplay:
		infoDisplay = [[UILabel alloc] init];
		infoDisplay.text = @"Tapping an alert will send it to saved.";
		infoDisplay.frame = CGRectMake(10, 100, screenBounds.size.width - 20, 10);
		
		//window:
		window = [[UIWindow alloc] initWithFrame:CGRectMake(0,20,screenBounds.size.width,screenBounds.size.height)];
		window.windowLevel = 989;
		window.userInteractionEnabled = NO;
		window.hidden = YES;
		
		//add our stuff!
		[window addSubview:picker];
		[window addSubview:tableView];
		[window addSubview:infoDisplay];
	}
	return self;
}

-(void)toggleDashboard:(BOOL)toggle
{
	window.userInteractionEnabled = toggle;
	window.hidden = !toggle;
}

-(void)activeArrayChanged:(id)sender
{
	//We don't want a deselected picker to give us -1
	if(picker.selectedSegmentIndex > -1)
	{
		activeArray = picker.selectedSegmentIndex;
		if(activeArray == kPendingActive)
		{
			activeArrayReference = [_delegate getPendingAlerts];
		}
		else if(activeArray == kSentActive)
		{
			activeArrayReference = [_delegate getSentAwayAlerts];
		}
		else if(activeArray == kDismissActive)
		{
			activeArrayReference = [_delegate getDismissedAlerts];
		}
		[tableView reloadData];
	}
}

//UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [activeArrayReference count];
}

@end