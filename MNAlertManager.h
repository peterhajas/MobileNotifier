#define kNewAlertForeground 0
#define kNewAlertBackground 1

#import "MNAlertData.h"
#import "MNAlertViewController.h"

@class MNAlertManager;
@protocol MNAlertManagerDelegate
- (void)launchAppInSpringBoardWithBundleID:(NSString *)bundleID;
@end

@interface MNAlertManager : NSObject <LAListener, MNAlertViewControllerDelegate>
{
	NSMutableArray *pendingAlerts;
	NSMutableArray *pendingAlertViews;
	NSMutableArray *sentAwayAlerts;
	NSMutableArray *dismissedAlerts;
	
	UIWindow *alertWindow;
	
	id<MNAlertManagerDelegate> _delegate;
}

-(void)newAlertWithData:(MNAlertData *)data;
-(void)saveOut;

@property (nonatomic, retain) UIWindow *alertWindow;

@property (nonatomic, retain) NSMutableArray *pendingAlerts;
@property (nonatomic, retain) NSMutableArray *pendingAlertViews;
@property (nonatomic, retain) NSMutableArray *sentAwayAlerts;
@property (nonatomic, retain) NSMutableArray *dismissedAlerts;

@property (nonatomic, assign) id<MNAlertManagerDelegate> delegate;

@end
