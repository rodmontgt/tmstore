//
//  LineItem.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "LineItem.h"
static NSMutableDictionary* lineItemProductImgUrls;
@implementation ProductMetaItemProperties

- (id)init {
    self = [super init];
    if (self) {
        self._key = @"";
        self._label = @"";
        self._value = @"";
    }
    return self;
};
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self._key = [decoder decodeObjectForKey:@"#1"];
        self._label = [decoder decodeObjectForKey:@"#2"];
        self._value = [decoder decodeObjectForKey:@"#3"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self._key forKey:@"#1"];
    [encoder encodeObject:self._label forKey:@"#2"];
    [encoder encodeObject:self._value forKey:@"#3"];
}

@end



@implementation LineItem
+ (void)setLineItemProductImgUrls:(NSMutableDictionary*)dict {
    lineItemProductImgUrls = dict;
}
- (id)init {
    self = [super init];
    if (self) {
        // initialize instance variables here
        self._id = 0;
        self._subtotal = 0;
        self._subtotal_tax = 0;
        self._total = 0;
        self._total_tax = 0;
        self._price = 0;
        self._quantity = 0;
        self._tax_class = @"";
        self._name = @"";
        self._product_id = 0;
        self._sku = @"";
        self._meta = [[NSMutableArray alloc]init];
    }
    return self;
}
+ (void)setImgUrlOnProductId:(int)productId imgUrl:(NSString*)imgUrl {
    [lineItemProductImgUrls setValue:imgUrl forKey:[NSString stringWithFormat:@"%d", productId]];
}
+ (NSString*)getImgUrlOnProductId:(int)productId {
    NSString* imgUrl = nil;
    NSString* prodIdStr = [NSString stringWithFormat:@"%d", productId];
    if (IS_NOT_NULL(lineItemProductImgUrls, prodIdStr)) {
        imgUrl = GET_VALUE_OBJ(lineItemProductImgUrls, prodIdStr);
    }
    return imgUrl;
}
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self._id = [decoder decodeIntForKey:@"#1"];
        self._subtotal = [decoder decodeFloatForKey:@"#2"];
        self._subtotal_tax = [decoder decodeFloatForKey:@"#3"];
        self._total = [decoder decodeFloatForKey:@"#4"];
        self._total_tax = [decoder decodeFloatForKey:@"#5"];
        self._price = [decoder decodeFloatForKey:@"#6"];
        self._quantity = [decoder decodeIntForKey:@"#7"];
        self._tax_class = [decoder decodeObjectForKey:@"#8"];
        self._name = [decoder decodeObjectForKey:@"#9"];
        self._product_id = [decoder decodeIntForKey:@"#10"];
        self._sku = [decoder decodeObjectForKey:@"#11"];
        self._meta = (NSMutableArray*)[decoder decodeObjectForKey:@"#12"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self._id forKey:@"#1"];
    [encoder encodeFloat:self._subtotal forKey:@"#2"];
    [encoder encodeFloat:self._subtotal_tax forKey:@"#3"];
    [encoder encodeFloat:self._total forKey:@"#4"];
    [encoder encodeFloat:self._total_tax forKey:@"#5"];
    [encoder encodeFloat:self._price forKey:@"#6"];
    [encoder encodeInt:self._quantity forKey:@"#7"];
    [encoder encodeObject:self._tax_class forKey:@"#8"];
    [encoder encodeObject:self._name forKey:@"#9"];
    [encoder encodeInt:self._product_id forKey:@"#10"];
    [encoder encodeObject:self._sku forKey:@"#11"];
    [encoder encodeObject:self._meta forKey:@"#12"];
}

@end
