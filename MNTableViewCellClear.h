#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface MNTableViewCellClear : UITableViewCell
{
    UIImageView *iconImageView;
    UILabel *headerLabel;
    UILabel *alertTextLabel;
}

@property(nonatomic,retain) UIImageView *iconImageView;
@property(nonatomic,retain) UILabel *headerLabel;
@property(nonatomic,retain) UILabel *alertTextLabel;

@end
