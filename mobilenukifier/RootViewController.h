@interface RootViewController: UIViewController 
{
	UIButton *doIt;
}

- (void)detonate:(id)sender;

@property (nonatomic, retain) UIButton *doIt;

@end
