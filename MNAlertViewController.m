
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

#import "MNAlertViewController.h"

@interface SBIconModel (peterhajas)
+(id)sharedInstance;
-(id)applicationIconForDisplayIdentifier:(id)displayIdentifier;
@end

@interface SBIcon (peterhajas)
-(id)iconImageView;
@end

@implementation MNAlertViewController

@synthesize alertBackgroundImageView, alertActionBackgroundImageView, iconImageView;
@synthesize alertHeaderLabel, alertTextLabel;
@synthesize laterButton, openButton;

@synthesize dataObj;
@synthesize alertIsShowingPopOver;
@synthesize useBlackAlertStyle;
@synthesize hasSwiped;

@synthesize delegate = _delegate;

-(id)init
{
    self = [super init];

    if (self != nil)
    {
        self.view.clipsToBounds = YES;
    }
    return self;
}

-(id)initWithMNData:(MNAlertData*) data pendingAlerts:(NSMutableArray *)_pendingAlerts
{
    self = [super init];

    dataObj = data;
    
    pendingAlerts = _pendingAlerts;

    return self;
}

-(void)loadView
{
    [super loadView];
    
    // Set position of notificationView here
    notificationViewRect = CGRectMake(0, 0, 320, 40);
    
    self.view.frame = CGRectMake(0,0,320,40);

    [UIView setAnimationDidStopSelector:@selector(animationDidStop:didFinish:inContext:)];
    [UIView setAnimationDelegate:self];

    alertBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
    [alertBackgroundImageView setAlpha:0.0];

    if (useBlackAlertStyle)
    {
        // Black alert style
        alertBackgroundImageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/alert_bg_small.png"];
    }
    else
    {
        // Gray alert style
        alertBackgroundImageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/statusbar_alert_bg.png"];
    }
    
    alertExpandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    alertExpandButton.frame = CGRectMake(0.0, 0.0, 320.0, 40.0);
    [alertExpandButton setAlpha:0.0];
    
    // Popdown alert actions
    alertActionBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3.5, 30.0, 313.0, 229.0)];
    alertActionBackgroundImageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/popout_bg.png"];
    alertActionBackgroundImageView.opaque = NO;
    alertActionBackgroundImageView.backgroundColor = [UIColor clearColor];
    alertActionBackgroundImageView.alpha = 0.0;
    
    openButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    openButton.frame = CGRectMake(72.0, 205.0, 46.0, 40.0);
    [openButton setBackgroundImage:[UIImage imageWithContentsOfFile: @"/Library/Application Support/MobileNotifier/btn_open.png"]
                          forState:UIControlStateNormal];
    [openButton setAlpha:0.0];
    
    laterButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    laterButton.frame = CGRectMake(16.0, 205.0, 46.0, 40.0);
    [laterButton setBackgroundImage:[UIImage imageWithContentsOfFile: @"/Library/Application Support/MobileNotifier/btn_archive.png"]
                           forState:UIControlStateNormal];
    [laterButton setAlpha:0.0];
    
    closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    closeButton.frame = CGRectMake(274, 7.0, 25.0, 26.0);
    
    if (useBlackAlertStyle)
    {
        // Black alert style
        [closeButton setBackgroundImage:[UIImage imageWithContentsOfFile: @"/Library/Application Support/MobileNotifier/statusbar_alert_dismiss_black.png"]
                               forState:UIControlStateNormal];    }
    else
    {
        // Gray alert style
        [closeButton setBackgroundImage:[UIImage imageWithContentsOfFile: @"/Library/Application Support/MobileNotifier/statusbar_alert_dismiss.png"]
                               forState:UIControlStateNormal];    }
    
    // Wire up buttons
    [openButton addTarget:self action:@selector(openPushed:)
         forControlEvents:UIControlEventTouchUpInside];
    
    [laterButton addTarget:self action:@selector(laterPushed:)
          forControlEvents:UIControlEventTouchUpInside];
    
    [closeButton addTarget:self action:@selector(closePushed:)
          forControlEvents:UIControlEventTouchUpInside];
    
    [alertExpandButton addTarget:self action:@selector(chevronPushed:)
          forControlEvents:UIControlEventTouchUpInside];

    // Add everything to our view
    [self.view addSubview:alertBackgroundImageView];

    // Release the stuff we don't want to hang on to
    [alertBackgroundImageView release];

    alertIsShowingPopOver = NO;

    [self loadViewInfo];
}

-(void)loadViewInfo
{
    // Create and configure the scroll view
    notificationScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [notificationScrollView setDelegate:self];
    [notificationScrollView setAlwaysBounceHorizontal:YES];
    [notificationScrollView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:notificationScrollView];
    
    // All notification data will go in this view. This way we can keep the
    // background image seperate from the notification data. Makes swiping a lot better.
    notificationView = [[UIView alloc] initWithFrame:notificationViewRect];
    [notificationScrollView addSubview:notificationView];
    
    /* Draw the seperators */
    
    iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(17.0, 9.0, 22.5, 22.5)];
    iconImageView.image = [_delegate iconForBundleID:dataObj.bundleID];
    [iconImageView setAlpha:0.0];
    iconImageView.layer.cornerRadius = 5.5;
    iconImageView.layer.masksToBounds = YES;
    
    alertHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(49.0, 3.0, 216.0, 22.0)];
    alertHeaderLabel.adjustsFontSizeToFitWidth = NO;
    alertHeaderLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.000];
    alertHeaderLabel.text = dataObj.header;
    alertHeaderLabel.textAlignment = UITextAlignmentLeft;
    alertHeaderLabel.backgroundColor = [UIColor clearColor];
    
    if (useBlackAlertStyle)
    {
        // Black alert style
        alertHeaderLabel.textColor   = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1.0];
        alertHeaderLabel.shadowColor = [UIColor grayColor];
    }
    else
    {
        // Gray alert style
        alertHeaderLabel.textColor   = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:0.9];
        alertHeaderLabel.shadowColor = [UIColor whiteColor];
    }
    
    alertHeaderLabel.shadowOffset = CGSizeMake(0,1);
    [alertHeaderLabel setAlpha:0.0];
    
    alertTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(49.0, 17.0, 216.0, 22.0)];
    alertTextLabel.adjustsFontSizeToFitWidth = NO;
    alertTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.000];
    alertTextLabel.text = dataObj.text;
    alertTextLabel.textAlignment = UITextAlignmentLeft;
    alertTextLabel.backgroundColor = [UIColor clearColor];
    
    if (useBlackAlertStyle)
    {
        // Black alert style
        alertTextLabel.textColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1.000];
        alertTextLabel.shadowColor = [UIColor blackColor];
    }
    else
    {
        // Gray alert style
        alertTextLabel.textColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:0.9];
        alertTextLabel.shadowColor = [UIColor whiteColor];
    }
    
    alertTextLabel.shadowOffset = CGSizeMake(0,1);
    [alertTextLabel setAlpha:0.0];
    
    detailText = [[UITextView alloc] initWithFrame:CGRectMake(8.0, 50.0, 303.0, 75.0)];
    detailText.delegate = self;
    detailText.font = [UIFont fontWithName:@"HelveticaNeue" size:16.000];
    detailText.text = dataObj.text;
    detailText.textAlignment = UITextAlignmentLeft;
    detailText.textColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:0.8];
    detailText.backgroundColor = [UIColor clearColor];
    detailText.editable = NO;
    [detailText setAlpha:0.0];
    
    dateText = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 127.0, 65.0, 15.0)];
    dateText.font = [UIFont fontWithName:@"HelveticaNeue" size:10.500];
    dateText.text = [dataObj.time descriptionWithCalendarFormat:@"%H:%M" timeZone: nil locale: nil];
    dateText.textAlignment = UITextAlignmentLeft;
    dateText.textColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:0.5];
    dateText.backgroundColor = [UIColor clearColor];
    [dateText setAlpha:0.0];
    
    // If we're an SMS alert, we have some more setup to do!
    if(dataObj.type == kSMSAlert)
    {
        // Set up the SMS elements
        sendButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        sendButton.frame = CGRectMake(226.0, 205.0, 76.0, 40.0);
        [sendButton setBackgroundImage:[UIImage imageWithContentsOfFile: @"/Library/Application Support/MobileNotifier/btn_send.png"]
                              forState:UIControlStateNormal];
        [sendButton setAlpha:0.0];
        [sendButton setTitle:@"Send" forState:UIControlStateNormal];
        sendButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.00];
        sendButton.titleLabel.textAlignment = UITextAlignmentCenter;
        sendButton.titleLabel.textColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1.0];
        sendButton.titleLabel.backgroundColor = [UIColor clearColor];
        sendButton.titleLabel.shadowColor = [UIColor blackColor];
        sendButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
        
        [sendButton addTarget:self action:@selector(sendPushed:)
             forControlEvents:UIControlEventTouchUpInside];
        
        charactersTyped = [[UILabel alloc] initWithFrame:CGRectMake(258.0, 127.0, 45.0, 15.0)];
        charactersTyped.font = [UIFont fontWithName:@"HelveticaNeue" size:10.500];
        charactersTyped.text = @"0/160";
        charactersTyped.textAlignment = UITextAlignmentRight;
        charactersTyped.textColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:0.5];
        charactersTyped.backgroundColor = [UIColor clearColor];
        [charactersTyped setAlpha:0.0];
        
        textBox = [[BCZeroEdgeTextView alloc] initWithFrame:CGRectMake(17.0, 145.0, 285.0, 50.0)];
        [textBox setDelegate:self];
        textBox.keyboardAppearance = UIKeyboardAppearanceAlert;
        textBox.keyboardType = UIKeyboardTypeDefault;
        textBox.returnKeyType = UIReturnKeyDefault;
        textBox.font = [UIFont fontWithName:@"HelveticaNeue" size:12.500];
        textBox.textColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:0.8];
        [textBox setAlpha:0.0];
    }
        
    // Add everything to our view
    [notificationView addSubview:iconImageView];
    [notificationView addSubview:alertHeaderLabel];
    [notificationView addSubview:alertTextLabel];
    [notificationView addSubview:alertExpandButton];
    
    // Release the stuff we don't want to hang on to
    [alertHeaderLabel         release];
    [alertTextLabel           release];
        
    [self fadeInView];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Detect single finger, double tap
    /*UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc]
        initWithTarget:self action:@selector(laterPushed:)];

    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;

    [self.view addGestureRecognizer:doubleTap];
    [doubleTap release];*/
}

-(void)slideAwayRight
{
    if (!alertIsShowingPopOver && isAnimationInProgress == NO) {
        if (index != 0) {
            isAnimationInProgress = YES;
            // Animate slide away to right of screen (newer notification)
            [UIView beginAnimations:@"slideAwayToRight" context:nil];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(animationDidStop:didFinish:inContext:)];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                [UIView setAnimationDuration:0.2];
                [notificationView setFrame:CGRectMake(320,0,320,40)];
            [UIView commitAnimations];
            --index;
        }
    }
}

-(void)slideAwayLeft
{
    if (!alertIsShowingPopOver && isAnimationInProgress == NO) {
        if (index < [pendingAlerts count] - 1) {
            isAnimationInProgress = YES;
            // Animate slide away to left of screen (older notification)
            [UIView beginAnimations:@"slideAwayToLeft" context:nil];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(animationDidStop:didFinish:inContext:)];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                [UIView setAnimationDuration:0.2];
                [notificationView setFrame:CGRectMake(-320,0,320,40)];
            [UIView commitAnimations];
            ++index;
        }
    }
}

-(void)slideIn
{
    [UIView beginAnimations:@"slideIn" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.2];
        [notificationView setFrame:CGRectMake(0,0,320,40)];
    [UIView commitAnimations];
}

-(void)chevronPushed:(id)sender
{
    [_delegate alertShowingPopOver:!alertIsShowingPopOver];
    if (alertIsShowingPopOver)
    {
        [notificationScrollView setScrollEnabled:YES];
        
        CGRect frame = self.view.frame;
        frame.size.height -= 229;
        self.view.frame = frame;

        [self fadeBottomAway:YES];
    }
    else
    {
        [notificationScrollView setScrollEnabled:NO];
        
        CGRect frame = self.view.frame;
        frame.size.height += 229;
        self.view.frame = frame;

        [self fadeBottomAway:NO];

        [self.view addSubview:openButton];
        [self.view addSubview:laterButton];
        [self.view addSubview:closeButton];
        [self.view addSubview:detailText];
        [self.view addSubview:dateText];

        if (dataObj.type == kSMSAlert)
        {
            [self.view addSubview:sendButton];
            [self.view addSubview:charactersTyped];
            [self.view addSubview:textBox];
            UIKeyboardEnableAutomaticAppearance();
            [textBox becomeFirstResponder];
        }
    }
    alertIsShowingPopOver = !alertIsShowingPopOver;
}

-(void)fadeBottomAway:(bool)fadeBottom
{
    if (fadeBottom)
    {
        [UIView beginAnimations:@"hideLower" context:NULL];
            [UIView setAnimationDuration:0.3];
            [alertActionBackgroundImageView setAlpha:0.0];
            [alertActionBackgroundImageViewShadow setAlpha:0.0];
            [openButton setAlpha:0.0];
            [laterButton setAlpha:0.0];
            [detailText setAlpha:0.0];
            [dateText setAlpha:0.0];
            [closeButton setHidden:YES];

            [textBox resignFirstResponder];

            if (dataObj.type == kSMSAlert)
            {
                [sendButton setAlpha:0.0];
                [charactersTyped setAlpha:0.0];
                [textBox setAlpha:0.0];
            }

        [UIView commitAnimations];
    }
    else
    {
        [self.view addSubview:alertActionBackgroundImageView];

        [UIView beginAnimations:@"showLower" context:NULL];
            [UIView setAnimationDuration:0.3];
            [alertActionBackgroundImageView setAlpha:1.0];
            [openButton setAlpha:1.0];
            [laterButton setAlpha:1.0];
            [detailText setAlpha:1.0];
            [dateText setAlpha:1.0];
            [closeButton setHidden:NO];

            [textBox becomeFirstResponder];

            if (dataObj.type == kSMSAlert)
            {
                [sendButton setAlpha:1.0];
                [charactersTyped setAlpha:1.0];
                [textBox setAlpha:1.0];
            }

        [UIView commitAnimations];
    }
}

-(void)fadeOutWholeView
{
    [UIView beginAnimations:@"fadeOutWholeView" context:NULL];
        [UIView setAnimationDuration:0.2];
        [alertBackgroundImageView             setAlpha:0.0];
        [iconImageView                        setAlpha:0.0];
        [alertHeaderLabel                     setAlpha:0.0];
        [alertTextLabel                       setAlpha:0.0];
        [alertExpandButton                    setAlpha:0.0];
        [alertActionBackgroundImageView       setAlpha:0.0];
        [alertActionBackgroundImageViewShadow setAlpha:0.0];
        [openButton                           setAlpha:0.0];
        [laterButton                          setAlpha:0.0];
        [detailText                           setAlpha:0.0];
        [dateText                             setAlpha:0.0];
        [closeButton                          setAlpha:0.0];
        [notificationView                     setAlpha:0.0];

        if (dataObj.type == kSMSAlert)
        {
            [sendButton setAlpha:0.0];
            [charactersTyped setAlpha:0.0];
            [textBox setAlpha:0.0];

            [textBox resignFirstResponder];
        }

    [UIView commitAnimations];

    alertIsShowingPopOver = NO;

    UIKeyboardDisableAutomaticAppearance();
}

-(void)fadeInView
{
    [UIView beginAnimations:@"fadeInView" context:NULL];
        [UIView setAnimationDuration:0.2];
        [alertBackgroundImageView setAlpha:1.0];
        [iconImageView            setAlpha:1.0];
        [alertHeaderLabel         setAlpha:1.0];
        [alertTextLabel           setAlpha:1.0];
        [alertExpandButton        setAlpha:1.0];
        [notificationView         setAlpha:1.0];
    [UIView commitAnimations];
}

-(void)animationDidStop:(NSString*)animationID didFinish:(NSNumber*)finished inContext:(id)context
{
    if ([animationID isEqualToString:@"slideAwayToRight"]) {
        // Set the position back to the left side of the screen to be animated back in, going right
        // loadViewInfo will do the moving for us
        notificationViewRect = CGRectMake(-320,0,320,40);
    }
    else if ([animationID isEqualToString:@"slideAwayToLeft"]) {
        // Set the position back to the right side of the screen to be animated back in, going left
        // loadViewInfo will do the moving for us
        notificationViewRect = CGRectMake(320,0,320,40);
    }
    if ([animationID isEqualToString:@"slideAwayToRight"] || [animationID isEqualToString:@"slideAwayToLeft"]) {
        isAnimationInProgress = NO;
        [self loadData];
        [self slideIn];
    }
    
    if ([animationID isEqualToString:@"fadeInView"])
    {
        [alertActionBackgroundImageView removeFromSuperview];
        [alertActionBackgroundImageViewShadow removeFromSuperview];
        [openButton removeFromSuperview];
        [laterButton removeFromSuperview];
        [detailText removeFromSuperview];
        [dateText removeFromSuperview];

        if (dataObj.type == kSMSAlert)
        {
            [sendButton removeFromSuperview];
            [charactersTyped removeFromSuperview];
            [textBox removeFromSuperview];
        }
    }

    if ([animationID isEqualToString:@"fadeOutWholeView"])
    {
        [self.view removeFromSuperview];
    }
}

-(void)loadData
{    
    dataObj = [pendingAlerts objectAtIndex:index];
    
    [self loadViewInfo];
}

-(void)openPushed:(id)sender
{
    [self fadeOutWholeView];
    // Notify the delegate
    [_delegate alertViewController:self hadActionTaken:kAlertTakeAction];
}

-(void)laterPushed:(id)sender
{
    [self fadeOutWholeView];
    // Notify the delegate
    [_delegate alertViewController:self hadActionTaken:kAlertSentAway];
}

-(void)closePushed:(id)sender
{
    [self fadeOutWholeView];
    // Notify the delegate
    [_delegate alertViewController:self hadActionTaken:kAlertClosed];
}

-(void)sendPushed:(id)sender
{
    // Take the text in the textbox, and send it!
    [MNSMSSender sendMessage:textBox.text toNumber:dataObj.senderAddress];

    // Dismiss this alert entirely (as if it were deleted)
    [self closePushed:nil];
}

// UITextViewDelegate methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    charactersTyped.text = [NSString stringWithFormat:@"%d/160", [textView.text length] + [text length] - range.length];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == notificationScrollView)
    {
        [self setHasSwiped:YES];
    }
    else if (scrollView.contentOffset.x != 0.0)
    {
        [scrollView setContentOffset: CGPointMake(0.0, scrollView.contentOffset.y)];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == notificationScrollView) {
        // If scroll was far enough to the left
        if ([notificationScrollView contentOffset].x > 60) {
            [self slideAwayLeft];
        }
        // If scroll was far enough to the right
        else if ([notificationScrollView contentOffset].x < -60) {
            [self slideAwayRight];
        }
    }
}

@end
