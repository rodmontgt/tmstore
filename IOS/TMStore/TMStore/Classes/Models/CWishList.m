//
//  CWishList.m
//  TMStore
//
//  Created by Vikas Patidar on 22/09/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWishList.h"

@implementation CWishList

static NSString* _id = @"";
static NSString* _url = @"";
static NSString* _token = @"";
static NSMutableArray* items = nil;

+ (CWishList*)create:(int)productId quantity:(int)quantity {
    
    if (items == nil) {
        items = [[NSMutableArray alloc] init];
    }
    
    
    if(items != nil) {
        for(CWishList* item in items) {
            if(item.productId == productId) {
                return item;
            }
        }
    }

    CWishList* item = [[CWishList alloc] init];
    item.productId = productId;
    item.quantity = quantity;
    [items addObject:item];
    return item;
}

+ (NSString*)getId {
    return _id;
}

+ (void)setId:(NSString*)str{
    _id = str;
}

+ (NSString*)getToken{
    return _token;
}

+ (void)setToken:(NSString*)token{
    _token = token;
}

+ (NSString*)getUrl{
    return _url;}

+ (void)setUrl:(NSString*)url{
    _url = url;
}

+ (NSString*)getSharableUrl{
    return [NSString stringWithFormat:@"%@%@", _url, _token];
}

+ (NSMutableArray*)getAll{
    return items;
}

+ (void)clearAll{
    if(items != nil) {
        [items removeAllObjects];
    }
}

@end
