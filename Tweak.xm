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

#import <libactivator/libactivator.h>

//Some class initialization:
//View initialization for a very very (VERY) basic view

@interface alertDisplayController : UIViewController
{
	UILabel *alertText;
    UIImageView *alertBG;
}

@property (readwrite, retain) UILabel *alertText;
@property (readwrite, retain) UIImageView *alertBG;

- (void)config;

@end

//Our alertController object, which will handle all event processing

@interface alertController : NSObject <LAListener>
{
    NSMutableDictionary *eventDict;

}

- (void)newAlert:(NSString *)title ofType:(NSString *)alertType;
- (void)updateSize;

//libactivator methods:
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event;
- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event;

@property (readwrite, retain) NSMutableDictionary *eventDict;

@end


//Alert Controller:
alertController *controller;

//Our UIWindow:

static UIWindow *alertWindow;

//Number of alerts currently onscreen:
int numAlerts = 0;

//How high each alert view is
int alertHeight = 60;

//Absolutely gross global variables. These will change when the libactivator branch is merged.
//These are for battery management
BOOL isCritical;
BOOL isWarning;
BOOL isFullyCharged;

//Mail class declaration. This was dumped with class dump z (by kennytm)
//and was generated with MobileMail.app

@protocol AFCVisibleMailboxFetch <NSObject>
-(void)setShouldCompact:(BOOL)compact;
-(void)setMessageCount:(unsigned)count;
-(void)setRemoteIDToPreserve:(id)preserve;
-(void)setDisplayErrors:(BOOL)errors;
-(id)mailbox;
@end

@interface AutoFetchRequestPrivate{
}
-(void)run;
-(BOOL)gotNewMessages;
-(int)messageCount;

@end

//SBSMSAlertItem and SBRemoteNotificationAlert class declarations:
//Header taken from kennytm's headers


//Hook into Springboard init method to initialize our window

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application
{    
    %orig;
    
    NSLog(@"Initializing alertWindow and controller");

    controller = [[alertController alloc] init];

    alertWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0,0,320,0)]; //Measured to be zero, we don't want to mess up interaction with views below!
	alertWindow.windowLevel = 990; //Don't mess around with WindowPlaner or SBSettings if the user has it installed :)
	alertWindow.userInteractionEnabled = YES;
	alertWindow.hidden = NO;

    isCritical = NO;
    isWarning = NO;
    isFullyCharged = NO;

    [[LAActivator sharedInstance] registerListener:controller forName:@"com.peterhajassoftware.mobilenotifier"];
    
}

-(void)batteryStatusDidChange:(id)batteryStatus
{   
    //Read out from the battery information dictionary contained in batteryStatus

    /*
    if([[batteryStatus] objectForKey:@"isCritical"] != isCritical)
    {
        //Trigger an alert!
        
        if(!isCritical)
        {
            isCritical = YES;
        }
         
    }
    else //Well, nothing's changed, let's keep that in mind
    {
        isCritical = [[batteryStatus] objectForKey:@"FullyCharged"];
    }

    if([[batteryStatus] objectForKey:@"FullyCharged"] != isWarning)
    {
        if(!isCritical)
        {
            isCritical = YES;
        } 
        
    }
    else 
    {
        isWarning = [[batteryStatus] objectForKey:@"isWarning"];
    }

    if([[batteryStatus] objectForKey:@"FullyCharged"] != isFullyCharged)
    {
        if(!isCritical)
        {
            isCritical = YES;
        } 
        
    }
    else 
    {
        isFullyCharged = [[batteryStatus] objectForKey:@"FullyCharged"];
    }
    */

    %orig;
}

%end;


@implementation alertController

@synthesize eventDict;

- (void)newAlert:(NSString *)title ofType:(NSString *)alertType
{
    alertDisplayController *alert = [[alertDisplayController alloc] init];
    [alert config];
	
	alert.alertText.text = title;

    numAlerts++;

    NSLog(@"Number of alerts: %d");
	
    alertWindow.frame = CGRectMake(0,0,320,(numAlerts * alertHeight));
    
    NSLog(@"New alertWindow frame: %f x %f", alertWindow.frame.size.width, alertWindow.frame.size.height);
    
    alert.view.frame = CGRectMake(0, ((numAlerts * alertHeight) + 20) - alertHeight, 320, alertHeight);
	[alertWindow addSubview:alert.view];

    [[alert view] performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:5.0];
    [self performSelector:@selector(updateSize) withObject:nil afterDelay:5.1];
}

//Update the size of the UIWindow we use to show our alerts
- (void)updateSize
{
    numAlerts--;
    NSLog(@"Number of alerts: %d");
    alertWindow.frame = CGRectMake(0,0,320,(numAlerts * alertHeight));
}


//libactivator methods:
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
   NSLog(@"We received an LAEvent!");
}
- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
   NSLog(@"We received an LAEvent abort!");
}
@end

@implementation alertDisplayController

@synthesize alertText, alertBG; 

- (void)config
{
	alertText = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280 , 40)];
    alertText.backgroundColor = [UIColor clearColor];

    if ([[UIScreen mainScreen] bounds].size.width >= 640)
    {
        //Retina display or iPad display
        alertBG = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/blueAlert_retina.png"]];
    }
    else
    {
        //Regular display, we call this "cornea display" because we have a good sense of humor
        alertBG = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/blueAlert_cornea.png"]];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{	
	NSLog(@"Alert touched!");
    [self.view removeFromSuperview];
    [controller updateSize];
}

- (void)viewDidLoad
{	
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, ([[alertWindow subviews] count] * 60), [[UIScreen mainScreen] bounds].size.width, 60)];
    self.view.backgroundColor = [UIColor clearColor];	
    
    [self.view addSubview:alertBG];
	[self.view addSubview:alertText];
	[alertText release];
}

@end

//Experimental: Hook SBAlertItemsController for skipping the alert grabbing and going right for the built-in manager

%hook SBAlertItemsController

-(void)activateAlertItem:(id)item
{
    if([item isKindOfClass:%c(SBSMSAlertItem)])
    {
        //It's an SMS/MMS!
        if([item alertImageData] == NULL)
        {
            [controller newAlert: [NSString stringWithFormat:@"SMS from %@: %@", [item name], [item messageText]] ofType:@"SMS"];
        }
        else
        {
            [controller newAlert: [NSString stringWithFormat:@"MMS from %@", [item name]] ofType: @"MMS"];
        }
    }
    else if([item isKindOfClass:%c(SBRemoteNotificationAlert)])
    {
        //It's a push notification!
        SBApplication *app(MSHookIvar<SBApplication *>(self, "_app"));
        NSString *body(MSHookIvar<NSString *>(self, "_body"));
        [controller newAlert: [NSString stringWithFormat:@"%@: %@", [app displayName], body] ofType:@"Push"];
    }
    else
    {
        //It's a different alert (power, for example)
    }


    %orig;
}

-(void)deactivateAlertItem:(id)item
{
    %log;
    %orig;
}

%end

//Hook SBAwayView for showing our lockscreen view.
//SBAwayView is released each time the phone is unlocked, and a new instance created when the phone is locked (thanks Limneos!)

%hook SBAwayView

-(void)viewDidLoad
{
    alertDisplayController *alert = [[alertDisplayController alloc] init];
    [alert config];
	
	alert.alertText.text = @"Test!";
 
    [self addSubview:alert.view];
    [self bringSubviewToFront:alert.view];

    %orig;
}

- (void)viewWillDisappear:(BOOL)animated
{
     
    %orig;
}

%end;

//Hook AutoFetchRequestPrivate for getting new mail

%hook AutoFetchRequestPrivate

-(void)run //This works! This is an appropriate way for us to display a new mail notification to the user
{
	%orig;
    %log;
	if([self gotNewMessages])
	{
		NSLog(@"Attempted fetch with %d new mail!", [self messageCount]); //Message count corresponds to maximum storage in an inbox (ie 200), not to the count of messages received...
    
        //Display our alert! 
        [controller newAlert:@"New mail!" ofType:@"Mail"];
	}
	else
	{
		NSLog(@"Attempted fetch with no new mail.");
	}
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

	//How to hook ivars!
	//MSHookIvar<ObjectType *>(self, "OBJECTNAME");
