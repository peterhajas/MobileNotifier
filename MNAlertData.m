#import "MNAlertData.h"

@implementation MNAlertData

@synthesize header, text, bundleID, time;
@synthesize type, status;

-(id)initWithHeader:(NSString*)_header withText:(NSString*)_title andType:(int)_type forBundleID:(NSString*)_bundleID atTime:(NSDate*)_time ofStatus:(int)_status
{
	self.header = _header;
	self.text = _text;
	self.bundleID = _bundleID;
	self.time = _time;

	self.type = _type;
	self.status = _status;
}
