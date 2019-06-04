//
//  CWishList.h
//  TMStore
//
//  Created by Vikas Patidar on 22/09/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//
@interface CWishList : NSObject

@property int productId;

@property int quantity;

+ (CWishList*)create:(int)productId quantity:(int)quantity;
+ (NSString*)getId;
+ (void)setId:(NSString*)str;
+ (NSString*)getToken;
+ (void)setToken:(NSString*)token;
+ (NSString*)getUrl;
+ (void)setUrl:(NSString*)url;
+ (NSString*)getSharableUrl;
+ (NSMutableArray*)getAll;
+ (void) clearAll;

@end
