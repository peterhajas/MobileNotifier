#import <UIKit/UIKit.h>
#import <libactivator/libactivator.h>
#import "AlertDataController.h"
#import "AlertDisplayController.h"

@class AlertDataController;

@interface AlertController : NSObject <LAListener, AlertDisplayControllerDelegate>
{
    NSMutableArray *eventArray;
    UIWindow *alertWindow;
}

- (void)newAlert:(NSString *)title ofType:(NSString *)alertType withBundle:(NSString *)bundle;
- (void)removeAlertFromArray:(AlertDataController *)alert;
- (void)loadArray;
- (void)saveArray;
- (void)updateSize;

//libactivator methods:
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event;
- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event;

@property (nonatomic, retain) UIWindow *alertWindow;

@end

// vim:ft=objc
