//
//  DLObject.m
//  TMStore
//
//  Created by Rishabh Jain on 18/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "DLObject.h"
@implementation DLObject
- (id)init {
    self = [super init];
    if (self) {
        self.col = 0;
        self.objId = 0;
        self.row = 0;
        self.size_x = 0.0f;
        self.size_y = 0.0f;
        self.variable = [[DLVariable alloc] init];//DLVariable
    }
    return self;
}
@end