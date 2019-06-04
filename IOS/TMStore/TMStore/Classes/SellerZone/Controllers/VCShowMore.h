//
//  VCShowMore.h
//  TMStore
//
//  Created by Rajshekhar on 21/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"
@interface VCShowMore : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource>{
IBOutlet UIScrollView *_scrollView;
//        id <BarcodeScannerDelegate> _delegate;
id _delegate;
}
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
@property (weak, nonatomic) IBOutlet UITableView *table_lineItemes;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerViewOptions;

- (IBAction)barButtonBackPressed:(id)sender;
@property UIImageView* topImage;
@property UIButton* btnProceed;
@property float defaultHeight;
@property UILabel* labelViewHeading;
@property (weak, nonatomic) IBOutlet UIView *viewTaxes;


@property (weak, nonatomic) IBOutlet UILabel *orderStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalTax;
@property (weak, nonatomic) IBOutlet UILabel *labelDiscount;
@property (weak, nonatomic) IBOutlet UILabel *labelShippingChargers;
@property (weak, nonatomic) IBOutlet UILabel *labelExtraFee;
@property (weak, nonatomic) IBOutlet UILabel *labelGrandTotal;
@property (weak, nonatomic) IBOutlet UILabel *labelDeliveryDate;
@property (weak, nonatomic) IBOutlet UILabel *labelDeliveryTime;
@property (weak, nonatomic) IBOutlet UILabel *labelPaymentMethod;
@property (weak, nonatomic) IBOutlet UILabel *labelShippingMethodName;
@property (weak, nonatomic) IBOutlet UILabel *labelShippingMethodPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrencyTotal;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrency;


@property (weak, nonatomic) IBOutlet UIToolbar *doneToolBar;


@property Order* selectedOrder;
- (void)setData:(Order*)order;


@end
