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

#import "MNSMSSender.h"

@implementation MNSMSSender

+(void)sendMessage:(NSString*)message toNumber:(NSString*)number
{
    /* ------------------------------------------------------------------------
    This uses ChatKit to send an SMS.
    ---------------------------------------------------------------------------
    ChatKit is not documented. ChatKit is not even half documented. Short of
    sitting and intercepting ChatKit message calls, I would not have been able
    to determine how the framework works. I was only able to thanks to some
    awesome detective work by myself and Dustin Howett. Spelunking is fun!   */

    // First, we need to grab the shared CKSMSService.
    CKSMSService* service = [objc_getClass("CKSMSService") sharedSMSService];

    // Now, grab the conversation list for this service
    CKConversationList* conversationList = service.conversationList;

    // We need the conversation for the number
    CKConversation* conversation = [conversationList existingConversationForAddresses:[NSArray arrayWithObjects:number, nil]];

    // Create the SMS message
    CKSMSMessage* smsMessage = [service _newSMSMessageWithText:message forConversation:conversation];

    // Send the message
    [service sendMessage:smsMessage];
}

@end
