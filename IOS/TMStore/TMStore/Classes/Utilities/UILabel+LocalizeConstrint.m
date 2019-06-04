//
//  UILabelController+LocalizeConstrint.m
//  LocalizeConstraint
#import "UILabel+LocalizeConstrint.h"
#import "Variables.h"
#import "Utility.h"
@implementation UILabel (LocalizeConstrint)
- (void)sizeToFitUI {
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        self.transform = CGAffineTransformMakeScale(1, 1);
    }
    [self sizeToFit];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        self.transform = CGAffineTransformMakeScale(-1, 1);
    }
}
- (void)setUIFont:(int)fontType isBold:(BOOL)isBold {
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        self.transform = CGAffineTransformMakeScale(-1, 1);
    }
    self.font = [Utility getUIFont:fontType isBold:isBold];
}
- (void)setUIFont:(UIFont*)font {
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        self.transform = CGAffineTransformMakeScale(-1, 1);
    }
    self.font = font;
}
- (void)setUIAttributedText:(NSAttributedString*)text {
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        self.transform = CGAffineTransformMakeScale(-1, 1);
        self.textAlignment = NSTextAlignmentRight;
    }
    [self setAttributedText:text];
}
@end
