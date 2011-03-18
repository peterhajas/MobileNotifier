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

#define kNewAlertForeground 0
#define kNewAlertBackground 1
#define kOldAlert 2

#define kSMSAlert 0
#define kPushAlert 1
#define kPhoneAlert 2

@interface MNAlertData : NSObject <NSCoding>
{
	NSString *header;
	NSString *text;
    NSString *senderAddress;
	int type;
	NSString *bundleID;
	NSDate *time;
	int status;
}

-(id)initWithHeader:(NSString*)_header withText:(NSString*)_title andSenderAddress:(NSString*)_senderAddress andType:(int)_type forBundleID:(NSString*)_bundleID atTime:(NSDate*)_time ofStatus:(int)_status;
-(id)initWithHeader:(NSString*)_header withText:(NSString*)_title andSenderAddress:(NSString*)_senderAddress andType:(int)_type forBundleID:(NSString*)_bundleID ofStatus:(int)_status;
-(id)init;

@property(nonatomic, retain) NSString *header;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSString *senderAddress;
@property(nonatomic) int type;
@property(nonatomic, retain) NSString *bundleID;
@property(nonatomic, retain) NSDate *time;
@property(nonatomic) int status;

@end

