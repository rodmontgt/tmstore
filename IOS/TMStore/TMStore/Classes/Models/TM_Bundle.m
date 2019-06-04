//
//  TM_Bundle.m
//  TMStore
//
//  Created by Rishabh Jain on 05/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "TM_Bundle.h"
#import "ProductInfo.h"
@implementation TM_Bundle
- (id)init {
    self = [super init];
    if (self) {
        self.productId = -1;
        self.product = nil;
        self.hide_thumbnail = false;
        self.override_title = false;
        self.override_description = false;
        self.optional = false;
        self.bundle_quantity = 1;
        self.bundle_discount = 1;
        self.visibility = true;
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.productId = [decoder decodeIntForKey:@"#1"];
        if (self.productId != -1) {
            self.product = [ProductInfo getProductWithId:self.productId];
        }
        self.hide_thumbnail = [decoder decodeBoolForKey:@"#2"];
        self.override_title = [decoder decodeBoolForKey:@"#3"];
        self.override_description = [decoder decodeBoolForKey:@"#4"];
        self.optional = [decoder decodeBoolForKey:@"#5"];
        self.bundle_quantity = [decoder decodeIntForKey:@"#6"];
        self.bundle_discount = [decoder decodeIntForKey:@"#7"];
        self.visibility = [decoder decodeBoolForKey:@"#8"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    if (((ProductInfo*)self.product)) {
        [encoder encodeInt:((ProductInfo*)self.product)._id forKey:@"#1"];
    }
    [encoder encodeBool:self.hide_thumbnail forKey:@"#2"];
    [encoder encodeBool:self.override_title forKey:@"#3"];
    [encoder encodeBool:self.override_description forKey:@"#4"];
    [encoder encodeBool:self.optional forKey:@"#5"];
    [encoder encodeInt:self.bundle_quantity forKey:@"#6"];
    [encoder encodeInt:self.bundle_discount forKey:@"#7"];
    [encoder encodeBool:self.visibility forKey:@"#8"];
}
@end