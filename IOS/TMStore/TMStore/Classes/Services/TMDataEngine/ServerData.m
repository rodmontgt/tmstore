//
//  ServerData.m
//  eMobileApp
//
//  Created by Rishabh Jain on 08/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ServerData.h"

@implementation ServerData

- (id)init{
    self = [super init];
    if (self) {
        self._serverRequest = nil;
//        self._serverRequestName = @"";
        self._serverRequestStatus = 0;
        self._serverUrl = @"";
        self._serverResultDictionary = nil;
        self._serverDataId = -1;
    }
    return self;
}

@end
