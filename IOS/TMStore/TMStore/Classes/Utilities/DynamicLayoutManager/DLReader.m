//
//  DLReader.m
//  TMStore
//
//  Created by Rishabh Jain on 18/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "DLReader.h"
#import "DLManager.h"

#define ENABLE_LOCAL_LAYOUT_FILE 0
#define DL_LOCAL_JSON_FILE_NAME @"dynamic_layout_vertical"

@implementation DLReader
+ (id)getInstance {
    static DLReader *dynReader = nil;
    @synchronized(self) {
        if (dynReader == nil)
            dynReader = [[self alloc] init];
    }
    return dynReader;
}
- (id)init {
    if (self = [super init]) {

        NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* fileName = @"dynamic_layout_server.json";
        NSString* pathServerFile = [filePath stringByAppendingPathComponent:fileName];//FILE FROM SERVER
        NSString *pathLocalFile = [[NSBundle mainBundle] pathForResource:DL_LOCAL_JSON_FILE_NAME ofType:@"json"];
        NSString* selectedFilePath = pathServerFile;
#if ENABLE_DEBUGGING
	#if ENABLE_LOCAL_LAYOUT_FILE
		selectedFilePath = pathLocalFile;
	#else
        selectedFilePath = pathServerFile;
	#endif
#endif
        NSData *data = [NSData dataWithContentsOfFile:selectedFilePath];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        //NSLog(@"json = %@", json);
        
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //RLOG(@"jsonString1 = %@", jsonString);
        
        if (json) {
            if (IS_NOT_NULL(json, @"homeElements")) {
                NSArray* homeElements = GET_VALUE_OBJECT(json, @"homeElements");
                [self readHomePageElements:homeElements];
            }
        }
    }
    return self;
}
- (void)readHomePageElements:(NSArray*)homeElements {
    DLManager* dlManager = [DLManager sharedManager];
    [dlManager.homeDLObjects removeAllObjects];
    for (NSDictionary* dict in homeElements) {
        DLObject* dlObject = [self parseDLObject:dict];
        [dlManager.homeDLObjects addObject:dlObject];
    }
}
- (DLObject*)parseDLObject:(NSDictionary*)dict {
    if (dict == nil || ![dict isKindOfClass:[NSDictionary class]]) {
        NSLog(@"parseDLObject: unable to parse");
        return nil;
    }
    DLObject* dlObj = [[DLObject alloc] init];
    if (IS_NOT_NULL(dict, @"col")) {
        dlObj.col = GET_VALUE_INT(dict, @"col") - 1;
    }
    if (IS_NOT_NULL(dict, @"id")) {
        dlObj.objId = GET_VALUE_INT(dict, @"id");
    }
    if (IS_NOT_NULL(dict, @"row")) {
        dlObj.row = GET_VALUE_INT(dict, @"row") - 1;
    }
    if (IS_NOT_NULL(dict, @"size_x")) {
        dlObj.size_x = GET_VALUE_FLOAT(dict, @"size_x");
    }
    if (IS_NOT_NULL(dict, @"size_y")) {
        dlObj.size_y = GET_VALUE_FLOAT(dict, @"size_y");
    }
    if (IS_NOT_NULL(dict, @"variables")) {
        NSDictionary* variable = GET_VALUE_OBJECT(dict, @"variables");
        dlObj.variable = [self parseDLVariable:variable];
    }
    return dlObj;
}
- (DLVariable*)parseDLVariable:(NSDictionary*)dict {
    if (dict == nil || ![dict isKindOfClass:[NSDictionary class]]) {
        NSLog(@"parseDLVariable: unable to parse");
        return nil;
    }
    DLVariable* dlVariable = [[DLVariable alloc] init];
    
    if (IS_NOT_NULL(dict, @"content")) {
        NSArray* contentArray = GET_VALUE_OBJECT(dict, @"content");
        if (contentArray) {
            for (NSDictionary* dict1 in contentArray) {
                DLContent* dlContent = [self parseDLContent:dict1];
                [dlVariable.content addObject:dlContent];
            }
        }
    }
    if (IS_NOT_NULL(dict, @"textStyle")) {
        NSDictionary* dict1 = GET_VALUE_OBJECT(dict, @"textStyle");
        dlVariable.textStyle = [self parseDLTextStyle:dict1];
    }
    if (IS_NOT_NULL(dict, @"tileStyle")) {
        NSDictionary* dict1 = GET_VALUE_OBJECT(dict, @"tileStyle");
        dlVariable.tileStyle = [self parseDLTileStyle:dict1];
    }
    if (IS_NOT_NULL(dict, @"tileRedirect")) {
        dlVariable.tileRedirect = GET_VALUE_BOOL(dict, @"tileRedirect");
    }
    if (IS_NOT_NULL(dict, @"scrollerFor")) {
//        product,categories,category,promotional,vendor
        NSString* scrollfor = GET_VALUE_OBJECT(dict, @"scrollerFor");
        if ([scrollfor isEqualToString:@"categories"]) {
            dlVariable.scrollerFor = DL_SCROLL_FOR_CATEGORIES;
        } else if ([scrollfor isEqualToString:@"category"]) {
            dlVariable.scrollerFor = DL_SCROLL_FOR_CATEGORY;
        } else if ([scrollfor isEqualToString:@"product"]) {
            dlVariable.scrollerFor = DL_SCROLL_FOR_PRODUCT;
        } else if ([scrollfor isEqualToString:@"promotional"]) {
            dlVariable.scrollerFor = DL_SCROLL_FOR_PROMOTIONAL;
        } else if ([scrollfor isEqualToString:@"vendor"]) {
            dlVariable.scrollerFor = DL_SCROLL_FOR_VENDOR;
        }
    }
    if (IS_NOT_NULL(dict, @"scrollerType")) {
//        horizontal/vertical
        NSString* scrollerType = GET_VALUE_OBJECT(dict, @"scrollerType");
        if ([scrollerType isEqualToString:@"horizontal"]) {
            dlVariable.scrollerType = DL_SCROLLER_TYPE_HORIZONTAL;
        } else if ([scrollerType isEqualToString:@"vertical"]) {
            dlVariable.scrollerType = DL_SCROLLER_TYPE_VERTICAL;
        }
    }
    if (IS_NOT_NULL(dict, @"tileTitle")) {
        dlVariable.tileTitle = GET_VALUE_OBJECT(dict, @"tileTitle");
    }
    if (IS_NOT_NULL(dict, @"bannerCount")) {
        dlVariable.bannerCount = GET_VALUE_INT(dict, @"bannerCount");
    }
    if (IS_NOT_NULL(dict, @"tileType")) {
        dlVariable.tileType = GET_VALUE_INT(dict, @"tileType");
        switch (dlVariable.tileType) {
            case DL_TILE_TYPE_CARROUSAL_HORIZONTAL:
            case DL_TILE_TYPE_CARROUSAL_VERTICAL:
            case DL_TILE_TYPE_CATEGORY:
            case DL_TILE_TYPE_PRODUCT:
            case DL_TILE_TYPE_UNSELECTED:
                break;
            default:
                dlVariable.tileType = DL_TILE_TYPE_UNSELECTED;
                break;
        }
    }
    if (IS_NOT_NULL(dict, @"tileType_Id")) {
        dlVariable.tileType_Id = GET_VALUE_INT(dict, @"tileType_Id");
    }
    if (IS_NOT_NULL(dict, @"scrollerCount")) {
        dlVariable.scrollerCount = GET_VALUE_INT(dict, @"scrollerCount");
    }
    if (IS_NOT_NULL(dict, @"scrollerIds")) {
        id scrollerIds = GET_VALUE_OBJ(dict, @"scrollerIds");
        if ([scrollerIds isKindOfClass:[NSArray class]]) {
            dlVariable.scrollerIds = scrollerIds;
        }
        else {
            dlVariable.scrollerIds =[[NSMutableArray alloc] init];
            [dlVariable.scrollerIds addObject:scrollerIds];
        }
    }
    
    return dlVariable;
}
- (DLContent*)parseDLContent:(NSDictionary*)dict {
    if (dict == nil || ![dict isKindOfClass:[NSDictionary class]]) {
        NSLog(@"parseDLContent: unable to parse");
        return nil;
    }
    DLContent* dlContent = [[DLContent alloc] init];
    if (IS_NOT_NULL(dict, @"img")) {
        dlContent.imgUrl = GET_VALUE_OBJECT(dict, @"img");
    }
    if (IS_NOT_NULL(dict, @"name")) {
        dlContent.name = GET_VALUE_OBJECT(dict, @"name");
    } if (IS_NOT_NULL(dict, @"display")) {
        dlContent.display = GET_VALUE_OBJECT(dict, @"display");
    }
    if (IS_NOT_NULL(dict, @"id")) {
        dlContent._id = GET_VALUE_INT(dict, @"id");
    }
    if (IS_NOT_NULL(dict, @"redirect")) {
        id r = GET_VALUE_OBJECT(dict, @"redirect");
        if ([r isKindOfClass:[NSNumber class]]) {
            BOOL redirect = [r boolValue];
            if (redirect) {
                dlContent.redirect = DL_REDIRECT_TRUE;
            } else {
                dlContent.redirect = DL_REDIRECT_FALSE;
            }
        }
        else if ([r isKindOfClass:[NSString class]]) {
            NSString* redirect = r;
            if ([[redirect lowercaseString] isEqualToString:@"noredirect"]) {
                dlContent.redirect = DL_REDIRECT_NONE;
            } else if ([[redirect lowercaseString] isEqualToString:@"redirect"]) {
                dlContent.redirect = DL_REDIRECT_URL;
            } else if ([[redirect lowercaseString] isEqualToString:@"product"]) {
                dlContent.redirect = DL_REDIRECT_PRODUCT;
            } else if ([[redirect lowercaseString] isEqualToString:@"category"]) {
                dlContent.redirect = DL_REDIRECT_CATEGORY;
            } else if ([[redirect lowercaseString] isEqualToString:@"cart"]) {
                dlContent.redirect = DL_REDIRECT_CART;
            } else if ([[redirect lowercaseString] isEqualToString:@"wishlist"]) {
                dlContent.redirect = DL_REDIRECT_WISHLIST;
            }
        }
        else {
            dlContent.redirect = DL_REDIRECT_NONE;
        }
//        noredirect
//        redirect
//        product
//        category
//        cart
//        wishlist
//        false/true
    }
    if (IS_NOT_NULL(dict, @"redirect_id")) {
        id r = GET_VALUE_OBJECT(dict, @"redirect_id");
        if ([r isKindOfClass:[NSNumber class]]) {
            dlContent.redirect_id = [r intValue];
            dlContent.redirect_url = @"";
        } else if ([r isKindOfClass:[NSString class]]) {
            dlContent.redirect_id = -1;
            dlContent.redirect_url = r;
        } else {
            dlContent.redirect_id = -1;
            dlContent.redirect_url = @"";
        }
    }
    if (IS_NOT_NULL(dict, @"redirect_url")) {
        dlContent.redirect_url = GET_VALUE_OBJECT(dict, @"redirect_url");
    }
    if (IS_NOT_NULL(dict, @"bgUrl")) {
        dlContent.bgUrl = GET_VALUE_OBJECT(dict, @"bgUrl");
    }
    if (IS_NOT_NULL(dict, @"bgcolor")) {
        dlContent.bgColor = [Utility colorWithHexString:GET_VALUE_OBJECT(dict, @"bgcolor") alpha:1.0f];
    }
    return dlContent;
}
- (DLTextStyle*)parseDLTextStyle:(NSDictionary*)dict {
    if (dict == nil || ![dict isKindOfClass:[NSDictionary class]]) {
        NSLog(@"parseDLTextStyle: unable to parse");
        return nil;
    }
    DLTextStyle* dlTextStyle = [[DLTextStyle alloc] init];
    if (IS_NOT_NULL(dict, @"position")) {
        NSString* alignment = GET_VALUE_OBJECT(dict, @"position");
        //        left,right,center
        if ([[alignment lowercaseString] isEqualToString:@"left"]) {
            dlTextStyle.alignmentH = DL_TEXT_STYLE_ALIGN_H_LEFT;
        } else if ([[alignment lowercaseString] isEqualToString:@"right"]) {
            dlTextStyle.alignmentH = DL_TEXT_STYLE_ALIGN_H_RIGHT;
        } else if ([[alignment lowercaseString] isEqualToString:@"center"]) {
            dlTextStyle.alignmentH = DL_TEXT_STYLE_ALIGN_H_CENTER;
        }
    }
    if (IS_NOT_NULL(dict, @"alignment")) {
        NSString* alignment = GET_VALUE_OBJECT(dict, @"alignment");
        //        above,below,top,bottom,center,hide
        if ([[alignment lowercaseString] isEqualToString:@"above"]) {
            dlTextStyle.alignmentV = DL_TEXT_STYLE_ALIGN_V_ABOVE;
        } else if ([[alignment lowercaseString] isEqualToString:@"below"]) {
            dlTextStyle.alignmentV = DL_TEXT_STYLE_ALIGN_V_BELOW;
        } else if ([[alignment lowercaseString] isEqualToString:@"top"]) {
            dlTextStyle.alignmentV = DL_TEXT_STYLE_ALIGN_V_TOP;
        } else if ([[alignment lowercaseString] isEqualToString:@"bottom"]) {
            dlTextStyle.alignmentV = DL_TEXT_STYLE_ALIGN_V_BOTTOM;
        } else if ([[alignment lowercaseString] isEqualToString:@"center"]) {
            dlTextStyle.alignmentV = DL_TEXT_STYLE_ALIGN_V_CENTER;
        } else if ([[alignment lowercaseString] isEqualToString:@"hide"]) {
            dlTextStyle.alignmentV = DL_TEXT_STYLE_ALIGN_V_HIDE;
        }
    }
    return dlTextStyle;
}
- (DLTileStyle*)parseDLTileStyle:(NSDictionary*)dict {
    if (dict == nil || ![dict isKindOfClass:[NSDictionary class]]) {
        NSLog(@"parseDLTileStyle: unable to parse");
        return nil;
    }
    DLTileStyle* dlTileStyle = [[DLTileStyle alloc] init];

    if (IS_NOT_NULL(dict, @"bgcolor")) {
        dlTileStyle.bgColor = [Utility colorWithHexString:GET_VALUE_OBJECT(dict, @"bgcolor") alpha:1.0f];
    }
    if (IS_NOT_NULL(dict, @"color")) {
        dlTileStyle.textColor = [Utility colorWithHexString:GET_VALUE_OBJECT(dict, @"color") alpha:1.0f];
    }
    if (IS_NOT_NULL(dict, @"textbgcolor")) {
        dlTileStyle.textBgColor = [Utility colorWithHexString:GET_VALUE_OBJECT(dict, @"textbgcolor") alpha:1.0f];
    }
    
    if (IS_NOT_NULL(dict, @"fontWeight")) {
        dlTileStyle.fontWeight = GET_VALUE_INT(dict, @"fontWeight");
    }
    if (IS_NOT_NULL(dict, @"fontsize")) {
        dlTileStyle.fontSize = GET_VALUE_INT(dict, @"fontsize");
    }
    if (IS_NOT_NULL(dict, @"scaletype")) {
        int scaleType = GET_VALUE_INT(dict, @"scaletype");
        switch (scaleType) {
            case DL_SCALE_TYPE_CENTER:
                dlTileStyle.scaleType = DL_SCALE_TYPE_CENTER;
            break;
            case DL_SCALE_TYPE_CENTER_CROP:
                dlTileStyle.scaleType = DL_SCALE_TYPE_CENTER_CROP;
            break;
            case DL_SCALE_TYPE_CENTER_INSIDE:
                dlTileStyle.scaleType = DL_SCALE_TYPE_CENTER_INSIDE;
            break;
            case DL_SCALE_TYPE_FIT_CENTER:
                dlTileStyle.scaleType = DL_SCALE_TYPE_FIT_CENTER;
            break;
            case DL_SCALE_TYPE_FIT_END:
                dlTileStyle.scaleType = DL_SCALE_TYPE_FIT_END;
            break;
            case DL_SCALE_TYPE_FIT_START:
                dlTileStyle.scaleType = DL_SCALE_TYPE_FIT_START;
            break;
            case DL_SCALE_TYPE_FIT_XY:
                dlTileStyle.scaleType = DL_SCALE_TYPE_FIT_XY;
            break;
            default:
            break;
        }
    }
    
    if (IS_NOT_NULL(dict, @"margin")) {
        NSArray* marginArray = GET_VALUE_OBJECT(dict, @"margin");
        if (marginArray && [marginArray count] == 4) {
            dlTileStyle.margin = CGRectMake(
                                            [[marginArray objectAtIndex:0] floatValue],
                                            [[marginArray objectAtIndex:1] floatValue],
                                            [[marginArray objectAtIndex:2] floatValue],
                                            [[marginArray objectAtIndex:3] floatValue]);
        }
    }
    if (IS_NOT_NULL(dict, @"padding")) {
        NSArray* paddingArray = GET_VALUE_OBJECT(dict, @"padding");
        if (paddingArray && [paddingArray count] == 4) {
            dlTileStyle.padding = CGRectMake(
                                             [[paddingArray objectAtIndex:0] floatValue],
                                             [[paddingArray objectAtIndex:1] floatValue],
                                             [[paddingArray objectAtIndex:2] floatValue],
                                             [[paddingArray objectAtIndex:3] floatValue]);
        }
    }
    return dlTileStyle;
}

@end
