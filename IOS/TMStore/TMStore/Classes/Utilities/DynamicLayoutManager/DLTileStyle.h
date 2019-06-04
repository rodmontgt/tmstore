//
//  DLTileStyle.h
//  TMStore
//
//  Created by Rishabh Jain on 18/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DLConstants.h"

@interface DLTileStyle : NSObject
@property UIColor* bgColor;
@property UIColor* textColor;
@property int fontWeight;
@property int fontSize;
@property CGRect margin;
@property CGRect padding;
@property DL_SCALE_TYPE scaleType;
@property UIColor* textBgColor;
- (id)init;
@end
