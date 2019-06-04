//
//  DLTextStyle.m
//  TMStore
//
//  Created by Rishabh Jain on 18/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "DLTextStyle.h"
@implementation DLTextStyle
- (id)init {
    self = [super init];
    if (self) {
        self.alignmentH = DL_TEXT_STYLE_ALIGN_H_CENTER;
        self.alignmentV = DL_TEXT_STYLE_ALIGN_V_CENTER;
    }
    return self;
}
@end