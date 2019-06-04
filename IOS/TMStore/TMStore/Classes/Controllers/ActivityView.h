//
//  ActivityView.h
//  eMobileApp
//
//  Created by V S Khutal on 07/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRProgress.h"
#import <MRProgress/MRProgressOverlayView+AFNetworking.h>
#import <MRProgress/MRActivityIndicatorView+AFNetworking.h>

@interface ActivityView : UIView

@property MRActivityIndicatorView *activityIndicator;

+ (id)sharedManager;

- (void)pushActivityIndicator:(AFURLConnectionOperation*)operation;
- (void)pushActivityIndicator;
- (void)popActivityIndicator;
@end
