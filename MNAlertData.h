#define kNewAlertForeground 0
#define kNewAlertBackground 1
#define kOldAlert 2

#define kSMSAlert 0
#define kPushAlert 1

@interface MNAlertData : NSObject <NSCoding>
{
	NSString *header;
	NSString *text;
	int type;
	NSString *bundleID;
	NSDate *time;
	int status;
}

-(id)initWithHeader:(NSString*)_header withText:(NSString*)_title andType:(int)_type forBundleID:(NSString*)_bundleID atTime:(NSDate*)_time ofStatus:(int)_status;
-(id)init;

@property(nonatomic, retain) NSString *header;
@property(nonatomic, retain) NSString *text;
@property(nonatomic) int type;
@property(nonatomic, retain) NSString *bundleID;
@property(nonatomic, retain) NSDate *time;
@property(nonatomic) int status;

@end

