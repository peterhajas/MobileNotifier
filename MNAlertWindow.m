#import "MNAlertWindow.h"

@implementation MNAlertWindow

- (void)drawRect:(CGRect)rect 
{
	/*NSLog(@"In drawRect!");
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    CGContextSetShadow(currentContext, CGSizeMake(0, 5), 2);
	*/
	[super drawRect: rect];
	//CGContextSetRGBFillColor(currentContext, 1.0, 0.0, 0.0, 1.0);
	//CGContextFillRect(currentContext, self.bounds);
    //CGContextRestoreGState(currentContext);
}

@end