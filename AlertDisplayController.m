#import "AlertDisplayController.h"

@implementation AlertDisplayController

@synthesize alertText, bundleID, alertType;

@synthesize alertLabel, dismissAlertButton, alertBG;

@synthesize delegate = _delegate;

- (void)hideAlert
{
    //Play an animation, then remove us from our superview
}

- (void)dismissAlert:(id)sender
{
    NSLog(@"button pushed!");

    [self.view removeFromSuperview];
    //Remove from the alertController
    //This has been implemented in AlertController.mm
    //Create data member
    /*
    alertDataController *data = [[alertDataController alloc] init];
    [data initWithAlertDisplayController:self];
    NSLog(@"data is %@, %@, %@, %@", data, data.alertText, data.bundleIdentifier, data.alertType);
    [controller removeAlertFromArray:data];

    [controller updateSize];
    */

    [_delegate alertDisplayController:self hadActionTaken:kHideAlert];
}

- (void)takeAction
{
    //Launch the app specified by the notification
    /* 
    SBUIController *uicontroller = (SBUIController *)[objc_getClass("SBUIController") sharedInstance];
    SBApplicationController *appcontroller = (SBApplicationController *)[objc_getClass("SBApplicationController") sharedInstance];

    [uicontroller activateApplicationAnimated:[[appcontroller applicationsWithBundleIdentifier:[self bundleID]] objectAtIndex:0]];
    */

    [_delegate alertDisplayController:self hadActionTaken:kTakeActionOnAlert];
}

- (void)intWithText:(NSString *)text type:(NSString *)type andBundle:(NSString *)bundle
{
    self.bundleID = [NSString stringWithString:bundle];
    self.alertType = [NSString stringWithString:type];
    self.alertText = [NSString stringWithString:text];

    NSString *imageForAlert = [[NSString alloc] init];

    if(alertType == @"SMS")
    {
        imageForAlert = @"/Library/Application Support/MobileNotifier/greenAlert_";
    }
    else if(alertType == @"Email")
    {
        imageForAlert = @"/Library/Application Support/MobileNotifier/yellowAlert_";
    }
    else
    {
        imageForAlert = @"/Library/Application Support/MobileNotifier/blueAlert_";
    }

    alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 250 , 40)];
    alertLabel.backgroundColor = [UIColor clearColor];
    alertLabel.text = text;
    
    //Wire up the UIButton!
    
    dismissAlertButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dismissAlertButton retain];
    [dismissAlertButton addTarget:self action:@selector(dismissAlert:) forControlEvents:UIControlEventTouchDown];
    
    dismissAlertButton.frame = CGRectMake(275, 13, 33, 33);

    if ([[UIScreen mainScreen] bounds].size.width >= 640)
    {
        //Retina display or iPad display
        alertBG = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat: @"%@%@", imageForAlert, @"retina.png"]]];
        [dismissAlertButton setBackgroundImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/dismiss_retina.png"] forState:UIControlStateNormal];
    }
    else
    {
        //Regular display, we call this "cornea display" because we have a good sense of humor
        alertBG = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat: @"%@%@", imageForAlert, @"cornea.png"]]]; 
        [dismissAlertButton setBackgroundImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/dismiss_cornea.png"] forState:UIControlStateNormal];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{	
	NSLog(@"Alert touched!");
    
    [self takeAction];
    //nil until I can figure out a better thing to pass...
    [self dismissAlert:nil];
}

- (void)loadView
{	
    [super loadView];
    NSLog(@"now at loadView!");
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
    NSLog(@"everything released!");
}

@end


// vim:ft=objc
