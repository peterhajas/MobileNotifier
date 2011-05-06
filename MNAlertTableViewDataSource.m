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

#import "MNAlertTableViewDataSource.h"

@implementation MNAlertTableViewDataSource

@synthesize delegate = _delegate;

-(id)initWithStyle:(int)style andDelegate:(id)__delegate
{
    self = [super init];
    if(self)
    {
        type = style;
        _delegate = __delegate;
        NSLog(@"my delegate is %@", _delegate);
    }
    
    return self;
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	MNTableViewCellClear *cell = (MNTableViewCellClear *) [tableView dequeueReusableCellWithIdentifier:@"notificationTableCell"];
	
	if (cell == nil)
	{
		cell = [[[MNTableViewCellClear alloc] init] autorelease];
	}
	
    MNAlertData *dataObj;
	
	if(type == kMNAlertTableViewDataSourceTypePending)
	{
	    dataObj = [[_delegate getPendingAlerts] objectAtIndex:indexPath.row];
	}
	
	else if(type == kMNAlertTableViewDataSourceTypeArchived)
	{
	    dataObj = [[_delegate getDismissedAlerts] objectAtIndex:indexPath.row];
	}
	
	else
	{
        dataObj = [[[MNAlertData alloc] initWithHeader:@"Null" 
                                             withText:@"Null" 
                                              andType:kPushAlert 
                                          forBundleID:@"com.apple.calculator" 
                                             ofStatus:kNewAlertForeground]
                                          autorelease];
	}
	
	cell.iconImageView.image = [_delegate iconForBundleID:dataObj.bundleID];
	cell.headerLabel.text = dataObj.header;
	cell.alertTextLabel.text = dataObj.text;
	return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(type == kMNAlertTableViewDataSourceTypePending)
	{
	    return [[_delegate getPendingAlerts] count];
	}
	
	else if(type == kMNAlertTableViewDataSourceTypeArchived)
	{
	    return [[_delegate getDismissedAlerts] count];
	}
	
    else
    {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60.0;
}

@end
