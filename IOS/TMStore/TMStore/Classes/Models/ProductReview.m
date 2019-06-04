//
//  ProductReview.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ProductReview.h"

@implementation ProductReview

-(id)init{
    self = [super init];
    if (self) {
        self._created_at = NULL;
        self._id = 0;
        self._rating = 0;
        self._review = @"";
        self._reviewer_email = @"";
        self._reviewer_name = @"";
        self._verified = NO;
    }
    return self;
}

@end
