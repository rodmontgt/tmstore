//
//  ConsentScreenConfig.h
//  TMStore
//
//  Created by Rishabh Jain on 23/10/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

enum CS_VIEW_TYPE {
    CS_VIEW_TYPE_NONE,
    CS_VIEW_TYPE_TEXT,
    CS_VIEW_TYPE_IMAGE,
    CS_VIEW_TYPE_BUTTON,
    CS_VIEW_TYPE_TOTAL
};
enum CS_VIEW_SUB_TYPE {
    CS_VIEW_SUB_TYPE_NONE,
    CS_VIEW_SUB_TYPE_NORMAL,
    CS_VIEW_SUB_TYPE_HEADER,
    CS_VIEW_SUB_TYPE_TOTAL
};
@interface ConsentScreenLayout : NSObject
@property enum CS_VIEW_TYPE viewType;
@property enum CS_VIEW_SUB_TYPE viewSubType;
@property NSString* contentString;
@end


@interface ConsentScreenConfig : NSObject
+ (id)sharedInstance;
+ (void)resetInstance;
@property BOOL enabled;
@property BOOL show_always;
@property NSMutableArray* layout;//Array of ConsentScreenLayout
@end
