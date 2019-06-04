//
//  SystemUptime.h
//  ios-ntp
//
//  Created by Uken Mini Coop 1.0 on 13-03-26.
//  Copyright (c) 2013 Ramsay Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemUptime : NSObject

+ (SystemUptime *)sharedInstance;

- (BOOL)uptime:(NSValue *)outTimeval;
- (NSDate *)uptimeAsDate;

@end
