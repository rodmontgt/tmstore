//
//  Coupon.h
//  TMStore
//
//  Created by Rishabh Jain on 08/04/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Coupon : NSObject
@property int _id;
@property NSString* _code;
@property NSString* _type;
@property NSString* _created_at;
@property NSString* _updated_at;
@property float _amount;
@property BOOL _individual_use;
@property NSMutableArray* _product_ids;
@property NSMutableArray* _exclude_product_ids;
@property int _usage_limit;
@property int _usage_limit_per_user;
@property int _limit_usage_to_x_items;
@property int _usage_count;
@property NSString* _expiry_dateStr;
@property NSDate* _expiry_date;
@property BOOL _enable_free_shipping;
@property NSMutableArray* _product_category_ids;
@property NSMutableArray* _exclude_product_category_ids;
@property BOOL _exclude_sale_items;
@property float _minimum_amount;
@property float _maximum_amount;
@property NSMutableArray* _customer_emails;
@property NSString* _description;
@property BOOL shouldAddThisCoupon;

@property float _couponDiscountOnApply;//temporary

- (id)init;
- (BOOL)applicableForId:(int)productId isProductOnSale:(BOOL)isProductOnSale;
- (NSString*)verify:(NSMutableArray*)selectedProductIds selectedCategoryIds:(NSMutableArray*)selectedCategoryIds userEmail:(NSString*)userEmail
       total_amount:(float)total_amount selectedProductVariations:(NSMutableArray*)selectedProductVariations;
- (void)register;
+ (NSMutableArray*)getAllCoupons;
+ (Coupon*)getWithCode:(NSString*)couponCode;
-(NSMutableArray*)getcouponList;
+ (id)sharedInstance;
@end
