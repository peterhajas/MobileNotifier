#import "AlertController.h"
#import "AlertDisplayController.h"

//How tall each alertDisplayController is
int __alertHeight = 60;

@implementation AlertController

@synthesize alertWindow;

@synthesize delegate = _delegate;

- (id)init
{
    alertWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0,20,320,0)]; //Measured to be zero, we don't want to mess up interaction with views below! Also, we live below the status bar
	alertWindow.windowLevel = 990; //Don't mess around with WindowPlaner or SBSettings if the user has it installed :)
	alertWindow.userInteractionEnabled = YES;
	alertWindow.hidden = NO;

	alertDashIsShowing = NO;

    visibleAlertDisplayControllers = [[NSMutableArray alloc] init];

    return self;
}

- (void)newAlert:(NSString *)title ofType:(NSString *)alertType withBundle:(NSString *)bundle
{
    //Add the alert to our internal array for tracking:
    AlertDataController *data = [[AlertDataController alloc] init];
    [data initWithText:title bundleID:bundle andType:alertType];

    [eventArray addObject:data];
    [self saveArray];

    NSLog(@"%@", eventArray);
    //Create alertDisplayController object, and populate members
    
    AlertDisplayController *display = [[AlertDisplayController alloc] init];
    [display intWithText:title type:alertType andBundle:bundle];
    
    //Assign the delegate, as this is always a good idea...

    display.delegate = self;

    //Add alertDisplayController to alertWindow
    display.view.frame = CGRectMake(0, __alertHeight * ([eventArray count] - 1), 320, __alertHeight);

    [visibleAlertDisplayControllers addObject:display];

    [self updateSize];
    NSLog(@"size updated");
    [alertWindow addSubview: display.view];
}

- (void)removeAlertFromArray:(AlertDataController *)alert
{
    for(unsigned int i = 0; i < [eventArray count]; i++)
    {
        if([[[eventArray objectAtIndex:i] alertText] isEqual:alert.alertText])
        {
            //if([[[eventArray objectAtIndex:i] alertType] isEqual:alert.alertType])
            //{
                if([[[eventArray objectAtIndex:i] bundleIdentifier] isEqual:alert.bundleIdentifier])
                {
                    [eventArray removeObjectAtIndex:i];
                }
            //}
        }
    }

    [self saveArray];
}

- (void)saveArray
{
    if([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/MobileNotifier/notifications.plist"])
    {
        //Aha! Good, let's save the array
        [NSKeyedArchiver archiveRootObject:eventArray toFile:@"/var/mobile/Library/MobileNotifier/notifications.plist"];
    }
    else
    {
        //Something terrible has happened!
        [NSKeyedArchiver archiveRootObject:eventArray toFile:@"/var/mobile/Library/MobileNotifier/notifications.plist"];
    }
}

- (void)loadArray 
{
    NSLog(@"Allocating eventArray");

    //eventArray = [[NSMutableArray arrayWithContentsOfFile:@"/var/mobile/MobileNotifier/notifications.plist"] retain];
    eventArray = [[NSKeyedUnarchiver unarchiveObjectWithFile:@"/var/mobile/Library/MobileNotifier/notifications.plist"] retain];
    if(!eventArray)
    {
        //First time user! Let's present them with some information.
        NSLog(@"Event array file doesn't exist!"); 

        //Create the directory!
        [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Library/MobileNotifier/" withIntermediateDirectories:NO attributes:nil error:NULL];

        eventArray = [[NSMutableArray alloc] init];

        //Now, we should create the array.
        [NSKeyedArchiver archiveRootObject:eventArray toFile:@"/var/mobile/Library/MobileNotifier/notifications.plist"];

    } 
}

- (void)updateSize
{
    int newHeight = (CGFloat)(__alertHeight * [eventArray count]);

    alertWindow.frame = CGRectMake(0,20,320, newHeight);
}

- (void)redrawAlertsFrom:(AlertDisplayController *)adc
{
    unsigned int i = 0;
    //Find the alert controller we need to redraw after
    for(i = 0; i < [visibleAlertDisplayControllers count]; i++)
    {
        if([adc equals:[visibleAlertDisplayControllers objectAtIndex:i]])
        {
            break;
        }
    }

    //Now, go through and shift the frame up
    for(unsigned int j = i; j < [visibleAlertDisplayControllers count]; j++)
    {
        AlertDisplayController *alertToShift = [visibleAlertDisplayControllers objectAtIndex:j];
        [alertToShift.view setCenter:CGPointMake(alertToShift.view.center.x, alertToShift.view.center.y - __alertHeight)];
    }
    
    //Redraw the window
    [alertWindow setNeedsDisplay];
    [self updateSize];
}

//Protocol for AlertDisplayController

- (void)alertDisplayController:(AlertDisplayController *)adc hadActionTaken:(int)action
{
    AlertDataController *data = [[AlertDataController alloc] init];
    [data initWithAlertDisplayController:adc];
    NSLog(@"Data: %@ %@ %@", data.alertText, data.bundleIdentifier, data.alertType);
    NSLog(@"Action taken: %d", action);
    if(action == kTakeActionOnAlert)
    {
        [_delegate launchAppInSpringBoardWithBundleID:adc.bundleIdentifier];
        [self removeAlertFromArray:data];
    }
    //The guts inside this if-block are from AlertDisplayController.h
    if(action == kHideAlert)
    {
        
        [self removeAlertFromArray:data];
        [self updateSize];
    }
    [self redrawAlertsFrom:adc];
}

- (void)toggleAlertDash
{
	if(alertDashIsShowing)
	{
		//Get rid of the alertDash!
		alertDash.hidden = YES;
		[alertDash release];
	}
	
	else
	{
		//Allocate the alertDash
	}		
}

//libactivator methods:
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
    NSLog(@"We received an LAEvent!");
	[self toggleAlertDash];

}
- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
    NSLog(@"We received an LAEvent abort!");
}
@end

// vim:ft=objc
