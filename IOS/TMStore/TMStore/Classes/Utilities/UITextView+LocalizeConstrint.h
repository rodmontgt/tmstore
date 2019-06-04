//
//  UITextField+LocalizeConstrint.h
//  LocalizeConstraint


#import <UIKit/UIKit.h>
#import "Variables.h"


@interface UITextView (LocalizeConstrint)
- (void)setUIFont:(int)fontType isBold:(BOOL)isBold;
- (void)setUIFont:(UIFont*)font;
#if ENABLE_KEYBOARD_CHANGE
- (BOOL)isKeyboardAvailable;
#endif
@end
