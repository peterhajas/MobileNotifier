#import "MNTableViewCell.h"

@implementation MNTableViewCell

@synthesize backgroundImageView, backgroundShadowImageView, iconImageView, headerLabel, alertTextLabel;

-(id)init
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notificationTableCell"];
	if(self != nil)
	{
    CGRect frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,290,60);

		backgroundImageView = [[UIImageView alloc] initWithFrame:frame];
		backgroundImageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/row_bg.png"];
		
		backgroundShadowImageView = [[UIImageView alloc] initWithFrame:frame];
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

        //Add everything to the table view cell
        [self.contentView addSubview:backgroundImageView];
        [self.contentView addSubview:iconImageView];
        [self.contentView addSubview:alertTextLabel];
        [self.contentView addSubview:headerLabel];
        [self.contentView addSubview:backgroundShadowImageView];
		
        self.clipsToBounds = YES;
        
        //Release the things we don't need to hang on to copies of
        
        [backgroundImageView            release];
        [backgroundShadowImageView      release]; 
        [iconImageView                  release]; 
        [headerLabel                    release]; 
        [alertTextLabel                 release]; 
        
	}
	return self;
}

@end