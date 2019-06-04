//
//  TMDataDoctor.h
//  TMDataDoctor
//
//  Created by Rishabh Jain on 18/01/16.
//  Copyright © 2016 Twist Mobile Pvt. Ltd. India. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Variables.h"
#import "TMMulticastDelegate.h"
#import "ServerData.h"

#import "Base64.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <AFNetworking/AFNetworking.h>
#import "MRProgress.h"
//#import <MRProgress/MRProgressOverlayView+AFNetworking.h>
//#import <MRProgress/MRActivityIndicatorView+AFNetworking.h>


enum FETCH_PRIMARY_DATA_ID {
    kFetchCommonData,
    kFetchCustomers,
    kFetchCategories,
    kFetchProducts,
    kFetchOrders,
    kFetchCustomer,
    kFetchSingleProduct,
    kFetchSingleProductReview,
    kFetchMoreProduct,
    kFetchCoupons,
    kFetchTotal,
};

@interface TMDataDoctor : NSObject <NSURLConnectionDelegate>

@property TMMulticastDelegate *tmMulticastDelegate;
@property MRActivityIndicatorView *mrActivityIndicatorView;
@property NSMutableArray *serverDatas;
// Properties
@property NSString* baseUrl;
@property NSString* oauth_consumer_key;
@property NSString* oauth_consumer_secret;
@property NSString* oauth_token;
@property NSString* request_url_products;
@property NSString* request_url_singleProduct;
@property NSString* request_url_customer;
@property NSString* request_url_orders;
@property NSString* request_url_all_orders;
@property NSString* request_url_categories;
@property NSString* request_url_common;
@property NSString* external_login_url;
@property NSString* external_login_url_hidden;
@property NSString* external_signup_url;
@property NSString* cart_url;
@property NSString* checkout_url;
@property NSString* version_string;

@property NSString* createUserPageLink;
@property NSString* externalLoginPageLink;
@property NSString* loginPageLink;
@property NSString* productPageBaseUrl;
@property NSString* pagelinkContactUs;
@property NSString* pagelinkAboutUs;
@property NSString* siteUrl;


@property NSString* request_url_frontpage_content;
@property NSString* request_url_initial_products;
@property NSString* request_url_countries;
@property NSString* request_url_update_customer;
@property NSString* request_url_sync_cart_items;
@property NSString* request_url_coupons;
@property NSString* request_url_more_products;
@property NSString* request_url_products_full_data;
@property NSString* request_url_search_products;
@property NSString* request_url_menu_items;
@property NSString* request_url_extra_attribs;
@property NSString* request_url_taxes;
@property NSString* request_url_single_product_fast;
@property NSString* request_url_filterdata_prices;
@property NSString* request_url_filterdata_attributes;
@property NSString* request_url_filter_products;
@property NSString* request_url_selected_orders_data;
@property NSString* request_url_products_fast;
//vendor
@property NSString* request_url_list_vendor;
@property NSString* request_url_frontpage_content_vendor;
@property NSString* request_url_initial_products_vendor;
@property NSString* request_url_products_vendor;
@property NSString* multiVendorPluginName;
/////////

@property NSString* url_shipment_track;
@property NSString* url_custom_sponsor_friend;
@property NSString* url_custom_wishlist;
@property NSString* url_custom_waitlist;
@property NSString* url_custom_reward_points;
@property NSString* url_products_brand_names;
@property NSString* url_products_price_labels;
@property NSString* url_incremental_product_quantities;
@property NSString* url_product_pin_code;
@property NSString* url_delivery_slots;
@property NSString* url_local_pickup_time_select;
@property NSString* url_pick_up_locations;

@property NSString* url_prdd_plugin_data;
+ (id)initWithParameter:(NSString*)storeName storeVersion:(NSString*)storeVersion baseUrl:(NSString*)baseUrl consumerKey:(NSString*)consumerKey consumerSecretKey:(NSString*)consumerSecretKey pagelinkContactus:(NSString*)pagelinkContactus pagelinkAboutus:(NSString*)pagelinkAboutus;
@end


@protocol TMDataDoctor <NSObject>
// Methods
- (id)initEngineWithBaseUrl:(NSString*)baseUrl storeVersion:(NSString*)storeVersion  consumerKey:(NSString*)consumerKey consumerSecretKey:(NSString*)consumerSecretKey pagelinkContactus:(NSString*)pagelinkContactus pagelinkAboutus:(NSString*)pagelinkAboutus;

- (ServerData*)fetchDataFromServer:(NSString *)_urlString dataId:(int)_dataId view:(UIView *)_view maxDataLimit:(int)maxDataLimit offset:(int)offset;
- (ServerData*)fetchDataFromServer:(NSString *)_urlString dataId:(int)_dataId view:(UIView *)_view maxDataLimit:(int)maxDataLimit;
- (ServerData*)fetchDataFromServer:(NSString *)_urlString dataId:(int)_dataId view:(UIView *)_view maxDataLimit:(int)maxDataLimit offset:(int)offset;
- (ServerData*)fetchDataFromServer:(NSString *)_urlString dataId:(int)_dataId view:(UIView *)_view maxDataLimit:(int)maxDataLimit;
- (ServerData*)fetchCommonData:(UIView*)view;
- (ServerData*)fetchCategoriesData:(UIView*)view;
- (ServerData*)fetchProductData:(UIView*)view;
- (ServerData*)fetchCustomerData:(UIView*)view userEmail:(NSString*)userEmail;
- (ServerData*)fetchOrdersData:(UIView*)view;
- (ServerData*)fetchCouponsData:(UIView*)view;
- (ServerData*)fetchSingleProductData:(UIView*)view productId:(int)productId;
- (ServerData*)fetchSingleProductDataReviews:(UIView*)view productId:(int)productId;
- (ServerData*)fetchProductsWithTag:(UIView*)view tag:(NSString*)tag offset:(int)offset productCount:(int)productCount;
- (ServerData*)fetchProductsByTagUsePlugin:(UIView*)view tag:(NSString*)tag offset:(int)offset productCount:(int)productCount;
- (void)checkPostMethod;

- (void) getWaitListProductIds:(int)userId
                       emailId:(NSString*)emailId
                       success:(void(^)(id data))success
                       failure:(void(^)(NSString* error))failure;

- (void) updateWaitListProduct:(NSDictionary*)params
                       success:(void(^)(id data))success
                       failure:(void(^)(NSString* error))failure;

- (void) getWishListProducts:(int)userId
                     emailId:(NSString*)emailId
                     success:(void(^)(id data))success
                     failure:(void(^)(NSString* error))failure;

- (void) getWishListDetails:(int)userId
                    emailId:(NSString*)emailId
                    success:(void(^)(id data))success
                    failure:(void(^)(NSString* error))failure;

- (void) syncWishListProduct:(NSDictionary*)params
                     success:(void(^)(id data))success
                     failure:(void(^)(NSString* error))failure;

- (void)sponsorYourFriend:(NSDictionary*)params
                  success:(void(^)(NSString* msg))success
                  failure:(void(^)(NSString* msg))failure;

- (void) getUserRewardPoints:(NSDictionary*)params
                     success:(void(^)(id data))success
                     failure:(void(^)(NSString* error))failure;

- (void) getProductRewardPoints:(NSDictionary*)params
                        success:(void(^)(id data))success
                        failure:(void(^)(NSString* error))failure;

- (void) getOrderRewardPoints:(NSDictionary*)params
                      success:(void(^)(id data))success
                      failure:(void(^)(NSString* error))failure;
- (void) getOrderDeliverySlots:(NSDictionary*)params
                          success:(void(^)(id data))success
                          failure:(void(^)(NSString* error))failure;
- (void) getOrderTimeSlots:(NSDictionary*)params
                       success:(void(^)(id data))success
                       failure:(void(^)(NSString* error))failure;

- (void) updateOrderRewardPoints:(NSDictionary*)params
                         success:(void(^)(id data))success
                         failure:(void(^)(NSString* error))failure;

- (void) getCartProductsRewardPoints:(NSDictionary*)params
                             success:(void(^)(id data))success
                             failure:(void(^)(NSString* error))failure;

- (void) getShipmentTrackingId:(NSString*)shipmentType
                       orderId:(int)orderId
                       success:(void(^)(id data))success
                       failure:(void(^)(NSString* error))failure;

- (void) getProductsBrandNames:(NSArray*)productIds
                       success:(void(^)(id data))success
                       failure:(void(^)(NSString* error))failure;

- (void) getProductsPriceLabels:(NSArray*)productIds
                        success:(void(^)(id data))success
                        failure:(void(^)(NSString* error))failure;

- (void) getProductsQuantityRules:(NSArray*)productIds
                          success:(void(^)(id data))success
                          failure:(void(^)(NSString* error))failure;


- (void) getProductsPincodeSettings:(void(^)(id data))success
                            failure:(void(^)(NSString* error))failure;
- (void)getPickupLocations:(void(^)(id data))success
                   failure:(void(^)(NSString* error))failure;
- (ServerData*)fetchProductDataForCategory:(UIView*)view
                              categorySlug:(NSString*)categorySlug
                                    offset:(int)offset productCount:(int)productCount
                                   success:(void(^)(id data))success
                                   failure:(void(^)(NSString* error))failure;

- (void)fetchProductDataForCategory_MultiVendor:(NSString*)vendorId
                                     categoryId:(int)categoryId
                                         offset:(int)offset
                                   productCount:(int)productCount
                                        success:(void(^)(id data))success
                                        failure:(void(^)(NSString* error))failure;
- (void)getGuestOrdersInBackground:(void (^)(id data))success failure:(void (^)(void))failure;
- (void)getProductDeliveryDataPRDD:(int)productId
                     success:(void(^)(id data))success
                     failure:(void(^)(NSString* error))failure;
- (void)postOrderShippingDataPRDD:(int)orderId
                  shippingBunches:(NSDictionary*)shippingBunches
                          success:(void(^)(id data))success
                          failure:(void(^)(NSString* error))failure;
@end
