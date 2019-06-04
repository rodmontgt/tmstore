//
//  NSUserDefaults+NSUserDefaultsExtensions.m
//  WooMobil
//
//  Created by Virat Khutal on 14/12/15.
//  Copyright © 2015 Twist Mobile. All rights reserved.
//

#import "NSUserDefaults+NSUserDefaultsExtensions.h"


@implementation NSUserDefaults (NSUserDefaultsExtensions)


- (void)saveCustomObject:(id<NSCoding>)object
                     key:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    [self setObject:encodedObject forKey:key];
    [self synchronize];
    
}

- (id<NSCoding>)loadCustomObjectWithKey:(NSString *)key {
    NSData *encodedObject = [self objectForKey:key];
    id<NSCoding> object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
    
    NSData *notesData = [[NSUserDefaults standardUserDefaults] objectForKey:@"notes"];
    NSArray *notes = [NSKeyedUnarchiver unarchiveObjectWithData:notesData];
}

@end