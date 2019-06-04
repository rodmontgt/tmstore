//
//  Opinion.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 02/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "Opinion.h"

static NSMutableArray* _allOpinionItems = NULL;
static int _notificationCount = 0;
@implementation Opinion
+ (void)setOpinionArray:(NSMutableArray*)array {
    _allOpinionItems = array;
    _notificationCount = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
}
- (id)init {
    self = [super init];
    if (self) {
        _likeCount = 0;
        _likeCountOld = 0;
        _dislikeCount = 0;
        _dislikeCountOld = 0;
        if (_allOpinionItems == NULL) {
            _allOpinionItems = [[AppUser sharedManager] _opinionArray];
        }
        [_allOpinionItems addObject:self];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.product_id = [decoder decodeIntForKey:@"#1"];
        self.likeCount = [decoder decodeIntForKey:@"#2"];
        self.dislikeCount = [decoder decodeIntForKey:@"#3"];
        self.likeCountOld = [decoder decodeIntForKey:@"#4"];
        self.dislikeCountOld = [decoder decodeIntForKey:@"#5"];
        self.isProductFetched = [decoder decodeBoolForKey:@"#6"];
        self.pollId = [decoder decodeObjectForKey:@"#7"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.product_id forKey:@"#1"];
    [encoder encodeInt:self.likeCount forKey:@"#2"];
    [encoder encodeInt:self.dislikeCount forKey:@"#3"];
    [encoder encodeInt:self.likeCountOld forKey:@"#4"];
    [encoder encodeInt:self.dislikeCountOld forKey:@"#5"];
    [encoder encodeBool:self.isProductFetched forKey:@"#6"];
    [encoder encodeObject:self.pollId forKey:@"#7"];
}
+ (Opinion*)addProduct:(int)productId pollId:(NSString*)pollId likeCount:(int)likeCount dislikeCount:(int)dislikeCount {
    for (Opinion* c in _allOpinionItems) {
        if(c.product_id == productId && [c.pollId isEqualToString:pollId]) {
            c.likeCount = likeCount;
            c.dislikeCount = dislikeCount;
            ProductInfo *pInfo = [ProductInfo getProductWithId:c.product_id];
            if (pInfo) {
                c.isProductFetched = true;
                pInfo.pollLikeCount = c.likeCount;
                pInfo.pollDislikeCount = c.dislikeCount;
            }else{
                c.isProductFetched = false;
                AppUser* appUser = [AppUser sharedManager];
                BOOL isExists = false;
                for (NSNumber* numObj in appUser._needProductsArrayForOpinion) {
                    if ([numObj intValue] == productId) {
                        isExists = true;
                        break;
                    }
                }
                if (isExists == false) {
                    [appUser._needProductsArrayForOpinion addObject:[NSNumber numberWithInt:productId]];
                }
            }
            return c;
        }
    }
    Opinion* c = [[Opinion alloc] init];
    c.pollId = pollId;
    c.product_id = productId;
    c.likeCount = likeCount;
    c.dislikeCount = dislikeCount;
    ProductInfo *pInfo = [ProductInfo getProductWithId:c.product_id];
    if (pInfo) {
        c.isProductFetched = true;
        pInfo.pollLikeCount = c.likeCount;
        pInfo.pollDislikeCount = c.dislikeCount;
    }else{
        c.isProductFetched = false;
        AppUser* appUser = [AppUser sharedManager];
        BOOL isExists = false;
        for (NSNumber* numObj in appUser._needProductsArrayForOpinion) {
            if ([numObj intValue] == productId) {
                isExists = true;
                break;
            }
        }
        if (isExists == false) {
            [appUser._needProductsArrayForOpinion addObject:[NSNumber numberWithInt:productId]];
        }
    }
    return c;
}
+ (NSMutableArray*)getAll {
    return _allOpinionItems;
}
+ (int) getItemCount {
    return (int)[_allOpinionItems count];
}
+ (int)getNotificationItemCount {
    int changedOpinions = 0;
    for (Opinion* c in _allOpinionItems) {
        if (c.likeCountOld != c.likeCount || c.dislikeCountOld != c.dislikeCount ) {
            changedOpinions++;
        }
        c.likeCountOld = c.likeCount;
        c.dislikeCountOld = c.dislikeCount;
    }
    _notificationCount = changedOpinions;
    return _notificationCount;
}
+ (Opinion*)getOpinionWithPollId:(NSString*)pollId {
    for (Opinion* c in _allOpinionItems) {
        if ([c.pollId isEqualToString:pollId]) {
            return c;
        }
    }
    return nil;
}
+ (Opinion*)getOpinionWithProductId:(int)productId {
    for (Opinion* c in _allOpinionItems) {
        if (c.product_id == productId) {
            return c;
        }
    }
    return nil;
}
@end
