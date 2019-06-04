//
//  CustomMenu.h
//  TMStore
//
//  Created by Rishabh Jain on 11/08/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Variables.h"


@interface CustomMenuChild : NSObject
@property int itemId;
@property int itemMenuOrder;
@property NSString* itemName;
@property int itemParentId;
@property int itemCategoryId;
@property NSString* itemUrl;
@property NSMutableArray* itemChildren;//CustomMenuChild
@end

@interface CustomMenuItem : NSObject
@property int itemId;
@property NSString* itemName;
@property NSString* itemSlug;
@property NSMutableArray* itemChildren;//CustomMenuChild
@end

@interface CustomMenu : NSObject
@property NSMutableArray* items;//CustomMenuItem
+ (id)sharedManager;
@end
