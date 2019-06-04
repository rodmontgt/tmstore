//
//  SellerZoneManager.h
//  TMStore
//
//  Created by Rajshekhar on 05/05/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductInfo.h"
#import "Attribute.h"

@interface SellerZoneManager : NSObject {
}
@property NSMutableArray* myOrders;
@property ProductInfo* tempProduct;
+ (id)getInstance;
@end
