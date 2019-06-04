//
//  Opinion.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 02/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Variables.h"
#import "AppUser.h"
#import "ParseHelper.h"
#import "ProductInfo.h"

@interface Opinion : NSObject
@property int product_id;
@property int likeCount;
@property int dislikeCount;
@property int likeCountOld;
@property int dislikeCountOld;
@property BOOL isProductFetched;
@property NSString* pollId;

- (id)init;
+ (Opinion*)addProduct:(int)productId pollId:(NSString*)pollId likeCount:(int)likeCount dislikeCount:(int)dislikeCount;

+ (NSMutableArray*)getAll;
+ (int)getItemCount;
+ (int)getNotificationItemCount;
+ (Opinion*)getOpinionWithPollId:(NSString*)pollId;
+ (Opinion*)getOpinionWithProductId:(int)productId;
+ (void)setOpinionArray:(NSMutableArray*)array;
@end
