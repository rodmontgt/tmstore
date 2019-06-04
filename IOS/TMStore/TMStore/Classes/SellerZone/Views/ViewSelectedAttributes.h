//
//  ViewSelectedAttributes.h
//  TMStore
//
//  Created by Rishabh Jain on 30/08/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewSelectedAttributes : UIView
@property (weak, nonatomic) IBOutlet UILabel *lblAttributeName;
@property (weak, nonatomic) IBOutlet UILabel *lblAttributeOptions;
@property (weak, nonatomic) IBOutlet UIButton *btnRemove;


@end
