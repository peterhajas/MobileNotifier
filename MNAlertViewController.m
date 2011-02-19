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
	
	self.view.frame = CGRectMake(0,0,320,60);

	alertBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 60.0)];
	alertBackgroundImageView.frame = CGRectMake(0.0, 0.0, 320.0, 60.0);
	alertBackgroundImageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/alert_bg.png"];

	alertBackgroundShadow = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 60.0, 320, 17)];
	alertBackgroundShadow.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/alert_bg_shadow.png"];

	iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 15.0, 30.0, 30.0)];
	iconImageView.frame = CGRectMake(12.0, 10.0, 38.0, 38.0);
	iconImageView.image = [_delegate iconForBundleID:dataObj.bundleID];

	chevronButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	chevronButton.contentMode = UIViewContentModeCenter;
	chevronButton.frame = CGRectMake(290.0, 22, 10.0, 15.0);
	[chevronButton setImage:[UIImage imageWithContentsOfFile: @"/Library/Application Support/MobileNotifier/alert_chevron.png"] 
				   forState:UIControlStateNormal];
	
	alertExpandButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	alertExpandButton.frame = CGRectMake(0.0, 0.0, 320.0, 60.0);

	alertHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 11.0, 216.0, 22.0)];
	alertHeaderLabel.frame = CGRectMake(60.0, 11.0, 216.0, 22.0);
	alertHeaderLabel.adjustsFontSizeToFitWidth = NO;
	alertHeaderLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.000];
	alertHeaderLabel.text = dataObj.header;
	alertHeaderLabel.textAlignment = UITextAlignmentLeft;
	alertHeaderLabel.textColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:1.000];
	alertHeaderLabel.backgroundColor = [UIColor clearColor];

	alertTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 27.0, 216.0, 22.0)];
	alertTextLabel.frame = CGRectMake(60.0, 27.0, 216.0, 22.0);
	alertTextLabel.adjustsFontSizeToFitWidth = NO;
	alertTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.000];
	alertTextLabel.text = dataObj.text;
	alertTextLabel.textAlignment = UITextAlignmentLeft;
	alertTextLabel.textColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:1.000];
	alertTextLabel.backgroundColor = [UIColor clearColor];

	//Popdown alert actions
	alertActionBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1.0, 47.0, 319.0, 93.0)];
	alertActionBackgroundImageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/popup_bg.png"];
	alertActionBackgroundImageView.opaque = NO;
	//alertActionBackgroundImageView.opaque = NO;
	alertActionBackgroundImageView.backgroundColor = [UIColor clearColor];
	
	//We also need the shadow for the Popdown
	alertActionBackgroundImageViewShadow = [[UIImageView alloc] initWithFrame:CGRectMake(1.0, 47.0, 319.0, 93.0)];
	alertActionBackgroundImageViewShadow.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/popup_bg_shadow.png"];
	alertActionBackgroundImageViewShadow.opaque = NO;
	
	openButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	openButton.frame = CGRectMake(163.0, 80.0, 139.0, 42.0);
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
	laterButton.frame = CGRectMake(16.0, 80.0, 139.0, 42.0);
	[laterButton setBackgroundImage:[UIImage imageWithContentsOfFile: @"/Library/Application Support/MobileNotifier/close_btn.png"] 
						   forState:UIControlStateNormal];

	//Wire up buttons
	
	[chevronButton addTarget:self action:@selector(chevronPushed:) 
			forControlEvents:UIControlEventTouchUpInside];

	[openButton addTarget:self action:@selector(openPushed:)
			 forControlEvents:UIControlEventTouchUpInside];

	[laterButton addTarget:self action:@selector(laterPushed:)
		  forControlEvents:UIControlEventTouchUpInside];
	
	[alertExpandButton addTarget:self action:@selector(chevronPushed:)
				forControlEvents:UIControlEventTouchUpInside];

	[self.view addSubview:alertBackgroundImageView];
	[self.view addSubview:iconImageView];
	[self.view addSubview:alertHeaderLabel];
	[self.view addSubview:alertTextLabel];
	[self.view addSubview:chevronButton];
	[self.view addSubview:alertBackgroundShadow];
	
	[self.view addSubview:alertExpandButton];
	
	alertIsShowingPopOver = NO;
	
	/*
	
	alertHeader = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 250 , 40)];
	alertHeader.text = dataObj.header;
	alertHeader.font = [UIFont fontWithName:@"Helvetica" size:12];
	alertHeader.backgroundColor = [UIColor clearColor];

	sendAway = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	sendAway.frame = CGRectMake(265, 18, 34, 20);
	[sendAway setBackgroundImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/sendAwayButton.png"] forState:UIControlStateNormal];
	takeAction = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[takeAction setTitle:dataObj.text forState:UIControlStateNormal];
	[takeAction setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[takeAction setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	takeAction.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:10];

	takeAction.frame = CGRectMake(20, 20, 230, 40);
	
	alertBackground = [[UIImageView alloc] init];
	[alertBackground setFrame:CGRectMake(0,0,320,62)];
	alertBackground.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/alertBackground.png"];		
	*/
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
		
		[self.view addSubview:alertBackgroundShadow];
		[alertActionBackgroundImageView removeFromSuperview];
		[alertActionBackgroundImageViewShadow removeFromSuperview];
		[openButton removeFromSuperview];
		[laterButton removeFromSuperview];
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
		
		[alertBackgroundShadow removeFromSuperview];
		[self.view addSubview:alertActionBackgroundImageViewShadow];
		[self.view addSubview:alertActionBackgroundImageView];
		[self.view addSubview:openButton];
		[self.view addSubview:laterButton];
	}
	
	alertIsShowingPopOver = !alertIsShowingPopOver;
	[_delegate alertShowingPopOver:alertIsShowingPopOver];
}

-(void)openPushed:(id)sender
{
	//Notify the delegate
	[_delegate alertViewController:self hadActionTaken:kAlertTakeAction];
}

-(void)laterPushed:(id)sender
{
	//Notify the delegate
	[_delegate alertViewController:self hadActionTaken:kAlertSentAway];

	//And that's it! The delegate will take care of everything else.
}

@end
