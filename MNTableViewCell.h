#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface MNTableViewCell : UITableViewCell
{
    UIImageView *iconImageView;
    UILabel *headerLabel;
    UILabel *alertTextLabel;

    UIImageView *backgroundImageView;
    UIImageView *backgroundShadowImageView;
}

@property(nonatomic,retain) UIImageView *backgroundImageView;
@property(nonatomic,retain) UIImageView *backgroundShadowImageView;
@property(nonatomic,retain) UIImageView *iconImageView;
@property(nonatomic,retain) UILabel *headerLabel;
@property(nonatomic,retain) UILabel *alertTextLabel;

@end

