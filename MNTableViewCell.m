#import "MNTableViewCell.h"

@implementation MNTableViewCell

@synthesize backgroundImageView, backgroundShadowImageView, iconImageView, headerLabel, alertTextLabel;

-(id)init
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notificationTableCell"];
	if(self != nil)
	{
		CGRect aframe = self.frame;
		self.frame = CGRectMake(aframe.origin.x,aframe.origin.y,290,60);

		backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 287.5, 60.0)];
		backgroundImageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/row_bg.png"];
		
		backgroundShadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 287.5, 60.0)];
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

        //Add everything to our view

		[self addSubview:backgroundImageView];
		[self addSubview:iconImageView];
		[self addSubview:alertTextLabel];
		[self addSubview:headerLabel];
        [self addSubview:backgroundShadowImageView];
		
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