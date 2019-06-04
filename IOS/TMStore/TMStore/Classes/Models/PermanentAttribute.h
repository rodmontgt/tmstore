//
//  PermanentAttribute.h
//  TMStore
//
//  Created by Rishabh Jain on 03/10/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface PermanentAttribute : NSObject
@property NSString* slug;
@property NSMutableDictionary* terms;
- (id)init;
+ (NSMutableArray*)getAllPermanentAttributes;
+ (NSString*)resetOption:(NSString*)slug option:(NSString*)option;
@end
