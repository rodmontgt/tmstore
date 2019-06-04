//
//  WaitList.m
//  TMStore
//
//  Created by Vikas Patidar on 20/09/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaitList.h"

@implementation WaitList

static NSMutableArray* productIds;

+(void)addProductId:(int)productId {
    if(productIds == nil) {
        productIds = [[NSMutableArray alloc] init];
    }

    if(![WaitList hasProductId:productId]) {
        [productIds addObject:[NSNumber numberWithInt:productId]];
    }
}

+(void)removeProductId:(int)productId {
    if(productIds != nil) {
        [productIds removeObject:[NSNumber numberWithInt:productId]];
    }
}

+(BOOL)hasProductId:(int)productId {
    if(productIds != nil) {
        NSNumber* value = [NSNumber numberWithInt:productId];
        return [productIds indexOfObject:value] != NSNotFound;
    }
    return false;
}

+(void)clearAllProductIds {
    if(productIds != nil) {
        [productIds removeAllObjects];
    }
}
@end
