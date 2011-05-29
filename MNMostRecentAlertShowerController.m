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

#import "MNMostRecentAlertShowerController.h"

@implementation MNMostRecentAlertShowerController

-(id)initWithManager:(MNAlertManager*)manager
{
	NSLog(@"initializing with manager: %@", manager);
	self = [super init];
	if(self)
	{
		alertManager = manager;

		// Register for libactivator events
        [[LAActivator sharedInstance] registerListener:self forName:@"com.peterhajassoftware.mobilenotifier.mostrecentpending"];
	}
	
	return self;
}

// --------------------
// Libactivator methods
// --------------------
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	[alertManager presentMostRecentPendingAlert];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
 	// Hide the most recent alert (if there is one)
	if(alertManager.pendingAlertViewController)
	{
		[alertManager.dashboard fadeDashboardDown];
	    [alertManager alertViewController:alertManager.pendingAlertViewController hadActionTaken: kAlertSentAway];
	}
}

@end