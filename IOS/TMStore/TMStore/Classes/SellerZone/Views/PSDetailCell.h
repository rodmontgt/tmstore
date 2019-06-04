//
//  PSDetailCell.h
//  TMStore
//
//  Created by Twist Mobile on 30/11/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACFloatingTextField.h"
@interface PSDetailCell : UITableViewCell<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfDetail;
@property UITapGestureRecognizer* tapGesture;

@end
