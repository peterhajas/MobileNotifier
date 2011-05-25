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

#import "MNQuickReplyViewController.h"

@implementation MNQuickReplyViewController

-(void)viewDidLoad
{
    NSLog(@"view added");
    [self.view setFrame:CGRectMake(0, 0, 320, 50)];
    NSLog(@"set frame");
    textField = [[[UITextField alloc] initWithFrame:CGRectMake(5, 5, 200, 40)] autorelease];
    textField.backgroundColor = [UIColor whiteColor];
    textField.text = @"hello!";
    sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.titleLabel.text = @"s";
    sendButton.backgroundColor = [UIColor greenColor];
    cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelButton.titleLabel.text = @"c";
    cancelButton.backgroundColor = [UIColor redColor];
    [cancelButton setFrame:CGRectMake(205, 5, 40, 40)];
    [sendButton setFrame:CGRectMake(250, 5, 40, 40)];
    NSLog(@"made buttons and text field");
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    [sendButton addTarget:self action:@selector(send:)
         forControlEvents:UIControlEventTouchUpInside];
    
    [cancelButton addTarget:self action:@selector(cancel:)
           forControlEvents:UIControlEventTouchUpInside];
    
    NSLog(@"wired up buttons");
    
    [self.view addSubview:textField];
    [self.view addSubview:sendButton];
    [self.view addSubview:cancelButton];
    
    NSLog(@"added to self");
}

-(id)initWithAddress:(NSString*)address
{
    NSLog(@"initializing");
    self = [super init];
    if(self)
    {
        NSLog(@"setting number");
        number = [[NSString alloc] initWithString:address];
    }
    NSLog(@"all done!");
    return self;
}

-(void)send:(id)sender
{
    // Send the message to the address
    NSLog(@"sending!");
    [MNSMSSender sendMessage:textField.text toNumber:number];
    [self.view removeFromSuperview];
}

-(void)cancel:(id)sender
{
    // Remove us from our superview
    [self.view removeFromSuperview];
}

@end