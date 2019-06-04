//
//  Cart.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 02/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductInfo.h"
#import "Coupon.h"
#import "CartBundleItem.h"
#import "CartMatchedItem.h"
#import "TM_ProductDeliveryDate.h"
enum PRODUCT_QTY {
    PRODUCT_QTY_INVALID,
    PRODUCT_QTY_ZERO,
    PRODUCT_QTY_STOCK,
    PRODUCT_QTY_DEMAND
};


@interface Cart : NSObject <NSCoding>
@property int product_id;
@property int count;
@property int selectedVariationId;
@property int selectedVariationIndex;
@property ProductInfo* product;
@property NSMutableArray* selected_attributes;//basicAttributes
@property float discountTotal;
@property float discountTotalExcludingTax;
@property float originalTotal;
@property float originalTotalExcludingTax;
@property NSString* productName;
@property NSString* productImgUrl;
@property float productPrice;
@property NSString* note;
@property NSMutableArray* mMixMatchProducts;//array of TM_SubProducts
@property NSMutableArray* mBundleProducts;//array of TM_SubProducts
@property float taxOnProduct;
@property TM_PRDD_Day* prddDay;
@property TM_PRDD_Time* prddTime;
@property NSString* prddDate;
//@property NSString* prddTimeStr;
+ (void)refresh;
+ (float)getTotalPayment;
+ (float)getTotalPaymentExclusiveOfCoupons;
+ (float)getTotalSavings;
+ (NSMutableArray*)getAll;//ARRAY OF Cart
+ (int)getItemCount;
+ (void)prepareCart;
+ (void)removeProduct:(ProductInfo*)product variationId:(int)variationId variationIndex:(int)variationIndex;
+ (BOOL)hasItem:(ProductInfo*)product variationId:(int)variationId variationIndex:(int)variationIndex;
+ (void)removeSafely:(Cart*)cart;
+ (void)printAll;
- (id)initWithParameters:(int)product_id product:(ProductInfo *)product variationId:(int)variationId variationIndex:(int)variationIndex;
+ (void)setCartArray:(NSMutableArray*)array;
- (int)getProductAvailibleState:(int)userDemand;
- (int)getProductAvailibleQuantity:(int)userDemand;
+ (int)getProductAvailibleState:(ProductInfo*)pInfo variationId:(int)variationId;
+ (void)removeAllProduct;
//coupons
+ (NSString*) addCoupon:(Coupon*) coupon;
+ (void) removeCoupon:(int) couponId;
+ (BOOL) isAnyCouponApplied;
+ (float) getTotalCouponBenefits:(float) totalCartPayment;
+ (void) clearCoupons;
+ (NSMutableArray*)getAppliedCoupons;

+ (int)getNotificationItemCount;
+ (void)resetNotificationItemCount;
+ (BOOL)hasItemCheckViaProductIdOnly:(ProductInfo*)product;
+ (Cart*)getCartFromProduct:(ProductInfo*)product variationId:(int)variationId variationIndex:(int)variationIndex;
- (float)getCartTotal;

+ (NSString*)getOrderNote;
+ (NSString*)getOrderNoteCartItems;
+ (NSString*)getOrderNoteCart;
+ (NSString*)getOrderNoteOrder;
+ (void)setOrderNoteCart:(NSString*)noteStr;
+ (void)setOrderNoteOrder:(NSString*)noteStr;
+ (void)resetOrderNotes;
+ (float)getTotalWeight:(float)shippingMinWeight shippingDefaultWeight:(float)shippingDefaultWeight;
+ (void) setPointsPriceDiscount:(float) pointsPriceDiscount;
+ (float) getPointsPriceDiscount;
+ (void) removePointsPriceDiscount;
+ (Cart*)removeProduct:(ProductInfo*)product variationId:(int)variationId variationIndex:(int)variationIndex selectedVariationAttributes:(NSMutableArray*)selectedVariationAttributes;
+ (Cart*)hasProduct:(ProductInfo*)product variationId:(int)variationId variationIndex:(int)variationIndex selectedVariationAttributes:(NSMutableArray*)selectedVariationAttributes;

+ (Cart*)addProduct:(ProductInfo*)product
        variationId:(int)variationId
     variationIndex:(int)variationIndex
selectedVariationAttributes:(NSMutableArray*)selectedVariationAttributes
        bundleItems:(NSMutableArray*)bundleItems
       matchedItems:(NSMutableArray*)matchedItems
            prddDay:(TM_PRDD_Day*)prddDay
           prddTime:(TM_PRDD_Time*)prddTime
           prddDate:(NSString*)prddDate;
+ (Cart*)addProduct:(ProductInfo*)product
        variationId:(int)variationId
     variationIndex:(int)variationIndex
selectedVariationAttributes:(NSMutableArray*)selectedVariationAttributes;
+ (BOOL)isBundleProductAvailable:(ProductInfo*)pInfo;
+ (NSMutableDictionary*)createBunches;


@property NSMutableArray* mBundles_ProductCopy;
@property int productType;

@end
