//
//  UIView+LocalizeConstrint.m
//  LocalizeConstraint
#import "UIView+LocalizeConstrint.h"
#import "Variables.h"
#import "Utility.h"
#import <UIKit/UIKit.h>
@implementation UIView (LocalizeConstrint)
- (void)resizeToFitSubviews {
    float w = 0;
    float h = 0;
    
    for (UIView *v in [self subviews]) {
        float fw = v.frame.origin.x + v.frame.size.width;
        float fh = v.frame.origin.y + v.frame.size.height;
        w = MAX(fw, w);
        h = MAX(fh, h);
    }
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, w, h)];
}
@end
