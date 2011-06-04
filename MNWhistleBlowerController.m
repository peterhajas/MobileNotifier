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

#import "MNWhistleBlowerController.h"

@implementation MNWhistleBlowerController

@synthesize delegate = _delegate;

-(id)initWithDelegate:(id)__delegate
{
    self = [super init];

    if (self)
    {
        _delegate = __delegate;
    }
    return self;
}

-(void)alertArrivedWithData:(MNAlertData*)data;
{
	// Get user setting for current notification tone on phone
	NSString *filePath = @"/private/var/mobile/Library/Preferences/com.apple.springboard.plist";
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];

    NSString *smsTone;
    smsTone = [plistDict objectForKey:@"sms-sound-identifier"];
	
	// Statements based on setting to play proper tone on phone
	if ([smsTone isEqualToString:@"Tri-tone"])
	{
		AudioServicesPlayAlertSound(1007);
	}
	else if ([smsTone isEqualToString:@"texttone:Chime"])
	{
		AudioServicesPlayAlertSound(1008);
	}
	else if ([smsTone isEqualToString:@"texttone:Glass"])
	{
		AudioServicesPlayAlertSound(1009);
	}
	else if ([smsTone isEqualToString:@"texttone:Horn"])
	{
		AudioServicesPlayAlertSound(1010);
	}
	else if ([smsTone isEqualToString:@"texttone:Bell"])
	{
		AudioServicesPlayAlertSound(1013);
	}
	else if ([smsTone isEqualToString:@"texttone:Electronic"])
	{
		AudioServicesPlayAlertSound(1014);
	}
	else if ([smsTone isEqualToString:@"texttone:Anticipate"])
	{
		AudioServicesPlayAlertSound(1020);
	}
	else if ([smsTone isEqualToString:@"texttone:Bloom"])
	{
		AudioServicesPlayAlertSound(1021);
	}
	else if ([smsTone isEqualToString:@"texttone:Calypso"])
	{
		AudioServicesPlayAlertSound(1022);
	}
	else if ([smsTone isEqualToString:@"texttone:Choo Choo"])
	{
		AudioServicesPlayAlertSound(1023);
	}
	else if ([smsTone isEqualToString:@"texttone:Descent"])
	{
		AudioServicesPlayAlertSound(1024);
	}
	else if ([smsTone isEqualToString:@"texttone:Fanfare"])
	{
		AudioServicesPlayAlertSound(1025);
	}
	else if ([smsTone isEqualToString:@"texttone:Ladder"])
	{
		AudioServicesPlayAlertSound(1026);
	}
	else if ([smsTone isEqualToString:@"texttone:Minuet"])
	{
		AudioServicesPlayAlertSound(1027);
	}
	else if ([smsTone isEqualToString:@"texttone:News Flash"])
	{
		AudioServicesPlayAlertSound(1028);
	}
	else if ([smsTone isEqualToString:@"texttone:Noir"])
	{
		AudioServicesPlayAlertSound(1029);
	}
	else if ([smsTone isEqualToString:@"texttone:Sherwood Forest"])
	{
		AudioServicesPlayAlertSound(1030);
	}
	else if ([smsTone isEqualToString:@"texttone:Spell"])
	{
		AudioServicesPlayAlertSound(1031);
	}
	else if ([smsTone isEqualToString:@"texttone:Suspense"])
	{
		AudioServicesPlayAlertSound(1032);
	}
	else if ([smsTone isEqualToString:@"texttone:Telegraph"])
	{
		AudioServicesPlayAlertSound(1033);
	}
	else if ([smsTone isEqualToString:@"texttone:TipToes"])
	{
		AudioServicesPlayAlertSound(1034);
	}
	else if ([smsTone isEqualToString:@"texttone:Typewriters"])
	{
		AudioServicesPlayAlertSound(1035);
	}
	else if ([smsTone isEqualToString:@"texttone:Update"])
	{
		AudioServicesPlayAlertSound(1036);
	}
	else
	{
		// There be dragons here!
    	AudioServicesPlayAlertSound(1007);
	}

    // Wake the device's screen
    [_delegate wakeDeviceScreen];
}

@end

