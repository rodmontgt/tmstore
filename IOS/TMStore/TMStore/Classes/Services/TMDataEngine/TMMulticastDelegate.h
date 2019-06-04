//
//  TMMulticastDelegate.h
//  TMMulticastDelegate
//
//  Created by Alexander Tkachenko on 7/15/13.
//  Copyright (c) 2013 Alexander Tkachenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerData.h"

@interface TMMulticastDelegate : NSObject
- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;
- (void)removeAllDelegates;
- (NSHashTable *)delegates;
- (void)respondToDelegates:(ServerData*)serverData;
- (BOOL)hasDelegate:(id)newDelegate;
@end

@protocol TMMulticastDelegate <NSObject>
- (void)dataFetchCompletion:(ServerData*)serverData;

@end