//
//  ActivityView.m
//  eMobileApp
//
//  Created by V S Khutal on 07/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ActivityView.h"

@implementation ActivityView

+ (id)sharedManager {
    static ActivityView *sharedActivityManager = nil;
    @synchronized(self) {
        if (sharedActivityManager == nil)
            sharedActivityManager = [[self alloc] init];
    }
    return sharedActivityManager;
}
- (id)init {
    if (self = [super init]) {
//        self.view.backgroundColor = [UIColor redColor];
        UIColor *colour = [[UIColor alloc] initWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 1.0f];
        self.backgroundColor = colour;
        self.activityIndicator = [[MRActivityIndicatorView alloc] init];
        [self.activityIndicator se]
        self.activityIndicator.center=self.center;
        [self addSubview:self.activityIndicator];
    }
    return self;
}
- (void)pushActivityIndicator:(AFURLConnectionOperation*)operation{
    [self.activityIndicator setAnimatingWithStateOfOperation:operation];
}
- (void)pushActivityIndicator{
}
- (void)popActivityIndicator{
}


@end
