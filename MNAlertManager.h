#define kNewAlertForeground 0
#define kNewAlertBackground 1

#import "MNAlertDashboardViewController.h"
#import "MNAlertData.h"
#import "MNAlertViewController.h"

@class MNAlertManager;
@protocol MNAlertManagerDelegate
- (void)launchAppInSpringBoardWithBundleID:(NSString *)bundleID;
@end

@interface MNAlertManager : NSObject <MNAlertViewControllerDelegate, MNAlertDashboardViewControllerProtocol>
{
	NSMutableArray *pendingAlerts;
	NSMutableArray *pendingAlertViews;
	NSMutableArray *sentAwayAlerts;
	NSMutableArray *dismissedAlerts;
	
	UIWindow *alertWindow;
	
	MNAlertDashboardViewController *dashboard;
	
	id<MNAlertManagerDelegate> _delegate;
}

-(void)newAlertWithData:(MNAlertData *)data;
-(void)saveOut;
-(void)redrawAlertsBelowIndex:(int)index;

@property (nonatomic, retain) UIWindow *alertWindow;

@property (nonatomic, retain) NSMutableArray *pendingAlerts;
@property (nonatomic, retain) NSMutableArray *pendingAlertViews;
@property (nonatomic, retain) NSMutableArray *sentAwayAlerts;
@property (nonatomic, retain) NSMutableArray *dismissedAlerts;

@property (nonatomic, retain) MNAlertDashboardViewController *dashboard;

@property (nonatomic, assign) id<MNAlertManagerDelegate> delegate;

@end
