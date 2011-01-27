/*
Copyright (c) 2010-2011, Peter Hajas
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Peter Hajas nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL PETER HAJAS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

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