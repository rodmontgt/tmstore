//
//  UIButton+LocalizeConstrint.m
//  LocalizeConstraint
#import "UIButton+LocalizeConstrint.h"
#import "Variables.h"
#import "Utility.h"
@implementation UIButton (LocalizeConstrint)
- (void)setUIImage:(nullable UIImage *)image forState:(UIControlState)state {
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        //    self.transform = CGAffineTransformMakeScale(-1, 1);
        self.imageView.transform = CGAffineTransformMakeScale(-1, 1);
    }
    [self setImage:image forState:state];
}
@end
