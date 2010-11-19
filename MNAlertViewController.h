#define kAlertSentAway 0

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

-(void)initWithData:(MNAlertData *data);

@property(nonatomic, retain) UILabel *alertHeader;
@property(nonatomic, retain) UILabel *alertText;
@property(nonatomic, retain) UIButton *sendAway;
@property(nonatomic, retain) UIImageView *alertBackground;

@property(readwrite, retain) id<MNAlertViewControllerDelegate> _delegate;

@end
