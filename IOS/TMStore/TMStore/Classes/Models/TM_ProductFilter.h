//
//  TM_ProductFilter.h
//  TMStore
//
//  Created by Rishabh Jain on 16/05/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TM_FilterAttribute.h"

@interface TM_ProductFilter : NSObject
@property int categoryId;
@property float minPrice;
@property float maxPrice;
@property float minDiscount;
@property float maxDiscount;

+ (NSMutableArray*)getAll;
- (id)init;
- (void)register;
- (NSMutableArray*)getAttributes;
- (void)addAttribute:(TM_FilterAttribute*)attribute;
+ (TM_ProductFilter*)getForCategory:(int)categoryId;
+ (TM_ProductFilter*)getWithCategoryId:(int)categoryId;
+(BOOL)attribsLoaded;
+(BOOL)attribsLoadedTrue;
+ (void)resetAttributeLoaded;
- (void)registered;
- (void)addPrice:(TM_ProductFilter*)attribute;
@end
