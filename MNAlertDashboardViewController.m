#import <QuartzCore/QuartzCore.h>
#import "MNAlertDashboardViewController.h"

@implementation MNAlertDashboardViewController

@synthesize picker, tableView, window;
@synthesize delegate = _delegate;

-(id)init
{
	self = [super init];
	if(self)
	{
		CGRect screenBounds = [[UIScreen mainScreen] bounds];
		
		//Initialize ivars:
		//picker:
		NSMutableArray *items = [[NSMutableArray alloc] init];
		[items addObject:@"pending"];
		[items addObject:@"sent"];
		[items addObject:@"saved"];
		activeArray = -1;
		picker = [[UISegmentedControl alloc] initWithItems: items];
		picker.segmentedControlStyle = UISegmentedControlStyleBar;
		picker.frame = CGRectMake(0, 10, screenBounds.size.width - 20, 40);
		[picker			  addTarget:self
		                     action:@selector(activeArrayChanged:)
		           forControlEvents:UIControlEventValueChanged];
		
		//tableView:
		tableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 55, screenBounds.size.width - 20, screenBounds.size.height / 2) style: UITableViewStylePlain];
		tableView.dataSource = self;
		tableView.delegate = self;
		//Rounded corners!
		tableView.layer.cornerRadius = 5;
		
		//window:
		window = [[UIWindow alloc] initWithFrame:CGRectMake(10 ,20,screenBounds.size.width,(screenBounds.size.height / 2) + 55)];
		window.windowLevel = 989;
		window.userInteractionEnabled = NO;
		window.hidden = YES;
		
		//add our stuff!
		[window addSubview:picker];
		[window addSubview:tableView];
	}
	return self;
}

-(void)toggleDashboard
{
	window.userInteractionEnabled = !window.userInteractionEnabled;
	window.hidden = !window.hidden;
}

-(void)hideDashboard
{
	window.userInteractionEnabled = NO;
	window.hidden = YES;
}

-(void)showDashboard
{
	window.userInteractionEnabled = YES;
	window.hidden = NO;
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

//UITableViewDataSource methods:

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//Declare our temporary cell. Reuse identifier of nil, as alert cells won't be recycled
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
	//We want to sort these in inverse order
	MNAlertData *data = (MNAlertData*)[activeArrayReference objectAtIndex: [activeArrayReference count] - 1 - indexPath.row];
	//Set the text to the text represented in the AlertData object
	cell.textLabel.text = data.header;
	cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
	cell.textLabel.textColor = [UIColor darkGrayColor];
	cell.detailTextLabel.text = data.text;
	cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:11];
	cell.detailTextLabel.textColor = [UIColor blackColor];
	
	//TODO: Set the icon for the cell.imageView.image property
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [activeArrayReference count];
}

//UITableViewDelegate methods:

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_delegate actionOnAlertAtIndex:indexPath.row inArray:activeArray];
}

@end