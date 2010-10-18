#import <UIKit/UIKit.h>
#import <libactivator/libactivator.h>
#import "alertDataController.h"

@interface alertController : NSObject <LAListener, alertDisplayControllerDelegate>
{
    NSMutableArray *eventArray;
    UIWindow *alertWindow;
}

- (void)newAlert:(NSString *)title ofType:(NSString *)alertType withBundle:(NSString *)bundle;
- (void)removeAlertFromArray:(alertDataController *)alert;
- (void)loadArray;
- (void)saveArray;
- (void)updateSize;

//libactivator methods:
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event;
- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event;

@property (nonatomic, retain) UIWindow *alertWindow;

@end
