//
//  UIImageView+LocalizeConstrint.m
//  LocalizeConstraint
#import "UIImageView+LocalizeConstrint.h"
#import "Variables.h"
#import "Utility.h"
@implementation UIImageView (LocalizeConstrint)
- (void)setUIImage:(UIImage *)image {
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        self.transform = CGAffineTransformMakeScale(-1, 1);
    }
    [self setImage:image];
}
@end
