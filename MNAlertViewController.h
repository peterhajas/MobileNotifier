
@class MNAlertViewController

@protocol MNAlertViewControllerDelegate
-(void)alertViewController:(MNAlertViewController *)viewController hadActionTaken:(int)action;

@interface MNAlertViewController : UIViewController
{
	UILabel *alertHeader;
	UILabel *alertText;
	UIButton *sendAway;
	UIImageView *alertBackground;

	id<MNAlertViewControllerDelegate> _delegate;
}
