//
//  MV2X_Engine.h
//  TMDataDoctor
//
//  Created by Rishabh Jain on 18/01/16.
//  Copyright © 2016 Twist Mobile Pvt. Ltd. India. All rights reserved.
//

#import "TMDataDoctor.h"
#import "MV2X_JsonHelper.h"
@interface MV2X_Engine : TMDataDoctor <TMDataDoctor>
@property MV2X_JsonHelper* tmJsonHelper;
@end

