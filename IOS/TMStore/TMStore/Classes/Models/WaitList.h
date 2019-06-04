//
//  WaitList.h
//  TMStore
//
//  Created by Vikas Patidar on 20/09/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface WaitList : NSObject

+(void)addProductId:(int)productId;

+(void)removeProductId:(int)productId;

+(BOOL)hasProductId:(int)productId;

+(void)clearAllProductIds;

@end
