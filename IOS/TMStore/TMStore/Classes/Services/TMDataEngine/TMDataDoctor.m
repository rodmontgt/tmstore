//
//  TMDataDoctor.m
//  TMDataDoctor
//
//  Created by Rishabh Jain on 18/01/16.
//  Copyright © 2016 Twist Mobile Pvt. Ltd. India. All rights reserved.
//

#import "TMDataDoctor.h"
#import "DataManager.h"

@implementation TMDataDoctor
@synthesize tmMulticastDelegate = _tmMulticastDelegate;
@synthesize mrActivityIndicatorView = _mrActivityIndicatorView;
@synthesize serverDatas = _serverDatas;
+ (id)initWithParameter:(NSString*)storeName storeVersion:(NSString*)storeVersion baseUrl:(NSString*)baseUrl consumerKey:(NSString*)consumerKey consumerSecretKey:(NSString*)consumerSecretKey pagelinkContactus:(NSString*)pagelinkContactus pagelinkAboutus:(NSString*)pagelinkAboutus {
    id tmdd = nil;
    if ([[storeName lowercaseString] isEqualToString:@"woocommerce"]) {
        tmdd = [[WC2X_Engine alloc] initEngineWithBaseUrl:baseUrl storeVersion:storeVersion consumerKey:consumerKey consumerSecretKey:consumerSecretKey pagelinkContactus:pagelinkContactus pagelinkAboutus:pagelinkAboutus];
    }
    return tmdd;
}
@end
