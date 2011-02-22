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
@synthesize delegate = _delegate;

-(id)init
{
	self = [super init];
	if(self)
	{
		CGRect screenBounds = [[UIScreen mainScreen] bounds];
		
		//window:
		window = [[UIWindow alloc] 
		initWithFrame:CGRectMake(0,0,screenBounds.size.width,screenBounds.size.height - 92)];
		
		window.windowLevel = 991;
		window.userInteractionEnabled = NO;
		window.hidden = YES;
		
		dashboardBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,screenBounds.size.width,screenBounds.size.height - 92)];
		dashboardBackground.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/complete_bg.png"];
		[dashboardBackground setAlpha:0.0];
		
		dashboardShowing = NO;
		[window addSubview:dashboardBackground];
		
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:didFinish:inContext:)];
	}
	return self;
}

-(void)toggleDashboard
{
	if(dashboardShowing)
	{
		[self showDashboard];
	}
	else
	{
		[self hideDashboard];
	}
}

-(void)hideDashboard
{
	window.userInteractionEnabled = NO;
	[UIView beginAnimations:@"fadeOut" context:NULL];
	[UIView setAnimationDuration:0.3];
	[dashboardBackground setAlpha:0.0];
	[UIView commitAnimations];
}

-(void)showDashboard
{
	window.hidden = NO;
	window.userInteractionEnabled = YES;
	[UIView beginAnimations:@"fadeIn" context:NULL];
	[UIView setAnimationDuration:0.3];
	[dashboardBackground setAlpha:1.0];
	[UIView commitAnimations];
}

-(void)animationDidStop:(NSString*)animationID didFinish:(NSNumber*)finished inContext:(id)context
{
	if([animationID isEqualToString:@"fadeIn"])
	{
		window.userInteractionEnabled = YES;
	}
	if([animationID isEqualToString:@"fadeOut"])
	{
		window.userInteractionEnabled = NO;
		window.hidden = YES;
	}
}

@end