//
//  ShippingEngine.h
//  TMShippingSDK
//
//  Created by Rishabh Jain on 28/09/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMRegion.h"
#import "TMStoreInfo.h"
#import "Utility.h"
#import <AFNetworking/AFNetworking.h>
#import "UIAlertView+NSCookbook.h"


enum SHIPPING_PROVIDER {
    SHIPPING_PROVIDER_WOOCOMMERCE,
    SHIPPING_PROVIDER_RAJAONGKIR
};

@interface ShippingEngine : NSObject {
    BOOL countrySelection;
    BOOL stateSelection;
    BOOL citySelection;
    BOOL districtSelection;
    BOOL subDistrictSelection;
}
@property NSMutableArray* regionSequences;
@property NSString* request_url_countries;
@property NSString* request_url_states;
@property NSString* request_url_districts;
@property NSString* request_url_sub_discricts;
@property NSString* request_url_cities;
@property NSString* request_url_calculate_shipping;
@property NSString* request_url_find_shippings;
@property NSString* request_url_currency;
@property NSString* request_store_destination;
- (BOOL)hasSubDistrictSelection;
- (BOOL)hasDistrictSelection;
- (BOOL)hasCitySelection;
- (BOOL)hasStateSelection;
- (BOOL)hasCountrySelection;

+ (BOOL)listCities;
- (void)setListCities:(BOOL)value;
+ (BOOL)areCitiesListed;
@end

@protocol ShippingEngine <NSObject>
- (void)getChildRegions:(TMRegion*)parentRegion
             success:(void(^)(id data))success
             failure:(void(^)(NSString* error))failure;


- (void)getCountries:(TMRegion*)parentRegion
             success:(void(^)(id data))success
             failure:(void(^)(NSString* error))failure;
- (void)getStates:(TMRegion*)parentRegion
          success:(void(^)(id data))success
          failure:(void(^)(NSString* error))failure;
- (void)getDistricts:(TMRegion*)parentRegion
             success:(void(^)(id data))success
             failure:(void(^)(NSString* error))failure;
- (void)getSubDistricts:(TMRegion*)parentRegion
                success:(void(^)(id data))success
                failure:(void(^)(NSString* error))failure;
- (void)getCities:(TMRegion*)parentRegion
          success:(void(^)(id data))success
          failure:(void(^)(NSString* error))failure;
- (void)calculateShipping:(TMRegion*)regionOrigin
        regionDestination:(TMRegion*)regionDestination
                  success:(void(^)(id data))success
                  failure:(void(^)(NSString* error))failure;
- (void)getAvailableShipping:(TMStoreInfo*)storeInfo
           regionDestination:(TMRegion*)regionDestination
                      weight:(float)weight
                     success:(void(^)(id data))success
                     failure:(void(^)(NSString* error))failure;
- (void)getCurrencyRate:(void(^)(id data))success
                failure:(void(^)(NSString* error))failure;
- (void)getStoreLocation:(void(^)(id data))success
                 failure:(void(^)(NSString* error))failure;
@end
