//
//  CartMatchedItem.h
//  TMStore
//
//  Created by Rishabh Jain on 08/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Variables.h"
@interface CartMatchedItem : NSObject
@property int productId;
@property NSString* title;
@property float price;
@property NSString* imgUrl;
@property int quantity;
@property id product;

@property UILabel* labelQty;
@property UILabel* labelPrice;

- (float)getTotalPrice;
- (id)init;
@end