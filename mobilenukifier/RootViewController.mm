#import "RootViewController.h"

@implementation RootViewController
@synthesize doIt;

- (void)loadView 
{
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.view.backgroundColor = [UIColor orangeColor];
	
	//Create button
	doIt = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	[doIt setTitle:@"Delete files" forState:UIControlStateNormal];
	//Wire it up
	[doIt addTarget:self 
		  	 action:@selector(detonate:) 
   forControlEvents:UIControlEventTouchUpInside];
	//Set the frame to something sane (do better for iPad?)
	doIt.frame = CGRectMake(60, 200, 200, 200);
	//Add to view
	[self.view addSubview:doIt];
}

- (void)detonate:(id)sender
{
	//Delete MobileNotifier files
	//Grab fileManager
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	//Remove MobileNotifier directory and contents
	[fileManager removeItemAtPath:@"/var/mobile/Library/MobileNotifier" 
				 			error:nil];	
	
	//Respring the phone!
	system("killall SpringBoard");
}

@end
