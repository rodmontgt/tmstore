//
//  MV1X_JsonHelper.h
//  TMDataDoctor
//
//  Created by Rishabh Jain on 18/01/16.
//  Copyright © 2016 Twist Mobile Pvt. Ltd. India. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ServerData.h"

@interface MV1X_JsonHelper : NSObject
@property id engineObj;
- (void)loadCustomerData:(NSDictionary*)dictionary;
- (void)loadOrdersData:(NSDictionary *)dictionary;
- (void)loadCategoriesData:(NSDictionary *)dictionary;
- (NSMutableArray*)loadProductsData:(NSDictionary *)dictionary;
- (void)loadCommonData:(NSDictionary *)dictionary;
- (id)initWithEngine:(id)tmEngineObj;
@end

