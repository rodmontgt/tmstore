//
//  FilterLocationView.h
//  TMStore
//
//  Created by Twist Mobile on 03/11/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ACFloatingTextField.h>

@interface FilterLocationView : UIView
@property (weak, nonatomic) IBOutlet UISearchBar *locationSearch;
@property (weak, nonatomic) IBOutlet ACFloatingTextField *tfRange;
@property (weak, nonatomic) IBOutlet UILabel *lblRangeUnit;
@property (weak, nonatomic) IBOutlet UIButton *btnRangeUnit;
@property (weak, nonatomic) IBOutlet UITableView *tableRangeUnit;
@property (weak, nonatomic) IBOutlet UIButton *btnCurrentLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblRangeTitle;
//@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;
@property NSArray *arrMeter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cLeadingLocationSearch;
@property (weak, nonatomic) IBOutlet UIImageView *imagepin;

@end
