//
//  DLContent.m
//  TMStore
//
//  Created by Rishabh Jain on 18/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "DLContent.h"
@implementation DLContent
- (id)init {
    self = [super init];
    if (self) {
        self.imgUrl = @"";
        self.name = @"";
        self.display = @"";
        self.redirect_url = @"";
        self.redirect = DL_REDIRECT_NONE;
        self.redirect_id = 0;
        self._id = 0;
        self.bgUrl = @"";
        self.bgColor = [UIColor whiteColor];
    }
    return self;
}
@end
