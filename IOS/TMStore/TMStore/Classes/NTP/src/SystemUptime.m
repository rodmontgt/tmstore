//
//  SystemUptime.m
//  ios-ntp
//
//  Created by Uken Mini Coop 1.0 on 13-03-26.
//  Copyright (c) 2013 Ramsay Consulting. All rights reserved.
//

#import "SystemUptime.h"

#include <sys/sysctl.h>

@implementation SystemUptime

static SystemUptime *_sharedInstance = nil;

+ (SystemUptime *)sharedInstance {
	@synchronized([SystemUptime class])
	{
		if (!_sharedInstance)
			_sharedInstance = [[self alloc] init];
        
		return _sharedInstance;
	}
    
	return nil;
}

- (BOOL)uptime:(NSValue *)outTimeval
{
    struct timeval boottime;
    
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    
    size_t size = sizeof(boottime);
    
    struct timeval  now;
	gettimeofday(&now, NULL);
    
    struct timeval *uptime = [outTimeval pointerValue];
    uptime->tv_sec = -1;
    uptime->tv_usec = -1;

    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0)
        
    {
        if ( now.tv_usec >= boottime.tv_usec ) {
            uptime->tv_sec = now.tv_sec - boottime.tv_sec;
            uptime->tv_usec = now.tv_usec - boottime.tv_usec;
        } else {
            uptime->tv_sec = now.tv_sec - boottime.tv_sec - 1;
            uptime->tv_usec = 1000000 + now.tv_usec - boottime.tv_usec;
        }
        
        return TRUE;
    }
    
    return FALSE;
}

-(NSDate *)uptimeAsDate {
    struct timeval uptime;
    BOOL success = [self uptime:[NSValue valueWithPointer:&uptime]];
    if ( !success ) {
        return Nil;
    }
    
    NSDate *uptimeDate = [NSDate dateWithTimeIntervalSince1970:uptime.tv_sec + uptime.tv_usec/1000000.0];
    
    return uptimeDate;
}

@end
