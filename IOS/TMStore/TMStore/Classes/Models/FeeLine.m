//
//  FeeLine.m
//  TMStore
//
//  Created by Rishabh Jain on 03/11/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "FeeLine.h"
@implementation FeeLine
- (id)init {
    self = [super init];
    if (self) {
        self.feeline_id = -1;
        self.title = @"";
        self.taxable = false;
        self.tax_class = @"";
        self.total = 0.0f;
        self.total_tax = 0.0f;
    }
    return self;
}
@end