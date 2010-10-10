/*

MobileNotifier, by Peter Hajas

Copyright 2010 Peter Hajas, Peter Hajas Software

This code is licensed under the GPL. The full text of which is available in the file "LICENSE"
which should have been included with this package. If not, please see:

http://www.gnu.org/licenses/gpl.txt

and notify Peter Hajas

iOS Notifications. Done right. Like 2010 right.

This is an RCOS project for the Spring 2010 semester. The website for RCOS is at rcos.cs.rpi.edu/

Thanks to:

Mukkai Krishnamoorthy - cs.rpi.edu/~moorthy - for being the faculty sponsor
Sean O' Sullivan - for his financial contributions. Thanks so much Mr. Sullivan.

Dustin Howett - howett.net - for Theos and amazing help on IRC!
Ryan Petrich - github.com/rpetrich - for Activator and help on IRC
chpwn - chpwn.com - for his awesome tweaks and help on IRC
KennyTM - github.com/kennytm - for his decompiled headers
Jay Freeman - saurik.com - for MobileSubstrate, Cydia, Veency and countless other gifts to the community

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

#import <objc/runtime.h>

#import <libactivator/libactivator.h>

//Some class initialization:

//View initialization for a very very (VERY) basic view
@interface alertDisplayController : UIViewController
{
	//UI Elements
    UILabel *alertLabel;
    UIButton *dismissAlertButton;

    UIImageView *alertBG;

    //Alert properties

    NSString *alertText;
    NSString *bundleIdentifier;
    NSString *alertType;
}

- (void)hideAlert;
- (void)dismissAlert;

- (void)configWithType:(NSString *)type andBundle:(NSString *)bundle;

@property (readwrite, retain) UILabel *alertLabel;
@property (readwrite, retain) UIButton *dismissAlertButton;

@property (readwrite, retain) UIImageView *alertBG;

@property (readwrite, retain) NSString *alertText;
@property (readwrite, retain) NSString *bundleID;
@property (readwrite, retain) NSString *alertType;

@end

@interface alertDataController : NSObject
{
    NSString *alertText;
    NSString *bundleIdentifier;
    NSString *alertType;
}

- (void)initWithAlertDisplayController:(alertDisplayController *) dispController;

@property (nonatomic, copy) NSString *alertText;
@property (nonatomic, copy) NSString *bundleIdentifier;
@property (nonatomic, copy) NSString *alertType;

@end

//Our alertController object, which will handle all event processing

@interface alertController : NSObject <LAListener>
{
    NSMutableArray *eventArray;
}

- (void)newAlert:(NSString *)title ofType:(NSString *)alertType withBundle:(NSString *)bundle;
- (void)removeAlertFromArray:(alertDataController *)alert;
- (void)saveArray;
- (void)updateSize;

//libactivator methods:
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event;
- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event;

@property (nonatomic, copy) NSMutableArray *eventArray;

@end


//Alert Controller:
alertController *controller;

//Our UIWindow:

static UIWindow *alertWindow;

//How tall each alertDisplayController is
int alertHeight = 60;

//Mail class declaration. This was dumped with class dump z (by kennytm)
//and was generated with MobileMail.app

@protocol AFCVisibleMailboxFetch <NSObject>
-(void)setShouldCompact:(BOOL)compact;
-(void)setMessageCount:(unsigned)count;
-(void)setRemoteIDToPreserve:(id)preserve;
-(void)setDisplayErrors:(BOOL)errors;
-(id)mailbox;
@end

@interface AutoFetchRequestPrivate
{

}

-(void)run;
-(BOOL)gotNewMessages;
-(int)messageCount;

@end

@implementation alertController

@synthesize eventArray;

- (void)newAlert:(NSString *)title ofType:(NSString *)alertType withBundle:(NSString *)bundle
{
    NSLog(@"newAlert!");
    alertDisplayController *alert = [[alertDisplayController alloc] init];
    [alert configWithType:alertType andBundle:bundle];
    NSLog(@"and we're after configWithType");	

    alertDataController *data = [[alertDataController alloc] init];
    [data initWithAlertDisplayController: alert];
    data.alertText = title;
    NSLog(@"after init'ing data");
    NSLog(@"data: %@, %@, %@, %@", data, data.alertText, data.bundleIdentifier, data.alertType);
    
    //Why does this call fail?
    [eventArray addObject: data];
    NSLog(@"after adding object");
    alertWindow.frame = CGRectMake(0,20,320, ([eventArray count] * alertHeight));
    NSLog(@"after changing frame");
    NSLog(@"New alertWindow frame: %f x %f", alertWindow.frame.size.width, alertWindow.frame.size.height);
    
    alert.view.frame = CGRectMake(0, (([eventArray count] * alertHeight) + 20) - alertHeight, 320, alertHeight);
	NSLog(@"about to add alert.view");
    [alertWindow addSubview:alert.view];
    NSLog(@"added alert.view");

    [[alert view] performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:5.0];
    [self performSelector:@selector(updateSize) withObject:nil afterDelay:5.1];

    [self saveArray];
}

- (void)removeAlertFromArray:(alertDataController *)alert
{
    [eventArray removeObject:alert];

    [self saveArray];
}

- (void)saveArray
{
    if([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/MobileNotifier/notifications.plist"])
    {
        //Aha! Good, let's save the array
        [eventArray writeToFile:@"/var/mobile/MobileNotifier/notifications.plist" atomically:YES];
    }
    else
    {
        //Something terrible has happened!
        [eventArray writeToFile:@"/var/mobile/MobileNotifier/notifications.plist" atomically:YES];
    }
}

- (void)loadArray
{
    if(eventArray == NULL)
    {
        eventArray = [[NSMutableArray alloc] init];
    }

    if([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/MobileNotifier/notifications.plist"])
    {
        //Aha! Good, let's load the array
        [eventArray initWithContentsOfFile:@"/var/mobile/MobileNotifier/notifications.plist"];
    }
    
    else
    {
        //First time user! Let's present them with some information.
        NSLog(@"Event array file doesn't exist!"); 
        
        //Create the directory!
        [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/MobileNotifier/" withIntermediateDirectories:NO attributes:nil error:NULL];

        //Now, we should create the array.
        [eventArray writeToFile:@"/var/mobile/MobileNotifier/notifications.plist" atomically:YES];
    }

}

- (void)updateSize
{
    alertWindow.frame.size = CGSizeMake(320, ([eventArray count] * alertHeight));
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

@synthesize alertText, bundleID, alertType;

@synthesize alertLabel, dismissAlertButton, alertBG;

- (void)hideAlert
{
    //Play an animation, then remove us from our superview
}

- (void)dismissAlert
{

}

- (void)takeAction
{
    //Launch the app specified by the notification
    
    //[[SBUIController sharedInstance] activateApplicationAnimated: [[[SBApplicationController sharedInstance] applicationsWithBundleIdentifier:[self bundleID]] objectAtIndex: 0]];

    //[(SBUIController *)[objc_getClass("SBUIController") sharedInstance] activateApplicationAnimated: [[(SBApplicationController *)[objc_getClass("SBApplicationController") sharedInstance] applicationsWithBundleIdentifier:[self bundleID]] objectAtIndex: 0]];

    SBUIController *uicontroller = (SBUIController *)[objc_getClass("SBUIController") sharedInstance];
    SBApplicationController *appcontroller = (SBApplicationController *)[objc_getClass("SBApplicationController") sharedInstance];

    [uicontroller activateApplicationAnimated:[[appcontroller applicationsWithBundleIdentifier:[self bundleID]] objectAtIndex:0]];
}

- (void)configWithType:(NSString *)type andBundle:(NSString *)bundle
{
    NSLog(@"configWithType!");
    
    self.bundleID = [NSString stringWithString:bundle];
    self.alertType = [NSString stringWithString:type];
    
    alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280 , 40)];
    alertLabel.backgroundColor = [UIColor clearColor];

    //Wire up the UIButton!
    
    dismissAlertButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [dismissAlertButton addTarget:self action:@selector(dismissAlert:) forControlEvents:UIControlEventTouchDown];
    [dismissAlertButton setTitle:@"X" forState:UIControlStateNormal];
    dismissAlertButton.frame = CGRectMake(280, 20, 50, 50);

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
	self.alertText = alertLabel.text;

    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, ([[alertWindow subviews] count] * 60), [[UIScreen mainScreen] bounds].size.width, 60)];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:alertBG];
    NSLog(@"alertBG added!");
	[self.view addSubview:alertLabel];
    NSLog(@"alertLabel added!");
    [self.view addSubview:dismissAlertButton];
    NSLog(@"dismissAlertButton added!");
	[alertBG release];
    [alertLabel release];
    [dismissAlertButton release];
}

@end

@implementation alertDataController

@synthesize alertText, bundleIdentifier, alertType;

- (void)initWithAlertDisplayController:(alertDisplayController *) dispController
{
    self.alertText = [[NSString alloc] init];
    self.bundleIdentifier = [NSString stringWithString:dispController.bundleID];
    self.alertType = [NSString stringWithString:dispController.alertType];
}

@end

//Hook into Springboard init method to initialize our window

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application
{    
    %orig;
    
    controller = [[alertController alloc] init];
    [controller loadArray];

    alertWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0,20,320,0)]; //Measured to be zero, we don't want to mess up interaction with views below! Also, we live below the status bar
	alertWindow.windowLevel = 990; //Don't mess around with WindowPlaner or SBSettings if the user has it installed :)
	alertWindow.userInteractionEnabled = YES;
	alertWindow.hidden = NO;

    //Connect up to Activator
    [[LAActivator sharedInstance] registerListener:controller forName:@"com.peterhajassoftware.mobilenotifier"];
}

%end;

//Experimental: Hook SBAlertItemsController for skipping the alert grabbing and going right for the built-in manager

%hook SBAlertItemsController

-(void)activateAlertItem:(id)item
{
    if([item isKindOfClass:%c(SBSMSAlertItem)])
    {
        //It's an SMS/MMS!
        if([item alertImageData] == NULL)
        {
            [controller newAlert: [NSString stringWithFormat:@"SMS from %@: %@", [item name], [item messageText]] ofType:@"SMS" withBundle:@"com.apple.mobilesms"];
        }
        else
        {
            [controller newAlert: [NSString stringWithFormat:@"MMS from %@", [item name]] ofType: @"MMS" withBundle:@"com.apple.mobilesms"];
        }
    }
    else if([item isKindOfClass:%c(SBRemoteNotificationAlert)])
    {
        //It's a push notification!
        SBApplication *app(MSHookIvar<SBApplication *>(self, "_app"));
        NSString *body(MSHookIvar<NSString *>(self, "_body"));
        [controller newAlert: [NSString stringWithFormat:@"%@: %@", [app displayName], body] ofType:@"Push" withBundle:[app bundleIdentifier]];
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
