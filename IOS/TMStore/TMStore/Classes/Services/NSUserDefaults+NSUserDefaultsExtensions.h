//
//  NSUserDefaults+NSUserDefaultsExtensions.h
//  WooMobil
//
//  Created by Virat Khutal on 14/12/15.
//  Copyright © 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (NSUserDefaultsExtensions)

- (void)saveCustomObject:(id<NSCoding>)object
                     key:(NSString *)key;
- (id<NSCoding>)loadCustomObjectWithKey:(NSString *)key;

@end
