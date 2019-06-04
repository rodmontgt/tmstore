//
//  DLVariable.h
//  TMStore
//
//  Created by Rishabh Jain on 18/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DLConstants.h"
#import "DLTileStyle.h"
#import "DLTextStyle.h"

@interface DLVariable : NSObject
@property int bannerCount;
@property NSMutableArray* content;//Array of DLContent
@property DLTextStyle* textStyle;//DLTextStyle
@property BOOL tileRedirect;
@property DLTileStyle* tileStyle;//DLTileStyle
@property DL_TILE_TYPE tileType;
@property int tileType_Id;
@property int scrollerCount;
@property DL_SCROLL_FOR scrollerFor;
@property NSMutableArray* scrollerIds;
@property DL_SCROLLER_TYPE scrollerType;
@property NSString* tileTitle;
- (id)init;
- (NSMutableArray*)getContentProducts;
- (NSMutableArray*)getContentCategories;

@property NSMutableArray* contentProducts;
@property NSMutableArray* contentCategories;
@property NSMutableArray* dataSourceProducts;
@end
