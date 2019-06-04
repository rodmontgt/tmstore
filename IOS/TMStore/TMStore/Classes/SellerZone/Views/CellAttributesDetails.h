//
//  CellAttributesDetails.h
//  TMStore
//
//  Created by Rajshekhar on 25/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryInfo.h"

@interface CellAttributesDetails : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelAttributeDetail;
@property (weak, nonatomic) IBOutlet UIButton *buttonCheckMark;
@property BOOL checked;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonWidthConstraint;

@property id categoryObj;
- (void)initButtonCheckMark:(UIButton*)button;
- (void)isButtonEnableForCategory:(CategoryInfo*)cInfo button:(UIButton*)button;
@end
