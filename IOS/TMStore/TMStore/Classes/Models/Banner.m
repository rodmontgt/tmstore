//
//  Banner.m
//  TMStore
//
//  Created by Rishabh Jain on 19/05/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "Banner.h"
NSMutableArray * _allBanners = nil;
@implementation Banner
- (id)init {
    self = [super init];
    if (self) {
        _bannerUrl = @"";
        _bannerType = BANNER_SIMPLE;
        _bannerId = -1;
        if (_allBanners == nil) {
            _allBanners = [[NSMutableArray alloc] init];
        }
        [_allBanners addObject:self];
    }
    return self;
}
- (id)initWithoutAddingToArray {
    self = [super init];
    if (self) {
        _bannerUrl = @"";
        _bannerType = BANNER_SIMPLE;
        _bannerId = -1;
    }
    return self;
}
+ (NSMutableArray*)getAllBanners {
    if (_allBanners == nil) {
        _allBanners = [[NSMutableArray alloc] init];
    }
    return _allBanners;
}


@end
