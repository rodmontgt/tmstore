//
//  DLManager.m
//  TMStore
//
//  Created by Rishabh Jain on 18/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "DLManager.h"
#import "DLReader.h"
@implementation DLManager
static DLManager *dlmanager = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (dlmanager == nil){
            dlmanager = [[self alloc] init];
        }
    }
    return dlmanager;
}
- (id)init {
    if (self = [super init]) {
    }
    return self;
}
- (id)initializeDLManager {
    self.homeDLObjects = [[NSMutableArray alloc] init];
    
    float screenW = [[MyDevice sharedManager] screenWidthInPortrait];
    float screenH = [[MyDevice sharedManager] screenHeightInPortrait];
    float posX = 0;
    float topBarHeight = [[Utility sharedManager] getTopBarHeight];
    float bottomBarHeight = [[Utility sharedManager] getBottomBarHeight];
    float visibleW = screenW;
    float visibleH = screenH;// - topBarHeight - bottomBarHeight;
    float posY = topBarHeight;
    float tileW = visibleW/DL_COLS_PARTITION;
    float tileH = visibleH/DL_ROWS_PARTITION;
    
    visibleRect = CGRectMake(posX, posY, visibleW, visibleH);
    PRINT_RECT_STR(@"visibleRect", visibleRect);
    tileSize = CGSizeMake(tileW, tileH);
    PRINT_SIZE_STR(@"tileSize", tileSize);
    
    dlReader = [DLReader getInstance];
    return self;
}
- (CGSize)getTileSize {
    return tileSize;
}
- (CGRect)getVisibleRect {
    return visibleRect;
}
@end
