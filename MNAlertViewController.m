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
@synthesize chevronButton;
@synthesize alertHeaderLabel, alertTextLabel;
@synthesize replyButton, laterButton, openButton;

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

	alertActionBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 60.0, 320.0, 45.0)];
	alertActionBackgroundImageView.frame = CGRectMake(0.0, 60.0, 320.0, 45.0);
	alertActionBackgroundImageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/alert_actions_bg.png"];

	iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 15.0, 30.0, 30.0)];
	iconImageView.frame = CGRectMake(12.0, 10.0, 38.0, 38.0);
	iconImageView.image = [_delegate iconForBundleID:dataObj.bundleID];

	chevronButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	chevronButton.contentMode = UIViewContentModeCenter;
	chevronButton.frame = CGRectMake(284.0, 8.0, 29.0, 44.0);
	[chevronButton setImage:[UIImage imageWithContentsOfFile: @"/Library/Application Support/MobileNotifier/alert_chevron_half.png"] 
				   forState:UIControlStateNormal];

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

	replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	replyButton.frame = CGRectMake(135.0, 66.0, 50.0, 32.0);
	replyButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.000];
	replyButton.titleLabel.shadowOffset = CGSizeMake(0.0, 0.0);
	[replyButton setTitle:@"Reply" forState:UIControlStateNormal];
	[replyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[replyButton setTitleShadowColor:[UIColor colorWithWhite:0.500 alpha:1.000] forState:UIControlStateNormal];
	[replyButton setBackgroundImage:[UIImage imageWithContentsOfFile: @"/Library/Application Support/MobileNotifier/alert_actions_bg.png"] 
						   forState:UIControlStateNormal];

	laterButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	laterButton.frame = CGRectMake(231.0, 66.0, 50.0, 32.0);
	laterButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.000];
	[laterButton setTitle:@"Later" forState:UIControlStateNormal];
	[laterButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[laterButton setTitleShadowColor:[UIColor colorWithWhite:0.500 alpha:1.000] forState:UIControlStateNormal];
	[laterButton setBackgroundImage:[UIImage imageWithContentsOfFile: @"/Library/Application Support/MobileNotifier/alert_actions_bg.png"] 
						   forState:UIControlStateNormal];
	
	openButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	openButton.frame = CGRectMake(39.0, 66.0, 50.0, 32.0);
	openButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.000];
	[openButton setTitle:@"Open" forState:UIControlStateNormal];
	[openButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[openButton setTitleShadowColor:[UIColor colorWithWhite:0.500 alpha:1.000] forState:UIControlStateNormal];
	[openButton setBackgroundImage:[UIImage imageWithContentsOfFile: @"/Library/Application Support/MobileNotifier/alert_actions_bg.png"] 
						   forState:UIControlStateNormal];

	//Wire up buttons
	
	[chevronButton addTarget:self action:@selector(chevronPushed:) 
			forControlEvents:UIControlEventTouchUpInside];
			
	[replyButton addTarget:self action:@selector(replyPushed:)
		  forControlEvents:UIControlEventTouchUpInside];

	[laterButton addTarget:self action:@selector(laterPushed:)
		  forControlEvents:UIControlEventTouchUpInside];
	
	[openButton addTarget:self action:@selector(openPushed:)
		 forControlEvents:UIControlEventTouchUpInside];

	[self.view addSubview:alertBackgroundImageView];
	[self.view addSubview:iconImageView];
	[self.view addSubview:alertHeaderLabel];
	[self.view addSubview:alertTextLabel];
	[self.view addSubview:chevronButton];
	[self.view addSubview:alertActionBackgroundImageView];
	[self.view addSubview:replyButton];
	[self.view addSubview:openButton];
	[self.view addSubview:laterButton];
	
	alertIsExpanded = NO;
	
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
	if(alertIsExpanded)
	{
		CGRect frame = self.view.frame;
		frame.size.height -= 45;
		self.view.frame = frame;
		
		[UIButton beginAnimations:nil context:NULL];
		[UIButton setAnimationDuration:0.3];
		CGAffineTransform transform = CGAffineTransformMakeRotation(0);
		chevronButton.transform = transform;
		[UIButton commitAnimations];
		
	}
	else
	{
		CGRect frame = self.view.frame;
		frame.size.height += 45;
		self.view.frame = frame;
		
		[UIButton beginAnimations:nil context:NULL];
		[UIButton setAnimationDuration:0.3];
		CGAffineTransform transform = CGAffineTransformMakeRotation(3.14/2);
		chevronButton.transform = transform;
		[UIButton commitAnimations];
	}
	
	alertIsExpanded = !alertIsExpanded;
	[_delegate alertExpanded:alertIsExpanded];
}

-(void)replyPushed:(id)sender
{
	NSLog(@"Reply pushed");
}

-(void)laterPushed:(id)sender
{
	//Notify the delegate
	[_delegate alertViewController:self hadActionTaken:kAlertSentAway];

	//And that's it! The delegate will take care of everything else.
}

-(void)openPushed:(id)sender
{
	//Notify the delegate
	[_delegate alertViewController:self hadActionTaken:kAlertTakeAction];
}

@end
