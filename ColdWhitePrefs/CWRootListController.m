#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface CWRootListController : PSListController
@end

@implementation CWRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [NSMutableArray array];
    }
    return _specifiers;
}

@end
