//
//  NavDrawItem.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "NavDrawItem.h"

@implementation NavDrawItem

- (id)init{
    self = [super init];
    if (self) {
        self._id = 0;
        self._itemImageId = 0;
        self._name = @"";
    }
    return self;
}
- (id)initWithParameters:(int) _id _name:(NSString *)_name _itemImageId:(int)_itemImageId {
    self = [super init];
    if (self) {
        self._id = _id;
        self._itemImageId = _itemImageId;
        self._name = _name;
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self._id = [decoder decodeIntForKey:@"#1"];
        self._itemImageId = [decoder decodeIntForKey:@"#2"];
        self._name = [decoder decodeObjectForKey:@"#3"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self._id forKey:@"#1"];
    [encoder encodeInt:self._itemImageId forKey:@"#2"];
    [encoder encodeObject:self._name forKey:@"#3"];
}

@end
