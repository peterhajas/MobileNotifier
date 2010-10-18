#import "AlertDataController.h"

@class alertDisplayController;
@protocol alertDisplayControllerDelegate
- (void)alert_DisplayController:(alertDisplayController *)adc hadActionTaken:(int)action;
@end


@interface alertDisplayController : UIViewController
{
	//UI Elements
    UILabel *alertLabel;
    UIButton *dismissAlertButton;

    UIImageView *alertBG;

    //Alert properties

    NSString *alertText;
    NSString *bundleIdentifier;
    NSString *alertType;

    //Delegate

    id<alertDisplayControllerDelegate> _delegate;
}

- (void)hideAlert;
- (void)dismissAlert:(id)sender;

- (void)intWithText:(NSString *)text type:(NSString *)type andBundle:(NSString *)bundle;

@property (nonatomic, assign) id<alertDisplayControllerDelegate> delegate;

@property (readwrite, retain) UILabel *alertLabel;
@property (readwrite, retain) UIButton *dismissAlertButton;

@property (readwrite, retain) UIImageView *alertBG;

@property (readwrite, retain) NSString *alertText;
@property (readwrite, retain) NSString *bundleID;
@property (readwrite, retain) NSString *alertType;

@end

