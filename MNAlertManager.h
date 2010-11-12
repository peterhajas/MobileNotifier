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

@property (nonatomic, retain) NSMutableArray *pendingAlerts;
@property (nonatomic, retain) NSMutableArray *pendingAlertViews;
@property (nonatomic, retain) NSMutableArray *sentAwayAlerts;
@property (nonatomic, retain) NSMutableArray *dismissedAlerts;

@end
