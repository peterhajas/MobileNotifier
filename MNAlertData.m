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

//Yay NSCoder!

-(void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:header forKey:@"header"];
	[encoder encodeObject:text forKey:@"text"];
	[encoder encodeInt:type forKey:@"type"];
	[encoder encodeObject:bundleID forKey:@"bundleID"];
	[encoder encodeObject:time forKey:@"time"];
	[encoder encodeInt:status forKey:@"status"];
}

-(id)initWithCoder:(NSCoder*)decoder
{
	header = [[decoder decodeObjectForKey:@"header"] retain];
	text = [[decoder decodeObjectForKey:@"text"] retain];
	type = [decoder decodeIntForKey:@"type"];
	bundleID = [[decoder decodeObjectForKey:@"bundleID"] retain];
	time = [[decoder decodeObjectForKey:@"time"] retain];
	status = [decoder decodeIntForKey:@"status"];
}

@end
