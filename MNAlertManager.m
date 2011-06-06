/*
Copyright (c) 2010-2011, Peter Hajas
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Peter Hajas nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL PETER HAJAS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "MNAlertManager.h"

@implementation MNAlertManager

@synthesize pendingAlerts, dismissedAlerts;
@synthesize alertIsShowing;
@synthesize delegate = _delegate;
@synthesize alertWindow, pendingAlertViewController;
@synthesize whistleBlower;
@synthesize dashboard;
@synthesize preferenceManager;

-(id)init
{
    self = [super init];

    // Let's hope the NSObject init doesn't fail!
    if (self != nil)
    {
        // Measured to be zero, we don't want to mess up interaction
        // with views below! Also, we live below the status bar
        alertWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0,0,320,0)];

        // Don't mess around with WindowPlaner or
        // SBSettings if the user has it installed
        alertWindow.windowLevel            = UIWindowLevelAlert - 10.0f /*+500.0f*/;
        alertWindow.userInteractionEnabled = YES;
        alertWindow.hidden                 = NO;
        alertWindow.clipsToBounds          = NO;
        alertWindow.backgroundColor        = [UIColor clearColor];

        // If the directory doesn't exist, create it!
        if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/MobileNotifier/"])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Library/MobileNotifier" withIntermediateDirectories:NO attributes:nil error:NULL];
        }

        // Load data from files
        pendingAlerts   = [[NSKeyedUnarchiver unarchiveObjectWithFile:@"/var/mobile/Library/MobileNotifier/pending.plist"] retain] ?: [[NSMutableArray alloc] init];
        dismissedAlerts = [[NSKeyedUnarchiver unarchiveObjectWithFile:@"/var/mobile/Library/MobileNotifier/dismissed.plist"] retain] ?: [[NSMutableArray alloc] init];
        alertIsShowing  = NO;

        // Allocate and init the whistle blower
        whistleBlower = [[MNWhistleBlowerController alloc] initWithDelegate:self];

        // Alloc and init the dashboard
        dashboard = [[MNAlertDashboardViewController alloc] initWithDelegate:self];

        // Alloc and init the lockscreen view controller
        lockscreen = [[MNLockScreenViewController alloc] initWithDelegate:self];

        // Alloc and init the preferences manager
        preferenceManager = [[MNPreferenceManager alloc] init];

        // Register for libactivator events
        [[LAActivator sharedInstance] registerListener:self forName:@"com.peterhajassoftware.mobilenotifier.showdashboard"];

        // Set up recentShower
        NSLog(@"setting up recentshower");
        recentShower = [[MNMostRecentAlertShowerController alloc] initWithManager:self];
        NSLog(@"set up recentshower: %@", recentShower);
    }

    return self;
}

-(void)newAlertWithData:(MNAlertData *)data
{
    // Add to pending alerts
    [pendingAlerts insertObject:data atIndex:0];

    // New foreground alert!
    if (data.status == kNewAlertForeground)
    {
        if (!pendingAlertViewController.alertIsShowingPopOver)
        {
            // Build a new MNAlertViewController
            if (alertIsShowing)
            {
                [pendingAlertViewController.view removeFromSuperview];
            }
            if (!dashboard.dashboardShowing && ![lockscreen isShowing])
            {
                NSNumber *blackAlertStyleEnabled = [preferenceManager.preferences valueForKey:@"blackAlertStyleEnabled"];
                bool isBlackAlertStyleEnabled    = blackAlertStyleEnabled ? [blackAlertStyleEnabled boolValue] : YES;

                MNAlertViewController *viewController = [[MNAlertViewController alloc] initWithMNData:data pendingAlerts:pendingAlerts];

                viewController.useBlackAlertStyle = isBlackAlertStyleEnabled;
                viewController.delegate    = self;
                pendingAlertViewController = viewController;
                alertIsShowing             = YES;

                // Change the window size
                [alertWindow setFrame:CGRectMake(0, 0, 320, 40)];

                // Add the subview
                [alertWindow addSubview:viewController.view];
                [alertWindow setNeedsDisplay];

                //Expand the status bar
                [_delegate setDoubleHighStatusBar:YES];
            }
        }
        else
        {
            // The user is interacting with an alert!
            // Let's send this to pending, and let them
            // continue with what they're doing
        }
        // Make noise
        [whistleBlower alertArrivedWithData:data];

        if ([_delegate deviceIsLocked])
        {
            [lockscreen expandPendingAlertsList];
            [self showLockscreen];
        }

        // Start the timer, if the user prefers it
        NSNumber *autoLaterEnabled = [preferenceManager.preferences valueForKey:@"autoLaterAlertsEnabled"];
        bool shouldAutoLater       = autoLaterEnabled ? [autoLaterEnabled boolValue] : YES;

        if (shouldAutoLater)
        {
            alertDismissTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(alertShouldGoLaterTimerFired:) userInfo:nil repeats:NO];
        }

    }
    // Not a foreground alert, but a background alert
    else if (data.status == kNewAlertBackground)
    {
        // We do nothing currently (already in pending)
    }
    [self saveOut];
    [lockscreen refresh];
    [dashboard refresh];
}

-(void)presentMostRecentPendingAlert
{
    if (!pendingAlertViewController.alertIsShowingPopOver)
    {
        // Build a new MNAlertViewController
        if (alertIsShowing)
        {
            [pendingAlertViewController.view removeFromSuperview];
        }
        if (!dashboard.dashboardShowing && [pendingAlerts count] > 0)
        {
            NSNumber *blackAlertStyleEnabled = [preferenceManager.preferences valueForKey:@"blackAlertStyleEnabled"];
            bool isBlackAlertStyleEnabled    = blackAlertStyleEnabled ? [blackAlertStyleEnabled boolValue] : YES;

            MNAlertViewController *viewController = [[MNAlertViewController alloc] initWithMNData:[pendingAlerts objectAtIndex:0] pendingAlerts:pendingAlerts];
            viewController.useBlackAlertStyle = isBlackAlertStyleEnabled;
            viewController.delegate    = self;
            pendingAlertViewController = viewController;
            alertIsShowing             = YES;

            // Change the window size
            [alertWindow setFrame:CGRectMake(0, 0, 320, 40)];

            // Add the subview
            [alertWindow addSubview:viewController.view];
            [alertWindow setNeedsDisplay];

            //Expand the status bar
            [_delegate setDoubleHighStatusBar:YES];
        }
    }

    // Start the timer, if the user prefers it
    NSNumber *autoLaterEnabled = [preferenceManager.preferences valueForKey:@"autoLaterAlertsEnabled"];
    bool shouldAutoLater       = autoLaterEnabled ? [autoLaterEnabled boolValue] : YES;

    if (shouldAutoLater)
    {
        alertDismissTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(alertShouldGoLaterTimerFired:) userInfo:nil repeats:NO];
    }


    [self saveOut];
    [lockscreen refresh];
    [dashboard refresh];
}

-(void)saveOut
{
    [NSKeyedArchiver archiveRootObject:pendingAlerts toFile:@"/var/mobile/Library/MobileNotifier/pending.plist"];
    [NSKeyedArchiver archiveRootObject:dismissedAlerts toFile:@"/var/mobile/Library/MobileNotifier/dismissed.plist"];
}

-(void)showDashboardFromSwitcher
{
    NSNumber *switcherViewEnabled = [preferenceManager.preferences valueForKey:@"switcherViewEnabled"];
    bool shouldShow = switcherViewEnabled ? [switcherViewEnabled boolValue] : YES;

    if (!shouldShow) { return; }

    [self hidePendingAlert];
    if([pendingAlerts count] > 0)
    {
        [dashboard showDashboard];
    }
}

-(void)showDashboard
{
    [self hidePendingAlert];
    [dashboard showDashboard];
}

-(void)fadeDashboardDown
{
    [dashboard fadeDashboardDown];
}

-(void)fadeDashboardAway
{
    [dashboard fadeDashboardAway];
}

void UIKeyboardDisableAutomaticAppearance(void);

-(void)showLockscreen
{
    // Disable the keyboard automatically appearing
    UIKeyboardDisableAutomaticAppearance();

    NSNumber *lockscreenEnabled = [preferenceManager.preferences valueForKey:@"lockscreenEnabled"];
    bool shouldShow = lockscreenEnabled ? [lockscreenEnabled boolValue] : YES;

    if (!shouldShow) { return; }

    [self hidePendingAlert];

    if ([pendingAlerts count] != 0) { [lockscreen show]; }
}

-(void)animateLockscreenLeft
{
    [lockscreen animateLeft];
}

-(void)hideLockscreen
{
    [lockscreen hide];
}

-(void)toggleLockWindowUserInteraction
{
    [lockscreen toggleLockWindowUserInteraction];
}

-(void)hideLockscreenPendingAlertsList
{
    [lockscreen hidePendingAlertsList];
}

-(void)hidePendingAlert
{
    [pendingAlertViewController.view removeFromSuperview];
    alertWindow.frame = CGRectMake(0,0,320,0);
    alertIsShowing = YES;
    [_delegate setDoubleHighStatusBar:NO];
}

-(void)alertShouldGoLaterTimerFired:(id)sender
{
    if (!pendingAlertViewController) { return; }

    // If the alert is expanded, then let's not have the alert go to "later"
    if (pendingAlertViewController.alertIsShowingPopOver) { return; }

    // If pop over is not up and there has been a swipe, then reset the timer
    else if (pendingAlertViewController.hasSwiped) {
        [alertDismissTimer invalidate];
        alertDismissTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(alertShouldGoLaterTimerFired:) userInfo:nil repeats:NO];
        
        // Reset hasSwiped
        [pendingAlertViewController setHasSwiped:NO];
        return;
    }

    [pendingAlertViewController laterPushed:nil];
}

-(void)reloadPreferences
{
    [preferenceManager reloadPreferences];
}

// -----------------------------------------
// Delegate method for MNAlertViewController
// -----------------------------------------
-(void)alertViewController:(MNAlertViewController *)viewController hadActionTaken:(int)action
{
    [_delegate setDoubleHighStatusBar:NO];

    if (action == kAlertSentAway)
    {
        alertIsShowing = NO;
    }
    else if (action == kAlertTakeAction)
    {
        alertIsShowing = NO;
        MNAlertData *data = viewController.dataObj;

        [self takeActionOnAlertWithData:data];
    }
    else if (action == kAlertClosed)
    {
        alertIsShowing = NO;
        // Dismiss the alert!
        MNAlertData *data = viewController.dataObj;
        [dismissedAlerts addObject:data];
        [pendingAlerts removeObject:data];
        [self refreshAll];
    }

    [self hidePendingAlert];
    [_delegate setDoubleHighStatusBar:NO];
    alertWindow.frame = CGRectMake(0,0,320,0);
    [self saveOut];
    [dashboard refresh];
    [lockscreen refresh];
}

-(void)takeActionOnAlertWithData:(MNAlertData *)data
{
    // Launch the bundle
    [_delegate launchAppInSpringBoardWithBundleID:data.bundleID];

    // Move alert into dismissed alerts from
    // either pendingAlerts or sentAwayAlerts
    [self removeAllPendingAlertsWithSender:data.header];
}

-(void)removeAllPendingAlertsWithSender:(NSString *)sender
{
    // Loop through all pending alerts, and remove
    // all the ones that are from the same sender
    NSMutableArray *toRemove = [NSMutableArray array];

    for (MNAlertData* dataObj in pendingAlerts)
    {
        if ([dataObj.header isEqualToString:sender])
        {
            [dismissedAlerts addObject:dataObj];
            [toRemove addObject:dataObj];
        }
    }

    [pendingAlerts removeObjectsInArray:toRemove];

    [self saveOut];
    [self refreshAll];
}

-(void)removeAllPendingAlertsForBundleIdentifier:(NSString *)bundleID
{
    // Loop through all pending alerts, and remove
    // all the ones that are from the bundle identifier
    NSMutableArray *toRemove = [NSMutableArray array];

    for (MNAlertData* dataObj in pendingAlerts)
    {
        if ([dataObj.bundleID isEqualToString:bundleID])
        {
            [dismissedAlerts addObject:dataObj];
            [toRemove addObject:dataObj];
        }
    }

    [pendingAlerts removeObjectsInArray:toRemove];

    [self saveOut];
    [self refreshAll];
}

-(void)refreshAll
{
    [dashboard refresh];
    [lockscreen refresh];
}

-(UIImage*)iconForBundleID:(NSString *)bundleID;
{
    return [_delegate iconForBundleID:bundleID];
}

-(void)alertShowingPopOver:(bool)isShowingPopOver;
{
    if (isShowingPopOver)
    {
        CGRect frame = alertWindow.frame;
        frame.size.height += 229;
        alertWindow.frame = frame;
        [alertWindow makeKeyWindow];
    }
    else
    {
        CGRect frame = alertWindow.frame;
        frame.size.height -= 229;
        alertWindow.frame = frame;
        [alertWindow resignKeyWindow];
    }
}

// ----------------------------------------------
// MNAlertDashboardViewControllerProtocol Methods
// ----------------------------------------------
- (void)actionOnAlertAtIndex:(int)index
{
    // Create the data object
    MNAlertData *data;
    data = [pendingAlerts objectAtIndex:index];

    // Hide the dashboard
    [dashboard fadeDashboardAway];

    // Take action on it
    [self takeActionOnAlertWithData:data];
}

-(void)dismissedAlertAtIndex:(int)index
{
    MNAlertData *data = [pendingAlerts objectAtIndex:index];
    [dismissedAlerts addObject:data];
    [pendingAlerts removeObject:data];
}

-(void)clearPending
{
    if ([pendingAlerts count] == 0) { return; }

    NSUInteger size = [pendingAlerts count];
    NSUInteger i;

    for (i = 0; i < size; i++)
    {
        MNAlertData* dataObj = [pendingAlerts lastObject];

        if (!dataObj) { break; }

        [dismissedAlerts addObject:dataObj];
        [pendingAlerts removeObject:dataObj];
    }

    [self saveOut];
    [self refreshAll];
}

- (NSMutableArray *)getPendingAlerts
{
    return pendingAlerts;
}

- (NSMutableArray *)getDismissedAlerts
{
    return dismissedAlerts;
}

-(void)dismissSwitcher
{
    [_delegate dismissSwitcher];
}

// ------------------------------------------
// MNWhistleBlowerController delegate methods
// ------------------------------------------
-(void)wakeDeviceScreen
{
    [self refreshAll];
    [_delegate wakeDeviceScreen];
}

// --------------------
// Libactivator methods
// --------------------
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
    [self hideLockscreen];
    [dashboard toggleDashboard];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
    [dashboard fadeDashboardDown];
    [self alertViewController:pendingAlertViewController hadActionTaken: kAlertSentAway];
}

@end
