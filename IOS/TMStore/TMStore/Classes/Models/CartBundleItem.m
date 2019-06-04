//
//  CartBundleItem.m
//  TMStore
//
//  Created by Rishabh Jain on 08/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "CartBundleItem.h"
#import "ProductInfo.h"
@implementation CartBundleItem
- (id)init {
    self = [super init];
    if (self) {
        self.productId = -1;
        self.title = @"";
        self.price = 0.0f;
        self.imgUrl = @"";
        self.quantity = 0;
        self.product = nil;
    }
    return self;
}
- (float)getTotalPrice {
   return self.price * self.quantity;
}
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.productId = [decoder decodeIntForKey:@"#1"];
        self.title = [decoder decodeObjectForKey:@"#2"];
        self.price = [decoder decodeFloatForKey:@"#3"];
        self.imgUrl = [decoder decodeObjectForKey:@"#4"];
        self.quantity = [decoder decodeIntForKey:@"#5"];
        self.product = [ProductInfo getProductWithId:self.productId];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.productId forKey:@"#1"];
    [encoder encodeObject:self.title forKey:@"#2"];
    [encoder encodeFloat:self.price forKey:@"#3"];
    [encoder encodeObject:self.imgUrl forKey:@"#4"];
    [encoder encodeInt:self.quantity forKey:@"#5"];
}
@end