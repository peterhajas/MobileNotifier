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
    // Have the device vibrate, if the ringer switch
    // is flipped (and if the device supports it)
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

    // Play noise, if the ringer switch is not
    // flipped (and if the device supports it)
    // Don't do this for push notifications

    if (data.type != kPushAlert)
    {
        AudioServicesPlaySystemSound(1007);
    }

    // Wake the device's screen
    [_delegate wakeDeviceScreen];
}

@end

