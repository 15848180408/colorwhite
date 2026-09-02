#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

static NSString * const kCWDomain = @"com.chatgpt.coldwhite";
static NSString * const kCWTempKey = @"temperature";
static CFStringRef kCWNotify = CFSTR("com.chatgpt.coldwhite.changed");

extern CGError CGSetDisplayTransferByFormula(CGDirectDisplayID display,
 CGGammaValue redMin, CGGammaValue redMax, CGGammaValue redGamma,
 CGGammaValue greenMin, CGGammaValue greenMax, CGGammaValue greenGamma,
 CGGammaValue blueMin, CGGammaValue blueMax, CGGammaValue blueGamma);
extern CGError CGDisplayRestoreColorSyncSettings(CGDirectDisplayID display);

static CGFloat clampv(CGFloat x, CGFloat a, CGFloat b){ return MIN(MAX(x,a),b); }

static void CWApply(void) {
    NSUserDefaults *d=[[NSUserDefaults alloc] initWithSuiteName:kCWDomain];
    CGFloat t=d ? [d doubleForKey:kCWTempKey] : 0;
    t=clampv(t,-100,100);
    CGDirectDisplayID display=CGMainDisplayID();
    if (fabs(t)<0.01) { CGDisplayRestoreColorSyncSettings(display); return; }
    CGFloat k=t/100.0;
    CGFloat rg=clampv(1.0+0.22*k,0.78,1.22);
    CGFloat bg=clampv(1.0-0.22*k,0.78,1.22);
    CGSetDisplayTransferByFormula(display,0,1,rg,0,1,1,0,1,bg);
}

static void CWNotify(CFNotificationCenterRef c, void *o, CFStringRef n,
                     const void *obj, CFDictionaryRef info) {
    dispatch_async(dispatch_get_main_queue(), ^{ CWApply(); });
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
        NULL, CWNotify, kCWNotify, NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(0.8*NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{ CWApply(); });
}
