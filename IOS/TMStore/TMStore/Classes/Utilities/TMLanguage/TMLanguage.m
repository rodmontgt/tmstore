//
//  TMLanguage.m
//  TMStore
//
//  Created by Rishabh Jain on 23/07/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "TMLanguage.h"
#import "TMLanguageKeys.h"
#import "Variables.h"
#import "ParseHelper.h"
#import "Addons.h"
@implementation TMLanguage
static TMLanguage *sharedManagerObj = nil;

static NSMutableArray *requiredStringsArray = nil;
static NSMutableDictionary *requiredStringsDict = nil;

static NSMutableDictionary *keyForStrings = nil;

static NSMutableDictionary *valueForKey_App = nil;
static NSMutableDictionary *valueForKey_Parse = nil;
static NSMutableDictionary *valueForKey_ParseOld = nil;

static NSString *requiredComment = @"";

static bool isRTL = false;
static bool isLangKeyboard = false;

+ (id)sharedManager {
    if (sharedManagerObj == nil){
        sharedManagerObj = [[self alloc] init];
        
        [sharedManagerObj setRTLValue:[[[NSUserDefaults standardUserDefaults] valueForKey:SET_RTL_VALUE] boolValue]];
        [sharedManagerObj setLangKeyboardValue:[[[NSUserDefaults standardUserDefaults] valueForKey:SET_KEYBOARD_VALUE] boolValue]];
        
        if ([[TMLanguage sharedManager] isLanguageKeyboardEnabled]) {
#if ENABLE_KEYBOARD_CHANGE
            sharedManagerObj.askForLanguageChange = KEYBOARD_CHANGE_NONE;
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"askForLanguageChange"]) {
                sharedManagerObj.askForLanguageChange = [[[NSUserDefaults standardUserDefaults] valueForKey:@"askForLanguageChange"] intValue];
            }
            if (sharedManagerObj.askForLanguageChange == KEYBOARD_CHANGE_LATER) {
                sharedManagerObj.askForLanguageChange = KEYBOARD_CHANGE_NONE;
            }
#endif
        }
        
        //generate new string for which key is required
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"RequiredStrings"]) {
            requiredStringsArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"RequiredStrings"]];
        }else {
            requiredStringsArray = [[NSMutableArray alloc] init];
        }
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"RequiredKeyValues"]) {
            requiredStringsDict = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:@"RequiredKeyValues"]];
        }else {
            requiredStringsDict = [[NSMutableDictionary alloc] init];
        }
        
        
        //
        NSDictionary *dictRoot = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"KeyValues" ofType:@"plist"]];
        if (IS_NOT_NULL(dictRoot, @"RequiredKeyValues")) {
            keyForStrings = GET_VALUE_OBJECT(dictRoot, @"RequiredKeyValues");
        }
        
        
    }
    return sharedManagerObj;
}
- (void)setUserLanguageFromApp:(NSString*)locale {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:locale ofType:@"json"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (fileExists) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data) {
            NSError *parsingError;
            NSMutableDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parsingError];
            if (parsingError) {
                RLOG(@"parsingError = %@", parsingError);
                
                NSData *badJSON = data;
                NSString *dataAsString = [NSString stringWithUTF8String:[badJSON bytes]];
                NSString *correctedJSONString = [NSString stringWithString:[dataAsString substringWithRange:NSMakeRange (0, dataAsString.length)]];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
                NSData *correctedData = [correctedJSONString dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error = nil;
                NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:correctedData options:NSJSONReadingAllowFragments error:&error];
                if (error) {
                    RLOG(@"parsingError = %@", parsingError);
                } else {
                    valueForKey_App = json;
                    RLOG(@"valueForKey_Parse = %@", valueForKey_App);
                }
            }else{
                NSData *badJSON = data;
                NSString *dataAsString = [NSString stringWithUTF8String:[badJSON bytes]];
                NSString *correctedJSONString = [NSString stringWithString:[dataAsString substringWithRange:NSMakeRange (0, dataAsString.length)]];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
                NSData *correctedData = [correctedJSONString dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error = nil;
                NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:correctedData options:NSJSONReadingAllowFragments error:&error];
                if (error) {
                    RLOG(@"parsingError = %@", parsingError);
                } else {
                    valueForKey_App = json;
                RLOG(@"valueForKey_App = %@", valueForKey_App);
                }
            }
        }
    }
}
- (void)setUserLanguageFromParse:(NSString*)locale {
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *filePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", locale]]];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (fileExists) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data) {
            NSError *parsingError;
            NSMutableDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parsingError];
            if (parsingError) {
                RLOG(@"parsingError = %@", parsingError);
                
                NSData *badJSON = data;
                NSString *dataAsString = [NSString stringWithUTF8String:[badJSON bytes]];
                NSString *correctedJSONString = [NSString stringWithString:[dataAsString substringWithRange:NSMakeRange (0, dataAsString.length)]];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
                NSData *correctedData = [correctedJSONString dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error = nil;
                NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:correctedData options:NSJSONReadingAllowFragments error:&error];
                if (error) {
                    RLOG(@"parsingError = %@", parsingError);
                } else {
                    valueForKey_Parse = json;
                    //RLOG(@"valueForKey_Parse = %@", valueForKey_Parse);
                }
            } else {
                NSData *badJSON = data;
                NSString *dataAsString = [NSString stringWithUTF8String:[badJSON bytes]];
                NSString *correctedJSONString = [NSString stringWithString:[dataAsString substringWithRange:NSMakeRange (0, dataAsString.length)]];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
                NSData *correctedData = [correctedJSONString dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error = nil;
                NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:correctedData options:NSJSONReadingAllowFragments error:&error];
                if (error) {
                    RLOG(@"parsingError = %@", parsingError);
                } else {
                    valueForKey_Parse = json;
                    //RLOG(@"valueForKey_Parse = %@", valueForKey_Parse);
                }
            }
        }
    }
}
- (void)setUserLanguageFromParseOld:(NSString*)locale {
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *filePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Old.json", locale]]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (fileExists) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data) {
            NSError *parsingError;
            NSMutableDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parsingError];
            if (parsingError) {
                RLOG(@"parsingError = %@", parsingError);
                
                NSData *badJSON = data;
                NSString *dataAsString = [NSString stringWithUTF8String:[badJSON bytes]];
                NSString *correctedJSONString = [NSString stringWithString:[dataAsString substringWithRange:NSMakeRange (0, dataAsString.length)]];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
                NSData *correctedData = [correctedJSONString dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error = nil;
                NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:correctedData options:NSJSONReadingAllowFragments error:&error];
                if (error) {
                    RLOG(@"parsingError = %@", parsingError);
                } else {
                    valueForKey_ParseOld = json;
                    //RLOG(@"valueForKey_Parse = %@", valueForKey_ParseOld);
                }
            }else{
                NSData *badJSON = data;
                NSString *dataAsString = [NSString stringWithUTF8String:[badJSON bytes]];
                NSString *correctedJSONString = [NSString stringWithString:[dataAsString substringWithRange:NSMakeRange (0, dataAsString.length)]];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
                correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
                NSData *correctedData = [correctedJSONString dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error = nil;
                NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:correctedData options:NSJSONReadingAllowFragments error:&error];
                if (error) {
                    RLOG(@"parsingError = %@", parsingError);
                } else {
                    valueForKey_ParseOld = json;
                    //RLOG(@"valueForKey_ParseOld = %@", valueForKey_ParseOld);
                }
            }
        }
    }
}
- (void)setUserLanguage:(NSString*)locale {
    Addons* addons = [Addons sharedManager];
    if (addons.language && addons.language.locales && [addons.language.locales count] > 0) {
        for (int i = 0; i < (int)[addons.language.locales count]; i++) {
            if ([addons.language.locales[i] isEqualToString:locale]) {
                if([addons.language.isDownloaded[i] boolValue]) {
                    [self setUserLanguageFromApp:locale];
                    [self setUserLanguageFromParse:locale];
                    [self setUserLanguageFromParseOld:locale];
                    if ([addons.language.isRTLNeeded count] > i) {
                        [self setRTLValue:[addons.language.isRTLNeeded[i] boolValue]];
                    }else {
                        [self setRTLValue:false];
                    }
                    [self setLangKeyboardValue:addons.language.isLanguageKeyboardNeeded];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LANGUAGE_CHANGED" object:nil];
                }
                else {
                    [self setUserLanguageFromApp:locale];
                    [self setUserLanguageFromParse:locale];
                    [self setUserLanguageFromParseOld:locale];
                    if ([addons.language.isRTLNeeded count] > i) {
                        [self setRTLValue:[addons.language.isRTLNeeded[i] boolValue]];
                    }else {
                        [self setRTLValue:false];
                    }
                    [self setLangKeyboardValue:addons.language.isLanguageKeyboardNeeded];
                    
                    
                    
                    [[ParseHelper sharedManager] downloadLanguageFile:locale];
                }
                break;
            }
        }
    }
}

- (void)postNotification:(NSString*)locale {
    Addons* addons = [Addons sharedManager];
    if (addons.language && addons.language.locales && [addons.language.locales count] > 0) {
        for (int i = 0; i < (int)[addons.language.locales count]; i++) {
            if ([addons.language.locales[i] isEqualToString:locale] && [addons.language.isDownloaded[i] boolValue]) {
                [self setUserLanguageFromApp:locale];
                [self setUserLanguageFromParse:locale];
                [self setUserLanguageFromParseOld:locale];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LANGUAGE_CHANGED" object:nil];
            }
        }
    }
}
- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}
- (BOOL)addComment:(NSString*)comment {
    requiredComment = comment;
    return true;
}
- (NSString*)getString:(NSString*)defaultValue {
    //generate new strings for which keys are required.
    requiredComment= @"";
    
    if ([defaultValue isEqualToString:@"login_failed"]) {
        NSLog(@"bug mila");
    }
    
//    if (![requiredStringsArray containsObject:defaultValue]) {
//        [requiredStringsArray addObject:defaultValue];
//        [requiredStringsDict setValue:@"" forKey:defaultValue];
//        [self saveRequiredStrings];
//    }
    
    if (IS_NOT_NULL(keyForStrings, defaultValue) && ![[keyForStrings valueForKey:defaultValue] isEqualToString:@""])
    {
        NSString* key = defaultValue;//[keyForStrings valueForKey:defaultValue];
        
        if (valueForKey_Parse && IS_NOT_NULL(valueForKey_Parse, key) && ![[valueForKey_Parse valueForKey:key] isEqualToString:@""]) {
            return [valueForKey_Parse valueForKey:key];
        }
        if (valueForKey_ParseOld && IS_NOT_NULL(valueForKey_ParseOld, key) && ![[valueForKey_ParseOld valueForKey:key] isEqualToString:@""]) {
            return [valueForKey_ParseOld valueForKey:key];
        }
        if (valueForKey_App && IS_NOT_NULL(valueForKey_App, key) && ![[valueForKey_App valueForKey:key] isEqualToString:@""]) {
            return [valueForKey_App valueForKey:key];
        }
    }
    
    NSString* str = [keyForStrings valueForKey:defaultValue];
    if (str != nil && ![str isEqualToString:@""]) {
        return str;
    }
    
    return defaultValue;
}
//-(NSString *)getStringForKey:(NSString *)key {
//    if (IS_NOT_NULL(keyForStrings, key) && ![[keyForStrings valueForKey:key] isEqualToString:@""]){
//        return [keyForStrings valueForKey:key];
//    }
//
//    if (valueForKey_Parse && IS_NOT_NULL(valueForKey_Parse, key) && ![[valueForKey_Parse valueForKey:key] isEqualToString:@""]) {
//        return [valueForKey_Parse valueForKey:key];
//    }
//    return @"";
//}
- (void)saveRequiredStrings {
    [[NSUserDefaults standardUserDefaults] setObject:requiredStringsArray forKey:@"RequiredStrings"];
    [[NSUserDefaults standardUserDefaults] setObject:requiredStringsDict forKey:@"RequiredKeyValues"];
}
- (void)refreshLanguage {
    Addons* addons = [Addons sharedManager];
    if (addons.language && (int)[addons.language.locales count] > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:addons.language.defaultLocale forKey:DEFAULT_LOCALE];
        NSString* languageLocale = addons.language.defaultLocale;
        if ([self isUserLanguageSet]) {
            languageLocale = [[NSUserDefaults standardUserDefaults] valueForKey:USER_LOCALE];
        }
        [self setUserLanguage:languageLocale];
    }
}
- (void)resetAllData {
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:DEFAULT_LOCALE];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:USER_LOCALE];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:USER_LOCAL_TITLE];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:false] forKey:SET_RTL_VALUE];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:VENDOR_ID];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:VENDOR_NAME];
}
- (BOOL)isUserLanguageSet{
    Addons* addons = [Addons sharedManager];
    if (addons.language && (int)[addons.language.locales count] > 0) {
        if ([[NSUserDefaults standardUserDefaults] valueForKey:USER_LOCALE] != nil) {
            if (![[[NSUserDefaults standardUserDefaults] valueForKey:USER_LOCALE] isEqualToString:@""]) {
                return true;
            }
        }
        return false;
    }
    return true;
}
- (BOOL)isLocalizationVisible{
    Addons* addons = [Addons sharedManager];
    if (addons.language && (int)[addons.language.locales count] > 1) {
        return true;
    }
    return false;
}
- (void)setRTLValue:(BOOL)value{
    isRTL = value;
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:isRTL] forKey:SET_RTL_VALUE];
}
- (BOOL)isRTLEnabled {
    return isRTL;
}
- (void)setLangKeyboardValue:(BOOL)value{
    isLangKeyboard = value;
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:isLangKeyboard] forKey:SET_KEYBOARD_VALUE];
}
- (BOOL)isLanguageKeyboardEnabled {
    return isLangKeyboard;
}



@end
