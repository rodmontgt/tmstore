//
//  ShippingRajaongkir.m
//  TMShippingSDK
//
//  Created by Rishabh Jain on 28/09/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "ShippingRajaongkir.h"
#import "DataManager.h"
#import "TMShipping.h"
@implementation ShippingRajaongkir

static BOOL countriesLoaded = false;
static NSString* key = @"";
static TMRegion* superCountry = nil;

- (id)init:(NSString*)baseUrl keyRajaongkir:(NSString*)keyRajaongkir {
    self = [super init];
    if (self) {
        self.request_url_countries          = @"http://pro.rajaongkir.com/api/province";
        self.request_url_states             = @"http://pro.rajaongkir.com/api/province";
        self.request_url_sub_discricts      = @"http://pro.rajaongkir.com/api/subdistrict";
        self.request_url_cities             = @"http://pro.rajaongkir.com/api/city";
        self.request_url_calculate_shipping = @"http://pro.rajaongkir.com/api/cost";
        self.request_url_find_shippings     = @"http://pro.rajaongkir.com/api/cost";
        self.request_url_currency           = @"http://pro.rajaongkir.com/api/currency";
        self.request_store_destination      = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/ext_ship_plugin/", baseUrl];
        
        [self setListCities:true];
        superCountry = [TMRegion getRegion:@"country" regionId:@"ID" regionTitle:@"Indonesia" regionParent:nil];
        countrySelection = true;
        stateSelection = true;
        citySelection = true;
        districtSelection = false;
        subDistrictSelection = true;
        key = keyRajaongkir;
        
        self.regionSequences = [[NSMutableArray alloc] init];
        [self.regionSequences addObject:[NSNumber numberWithInt:REGION_SEQUENCE_COUNTRY]];
        [self.regionSequences addObject:[NSNumber numberWithInt:REGION_SEQUENCE_STATE]];
        [self.regionSequences addObject:[NSNumber numberWithInt:REGION_SEQUENCE_CITY]];
        [self.regionSequences addObject:[NSNumber numberWithInt:REGION_SEQUENCE_SUBDISTRICT]];
    }
    return self;
}
- (void)getChildRegions:(TMRegion*)parentRegion
                success:(void(^)(id data))success
                failure:(void(^)(NSString* error))failure {
    
    if (parentRegion != nil) {
        if([parentRegion.regionType isEqualToString:@"country"]) {
            [self getStates:parentRegion success:^(id data) {
                success(data);
            } failure:^(NSString *error) {
                
            }];
        }
        if([parentRegion.regionType isEqualToString:@"province"]) {
            [self getCities:parentRegion success:^(id data) {
                success(data);
            } failure:^(NSString *error) {
                
            }];
        }
        if([parentRegion.regionType isEqualToString:@"city"]) {
            [self getSubDistricts:parentRegion success:^(id data) {
                success(data);
            } failure:^(NSString *error) {
                
            }];
        }
        if([parentRegion.regionType isEqualToString:@"subdistrict"]) {
            success(nil);
        }
    } else {
        [self getCountries:nil success:^(id data) {
            success(data);
        } failure:^(NSString *error) {
            
        }];
    }
}
- (void)getCountries:(TMRegion*)parentRegion
             success:(void(^)(id data))success
             failure:(void(^)(NSString* error))failure {
    if (success != nil) {
        NSMutableArray* list = [[NSMutableArray alloc] init];
        [list addObject:superCountry];
        success(list);
    }
}
- (void)getStates:(TMRegion*)parentRegion
          success:(void(^)(id data))success
          failure:(void(^)(NSString* error))failure {
    if (parentRegion.regionIsLoaded) {
        if (success != nil) {
            success([TMRegion getRegions:parentRegion]);
        }
        return;
    }
    if (![Utility isNetworkAvailable]) {
        if (failure != nil) {
            failure(@"No Network");
        }
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:key forKey:@"key"];
    NSDictionary* parameters = [[NSDictionary alloc] initWithDictionary:params];
    NSString* requestUrl = [NSString stringWithFormat:@"%@", self.request_url_states];
    AFHTTPSessionManager* manager = [self getAFHTTPSessionManager];
    [manager GET:requestUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSDictionary *dict = [Utility getJsonObject:responseObject];
        success([self parseJsonAndCreateStates:parentRegion response:dict]);
//        parentRegion.regionIsLoaded = true;
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        failure(@"retry");
    }];
}
- (void)getDistricts:(TMRegion*)parentRegion
             success:(void(^)(id data))success
             failure:(void(^)(NSString* error))failure {
    if (failure != nil) {
        failure(@"NoSuchMethodException");
    }
}
- (void)getSubDistricts:(TMRegion*)parentRegion
                success:(void(^)(id data))success
                failure:(void(^)(NSString* error))failure {
    if (parentRegion.regionIsLoaded) {
        if (success != nil) {
            success([TMRegion getRegions:parentRegion]);
        }
        return;
    }
    if (![Utility isNetworkAvailable]) {
        if (failure != nil) {
            failure(@"No Network");
        }
        return;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:key forKey:@"key"];
    [params setObject:parentRegion.regionId forKey:@"city"];
    
    NSDictionary* parameters = [[NSDictionary alloc] initWithDictionary:params];
    NSString* requestUrl = [NSString stringWithFormat:@"%@", self.request_url_sub_discricts];
    AFHTTPSessionManager* manager = [self getAFHTTPSessionManager];
    [manager GET:requestUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSDictionary *dict = [Utility getJsonObject:responseObject];
        success([self parseJsonAndCreateSubDistricts:parentRegion response:dict]);
//        parentRegion.regionIsLoaded = true;
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        failure(@"retry");
    }];
}
- (void)getCities:(TMRegion*)parentRegion
          success:(void(^)(id data))success
          failure:(void(^)(NSString* error))failure {
    if (parentRegion.regionIsLoaded) {
        if (success != nil) {
            success([TMRegion getRegions:parentRegion]);
        }
        return;
    }
    if (![Utility isNetworkAvailable]) {
        if (failure != nil) {
            failure(@"No Network");
        }
        return;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:key forKey:@"key"];
    [params setObject:parentRegion.regionId forKey:@"province"];
    NSDictionary* parameters = [[NSDictionary alloc] initWithDictionary:params];
    NSString* requestUrl = [NSString stringWithFormat:@"%@", self.request_url_cities];
    AFHTTPSessionManager* manager = [self getAFHTTPSessionManager];
    [manager GET:requestUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSDictionary *dict = [Utility getJsonObject:responseObject];
        success([self parseJsonAndCreateCities:parentRegion response:dict]);
//        parentRegion.regionIsLoaded = true;
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        failure(@"retry");
    }];
}
- (void)calculateShipping:(TMRegion*)regionOrigin
        regionDestination:(TMRegion*)regionDestination
                  success:(void(^)(id data))success
                  failure:(void(^)(NSString* error))failure {
    if (failure != nil) {
        failure(@"NoSuchMethodException");
    }
}
- (void)getAvailableShipping:(TMStoreInfo*)storeInfo
           regionDestination:(TMRegion*)regionDestination
                      weight:(float)weight
                     success:(void(^)(id data))success
                     failure:(void(^)(NSString* error))failure {
    if (![Utility isNetworkAvailable]) {
        if (failure != nil) {
            failure(@"No Network");
        }
        return;
    }
    
    TMRegion* regionSource = [storeInfo.locations objectAtIndex:0];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:key forKey:@"key"];
    [params setObject:regionSource.regionId forKey:@"origin"];
    [params setObject:regionSource.regionType forKey:@"originType"];
    [params setObject:regionDestination.regionId forKey:@"destination"];
    [params setObject:regionDestination.regionType forKey:@"destinationType"];
    [params setObject:[NSNumber numberWithFloat:weight] forKey:@"weight"];
    NSString *courier = @"";
    for (NSString* courier_type in storeInfo.courier_types) {
        courier = [courier stringByAppendingString:[NSString stringWithFormat:@"%@:", courier_type]];
    }
    if ([courier length] > 0) {
        courier = [courier substringWithRange:NSMakeRange(0, [courier length] - 1)];
    }
    [params setObject:courier forKey:@"courier"];
    NSDictionary* parameters = [[NSDictionary alloc] initWithDictionary:params];
    NSString* requestUrl = [NSString stringWithFormat:@"%@", self.request_url_find_shippings];
    AFHTTPSessionManager* manager = [self getAFHTTPSessionManager];
    [manager POST:requestUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [Utility getJsonObject:responseObject];
        success([self parseJsonAndCreateShipping:dict]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(@"retry");
    }];
}
- (void)getCurrencyRate:(void(^)(id data))success
                failure:(void(^)(NSString* error))failure {
    if (![Utility isNetworkAvailable]) {
        if (failure != nil) {
            failure(@"No Network");
        }
        return;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:key forKey:@"key"];
    NSDictionary* parameters = [[NSDictionary alloc] initWithDictionary:params];
    NSString* requestUrl = [NSString stringWithFormat:@"%@", self.request_url_currency];
    AFHTTPSessionManager* manager = [self getAFHTTPSessionManager];
    [manager GET:requestUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSDictionary *dict = [Utility getJsonObject:responseObject];
        success([self parseJsonAndFindCurrencyRate:dict]);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        failure(@"retry");
    }];
}
- (void)getStoreLocation:(void(^)(id data))success
                 failure:(void(^)(NSString* error))failure {
    if (![Utility isNetworkAvailable]) {
        if (failure != nil) {
            failure(@"No Network");
        }
        return;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    NSString* plugin_ongkos_kirim = @"plugin_ongkos_kirim";
    [params setObject:[[plugin_ongkos_kirim dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0] forKey:@"ship_type"];
    NSDictionary* parameters = [[NSDictionary alloc] initWithDictionary:params];
    NSString* requestUrl = [NSString stringWithFormat:@"%@", self.request_store_destination];
    AFHTTPSessionManager* manager = [self getAFHTTPSessionManager];
    [manager POST:requestUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [Utility getJsonObject:responseObject];
        success([self parseJsonAndGetLocation:dict]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(@"retry");
    }];
}

- (AFHTTPSessionManager *)getAFHTTPSessionManager {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    return manager;
}

- (NSMutableArray*)parseJsonAndCreateStates:(TMRegion*)parentRegion response:(id)response {
    NSMutableArray* states = [[NSMutableArray alloc] init];
    if (response) {
        if (IS_NOT_NULL(response, @"rajaongkir")) {
            NSDictionary* rajaongkir = [response objectForKey:@"rajaongkir"];
            NSArray* results = [rajaongkir objectForKey:@"results"];
            for (NSDictionary* dict in results) {
                NSString *type = @"province";
                NSString *province_id = GET_VALUE_OBJECT(dict, @"province_id");
                NSString *province_name = GET_VALUE_OBJECT(dict, @"province");
                TMRegion* state = [TMRegion getRegion:type regionId:province_id regionTitle:province_name regionParent:parentRegion];
                [states addObject:state];
            }
        }
    }
    return states;
}
- (NSMutableArray*)parseJsonAndCreateCities:(TMRegion*)parentRegion response:(id)response {
    NSMutableArray* cities = [[NSMutableArray alloc] init];
    if (response) {
        if (IS_NOT_NULL(response, @"rajaongkir")) {
            NSDictionary* rajaongkir = [response objectForKey:@"rajaongkir"];
            NSArray* results = [rajaongkir objectForKey:@"results"];
            for (NSDictionary* dict in results) {
                NSString *type = @"city";
                NSString *city_id = GET_VALUE_OBJECT(dict, @"city_id");
                NSString *city_name = GET_VALUE_OBJECT(dict, @"city_name");
                TMRegion* city = [TMRegion getRegion:type regionId:city_id regionTitle:city_name regionParent:parentRegion];
                [cities addObject:city];
            }
        }
    }
    return cities;
}
- (NSMutableArray*)parseJsonAndCreateSubDistricts:(TMRegion*)parentRegion response:(id)response {
    NSMutableArray* subdistricts = [[NSMutableArray alloc] init];
    if (response) {
        if (IS_NOT_NULL(response, @"rajaongkir")) {
            NSDictionary* rajaongkir = [response objectForKey:@"rajaongkir"];
            NSArray* results = [rajaongkir objectForKey:@"results"];
            for (NSDictionary* dict in results) {
                NSString *type = @"subdistrict";
                NSString *subdistrict_id = GET_VALUE_OBJECT(dict, @"subdistrict_id");
                NSString *subdistrict_name = GET_VALUE_OBJECT(dict, @"subdistrict_name");
                TMRegion* subdistrict = [TMRegion getRegion:type regionId:subdistrict_id regionTitle:subdistrict_name regionParent:parentRegion];
                [subdistricts addObject:subdistrict];
            }
        }
    }
    return subdistricts;
}
- (TMStoreInfo*)parseJsonAndGetLocation:(id)response {
    if(response){
        if (IS_NOT_NULL(response, @"ship_data")) {
            NSDictionary* ship_data = GET_VALUE_OBJECT(response, @"ship_data");
            NSArray* store_location = GET_VALUE_OBJECT(ship_data, @"store_location");
            NSArray* courier_type = GET_VALUE_OBJECT(ship_data, @"courier_type");
            
            TMStoreInfo* storeInfo = [[TMStoreInfo alloc] init];
            for (NSString* str in store_location) {
                [storeInfo.locations addObject:[TMRegion getRegionFromAll:@"city" regionTitle:str]];
            }
            for (NSString* str in courier_type) {
                [storeInfo.courier_types addObject:str];
            }
            return storeInfo;
        }
    }
    return nil;
}
- (NSNumber*)parseJsonAndFindCurrencyRate:(id)response {
    if (response) {
        if (IS_NOT_NULL(response, @"rajaongkir")) {
            NSDictionary* rajaongkir = GET_VALUE_OBJECT(response, @"rajaongkir");
            if (rajaongkir) {
                if (IS_NOT_NULL(rajaongkir, @"result")) {
                    NSDictionary* result = GET_VALUE_OBJECT(rajaongkir, @"result");
                    if (result) {
                        if (IS_NOT_NULL(result, @"value")) {
                            return [NSNumber numberWithFloat:GET_VALUE_FLOAT(result, @"value")];
                        }
                    }
                }
            }
        }
    }
    return [NSNumber numberWithFloat:1.0f];
}
- (NSArray*)parseJsonAndCreateShipping:(id)response {
    NSMutableArray* shipping = [[NSMutableArray alloc] init];
    if (response) {
        if (IS_NOT_NULL(response, @"rajaongkir")) {
            NSDictionary* rajaongkir = GET_VALUE_OBJECT(response, @"rajaongkir");
            if (IS_NOT_NULL(rajaongkir, @"results")) {
                NSArray* results = GET_VALUE_OBJECT(rajaongkir, @"results");
                for (NSDictionary* resultObject in results) {
                    NSArray* costs = GET_VALUE_OBJECT(resultObject, @"costs");
                    for (NSDictionary* costsJSONObject in costs) {
                        TMShipping* shippingItem = [[TMShipping alloc] init];
                        shippingItem.shippingId = GET_VALUE_OBJECT(resultObject, @"code");
                        shippingItem.shippingMethodId = GET_VALUE_OBJECT(costsJSONObject, @"service");
                        shippingItem.shippingLabel = [NSString stringWithFormat:@"%@ %@", [shippingItem.shippingId uppercaseString], shippingItem.shippingMethodId];
                        shippingItem.shippingDescription = GET_VALUE_OBJECT(costsJSONObject, @"description");
                        {
                            NSArray* cost = GET_VALUE_OBJECT(costsJSONObject, @"cost");
                            NSDictionary* faltuKaObject = [cost objectAtIndex:0];
                            shippingItem.shippingCost = GET_VALUE_FLOAT(faltuKaObject, @"value");
                            shippingItem.shippingEtd = GET_VALUE_OBJECT(faltuKaObject, @"etd");
                        }
                        [shipping addObject:shippingItem];
                    }
                }
            }
        }
    }
    return [NSArray arrayWithArray:shipping];
}
@end
