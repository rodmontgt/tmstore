//
//  ProductImage.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ProductImage.h"

@implementation ProductImage

-(id)init{
    self = [super init];
    if (self) {
        self._alt = @"";
        self._id = 0;
        self._position = 0;
        self._src = @"";
        self._title = @"";
    }
    return self;
}
@end
