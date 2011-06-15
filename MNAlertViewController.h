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

#define kAlertSentAway 0
#define kAlertTakeAction 1
#define kAlertClosed 2

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <SpringBoard/SpringBoard.h>
#import "MNAlertData.h"
#import "MNSMSSender.h"
#import "BCZeroEdgeTextView.h"

@class MNAlertViewController;

@protocol MNAlertViewControllerDelegate

-(void)alertViewController:(MNAlertViewController *)viewController hadActionTaken:(int)action;
-(void)alertShowingPopOver:(bool)isShowingPopOver;
-(UIImage*)iconForBundleID:(NSString *)bundleID;

@end

@interface MNAlertViewController : UIViewController <UITextViewDelegate>
{
    UIScrollView* notificationScrollView;
    UIView* notificationView;

    bool isAnimationInProgress;
    bool hasSwiped;

    UIImageView* alertBackgroundImageView;
    UIImageView* iconImageView;

    UIButton* alertExpandButton;

    UILabel* alertHeaderLabel;
    UILabel* alertTextLabel;

    UIImageView* alertActionBackgroundImageView;
    UIImageView* alertActionBackgroundImageViewShadow;

    UIButton* openButton;
    UIButton* laterButton;
    UIButton* closeButton;

    UITextView* detailText;
    UILabel* dateText;

    // UI Elements for QuickReply:
    UIButton* sendButton;
    UILabel* charactersTyped;
    BCZeroEdgeTextView* textBox;

    bool alertIsShowingPopOver;
    bool useBlackAlertStyle;

    NSMutableArray* pendingAlerts;
    int index;

    MNAlertData* dataObj;

    id<MNAlertViewControllerDelegate> _delegate;
}

-(id)initWithMNData:(MNAlertData*) data pendingAlerts:(NSMutableArray *)pendingAlerts;

-(void)reloadViewInfo;

-(void)slideAwayRight;
-(void)slideAwayLeft;
-(void)slideIn;

-(void)chevronPushed:(id)sender;

-(void)fadeBottomAway:(bool)fadeBottom;
-(void)fadeOutWholeView;
-(void)fadeInView;
-(void)animationDidStop:(NSString*)animationID didFinish:(NSNumber*)finished inContext:(id)context;

-(void)loadData;
-(void)openPushed:(id)sender;
-(void)laterPushed:(id)sender;
-(void)closePushed:(id)sender;
-(void)sendPushed:(id)sender;

void UIKeyboardEnableAutomaticAppearance(void);
void UIKeyboardDisableAutomaticAppearance(void);

@property(nonatomic, retain) MNAlertData *dataObj;
@property(readwrite, retain) id<MNAlertViewControllerDelegate> delegate;

@property(nonatomic, retain) UIImageView* alertBackgroundImageView;
@property(nonatomic, retain) UIImageView* alertActionBackgroundImageView;
@property(nonatomic, retain) UIImageView* iconImageView;

@property(readwrite) bool alertIsShowingPopOver;
@property(readwrite) bool useBlackAlertStyle;
@property(readwrite) bool hasSwiped;

@property(nonatomic, retain) UILabel* alertHeaderLabel;
@property(nonatomic, retain) UILabel* alertTextLabel;

@property(nonatomic, retain) UIButton* openButton;
@property(nonatomic, retain) UIButton* laterButton;

@end
