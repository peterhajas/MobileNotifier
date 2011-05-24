#import "MNTableViewCellClear.h"

@implementation MNTableViewCellClear

@synthesize iconImageView, headerLabel, alertTextLabel;

-(id)init
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notificationTableCell"];
    if(self != nil)
    {
        CGRect _frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,320,60);

        [self setFrame:_frame];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAlpha:0.7];
        [self setClipsToBounds:YES];

        iconImageView  = [[UIImageView alloc] initWithFrame:CGRectMake(15, 13.5, 33.0, 33.0)];
        headerLabel    = [[UILabel alloc] initWithFrame:CGRectMake(61.0, 11.0, 245.0, 22.0)];
        alertTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(61.0, 27.0, 245.0, 22.0)];

        headerLabel.font            = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.000];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor       = [UIColor whiteColor];
        headerLabel.shadowColor     = [UIColor blackColor];
        headerLabel.shadowOffset    = CGSizeMake(0,-1);

        alertTextLabel.font            = [UIFont fontWithName:@"HelveticaNeue" size:13.000];
        alertTextLabel.backgroundColor = [UIColor clearColor];
        alertTextLabel.textColor       = [UIColor whiteColor];
        alertTextLabel.shadowColor     = [UIColor blackColor];
        alertTextLabel.shadowOffset    = CGSizeMake(0,-1);

        iconImageView.layer.cornerRadius  = 5.5;
        iconImageView.layer.masksToBounds = YES;

        //Add everything to the table view cell
        [self.contentView addSubview:iconImageView];
        [self.contentView addSubview:alertTextLabel];
        [self.contentView addSubview:headerLabel];

        //Release the things we don't need to hang on to copies of
        [iconImageView   release];
        [headerLabel     release];
        [alertTextLabel  release];
    }
    return self;
}

@end

