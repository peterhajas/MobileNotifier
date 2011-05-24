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

#import "MNTableViewCell.h"

@implementation MNTableViewCell

@synthesize backgroundImageView, backgroundShadowImageView, iconImageView, headerLabel, alertTextLabel;

-(id)init
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notificationTableCell"];

    if (self != nil)
    {
        CGRect _frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,290,60);

        [self setFrame:_frame];

        backgroundImageView = [[UIImageView alloc] initWithFrame:_frame];
        backgroundImageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/row_bg.png"];

        backgroundShadowImageView = [[UIImageView alloc] initWithFrame:_frame];
        backgroundShadowImageView.userInteractionEnabled = NO;

        iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(13.5, 13.5, 33.0, 33.0)];
        headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 11.0, 216.0, 22.0)];
        alertTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 27.0, 216.0, 22.0)];

        headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.000];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor = [UIColor blackColor];
        headerLabel.shadowColor = [UIColor whiteColor];
        headerLabel.shadowOffset = CGSizeMake(0,1);

        alertTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.000];
        alertTextLabel.backgroundColor = [UIColor clearColor];
        alertTextLabel.textColor = [UIColor blackColor];
        alertTextLabel.shadowColor = [UIColor whiteColor];
        alertTextLabel.shadowOffset = CGSizeMake(0,1);

        iconImageView.layer.cornerRadius = 5.5;
        iconImageView.layer.masksToBounds = YES;

        // Add everything to the table view cell
        [self.contentView addSubview:backgroundImageView];
        [self.contentView addSubview:iconImageView];
        [self.contentView addSubview:alertTextLabel];
        [self.contentView addSubview:headerLabel];
        [self.contentView addSubview:backgroundShadowImageView];

        self.clipsToBounds = YES;

        // Release the things we don't need to hang on to copies of
        [backgroundImageView       release];
        [backgroundShadowImageView release];
        [iconImageView             release];
        [headerLabel               release];
        [alertTextLabel            release];
    }

    return self;
}

@end

