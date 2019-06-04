//
//  DLData.m
//  TMStore
//
//  Created by Rishabh JainDLData.h on 18/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "DLData.h"
@implementation DLTileStyle
- (id)init {
    self = [super init];
    if (self) {
        self.bgcolor = @"";
        self.color = @"";
        self.fontWeight = 0;
        self.fontsize = 0;
        self.margin = CGRectMake(0, 0, 0, 0);
        self.padding = CGRectMake(0, 0, 0, 0);
        self.scaletype = 0;
        self.textbgcolor = @"";
    }
    return self;
}
@end

@implementation DLTextStyle
- (id)init {
    self = [super init];
    if (self) {
        self.alignment = @"";
        self.position = @"";
    }
    return self;
}
@end

@implementation DLContent
- (id)init {
    self = [super init];
    if (self) {
        self.img = @"";
        self.redirect = @"";
        self.redirect_id = 0;
    }
    return self;
}
@end

@implementation DLVariables
- (id)init {
    self = [super init];
    if (self) {
        self.bannerCount = 0;
        self.content = [[NSMutableArray alloc] init]; //DLContent
        self.textStyle = nil; //DLTextStyle
        self.tileRedirect = false;
        self.tileStyle = nil; //DLTileStyle
        self.tileType = 0;
        self.tileType_Id = 0;
        self.scrollerCount = 0;
        self.scrollerFor = @"";
        self.scrollerIds = 0;
        self.scrollerType = @"";
        self.tileTitle = @"";
    }
    return self;
}
@end

@implementation DLObject
- (id)init {
    self = [super init];
    if (self) {
        self.col = 0;
        self._id = 0;
        self.row = 0;
        self.size_x = 0.0f;
        self.size_y = 0.0f;
        self.variables = nil;//DLVariables
    }
    return self;
}
@end