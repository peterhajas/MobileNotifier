int main(int argc, char **argv) {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	int ret = UIApplicationMain(argc, argv, @"MobileNukifierApplication", @"MobileNukifierApplication");
	[p drain];
	return ret;
}

// vim:ft=objc
