#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>

static NSString * const kCWDomain = @"com.chatgpt.coldwhite";
static NSString * const kCWTempKey = @"temperature";
static CFStringRef kCWNotify = CFSTR("com.chatgpt.coldwhite.changed");

static UIWindow *g_overlayWindow = nil;

static CGFloat clampv(CGFloat x, CGFloat a, CGFloat b) {
    return MIN(MAX(x, a), b);
}

static void CWApply(void) {
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:kCWDomain];
    CGFloat t = d ? [d doubleForKey:kCWTempKey] : 0;
    t = clampv(t, -100, 100);

    if (!g_overlayWindow) {
        g_overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        g_overlayWindow.windowLevel = UIWindowLevelAlert + 1000;
        g_overlayWindow.userInteractionEnabled = NO;
        g_overlayWindow.rootViewController = [UIViewController new];
    }

    if (fabs(t) < 0.01) {
        g_overlayWindow.hidden = YES;
        return;
    }

    g_overlayWindow.hidden = NO;
    CGFloat intensity = fabs(t) / 100.0 * 0.18;

    if (t > 0) {
        // 冷色：蓝调
        g_overlayWindow.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:intensity];
    } else {
        // 暖色：橙红调
        g_overlayWindow.backgroundColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:intensity];
    }
}

static void CWNotify(CFNotificationCenterRef c, void *o, CFStringRef n,
                     const void *obj, CFDictionaryRef info) {
    dispatch_async(dispatch_get_main_queue(), ^{ CWApply(); });
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
        NULL, CWNotify, kCWNotify, NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{ CWApply(); });
}
