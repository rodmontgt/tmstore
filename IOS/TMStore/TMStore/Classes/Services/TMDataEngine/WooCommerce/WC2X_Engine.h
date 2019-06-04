//
//  WC2X_Engine.h
//  TMDataDoctor
//
//  Created by Rishabh Jain on 18/01/16.
//  Copyright © 2016 Twist Mobile Pvt. Ltd. India. All rights reserved.
//

#import "TMDataDoctor.h"
#import "WC2X_JsonHelper.h"
#import "TMShipping.h"
#import "DateTimeSlot.h"
#import "TimeSlot.h"
#import "UserFilter.h"
@interface WC2X_Engine : TMDataDoctor <TMDataDoctor>
@property WC2X_JsonHelper* tmJsonHelper;

- (void)fetchHomePageDataFromPlugin;
- (void)fetchInitialProductsDataFromPlugin;
- (void)fetchHomePageDataFromPlugin_MultiVendor;
- (void)fetchInitialProductsDataFromPlugin_MultiVendor;
- (void)fetchProductDataForCategory_MultiVendor:(NSString*)vendorId
                                     categoryId:(int)categoryId
                                         offset:(int)offset
                                   productCount:(int)productCount
                                        success:(void(^)(id data))success
                                        failure:(void(^)(NSString* error))failure;
- (void)fetchCountryDataFromPlugin;
- (void)fetchMoreProductsDataFromPlugin;
- (void)fetchCartProductsDataFromPlugin;
- (void)fetchMenuItemsDataFromPlugin;
- (void)fetchVendorDataFromPlugin;
- (void)updateCustomerData;
- (void)syncCart ;
- (void)createBlankOrder:(NSMutableArray*)selectedShippingMethods paymentGateway:(TMPaymentGateway*)paymentGateway;
- (void)updateOrder:(TMPaymentGateway*)paymentGateway orderId:(int)orderId orderStatus:(NSString*)orderStatus isPaid:(BOOL)isPaid;
- (void)getFilterPricesInBackground:(NSDictionary*)params success:(void(^)(id data))success failure:(void(^)(NSString* error))failure;
- (void)getFilterAttributesInBackground:(NSDictionary*)params success:(void(^)(id data))success failure:(void(^)(NSString* error))failure;
@property MRProgressOverlayView* overlayUpdateOrderAfterPurchase;
- (AFHTTPSessionManager*)initializeRequestManagerForPostMethod;

@property BOOL isHomePageDataFetched;
@property BOOL isInitialPageDataFetched;
@property BOOL isVendorDataFetched;
- (void)testMagentoPost;
- (void)testWooCommercePost;

- (void)loadExtraAttribData:(ProductInfo*)pInfo
                    success:(void(^)(id data))success
                    failure:(void(^)(NSString* error))failure;
- (void)fetchCartProductsDataFromPlugin:(void(^)(id data))success
                                failure:(void(^)(NSString* error))failure;
- (void)fetchTaxesData:(void(^)(id data))success
               failure:(void(^)(NSString* error))failure;
- (void)syncCartForAppliedCoupon:(void (^)(void))success failure:(void (^)(void))failure;
- (void)fetchMoreProductsDataFromPlugin:(NSArray*)productIds success:(void (^)(void))success failure:(void (^)(void))failure;
- (void)fetchProductsFullDataFromPlugin:(NSArray*)productIds success:(void (^)(id data))success failure:(void (^)(void))failure;
- (void)getProductInfoFastInBackground:(ProductInfo*)product success:(void (^)(id data))success failure:(void (^)(void))failure;
- (void)getCustomMenuItems:(NSArray*) menuIds
                   success:(void(^)(id data))success
                   failure:(void(^)(NSString* error))failure;
- (void)fetchDeliverySlotsFromPlugin:(void (^)(id data))success failure:(void(^)(NSString* error))failure;
- (void)postDeliverySlotsThroughPlugin:(int)orderId dateTimeSlot:(DateTimeSlot*)dateTimeSlot timeSlot:(TimeSlot*)timeSlot success:(void (^)(void))success failure:(void (^)(void))failure;

- (void)fetchLocalPickupTimeSelectFromPlugin:(void (^)(id data))success failure:(void (^)(void))failure;
- (void)postTimeSlotsThroughPlugin:(int)orderId timeSlot:(TimeSlot*)timeSlot success:(void (^)(void))success failure:(void (^)(void))failure;
- (NSMutableArray *)parseJsonAndCreateFilterPrices:(NSDictionary*) json;
- (NSMutableArray*)parseJsonAndCreateFilterAttributes:(NSMutableArray*) json;
- (void)getProductsByFilter:(NSDictionary *)userFilter success:(void(^)(id data))success failure:(void(^)(NSString* error))failure;
- (void)getAttributByAttributSelectedAttribute:(NSDictionary *)userFilter success:(void(^)(id data))success failure:(void(^)(NSString* error))failure;
- (void)fetchCouponsData:(void(^)(id data))success failure:(void(^)(NSString* error))failure;

- (void)createBlankOrder:(NSMutableArray*)selectedShippingMethods
          paymentGateway:(TMPaymentGateway*)paymentGateway
                 success:(void(^)(id data))success
                 failure:(void(^)(NSString* error))failure;
- (void)updateBlankOrderWithOrderId:(int)orderId
                     shippingMethod:(TMShipping*)shippingMethod
                            success:(void(^)(id data))success
                            failure:(void(^)(NSString* error))failure;
- (void)fetchOrdersInBackground:(void (^)(id data))success failure:(void (^)(NSString* error))failure;

#pragma mark Reservation&ContactForm Data
- (void)getContactForm3InBackground:(int)formId
                            success:(void(^)(id data))success
                            failure:(void(^)(NSString* error))failure;
- (void)postContactForm3InBackground:(int)formId
                                name:(NSString*)name
                               email:(NSString*)email
                             message:(NSString*)message
                             success:(void(^)(id data))success
                             failure:(void(^)(NSString* error))failure;
- (void)getReservationFormInBackground:(int)formId
                               success:(void(^)(id data))success
                               failure:(void(^)(NSString* error))failure;
- (void)postReservationFormInBackground:(int)formId
                                   name:(NSString*)name
                                  email:(NSString*)email
                                dateStr:(NSString*)dateStr
                              date_pers:(NSString*)date_pers
                                timeStr:(NSString*)timeStr
                             timePeriod:(NSString*)timePeriod
                                  phone:(NSString*)phone
                                message:(NSString*)message
                                success:(void(^)(id data))success
                                failure:(void(^)(NSString* error))failure;

- (void)fetchProductDataFromSku:(NSString*)sku
                        success:(void(^)(id data))success
                        failure:(void(^)(NSString* error))failure;
- (void)pluginOTP:(NSString*)mobileNumber
             code:(NSString*)code
             type:(int)type
          success:(void(^)(NSString* str))success
          failure:(void(^)(NSString* error))failure;
- (void)pluginResetPassword:(NSString*)userEmail
                oldPassword:(NSString*)oldPassword
                newPassword:(NSString*)newPassword
                    success:(void(^)(NSString* str))success
                    failure:(void(^)(NSString* error))failure;
#pragma mark WOOCOMMERCE CHECKOUT MANAGER (WCCM)
- (void)getWCCMData:(void(^)(id data))success
            failure:(void(^)(NSString* error))failure;
- (void)setWCCMDataForOrderId:(int)orderId
                     metaData:(NSDictionary*)metaData
                      success:(void(^)(id data))success
                      failure:(void(^)(NSString* error))failure;
- (void)getWCCMDataForOrders:(NSArray*)orderIds
                     success:(void(^)(id data))success
                     failure:(void(^)(NSString* error))failure;
- (void)updateCustomerData:(void(^)(id data))success
                   failure:(void(^)(NSString* error))failure;
#pragma mark SELLER_ZONE START
- (void)getProductsOfSeller:(NSString*)sellerId
                    productLimit:(int)productLimit
                     offset:(int)offset
                    success:(void(^)(id data))success
                    failure:(void(^)(NSString* error))failure;
- (void)getOrdersOfSeller:(int)sellerId
                    success:(void(^)(id data))success
                    failure:(void(^)(NSString* error))failure;
- (void)szFetchSplashData:(int)sellerId
                  success:(void(^)(id data))success
                  failure:(void(^)(NSString* error))failure;
- (void)uploadProduct:(int)productId
           uploadDict:(NSMutableDictionary*)uploadDict
              success:(void(^)(id data))success
              failure:(void(^)(NSString* error))failure;
- (void)uploadImageToServer:(UIImage*)img
                    success:(void(^)(NSString* imgUrl))success
                    failure:(void(^)(NSString* error))failure;
- (void)linkProductWithSeller:(int)productId
                     sellerId:(int)sellerId
                      success:(void(^)(void))success
                      failure:(void(^)(NSString* error))failure;
- (void)getSellerInformation:(int)sellerId
                       success:(void(^)(id data))success
                       failure:(void(^)(NSString* error))failure;
- (void)getAllAttributes:(void(^)(void))success
                 failure:(void(^)(NSString* error))failure;
- (void)deleteProduct:(int)productId
              success:(void(^)(NSString* msg))success
              failure:(void(^)(NSString* msg))failure;
- (void)getProductsOfCategory:(int)categoryId
                       offset:(int)offset
                 productLimit:(int)productLimit
                      success:(void(^)(id data))success
                      failure:(void(^)(NSString* error))failure;
- (void)updateSellerInformation:(NSDictionary*)params
                        success:(void(^)(id data))success
                        failure:(void(^)(NSString* error))failure;
#pragma mark SELLER_ZONE END

- (void)fetchCategoryProductsFast:(int)categoryId
                    product_limit:(int)product_limit
                           offset:(int)offset
                          success:(void (^)(id data))success
                          failure:(void (^)(void))failure;
- (void)fetchMultipleShippingAddress:(void(^)(id responseObj))success
                             failure:(void(^)(NSString* errorString))failure;
- (void)updateMultipleShippingAddress:(NSMutableDictionary*)addressJson
                              success:(void(^)(id responseObj))success
                              failure:(void(^)(NSString* errorString))failure;
- (void)updateSellerOrder:(Order*)order
              orderStatus:(NSString*)orderStatus
                  success:(void(^)(id data))success
                  failure:(void(^)(NSString* error))failure;
- (void)fetchProductFromServer:(int)productId
                       success:(void(^)(id responseObj))success
                       failure:(void(^)(NSString* errorString))failure;
#pragma mark - new methods

- (void)fetchCategoriesDataNew:(int)categoryId
                         count:(int)count
                       success:(void(^)(id data))success
                       failure:(void(^)(NSString* error))failure;
- (void)getAllAttributesForCategories:(NSArray*)categoryIds
                              success:(void(^)(void))success
                              failure:(void(^)(NSString* error))failure;
@end

