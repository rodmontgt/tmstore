//
//  LineItem.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductInfo.h"
#import "Variation.h"

@interface ProductMetaItemProperties : NSObject

@property NSString *_key;
@property NSString *_label;
@property NSString *_value;

@end

@interface LineItem : NSObject

@property int _id;
@property float _subtotal;
@property float _subtotal_tax;
@property float _total;
@property float _total_tax;
@property float _price;
@property int _quantity;
@property NSString *_tax_class;
@property NSString *_name;
@property int _product_id;
@property NSString *_sku;
@property NSMutableArray *_meta;//Array of ProductMetaItemProperties

- (id)init;
+ (void)setLineItemProductImgUrls:(NSMutableDictionary*)dict;//used from appuser
//for showing in order screen
+ (void)setImgUrlOnProductId:(int)productId imgUrl:(NSString*)imgUrl;
+ (NSString*)getImgUrlOnProductId:(int)productId;

@end
