#import "MNAlertData.h"

@implementation MNAlertData

@synthesize header, text, bundleID, time;
@synthesize type, status;

-(id)init
{
	self = [super init];
	
	return self;
}

-(id)initWithHeader:(NSString*)_header withText:(NSString*)_title andType:(int)_type forBundleID:(NSString*)_bundleID atTime:(NSDate*)_time ofStatus:(int)_status
{
	self.header = [[NSString alloc] initWithString:_header];
	self.text = [[NSString alloc] initWithString:_title];
	self.bundleID = [[NSString alloc] initWithString:_bundleID];
	self.time = _time;

	self.type = _type;
	self.status = _status;

	return self;
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
	
	return self;
}

@end
