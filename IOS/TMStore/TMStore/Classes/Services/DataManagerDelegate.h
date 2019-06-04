//
//  DataManagerDelegate.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 06/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#ifndef eCommerceApp_DataManagerDelegate_h
#define eCommerceApp_DataManagerDelegate_h
#import "ServerData.h"
@protocol DataManagerDelegate <NSObject>
- (void)dataFetchCompletion:(ServerData*)serverData;
@end
#endif
