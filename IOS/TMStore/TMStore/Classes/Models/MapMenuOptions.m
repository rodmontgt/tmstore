//
//  MapMenuOptions.m
//  TMStore
//
//  Created by Rishabh Jain on 27/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapMenuOptions.h"
#import "Utility.h"


@implementation MapMenuOptions

- (id)init {
    self = [super init];
    if (self) {
        _title = @"";
        _url = @"";
    }
    return self;
}

@end
