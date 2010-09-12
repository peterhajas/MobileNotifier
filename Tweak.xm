/*

MobileNotifier, by Peter Hajas

Copyright 2010 Peter Hajas, Peter Hajas Software

This code is licensed under the GPL. The full text of which is available in the file "LICENSE"
which should have been included with this package. If not, please see:

http://www.gnu.org/licenses/gpl.txt


iOS Notifications. Done right. Like 2010 right.

This is an RCOS project for the Spring 2010 semester. The website for RCOS is at rcos.cs.rpi.edu/

Thanks to:

Mukkai Krishnamoorthy - cs.rpi.edu/~moorthy
Sean O' Sullivan

Dustin Howett - howett.net
Ryan Petrich - github.com/rpetrich
chpwn - chpwn.com
KennyTM - github.com/kennytm
Jay Freeman - saurik.com

for all your help and mega-useful tools.

To build this, use "make" in the directory. This project utilizes Theos as its makefile system and Logos as its hooking preprocessor.

You will need Theos installed:
http://github.com/DHowett/theos
With the decompiled headers in /theos/include/:
http://github.com/kennytm/iphone-private-frameworks

I hope you enjoy! Questions and comments to peterhajas (at) gmail (dot) com

And, as always, have fun!

*/

#import <SpringBoard/SpringBoard.h>
#import <ChatKit/ChatKit.h>

//Our UIWindow:

static UIWindow *alertWindow;


//View initialization for a very very (VERY) basic view

@interface alertDisplayController : UIViewController
{
	UILabel *alertText;
	SBSMSAlertItem *smsAlert;
}

@property (readwrite, retain) UILabel *alertText;
@property (readwrite, retain) SBSMSAlertItem *smsAlert;

@end

@implementation alertDisplayController

@synthesize alertText, smsAlert;

- (void)config
{
	alertText = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 40)];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{	
	//UITouch *touch = [touches anyObject];
	NSLog(@"Alert touched!");
	[smsAlert reply];
}

- (void)viewDidLoad
{
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
	self.view.backgroundColor = [UIColor blueColor];

	///*UILabel **/alertText = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 40)];
	//alertText.text = @"Test alert";

	[self.view addSubview:alertText];
	[alertText release];
}

@end

//Hook the display method for receiving an SMS message
%hook SBSMSAlertItem

-(void)init
{
	%log;
	NSString *name = [self name];
	NSLog(@"Test!");
	NSLog(@"Name: %@", name);
	
	NSString *messageText = [self messageText];
	NSLog(@"Message Text: %@", messageText);
	
	NSLog(@"Address: %@", [self address]);
	
	//CKMessage parsing code:
	//How to hook ivars!
	//MSHookIvar<ObjectType *>("self", "OBJECTNAME");
	
	
	CKMessage *demo = MSHookIvar<CKMessage *>(self, "_message");
	
	if(demo == nil)
	{
		NSLog(@"Message is null");
	}
	NSString *text = [demo text];
	NSString *subject = [demo subject];
	NSString *address = [demo address];
	
	NSLog(@"Text: %@", text);
	NSLog(@"Subject: %@", subject);
	NSLog(@"Address: %@", address);
	
	//Call the original function, we kind of would like to be notified of
	//getting a new text message while this is in its early stages.
	%orig;
}

-(void)setMessage:(id)message
{
	NSLog(@"setMessage called!");
	CKSMSMessage *theMessage = message;
	
	NSLog(@"Messages: %@", [theMessage messages]); 
	//CKSMSRecord object
	
	NSLog(@"Sender: %@", [[theMessage sender] name]);
	//CKSMSEntity object is [theMessage sender],
	//With name flag, we get the name in the address book!
	
	NSLog(@"Address: %@", [theMessage address]); 
	//Phone number of user sending text
	
	NSLog(@"Total Message Count: %d", [theMessage totalMessageCount]); 
	//Number of new messages? - not so with messages of > 160 characters
	
	
	//Display our alert!
	alertDisplayController *alert = [[alertDisplayController alloc] init];
	[alert config];
	
	alert.alertText.text = [NSString stringWithFormat:@"New SMS from %@: %@", [[theMessage sender] name], @"message placeholder"];
	alert.smsAlert = self;
	
	alertWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	alertWindow.windowLevel = 99998; //Don't mess around with WindowPlaner if the user has it installed :)
	alertWindow.userInteractionEnabled = NO;
	alertWindow.hidden = NO;
	
	[alertWindow addSubview:alert.view];
	
	%orig;
}

-(void)reply
{
	NSLog(@"Reply called!");
	
	//Equivalent to pressing "View" with a long message
	%orig;
}

%end


//Information about Logos for future reference:

/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.

%hook ClassName

// Hooking a class method
+ (id)sharedInstance {
	return %orig;
}

// Hooking an instance method with an argument.
- (void)messageName:(int)argument {
	%log; // Write a message about this call, including its class, name and arguments, to the system log.

	%orig; // Call through to the original function with its original arguments.
	%orig(nil); // Call through to the original function with a custom argument.

	// If you use %orig(), you MUST supply all arguments (except for self and _cmd, the automatically generated ones.)
}

// Hooking an instance method with no arguments.
- (id)noArguments {
	%log;
	id awesome = %orig;
	[awesome doSomethingElse];

	return awesome;
}

// Always make sure you clean up after yourself; Not doing so could have grave conseqeuences!
%end
*/