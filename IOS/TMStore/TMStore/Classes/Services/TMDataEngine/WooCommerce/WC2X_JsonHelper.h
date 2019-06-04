//
//  WC2X_JsonHelper.h
//  TMDataDoctor
//
//  Created by Rishabh Jain on 18/01/16.
//  Copyright © 2016 Twist Mobile Pvt. Ltd. India. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ServerData.h"
#import "Order.h"
#import "ProductInfo.h"
#import "TM_ProductFilter.h"
#import "SellerInfo.h"

@interface WC2X_JsonHelper : NSObject
@property id engineObj;
- (void)loadCustomerData:(NSDictionary*)dictionary;
- (void)loadOrdersData:(NSDictionary *)dictionary;
- (void)loadCategoriesData:(NSDictionary *)dictionary;
- (NSMutableArray*)loadProductsData:(NSDictionary *)dictionary;
- (ProductInfo*)loadSingleProductData:(NSDictionary *)mainDict;
- (void)loadSingleProductReviewData:(NSDictionary *)mainDict product:(ProductInfo*)product;
- (void)loadCommonData:(NSDictionary *)dictionary;
- (void)loadCouponData:(NSDictionary *)dictionary;
- (id)initWithEngine:(id)tmEngineObj;

+ (void)loadPluginDataForMenuItems:(NSArray*)array;
- (void)loadPluginDataForHomePage:(NSDictionary*)dict;
- (void)loadPluginDataForInitialProducts:(NSArray*)dict;
- (void)loadPluginDataForCountries:(NSDictionary*)dict;
- (void)loadPaymentGatewayDatasViaPlugin:(NSDictionary*)mainDict;
- (void)loadShippingMethodsDatasViaPlugin:(NSArray*)shippingData;
- (void)loadPluginDataForMoreProducts:(NSArray*)dict;
- (void)loadPluginDataForCartProducts:(NSArray*)dict;
- (Order*)parseOrderJson:(NSDictionary *)mainDict;
- (Order*)parseOrderJsonWithOrderObject:(NSDictionary *)mainDict order:(Order*)order;
- (NSMutableArray *)loadProductsDataAndReturn:(NSDictionary *)dictionary;
- (void)loadPluginDataForVendors:(NSArray*)array;
+ (void)createWaitList:(NSDictionary*) json;
+ (void)createWishList:(NSDictionary*) json;
+ (void)parseWishListDetails:(NSDictionary*) json;
+ (void)parseUserRewardPoints:(NSDictionary*) json;
+ (void)parseProductRewardPoints:(NSDictionary*) json;
+ (void)parseOrderRewardPoints:(NSDictionary*)json;
+ (void)parseOrderDeliveySlots:(NSDictionary*)json;
+ (void)parseCartProductsRewardPoints:(NSDictionary*) json;
- (void)parseExtraAttributesForProduct:(ProductInfo*)product variation_simple_fields:(NSArray*)variation_simple_fields;
- (void)loadTaxesData:(NSDictionary *)dictionary;
- (void)parseJsonAndCreateCartMeta:(NSDictionary*)mainDict;
- (void)parseJsonAndCreateMinOrderData:(NSDictionary*)mainDict;
- (void)parseJsonAndCreateFees:(NSDictionary*)mainDict;
+ (void)parseProductsBrandNames:(NSDictionary*) json;
+ (void)parseProductsPriceLabels:(NSDictionary*) json;
+ (void)parseProductsQuantityRules:(NSDictionary*) json;

+ (int)safeIntWithCeil:(NSDictionary*)json stringKey:(NSString*)key value:(int)defaultValue;
- (void)parseAndSetProductPriceLabels:(NSDictionary *)json product:(ProductInfo*) product;
+ (void)parseAndSetProductQuantityRules:(NSDictionary *)json product:(ProductInfo*) product;

+ (void)parseProductsPincodeSettings:(NSDictionary*) json;
+ (void)parsePickupLocations:(NSArray*)pickupLocations;
+ (NSMutableArray*)parseDeliverySlotDataType1:(NSArray*)jsonArray;
+ (NSMutableArray*)parseDeliverySlotDataType2:(NSDictionary*)jsonDict;
+ (NSMutableArray*)parsePickUpTimeSlotData:(NSDictionary*)jsonObject keysArray:(NSMutableArray*)keysArray valuesArray:(NSMutableArray*)valuesArray;
- (TM_ProductFilter*)parseFilterPrices:(NSDictionary*) json;
- (TM_ProductFilter*)parseFilterAttributes:(NSDictionary*) json;
- (void)loadTrendingDatasViaPlugin:(NSArray*)pluginDataArray originalDataArray:(NSMutableArray*)originalDataArray resizeEnable:(BOOL)resizeEnable;
- (void)parse_pddData:(NSDictionary*)json productId:(int)productId;
- (void)loadCheckoutAddonsViaPlugin:(NSArray*)checkoutAddons;

- (void)parse_ContactForm3Config:(NSDictionary*)json;
- (void)parse_ReservationFormConfig:(NSDictionary*)json;
- (void)parseWCCheckoutManagerData:(NSArray*)array;
- (void)parseWCCheckoutManagerDataAllOrders:(NSArray*)array;
- (void)parseMultipleShippingAddresses:(NSArray*)array;

#pragma mark SELLER_ZONE
- (NSMutableArray*)sellerZoneParseOrderJson:(NSDictionary*)dict;
- (SellerInfo*)szParseSellerInfo:(NSDictionary*)dict;
- (void)szParseAttributesData:(NSDictionary*)dict;
@end

