#import "AlertDataController.h"
#import "AlertDisplayController.h"

@implementation AlertDataController

@synthesize alertText, bundleIdentifier, alertType;

- (void)initWithAlertDisplayController:(AlertDisplayController *) dispController
{
    self.alertText = [NSString stringWithString:dispController.alertText];
    self.bundleIdentifier = [NSString stringWithString:dispController.bundleID];
    self.alertType = [NSString stringWithString:dispController.alertType];
}

- (void)initWithText:(NSString *)text bundleID:(NSString *)bundle andType:(NSString *)type
{
    self.alertText = [NSString stringWithString:text];
    self.bundleIdentifier = [NSString stringWithString:bundle];
    self.alertType = [NSString stringWithString:type];
}

//NSCoder fun!
- (void) encodeWithCoder:(NSCoder*)encoder 
{
    [encoder encodeObject:alertText forKey:@"alertText"];
    [encoder encodeObject:bundleIdentifier forKey:@"bundleIdentifier"];
    [encoder encodeObject:alertType forKey:@"alertType"];
}

- (id) initWithCoder:(NSCoder*)decoder
{
    alertText = [[decoder decodeObjectForKey:@"alertText"] retain];
    bundleIdentifier = [[decoder decodeObjectForKey:@"bundleIdentifier"] retain];
    alertType = [[decoder decodeObjectForKey:@"alertType"] retain];

    return self;
}

@end

// vim:ft=objc
