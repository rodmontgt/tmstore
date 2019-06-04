//
//  TM_Bundle.h
//  TMStore
//
//  Created by Rishabh Jain on 05/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Variables.h"

@interface TM_Bundle : NSObject
@property id product;
@property int productId;
@property BOOL hide_thumbnail;
@property BOOL override_title;
@property BOOL override_description;
@property BOOL optional;
@property int bundle_quantity;
@property float bundle_discount;
@property BOOL visibility;
- (id)init;
@end


