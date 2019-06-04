//
//  ConsentScreenConfig.m
//  TMStore
//
//  Created by Rishabh Jain on 23/10/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "ConsentScreenConfig.h"

@implementation ConsentScreenLayout
- (id)init {
    if (self = [super init]) {
        self.viewType = CS_VIEW_TYPE_NONE;
        self.viewSubType = CS_VIEW_SUB_TYPE_NONE;
        self.contentString = @"";
    }
    return self;
}
@end


@implementation ConsentScreenConfig
static ConsentScreenConfig *csConfigObj = nil;
+ (id)sharedInstance {
    @synchronized(self) {
        if (csConfigObj == nil){
            csConfigObj = [[self alloc] init];
        }
    }
    return csConfigObj;
}
+ (void)resetInstance {
    csConfigObj = nil;
}
- (id)init {
    if (self = [super init]) {
        self.enabled = false;
        self.show_always = false;
        self.layout = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
