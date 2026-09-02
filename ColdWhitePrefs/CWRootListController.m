#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <CoreFoundation/CoreFoundation.h>

@interface CWRootListController : PSListController
@end

@implementation CWRootListController
- (NSArray *)specifiers {
    if (!_specifiers) {
        PSSpecifier *g=[PSSpecifier preferenceSpecifierNamed:@"Cold White"
            target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [g setProperty:@"右侧 = 更冷，左侧 = 更暖，0 = 原厂。" forKey:@"footerText"];

        PSSpecifier *s=[PSSpecifier preferenceSpecifierNamed:@"色温"
            target:self set:@selector(setTemperature:specifier:)
            get:@selector(getTemperature:) detail:nil cell:PSSliderCell edit:nil];
        [s setProperty:@(-100.0) forKey:@"min"];
        [s setProperty:@(100.0) forKey:@"max"];
        [s setProperty:@(0.0) forKey:@"default"];
        [s setProperty:@"com.chatgpt.coldwhite" forKey:@"defaults"];
        [s setProperty:@"temperature" forKey:@"key"];
        [s setProperty:@YES forKey:@"showValue"];

        PSSpecifier *r=[PSSpecifier preferenceSpecifierNamed:@"恢复原厂"
            target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
        [r setProperty:@"resetTemperature" forKey:@"action"];
        _specifiers = [NSMutableArray arrayWithObjects:g, s, r, nil];
    }
    return _specifiers;
}
- (id)getTemperature:(PSSpecifier *)s {
    NSUserDefaults *d=[[NSUserDefaults alloc] initWithSuiteName:@"com.chatgpt.coldwhite"];
    return @([d doubleForKey:@"temperature"]);
}
- (void)setTemperature:(id)v specifier:(PSSpecifier *)s {
    NSUserDefaults *d=[[NSUserDefaults alloc] initWithSuiteName:@"com.chatgpt.coldwhite"];
    [d setDouble:[v doubleValue] forKey:@"temperature"]; [d synchronize];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
        CFSTR("com.chatgpt.coldwhite.changed"),NULL,NULL,true);
}
- (void)resetTemperature {
    NSUserDefaults *d=[[NSUserDefaults alloc] initWithSuiteName:@"com.chatgpt.coldwhite"];
    [d setDouble:0 forKey:@"temperature"]; [d synchronize];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
        CFSTR("com.chatgpt.coldwhite.changed"),NULL,NULL,true);
    [self reloadSpecifiers];
}
@end
