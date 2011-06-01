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

#import "MNAlertData.h"

@implementation MNAlertData

@synthesize header, senderAddress, text, bundleID, time;
@synthesize type, status;

-(id)init
{
    self = [super init];

    return self;
}

-(id)initWithHeader:(NSString*)_header withText:(NSString*)_title andSenderAddress:(NSString*)_senderAddress andType:(int)_type forBundleID:(NSString*)_bundleID atTime:(NSDate*)_time ofStatus:(int)_status;
{
    if ((self = [self init]))
    {
        self.header        = _header;
        self.text          = _title;
        self.senderAddress = _senderAddress;
        self.bundleID      = _bundleID;
        self.time          = _time;
        self.type          = _type;
        self.status        = _status;
    }

    return self;
}

-(id)initWithHeader:(NSString*)_header withText:(NSString*)_title andSenderAddress:(NSString*)_senderAddress andType:(int)_type forBundleID:(NSString*)_bundleID ofStatus:(int)_status;
{
    if ((self = [self init]))
    {
        self.header        = _header;
        self.text          = _title;
        self.senderAddress = _senderAddress;
        self.bundleID      = _bundleID;
        self.time          = [NSDate date];
        self.type          = _type;
        self.status        = _status;
    }

    return self;
}

-(void)encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:header forKey:@"header"];
    [encoder encodeObject:text forKey:@"text"];
    [encoder encodeObject:senderAddress forKey:@"senderAddress"];
    [encoder encodeInt:type forKey:@"type"];
    [encoder encodeObject:bundleID forKey:@"bundleID"];
    [encoder encodeObject:time forKey:@"time"];
    [encoder encodeInt:status forKey:@"status"];
}

-(id)initWithCoder:(NSCoder*)decoder
{
    header        = [[decoder decodeObjectForKey:@"header"] retain];
    text          = [[decoder decodeObjectForKey:@"text"] retain];
    senderAddress = [[decoder decodeObjectForKey:@"senderAddress"] retain];
    type          = [decoder decodeIntForKey:@"type"];
    bundleID      = [[decoder decodeObjectForKey:@"bundleID"] retain];
    time          = [[decoder decodeObjectForKey:@"time"] retain];
    status        = [decoder decodeIntForKey:@"status"];

    return self;
}

@end

