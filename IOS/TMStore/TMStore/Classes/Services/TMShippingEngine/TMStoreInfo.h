//
//  TMStoreInfo.h
//  TMShippingSDK
//
//  Created by Rishabh Jain on 28/09/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMStoreInfo : NSObject
@property NSMutableArray* locations;//tmregion
@property NSMutableArray* courier_types;//nstring
- (id)init;
@end
