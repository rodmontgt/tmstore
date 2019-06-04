//
//  UITextField+LocalizeConstrint.m
//  LocalizeConstraint
#import "UITextField+LocalizeConstrint.h"
#import "Utility.h"
#import "UIAlertView+NSCookbook.h"
@implementation UITextField (LocalizeConstrint)
- (void)setUIFont:(int)fontType isBold:(BOOL)isBold {
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        self.transform = CGAffineTransformMakeScale(-1, 1);
        self.textAlignment = NSTextAlignmentRight;
    }
    self.font = [Utility getUIFont:fontType isBold:isBold];
}
- (void)setUIFont:(UIFont*)font {
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        self.transform = CGAffineTransformMakeScale(-1, 1);
        self.textAlignment = NSTextAlignmentRight;
    }
    self.font = font;
}

#if ENABLE_KEYBOARD_CHANGE
- (BOOL)isKeyboardAvailable {
    if ([[TMLanguage sharedManager] isLanguageKeyboardEnabled]) {
        BOOL isAvailable = false;
        for (UITextInputMode *inputMode in [UITextInputMode activeInputModes])
        {
            if ([[self langFromLocale:[self localeKey]] isEqualToString:[self langFromLocale:inputMode.primaryLanguage]]) {
                isAvailable = true;
                break;
            }
        }
        return isAvailable;
    }
    return true;
}
- (UITextInputMode *)textInputMode {
    if ([[TMLanguage sharedManager] isLanguageKeyboardEnabled]) {
        for (UITextInputMode *inputMode in [UITextInputMode activeInputModes])
        {
            if ([[self langFromLocale:[self localeKey]] isEqualToString:[self langFromLocale:inputMode.primaryLanguage]]) {
                return inputMode;
            }
        }
        TMLanguage* tmLanguage = [TMLanguage sharedManager];
        switch (tmLanguage.askForLanguageChange) {
            case KEYBOARD_CHANGE_LATER:
                break;
            case KEYBOARD_CHANGE_NEVER:
                break;
            default:{
                NSString* selectedLocale = [[NSUserDefaults standardUserDefaults] valueForKey:USER_LOCALE];
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Add New Keyboards..." message:[NSString stringWithFormat:@"Add %@ keyboard from Settings.", [[Addons sharedManager] getTitleForLocale:selectedLocale]] delegate:nil cancelButtonTitle:@"Ask me later" otherButtonTitles:@"Ok", @"No, thanks", nil];
                [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    switch (buttonIndex) {
                        case 0:
                        {
                            tmLanguage.askForLanguageChange = KEYBOARD_CHANGE_LATER;
                            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:tmLanguage.askForLanguageChange] forKey:@"askForLanguageChange"];
                        }break;
                        case 1:
                        {
                            tmLanguage.askForLanguageChange = KEYBOARD_CHANGE_NONE;
                            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:tmLanguage.askForLanguageChange] forKey:@"askForLanguageChange"];
                            // IOS 11 update : Pallavi
//                            NSURL *url = [NSURL URLWithString:@"prefs:root=General&path=Keyboard/KEYBOARDS"];
//                            RLOG(@"OpenURL_A");
//                            if ([[UIApplication sharedApplication] canOpenURL:url]) {
//                                [[UIApplication sharedApplication] openURL:url];
//                            }
                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

                            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                            }
                            RLOG(@"	");
                        }break;
                        case 2:
                        {
                            tmLanguage.askForLanguageChange = KEYBOARD_CHANGE_NEVER;
                            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:tmLanguage.askForLanguageChange] forKey:@"askForLanguageChange"];
                        }break;
                            
                        default:
                            break;
                    }
                }];
            }break;
        }
        RLOG(@"OpenURL_C");
    }
    return [super textInputMode];
}
- (NSString*)localeKey {
    NSArray* lang = [[NSUserDefaults standardUserDefaults]objectForKey:@"AppleLanguages"];
    NSString* currentLang = lang[0];
    return currentLang;
}
- (NSString *)langFromLocale:(NSString *)locale {
    NSRange r = [locale rangeOfString:@"_"];
    if (r.length == 0) r.location = locale.length;
    NSRange r2 = [locale rangeOfString:@"-"];
    if (r2.length == 0) r2.location = locale.length;
    return [[locale substringToIndex:MIN(r.location, r2.location)] lowercaseString];
}
#endif
@end
