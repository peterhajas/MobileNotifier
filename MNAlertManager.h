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
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
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
#import "MNAlertData.h"
#import "MNAlertViewController.h"

@class MNAlertManager;
@protocol MNAlertManagerDelegate
- (void)launchAppInSpringBoardWithBundleID:(NSString *)bundleID;
@end

@interface MNAlertManager : NSObject <MNAlertViewControllerDelegate, 
									  MNAlertDashboardViewControllerProtocol,
									  LAListener>
{
	NSMutableArray *pendingAlerts;
	NSMutableArray *pendingAlertViews;
	NSMutableArray *sentAwayAlerts;
	NSMutableArray *dismissedAlerts;
	
	UIWindow *alertWindow;
	
	MNAlertDashboardViewController *dashboard;
	
	id<MNAlertManagerDelegate> _delegate;
}

-(void)newAlertWithData:(MNAlertData *)data;
-(void)saveOut;
-(void)redrawAlertsBelowIndex:(int)index;

@property (nonatomic, retain) UIWindow *alertWindow;

@property (nonatomic, retain) NSMutableArray *pendingAlerts;
@property (nonatomic, retain) NSMutableArray *pendingAlertViews;
@property (nonatomic, retain) NSMutableArray *sentAwayAlerts;
@property (nonatomic, retain) NSMutableArray *dismissedAlerts;

@property (nonatomic, retain) MNAlertDashboardViewController *dashboard;

@property (nonatomic, assign) id<MNAlertManagerDelegate> delegate;

@end
