#import "MNAlertData.h"
#import "MNAlertViewController.h"

@interface MNAlertManager : NSObject <LAListener, MNAlertViewControllerDelegate>
{
	NSMutableArray *pendingAlerts;
	NSMutableArray *pendingAlertViews;
	NSMutableArray *sentAwayAlerts;
	NSMutableArray *dismissedAlerts;

}

-(void)newAlertWithData:(MNAlertData *)data;
-(void)saveOut;

@end
