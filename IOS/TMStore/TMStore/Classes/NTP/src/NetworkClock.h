/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ NetworkClock.h                                                                                   ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Oct17/10                                                               ║
  ║ Copyright 2010 Ramsay Consulting. All rights reserved.                                           ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CFNetwork/CFNetwork.h>
#import "GCDAsyncUdpSocket.h"
#import "NetAssociation.h"

#define IOS_NTP_NETWORK_CONFIDENCE_CHANGED  @"ios_ntp:network_confidence_changed" // userInfo: @{ @"confidence": NSNumber *confidence }

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ The NetworkClock sends notifications of the network time.  It will attempt to provide a very     ┃
  ┃ early estimate and then refine that and reduce the number of notifications ...                   ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

@interface NetworkClock : NSObject {

    NSTimeInterval          timeIntervalSinceDeviceTime;

    NSMutableArray *        timeAssociations;

@private
    
    NSSortDescriptor *      dispersionSortDescriptor;
    NSArray *               sortDescriptors;
    
    dispatch_queue_t        associationDelegateQueue;
}

+ (NetworkClock *) sharedNetworkClock;

- (void) createAssociations;
- (void) enableAssociations;
- (void) reportAssociations;
- (void) finishAssociations;

- (NSDate *) networkTime;

- (float) networkConfidence;

@end