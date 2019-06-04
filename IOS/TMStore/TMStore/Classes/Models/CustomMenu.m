//
//  CustomMenu.m
//  TMStore
//
//  Created by Rishabh Jain on 11/08/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "CustomMenu.h"

@implementation CustomMenuItem
- (id)init{
    self = [super init];
    if (self) {
        _itemId = -1;
        _itemName = @"";
        _itemSlug = @"";
        _itemChildren = [[NSMutableArray alloc] init];
    }
    return self;
}
@end

@implementation CustomMenuChild
- (id)init{
    self = [super init];
    if (self) {
        _itemId = -1;
        _itemMenuOrder = -1;
        _itemName = @"";
        _itemParentId = -1;
        _itemCategoryId = -1;
        _itemUrl = @"";
        _itemChildren = [[NSMutableArray alloc] init];
    }
    return self;
}
@end

@implementation CustomMenu
static CustomMenu *sharedObj = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (sharedObj == nil){
            sharedObj = [[self alloc] init];
        }
    }
    return sharedObj;
}
- (id)init{
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
