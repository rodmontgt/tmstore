//
//  TMLanguage.h
//  TMStore
//
//  Created by Rishabh Jain on 23/07/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Variables.h"

#if ENABLE_KEYBOARD_CHANGE
typedef enum : NSUInteger {
    KEYBOARD_CHANGE_NONE,
    KEYBOARD_CHANGE_NEVER,
    KEYBOARD_CHANGE_LATER
} KEYBOARD_CHANGE;
#endif

@class TMLanguage;

//#define LocalizeDesc(defaultValue, comment) [[TMLanguage sharedManager] addComment:comment]? NSLocalizedString([[TMLanguage sharedManager] getString:defaultValue], nil) : 0
//#define Localize(defaultValue) defaultValue

#define Localize(defaultValue) NSLocalizedString([[TMLanguage sharedManager] getString:defaultValue], nil)

//#define getString(key) NSLocalizedString([[TMLanguage sharedManager] getStringForKey:key], nil)

@interface TMLanguage : NSObject
+ (id)sharedManager;
- (NSString*)getString:(NSString*)defaultValue;
- (NSString*)getStringForKey:(NSString*)key;
- (BOOL)addComment:(NSString*)comment;

- (void)setUserLanguageFromApp:(NSString*)locale;//used only from parse helper
- (void)setUserLanguageFromParse:(NSString*)locale;//used only from parse helper
- (void)setUserLanguageFromParseOld:(NSString*)locale;//used only from parse helper
- (void)setUserLanguage:(NSString*)locale;


- (void)refreshLanguage;
- (BOOL)isUserLanguageSet;
- (void)postNotification:(NSString*)locale;
- (BOOL)isLocalizationVisible;
- (BOOL)isRTLEnabled;
- (BOOL)isLanguageKeyboardEnabled;
#if ENABLE_KEYBOARD_CHANGE
@property int askForLanguageChange;
#endif
- (void)resetAllData;
@end

