//
//  DLTileStyle.m
//  TMStore
//
//  Created by Rishabh Jain on 18/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "DLTileStyle.h"
@implementation DLTileStyle
- (id)init {
    self = [super init];
    if (self) {
        self.bgColor = [UIColor darkGrayColor];
        self.textColor = [UIColor lightGrayColor];
        self.fontWeight = 0;
        self.fontSize = 0;
        self.margin = CGRectMake(0, 0, 0, 0);
        self.padding = CGRectMake(0, 0, 0, 0);
        self.scaleType = DL_SCALE_TYPE_FIT_CENTER;
        self.textBgColor = [UIColor darkTextColor];
    }
    return self;
}
@end