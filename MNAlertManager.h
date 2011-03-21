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

#define kNewAlertForeground 0
#define kNewAlertBackground 1

#import <libactivator/libactivator.h>

#import "MNAlertDashboardViewController.h"
#import "MNLockScreenViewController.h"
#import "MNAlertData.h"
#import "MNAlertViewController.h"
#import "MNAlertWindow.h"
#import "MNWhistleBlowerController.h"
#import "MNPreferenceManager.h"

@class MNAlertManager;
@protocol MNAlertManagerDelegate
-(void)launchAppInSpringBoardWithBundleID:(NSString *)bundleID;
-(UIImage*)iconForBundleID:(NSString *)bundleID;
-(void)dismissSwitcher;
-(void)wakeDeviceScreen;
-(void)toggleDoubleHighStatusBar;
@end

@interface MNAlertManager : NSObject <MNAlertViewControllerDelegate, 
									  MNAlertDashboardViewControllerProtocol,
									  MNLockScreenViewControllerDelegate,
									  MNWhistleBlowerControllerProtocol,
									  LAListener>
{
	NSMutableArray *pendingAlerts;
	NSMutableArray *dismissedAlerts;
	
	bool alertIsShowing;
	
	MNAlertWindow *alertWindow;	
	MNAlertViewController *pendingAlertViewController;
	
	MNAlertDashboardViewController *dashboard;
    MNLockScreenViewController *lockscreen;
	
	MNWhistleBlowerController *whistleBlower;
	
	MNPreferenceManager *preferenceManager;
	
	NSTimer* alertDismissTimer;
	
	id<MNAlertManagerDelegate> _delegate;
}

-(void)newAlertWithData:(MNAlertData *)data;
-(void)saveOut;
-(void)showDashboard;
-(void)showDashboardFromSwitcher;
-(void)fadeDashboardDown;
-(void)fadeDashboardAway;
-(void)showLockscreen;
-(void)hideLockscreen;
-(void)hidePendingAlert;
-(void)reloadPreferences;

-(void)clearPending;
-(void)alertShouldGoLaterTimerFired:(id)sender;

@property (nonatomic, retain) MNAlertWindow *alertWindow;

@property (nonatomic, retain) NSMutableArray *pendingAlerts;
@property (nonatomic, retain) NSMutableArray *dismissedAlerts;

@property (nonatomic, retain) MNAlertDashboardViewController *dashboard;
@property (nonatomic, retain) MNAlertViewController *pendingAlertViewController;
@property (nonatomic, retain) MNWhistleBlowerController *whistleBlower;

@property (nonatomic, retain) MNPreferenceManager *preferenceManager;

@property (nonatomic, assign) id<MNAlertManagerDelegate> delegate;

@end
