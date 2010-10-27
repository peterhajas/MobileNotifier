#import <UIKit/UIKit.h>
#import <libactivator/libactivator.h>
#import "AlertDataController.h"
#import "AlertDisplayController.h"

@class AlertDataController;

@class AlertController;
@protocol AlertControllerDelegate
- (void)launchAppInSpringBoardWithBundleID:(NSString *)bundleID;
@end

@interface AlertController : NSObject <LAListener, AlertDisplayControllerDelegate>
{
    NSMutableArray *eventArray;
    NSMutableArray *visibleAlertDisplayControllers;
    UIWindow *alertWindow;

    //Delegate

    id<AlertControllerDelegate> _delegate;
}

- (void)newAlert:(NSString *)title ofType:(NSString *)alertType withBundle:(NSString *)bundle;
- (void)removeAlertFromArray:(AlertDataController *)alert;
- (void)loadArray;
- (void)saveArray;
- (void)updateSize;
- (void)redrawAlertsFrom:(AlertDisplayController *)adc;

//libactivator methods:
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event;
- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event;

@property (nonatomic, assign) id<AlertControllerDelegate> delegate;

@property (nonatomic, retain) UIWindow *alertWindow;

@end

// vim:ft=objc
