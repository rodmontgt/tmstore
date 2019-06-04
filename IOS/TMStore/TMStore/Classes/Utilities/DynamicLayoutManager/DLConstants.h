//
//  DLConstants.h
//  TMStore
//
//  Created by Rishabh Jain on 18/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#ifndef DLConstants_h
#define DLConstants_h

#define DL_ROWS_PARTITION 24
#define DL_COLS_PARTITION 12

typedef enum : NSUInteger {//used in dlvariable
    DL_TILE_TYPE_UNSELECTED             = 0,
    DL_TILE_TYPE_CATEGORY               = 1,
    DL_TILE_TYPE_PRODUCT                = 3,//before it is 2
    DL_TILE_TYPE_CARROUSAL_HORIZONTAL   = 4,
    DL_TILE_TYPE_CARROUSAL_VERTICAL     = 8

} DL_TILE_TYPE;

typedef enum : NSUInteger {
    DL_TILE_TYPE_ID_UNSELECTED          = -1
    
} DL_TILE_TYPE_ID;

typedef enum : NSUInteger {
    DL_REDIRECT_NONE,
    DL_REDIRECT_TRUE,
    DL_REDIRECT_FALSE,
    DL_REDIRECT_URL,
    DL_REDIRECT_PRODUCT,
    DL_REDIRECT_CATEGORY,
    DL_REDIRECT_CART,
    DL_REDIRECT_WISHLIST
} DL_REDIRECT;

typedef enum : NSUInteger {
    DL_SCROLL_FOR_PRODUCT,
    DL_SCROLL_FOR_CATEGORIES,
    DL_SCROLL_FOR_CATEGORY,
    DL_SCROLL_FOR_PROMOTIONAL,
    DL_SCROLL_FOR_VENDOR
} DL_SCROLL_FOR;

typedef enum : NSUInteger {
    DL_PROMOTIONAL_IDS_TRENDING         = -1,
    DL_PROMOTIONAL_IDS_BESTDEALS        = -2,
    DL_PROMOTIONAL_IDS_FRESHARRIVALS    = -3,
    DL_PROMOTIONAL_IDS_RECENTLY_VIEWED  = -4,
} DL_PROMOTIONAL_IDS;

typedef enum : NSUInteger {
    DL_SCROLLER_TYPE_HORIZONTAL,
    DL_SCROLLER_TYPE_VERTICAL
} DL_SCROLLER_TYPE;

typedef enum : NSUInteger {
    DL_SCALE_TYPE_CENTER                = 0,
    DL_SCALE_TYPE_CENTER_CROP           = 1,
    DL_SCALE_TYPE_CENTER_INSIDE         = 2,
    DL_SCALE_TYPE_FIT_CENTER            = 3,
    DL_SCALE_TYPE_FIT_END               = 4,
    DL_SCALE_TYPE_FIT_START             = 5,
    DL_SCALE_TYPE_FIT_XY                = 6
} DL_SCALE_TYPE;

typedef enum : NSUInteger {
    DL_TEXT_STYLE_ALIGN_H_LEFT,
    DL_TEXT_STYLE_ALIGN_H_RIGHT,
    DL_TEXT_STYLE_ALIGN_H_CENTER
} DL_TEXT_STYLE_ALIGN_H;

typedef enum : NSUInteger {
    DL_TEXT_STYLE_ALIGN_V_ABOVE,
    DL_TEXT_STYLE_ALIGN_V_BELOW,
    DL_TEXT_STYLE_ALIGN_V_TOP,
    DL_TEXT_STYLE_ALIGN_V_BOTTOM,
    DL_TEXT_STYLE_ALIGN_V_CENTER,
    DL_TEXT_STYLE_ALIGN_V_HIDE
} DL_TEXT_STYLE_ALIGN_V;

#endif /* DLConstants_h */
