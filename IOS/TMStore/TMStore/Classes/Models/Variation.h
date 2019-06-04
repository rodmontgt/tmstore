//
//  Variation.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dimension.h"
#import "VariationAttribute.h"

@interface Variation : NSObject

@property int _id;
@property int _stock_quantity;
@property int _download_limit;
@property int _download_expiry;
@property NSDate *_created_at;
@property NSDate *_updated_at;
@property NSString *_permalink;
@property NSString *_sku;
@property NSString *_tax_status;
@property NSString *_tax_class;
@property NSString *_shipping_class;
@property NSString *_shipping_class_id;
@property float _price;
@property float _regular_price;
@property float _sale_price;
@property float _priceOriginal;

@property float price_clone;
@property float regular_price_clone;
@property float sale_price_clone;

@property float _regular_priceOriginal;
@property float _sale_priceOriginal;
@property BOOL _downloadable;
@property BOOL _virtual;
@property BOOL _taxable;
@property BOOL _managing_stock;
@property BOOL _in_stock;
@property BOOL _backordered;
@property BOOL _purchaseable;
@property BOOL _visible;
@property BOOL _on_sale;
@property Dimension *_dimensions;
@property NSMutableArray *_images;//Array of ProductImage
@property NSMutableArray *_attributes;//Array of Attribute
@property NSMutableArray *_downloads;//Array of NSString
//sale_price_dates_from
//sale_price_dates_to
@property float _weight;
@property int _variation_index;

@property int rewardPoints;

- (id)init;
- (void)clonePrice;
- (BOOL)equals:(Variation*)other;
- (BOOL)compareAttributes:(NSMutableArray*)other_attibutes;
- (NSString*)getAttributeString;
- (id)cloneMe;

- (BOOL)hasOptionForAttribute:(NSString*)attribName option:(NSString*)option;
- (VariationAttribute*)getWithName:(NSString*)name;
@end
