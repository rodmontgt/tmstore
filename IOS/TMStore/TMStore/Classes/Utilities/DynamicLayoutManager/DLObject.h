//
//  DLObject.h
//  TMStore
//
//  Created by Rishabh Jain on 18/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DLConstants.h"
#import "DLVariable.h"
@interface DLObject : NSObject
@property int col;
@property int objId;
@property int row;
@property float size_x;
@property float size_y;
@property DLVariable* variable;//DLVariable
- (id)init;


@property UIView* dView;
@property float extraH;
@end


