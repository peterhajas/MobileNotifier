#import "MNAlertTableViewDataSourceEditable.h"

@implementation MNAlertTableViewDataSourceEditable

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        if(type == kMNAlertTableViewDataSourceTypePending)
        {
            //Dismiss the alert
            [_delegate dismissedAlertAtIndex:indexPath.row];
        }

        //Delete row from tableview
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
}

@end