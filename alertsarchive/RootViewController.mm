#import "RootViewController.h"

@implementation RootViewController
- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.view.backgroundColor = [UIColor redColor];
}
@end
