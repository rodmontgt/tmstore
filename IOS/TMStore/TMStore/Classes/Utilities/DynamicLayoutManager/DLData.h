//
//  DLData.h
//  TMStore
//
//  Created by Rishabh Jain on 18/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DLTileStyle : NSObject
@property NSString* bgcolor;
@property NSString* color;
@property int fontWeight;
@property int fontsize;
@property CGRect margin;
@property CGRect padding;
@property int scaletype;
@property NSString* textbgcolor;
- (id)init;
@end

@interface DLTextStyle : NSObject
@property NSString* alignment;
@property NSString* position;
- (id)init;
@end

@interface DLContent : NSObject
@property NSString* img;
@property NSString* redirect;
@property int redirect_id;
- (id)init;
@end

@interface DLVariables : NSObject
@property int bannerCount;
@property NSMutableArray* content; //DLContent
@property DLTextStyle* textStyle;
@property BOOL tileRedirect;
@property DLTileStyle* tileStyle;
@property int tileType;
@property int tileType_Id;
@property int scrollerCount;
@property NSString* scrollerFor;
@property int scrollerIds;
@property NSString* scrollerType;
@property NSString* tileTitle;
- (id)init;
@end

@interface DLObject : NSObject
@property int col;
@property int _id;
@property int row;
@property float size_x;
@property float size_y;
@property DLVariables* variables;
- (id)init;
@end


