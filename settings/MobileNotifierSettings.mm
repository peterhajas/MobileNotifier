#import <Preferences/Preferences.h>

@interface MobileNotifierSettingsListController: PSListController {}
@end

@implementation MobileNotifierSettingsListController
- (id)specifiers
{
    if (_specifiers == nil)
    {
        _specifiers = [[self loadSpecifiersFromPlistName:@"MobileNotifierSettings" target:self] retain];
    }
    return _specifiers;
}
@end

// vim:ft=objc

