//
//  VariationAttribute.h
//  WooMobil
//
//  Created by Rishabh Jain on 02/02/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VariationAttribute : NSObject <NSCoding>
@property NSString *name;
@property NSString *slug;
@property NSString *value;
@property float extraPrice;
- (BOOL)isEqual:(VariationAttribute*)other;
@end
