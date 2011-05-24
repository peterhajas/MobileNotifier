#import "MNAlertTableViewDataSourceEditable.h"

@implementation MNAlertTableViewDataSourceEditable

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  MNTableViewCell *cell = (MNTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"notificationTableCell"];

  if (cell == nil)
  {
    cell = [[[MNTableViewCell alloc] init] autorelease];
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

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (type == kMNAlertTableViewDataSourceTypePending)
        {
            // Dismiss the alert
            [_delegate dismissedAlertAtIndex:indexPath.row];
        }

        // Delete row from tableview
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
        // Reload data
        [tableView reloadData];
    }
}

@end
