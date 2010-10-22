#define kHideAlert 0
#define kTakeActionOnAlert 1

#import "AlertDataController.h"

@class AlertDisplayController;
@protocol AlertDisplayControllerDelegate
- (void)alertDisplayController:(AlertDisplayController *)adc hadActionTaken:(int)action;
@end


@interface AlertDisplayController : UIViewController
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

    id<AlertDisplayControllerDelegate> _delegate;
}

- (void)hideAlert;
- (void)dismissAlert:(id)sender;

- (void)intWithText:(NSString *)text type:(NSString *)type andBundle:(NSString *)bundle;

- (BOOL)equals:(AlertDisplayController *)adc;
- (BOOL)isEqualToAlertDataController:(AlertDataController *)adc;

@property (nonatomic, assign) id<AlertDisplayControllerDelegate> delegate;

@property (readwrite, retain) UILabel *alertLabel;
@property (readwrite, retain) UIButton *dismissAlertButton;

@property (readwrite, retain) UIImageView *alertBG;

@property (readwrite, retain) NSString *alertText;
@property (readwrite, retain) NSString *bundleIdentifier;
@property (readwrite, retain) NSString *alertType;

@end

// vim:ft=objc
