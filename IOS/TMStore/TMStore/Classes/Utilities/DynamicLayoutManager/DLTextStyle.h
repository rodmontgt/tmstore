//
//  DLTextStyle.h
//  TMStore
//
//  Created by Rishabh Jain on 18/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DLConstants.h"

@interface DLTextStyle : NSObject
//@property NSString* alignment;
//@property NSString* position;

@property DL_TEXT_STYLE_ALIGN_H alignmentH;
@property DL_TEXT_STYLE_ALIGN_V alignmentV;
- (id)init;
@end


