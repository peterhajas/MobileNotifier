#import "AlertDisplayController.h"

@class AlertDisplayController;

@interface AlertDataController : NSObject <NSCoding>
{
    NSString *alertText;
    NSString *bundleIdentifier;
    NSString *alertType;
}

- (void)initWithAlertDisplayController:(AlertDisplayController *) dispController;
- (void)initWithText:(NSString *)text bundleID:(NSString *)bundle andType:(NSString *)type;

@property (nonatomic, copy) NSString *alertText;
@property (nonatomic, copy) NSString *bundleIdentifier;
@property (nonatomic, copy) NSString *alertType;

@end

// vim:ft=objc
