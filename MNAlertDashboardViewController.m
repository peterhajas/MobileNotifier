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

#import <QuartzCore/QuartzCore.h>
#import "MNAlertDashboardViewController.h"

@implementation MNAlertDashboardViewController

@synthesize window;
@synthesize dashboardShowing;
@synthesize delegate = _delegate;

-(id)initWithDelegate:(id)__delegate;
{
    self = [super init];

    if (self)
    {
        _delegate = __delegate;

		CGRect screenBounds = [[UIScreen mainScreen] bounds];

        // window:
        window = [[UIWindow alloc]
        initWithFrame:CGRectMake(0,0,screenBounds.size.width,385)];

        window.windowLevel = UIWindowLevelAlert+102.0f;
        window.userInteractionEnabled = YES;
        window.hidden = YES;

		// ClearAllButton
        clearAllButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        clearAllButton.frame = CGRectMake(245,10.5,72,33);
        [clearAllButton setAlpha:1.0];
        clearAllButton.backgroundColor = [UIColor clearColor];
		[clearAllButton setBackgroundImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/clear_btn.png"] forState:UIControlStateNormal];

        // Wire up clearAllButton
        [clearAllButton addTarget:self action:@selector(clearDashboardPushed:)
                 forControlEvents:UIControlEventTouchUpInside];
        


        logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 32, 32)];
        logoImageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/lockscreen-logo.png"];

        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,54)];
        backgroundImageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/lockscreenbg.png"];
        backgroundImageView.opaque = NO;
		[backgroundImageView setAlpha:0.9];

        numberOfPendingAlertsLabel = [[UILabel alloc] initWithFrame:CGRectMake(265,16,35,22)];
        numberOfPendingAlertsLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        numberOfPendingAlertsLabel.textAlignment = UITextAlignmentCenter;
        numberOfPendingAlertsLabel.textColor = [UIColor blackColor];
        numberOfPendingAlertsLabel.backgroundColor = [UIColor clearColor];
        numberOfPendingAlertsLabel.opaque = NO;

        numberOfPendingAlertsBackground = [[UIImageView alloc] initWithFrame:CGRectMake(270,17,27,20)];
        numberOfPendingAlertsBackground.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/lockscreen-count-bg.png"];
        numberOfPendingAlertsBackground.opaque = NO;

        mobileNotifierTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(60,16,180,22)];
        mobileNotifierTextLabel.text = @"Missed Notifications";
        mobileNotifierTextLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        mobileNotifierTextLabel.textAlignment = UITextAlignmentLeft;
        mobileNotifierTextLabel.textColor = [UIColor whiteColor];
        mobileNotifierTextLabel.shadowColor = [UIColor blackColor];
        mobileNotifierTextLabel.shadowOffset = CGSizeMake(0,-1);
        mobileNotifierTextLabel.backgroundColor = [UIColor clearColor];

        // Table View Data Source
        tableViewDataSourceEditable = [[MNAlertTableViewDataSourceEditable alloc] initWithStyle:kMNAlertTableViewDataSourceTypePending
                                                                                    andDelegate:_delegate];

        // Create the tableview
        alertListView = [[UITableView alloc] initWithFrame:CGRectMake(0,54,320,332) style:UITableViewStylePlain];
        alertListView.delegate = self;
        alertListView.dataSource = tableViewDataSourceEditable;
        alertListView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
		alertListView.separatorStyle = UITableViewCellSeparatorStyleNone;
        alertListView.hidden = NO;
        alertListView.allowsSelection = YES;

        // Create and wire up the button for showing and hiding the alertListView
        showAlertsListViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        showAlertsListViewButton.frame = CGRectMake(0,0,320,54);
        [showAlertsListViewButton addTarget:self action:@selector(togglealertListView:)
                 forControlEvents:UIControlEventTouchUpInside];

        [window addSubview:backgroundImageView];
        [window addSubview:logoImageView];
        [window addSubview:numberOfPendingAlertsBackground];
        [window addSubview:numberOfPendingAlertsLabel];
        [window addSubview:mobileNotifierTextLabel];
        [window addSubview:alertListView];
        [window addSubview:showAlertsListViewButton];

        dashboardShowing = NO;
		isExpanded = NO;

        [self refresh];
    }

    return self;
}

-(void)addClearButton
{
    // Make the clear all button appear
	[window addSubview:clearAllButton];
}

-(void)removeClearButton
{
    // Make the clear all button go away
	[clearAllButton removeFromSuperview];
}

-(void)refresh
{
    NSNumber *pendingCount = [NSNumber numberWithInt:[[_delegate getPendingAlerts] count]];

    numberOfPendingAlertsLabel.text = [pendingCount stringValue];

    [alertListView reloadData];
}

-(bool)isShowing
{
    return !window.hidden;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableViewDataSourceEditable tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Take action on the alert
    [_delegate actionOnAlertAtIndex:indexPath.row];
	[self refresh];
}

-(void)dismissSwitcher:(id)sender
{
    [_delegate dismissSwitcher];
}

-(void)toggleDashboard
{
    if (dashboardShowing)
    {
        [self fadeDashboardDown];
    }
    else
    {
        [self showDashboard];
    }
}

// ---------------------------------------------------
// Animate dashboard elements down for a "fade down"
// effect similar to the multitasking drawer animation
// ---------------------------------------------------
-(void)fadeDashboardDown
{
    window.userInteractionEnabled = NO;
    dashboardShowing              = NO;

    [UIView beginAnimations:@"fadeDashboardDown" context:NULL];
      [UIView setAnimationDuration:0.25];
      [window setAlpha:0.0];
    [UIView commitAnimations];
}

// -----------------------------------------------
// Animate dashboard elements using a "fade away"
// effect to better match the app switching effect
// -----------------------------------------------
-(void)fadeDashboardAway
{
    window.userInteractionEnabled = NO;
    dashboardShowing              = NO;

    [UIView beginAnimations:@"fadeDashboardAway" context:NULL];
      [UIView setAnimationDuration:0.135];

      // Shrink the elements and fade out
      // to create a zoom out effect
      alertListView.transform  = CGAffineTransformMakeScale(0.1,0.1);

      [window setAlpha:0.0];
    [UIView commitAnimations];
}

// -----------------------------------------------
// Animate the dashboard elements "up" similar to
// the multitasking drawer animation to make room
// for the application switcher
// -----------------------------------------------
-(void)showDashboard
{
	window.userInteractionEnabled = YES;
    window.hidden                 = NO;
    dashboardShowing              = YES;

    // Restore previously transformed elements
    alertListView.transform  = CGAffineTransformIdentity;

    [UIView beginAnimations:@"fadeIn" context:NULL];
      [UIView setAnimationDuration:0.25];
      [window setAlpha:1.0];
    [UIView commitAnimations];
}

-(void)togglealertListView:(id)sender
{
	[self refresh];
	if (isExpanded)
    {
        [UIView beginAnimations:@"listDisappear" context:NULL];
            [UIView setAnimationDuration:0.1];
			[window setFrame:CGRectMake(0,0,320,385)];
			[self addClearButton];
        [UIView commitAnimations];

        alertListView.hidden = NO;
        isExpanded = !isExpanded;
		
		NSLog(@"new frame:%f x %f", window.frame.size.width, window.frame.size.height);
    }
    else
    {
        [self expandAlertListView];
    }
}

-(void)expandAlertListView
{
	[self refresh];
	[UIView beginAnimations:@"listAppear" context:NULL];
        [UIView setAnimationDuration:0.1];
        [window setFrame:CGRectMake(0,0,320,54)];
		[self removeClearButton];
    [UIView commitAnimations];

    alertListView.hidden = YES;
    isExpanded = YES;

	NSLog(@"new frame:%f x %f", window.frame.size.width, window.frame.size.height);
}

-(void)clearDashboardPushed:(id)sender
{
    // Clear notifications!
    [_delegate clearPending];
    // Hide the dashboard view
    [self fadeDashboardDown];
}

-(void)animationDidStop:(NSString*)animationID didFinish:(NSNumber*)finished inContext:(id)context
{
    if ([animationID isEqualToString:@"fadeIn"])
	{
	    window.userInteractionEnabled = YES;
	}
	if ([animationID isEqualToString:@"fadeDashboardDown"] || [animationID isEqualToString:@"fadeDashboardAway"])
	{
	    window.userInteractionEnabled = NO;
	    window.hidden = YES;
	}

 	if ([animationID isEqualToString:@"listAppear"])
    {
        alertListView.hidden = NO;
    }

    if ([animationID isEqualToString:@"listDisappear"] || [animationID isEqualToString:@"fadeDashboardAway"])
    {
        alertListView.hidden = YES;
    }
}

@end

