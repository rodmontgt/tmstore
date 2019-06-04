//
//  UIViewController+LocalizeConstrint.h
//  LocalizeConstraint


#import <UIKit/UIKit.h>

@interface UILabel (LocalizeConstrint)
- (void)setUIFont:(int)fontType isBold:(BOOL)isBold;
- (void)setUIFont:(UIFont*)font;
- (void)sizeToFitUI;
- (void)setUIAttributedText:(NSAttributedString*)text;
@end
