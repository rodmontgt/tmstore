//
//  FeeData.h
//  TMStore
//
//  Created by Rishabh Jain on 03/11/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeeData : NSObject
@property NSString* plugin_title;
@property NSString* label;
@property BOOL taxable;
@property float minorder;
@property float cost;
- (id)init;
+ (NSMutableArray*)getAllFeeData;
+ (void)resetFeeData;
@end
