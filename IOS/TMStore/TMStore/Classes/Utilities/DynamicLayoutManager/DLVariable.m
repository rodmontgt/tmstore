//
//  DLVariable.m
//  TMStore
//
//  Created by Rishabh Jain on 18/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "DLVariable.h"
#import "DLContent.h"
#import "ProductInfo.h"
#import "DataManager.h"

@implementation DLVariable
- (id)init {
    self = [super init];
    if (self) {
        self.bannerCount = 0;
        self.content = [[NSMutableArray alloc] init]; //DLContent
        self.textStyle = [[DLTextStyle alloc] init]; //DLTextStyle
        self.tileRedirect = false;
        self.tileStyle = [[DLTileStyle alloc] init]; //DLTileStyle
        self.tileType = 0;
        self.tileType_Id = 0;
        self.scrollerCount = 0;
        self.scrollerFor = 0;
        self.scrollerIds = [[NSMutableArray alloc] init];
        self.scrollerType = 0;
        self.tileTitle = @"";

        self.contentProducts = nil;
        self.contentCategories = nil;
        self.dataSourceProducts = nil;
    }
    return self;
}
- (NSMutableArray*)getContentProducts {
    if(self.contentProducts == nil) {
        if (self.content && [self.content count] > 0) {
            self.contentProducts = [[NSMutableArray alloc] init];
            for (DLContent* dlContent in self.content) {
               ProductInfo* pInfo = [ProductInfo getProductWithId:dlContent._id];
                [self.contentProducts addObject:pInfo];
            }
        }
    }
    return self.contentProducts;
}
- (NSMutableArray*)getContentCategories {
    if(self.contentCategories == nil) {
        if (self.content && [self.content count] > 0) {
            self.contentCategories = [[NSMutableArray alloc] init];
            for (DLContent* dlContent in self.content) {
                CategoryInfo* cInfo = [CategoryInfo getWithId:dlContent._id];
                [self.contentCategories addObject:cInfo];
            }
        }
    }
    return self.contentCategories;
}
@end
