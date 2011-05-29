#import <UIKit/UIKit.h>

// The following is from this post on StackOverflow - http://stackoverflow.com/questions/1178010/how-to-stop-uitextview-from-scrolling-up-when-entering-it/1864205#1864205

@interface BCZeroEdgeTextView : UITextView

-(UIEdgeInsets)contentInset;

@end

// This ends code from the post on StackOverflow