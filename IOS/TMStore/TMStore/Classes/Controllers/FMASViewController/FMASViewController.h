//
//  FMASViewController.h
//
//  Created by Rishabh Jain on 04/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


#if ENABLE_FMAS
#import "WrapperController.h"
@interface FMASViewController : UIViewController<UIWebViewDelegate, FMASDelegate>
#else
@interface FMASViewController : UIViewController<UIWebViewDelegate>
#endif
{
    
    UIButton *navButton;
    AppDelegate *appdelegate;
}
@property id responseDelegate;
- (id)initWithDelegate:(id)delegate;
@end

