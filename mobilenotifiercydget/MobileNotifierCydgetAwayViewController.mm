#import <SpringBoardUI/SBAwayViewPluginController.h>

@interface MobileNotifierCydgetAwayViewController: SBAwayViewPluginController {
}
@end

@implementation MobileNotifierCydgetAwayViewController
- (BOOL)handleMenuButtonDoubleTap {
	return [super handleMenuButtonDoubleTap];
}

- (BOOL)handleMenuButtonHeld {
	return [super handleMenuButtonHeld];
}

- (BOOL)handleMenuButtonTap {
	return [super handleMenuButtonTap];
}

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.view.backgroundColor = [UIColor redColor];
}

+ (id)rootViewController { return [[[self alloc] init] autorelease]; }
@end

// vim:ft=objc
