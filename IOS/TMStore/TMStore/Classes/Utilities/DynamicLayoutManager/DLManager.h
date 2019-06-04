//
//  DLManager.h
//  TMStore
//
//  Created by Rishabh Jain on 18/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Variables.h"
#import "Utility.h"
#import "MyDevice.h"

#import "DLConstants.h"
#import "DLReader.h"

@interface DLManager : NSObject {
    CGSize tileSize;
    CGRect visibleRect;
    id dlReader;
}
+ (id)sharedManager;
- (id)initializeDLManager;
- (CGSize)getTileSize;
- (CGRect)getVisibleRect;
@property NSMutableArray* homeDLObjects;
@end
