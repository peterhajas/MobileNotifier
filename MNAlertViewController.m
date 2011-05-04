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

@synthesize alertBackgroundImageView, alertActionBackgroundImageView, iconImageView, alertBackgroundShadow;
@synthesize chevronButton;
@synthesize alertHeaderLabel, alertTextLabel;
@synthesize laterButton, openButton;

@synthesize dataObj;
@synthesize alertIsShowingPopOver;

@synthesize delegate = _delegate;

-(id)init
{
	self = [super init];
	if(self != nil)
	{
		self.view.clipsToBounds = YES;
	}
	return self;
}

-(id)initWithMNData:(MNAlertData*) data
{
	self = [super init];
	
	dataObj = data;
	
	return self;
}

-(void)loadView
{
	[super loadView];
	
	self.view.frame = CGRectMake(0,0,320,40);

	[UIView setAnimationDidStopSelector:@selector(animationDidStop:didFinish:inContext:)];
	[UIView setAnimationDelegate:self];

	alertBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
	alertBackgroundImageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/alert_bg_small.png"];
	[alertBackgroundImageView setAlpha:0.0];

	alertBackgroundShadow = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 40.0, 320, 17)];
	alertBackgroundShadow.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/alert_bg_shadow.png"];
	[alertBackgroundShadow setAlpha:0.0];

	iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 7.0, 26.0, 26.0)];
	iconImageView.image = [_delegate iconForBundleID:dataObj.bundleID];
	[iconImageView setAlpha:0.0];
	iconImageView.layer.cornerRadius = 5.5;
	iconImageView.layer.masksToBounds = YES;

	chevronButton = [UIButton buttonWithType:UIButtonTypeCustom];
	chevronButton.contentMode = UIViewContentModeCenter;
	chevronButton.frame = CGRectMake(285.0, 11, 10.0, 15.0);
	[chevronButton setImage:[UIImage imageWithContentsOfFile: @"/Library/Application Support/MobileNotifier/alert_chevron.png"] 
				   forState:UIControlStateNormal];
	[chevronButton setAlpha:0.0];
	
	alertExpandButton = [UIButton buttonWithType:UIButtonTypeCustom];
	alertExpandButton.frame = CGRectMake(0.0, 0.0, 320.0, 40.0);
	[alertExpandButton setAlpha:0.0];

	alertHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 2.0, 216.0, 22.0)];
	alertHeaderLabel.adjustsFontSizeToFitWidth = NO;
	alertHeaderLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.000];
	alertHeaderLabel.text = dataObj.header;
	alertHeaderLabel.textAlignment = UITextAlignmentLeft;
	alertHeaderLabel.textColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1.000];
	alertHeaderLabel.backgroundColor = [UIColor clearColor];
	alertHeaderLabel.shadowColor = [UIColor blackColor];
	alertHeaderLabel.shadowOffset = CGSizeMake(0,1);
	[alertHeaderLabel setAlpha:0.0];

	alertTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 19.0, 216.0, 22.0)];
	alertTextLabel.adjustsFontSizeToFitWidth = NO;
	alertTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.000];
	alertTextLabel.text = dataObj.text;
	alertTextLabel.textAlignment = UITextAlignmentLeft;
	alertTextLabel.textColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1.000];
	alertTextLabel.backgroundColor = [UIColor clearColor];
	alertTextLabel.shadowColor = [UIColor blackColor];
	alertTextLabel.shadowOffset = CGSizeMake(0,1);
	[alertTextLabel setAlpha:0.0];

	//Popdown alert actions
	alertActionBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1.0, 27.0, 319.0, 93.0)];
	alertActionBackgroundImageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/popup_bg.png"];
	alertActionBackgroundImageView.opaque = NO;
	//alertActionBackgroundImageView.opaque = NO;
	alertActionBackgroundImageView.backgroundColor = [UIColor clearColor];
	alertActionBackgroundImageView.alpha = 0.0;
	
	//We also need the shadow for the Popdown
	alertActionBackgroundImageViewShadow = [[UIImageView alloc] initWithFrame:CGRectMake(1.0, 27.0, 319.0, 93.0)];
	alertActionBackgroundImageViewShadow.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/popup_bg_shadow.png"];
	alertActionBackgroundImageViewShadow.opaque = NO;
	
    openButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	openButton.frame = CGRectMake(163.0, 56.0, 139.0, 47.0);
	[openButton setAlpha:0.0];

	if(dataObj.type == kSMSAlert)
	{
		//Change this to quick reply once that feature is functional
		[openButton setBackgroundImage:[UIImage imageWithContentsOfFile: @"/Library/Application Support/MobileNotifier/open_btn.png"] 
							  forState:UIControlStateNormal];
	}
	else
	{
		[openButton setBackgroundImage:[UIImage imageWithContentsOfFile: @"/Library/Application Support/MobileNotifier/open_btn.png"] 
							  forState:UIControlStateNormal];
	}
	
    laterButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	laterButton.frame = CGRectMake(16.0, 56.0, 139.0, 47.0);
	[laterButton setBackgroundImage:[UIImage imageWithContentsOfFile: @"/Library/Application Support/MobileNotifier/close_btn.png"] 
						   forState:UIControlStateNormal];
	[laterButton setAlpha:0.0];
	
	//Wire up buttons
	
	[chevronButton addTarget:self action:@selector(chevronPushed:) 
			forControlEvents:UIControlEventTouchUpInside];

	[openButton addTarget:self action:@selector(openPushed:)
			 forControlEvents:UIControlEventTouchUpInside];

	[laterButton addTarget:self action:@selector(laterPushed:)
		  forControlEvents:UIControlEventTouchUpInside];
	
	[alertExpandButton addTarget:self action:@selector(chevronPushed:)
				forControlEvents:UIControlEventTouchUpInside];

    //Add everything to our view
    
	[self.view addSubview:alertBackgroundImageView];
	[self.view addSubview:iconImageView];
	[self.view addSubview:alertHeaderLabel];
	[self.view addSubview:alertTextLabel];
	[self.view addSubview:chevronButton];
	[self.view addSubview:alertBackgroundShadow];
	[self.view addSubview:alertExpandButton];
	
	//Release the stuff we don't want to hang on to
	
    [alertBackgroundImageView               release];
    [alertBackgroundShadow                  release];
    [alertHeaderLabel                       release];
    [alertTextLabel                         release];    
	
	alertIsShowingPopOver = NO;
	
	[self fadeInView];
}

-(void)viewDidLoad 
{ 
	[super viewDidLoad];
	
	//If the system understands UIGestureRecognizer, utilize it!
	if([UISwipeGestureRecognizer respondsToSelector:@selector(setNumberOfTouches:)])
	{
		// Single finger, double tap
	    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]
	        initWithTarget:self action:@selector(didSwipeRight)];

	    swipeRight.numberOfTouchesRequired = 1;
	    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
	    [self.view addGestureRecognizer:swipeRight];
	    [swipeRight release];
	}
}

-(void)didSwipeRight
{
    if(alertIsShowingPopOver)
    {
        //Do nothing
        return;
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    CGRect frame = self.view.frame;
    frame.origin.x += 320;
    self.view.frame = frame;
    [UIView commitAnimations];
    
    //Notify the delegate
	[_delegate alertViewController:self hadActionTaken:kAlertSentAway];
}

-(void)chevronPushed:(id)sender
{	
	if(alertIsShowingPopOver)
	{
		CGRect frame = self.view.frame;
		frame.size.height -= 45;
		self.view.frame = frame;
		
		[UIButton beginAnimations:nil context:NULL];
		[UIButton setAnimationDuration:0.3];
		CGAffineTransform transform = CGAffineTransformMakeRotation(0);
		chevronButton.transform = transform;
		[UIButton commitAnimations];
		
		[self fadeBottomAway:YES];
	}
	else
	{
		CGRect frame = self.view.frame;
		frame.size.height += 93;
		self.view.frame = frame;
		
		[UIButton beginAnimations:nil context:NULL];
		[UIButton setAnimationDuration:0.3];
		CGAffineTransform transform = CGAffineTransformMakeRotation(3.14/2);
		chevronButton.transform = transform;
		[UIButton commitAnimations];
		
		[self fadeBottomAway:NO];
		
		[self.view addSubview:openButton];
		[self.view addSubview:laterButton];
	}
	
	alertIsShowingPopOver = !alertIsShowingPopOver;
	[_delegate alertShowingPopOver:alertIsShowingPopOver];
}

-(void)fadeBottomAway:(bool)fadeBottom
{
	if(fadeBottom)
	{
		[self.view addSubview:alertBackgroundShadow];
		
		[UIView beginAnimations:@"hideLower" context:NULL];
		
		[UIView setAnimationDuration:0.3];
		[alertActionBackgroundImageView setAlpha:0.0];
		[alertActionBackgroundImageViewShadow setAlpha:0.0];
		[openButton setAlpha:0.0];
		[laterButton setAlpha:0.0];
		
		[UIView commitAnimations];
	}
	else
	{
		[self.view addSubview:alertActionBackgroundImageViewShadow];
		[self.view addSubview:alertActionBackgroundImageView];
				
		[UIView beginAnimations:@"showLower" context:NULL];
		
		[UIView setAnimationDuration:0.3];
		[alertActionBackgroundImageView setAlpha:0.9];
		[alertActionBackgroundImageViewShadow setAlpha:1.0];
		[openButton setAlpha:1.0];
		[laterButton setAlpha:1.0];
		
		[UIView commitAnimations];
	}
}

-(void)fadeOutWholeView
{
	[UIView beginAnimations:@"fadeOutWholeView" context:NULL];
	[UIView setAnimationDuration:0.2];
	
	[alertBackgroundImageView			   setAlpha:0.0];
	[iconImageView           			   setAlpha:0.0];
	[alertHeaderLabel        			   setAlpha:0.0];
	[alertTextLabel          			   setAlpha:0.0];
	[chevronButton           			   setAlpha:0.0];
	[alertBackgroundShadow   			   setAlpha:0.0];
	[alertExpandButton       			   setAlpha:0.0];
	
	[alertActionBackgroundImageView        setAlpha:0.0];
	[alertActionBackgroundImageViewShadow  setAlpha:0.0];
	[openButton                            setAlpha:0.0];
	[laterButton                           setAlpha:0.0];
	
	[UIView commitAnimations];
	
	alertIsShowingPopOver = NO;
}

-(void)fadeInView
{
	[UIView beginAnimations:@"fadeInView" context:NULL];
	[UIView setAnimationDuration:0.2];
	[alertBackgroundImageView setAlpha:1.0];
	[iconImageView            setAlpha:1.0];
	[alertHeaderLabel         setAlpha:1.0];
	[alertTextLabel           setAlpha:1.0];
	[chevronButton            setAlpha:1.0];
	[alertBackgroundShadow    setAlpha:1.0];
	[alertExpandButton        setAlpha:1.0];
	[UIView commitAnimations];
}

-(void)animationDidStop:(NSString*)animationID didFinish:(NSNumber*)finished inContext:(id)context
{
	if([animationID isEqualToString:@"fadeInView"])
	{
		[alertActionBackgroundImageView removeFromSuperview];
		[alertActionBackgroundImageViewShadow removeFromSuperview];
		[openButton removeFromSuperview];
		[laterButton removeFromSuperview];
	}
	if([animationID isEqualToString:@"fadeOutWholeView"])
	{
		[self.view removeFromSuperview];
	}
}

-(void)openPushed:(id)sender
{
	[self fadeOutWholeView];
	
	//Notify the delegate
	[_delegate alertViewController:self hadActionTaken:kAlertTakeAction];
}

-(void)laterPushed:(id)sender
{
	[self fadeOutWholeView];
	
	//Notify the delegate
	[_delegate alertViewController:self hadActionTaken:kAlertSentAway];
}

@end
