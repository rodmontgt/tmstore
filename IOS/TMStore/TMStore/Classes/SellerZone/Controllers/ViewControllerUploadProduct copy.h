//
//  ViewControllerUploadProduct.h
//  TMStore
//
//  Created by Rajshekhar on 19/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"
#import "ProductInfo.h"
#import "ANTagsView.h"
@interface ViewControllerUploadProduct : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate, ANTagsViewDelegate, UITableViewDataSource, UITableViewDelegate>{
IBOutlet UIScrollView *_scrollView;
//        id <BarcodeScannerDelegate> _delegate;
id _delegate;
}
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;

- (IBAction)barButtonBackPressed:(id)sender;
@property UIImageView* topImage;
@property UIButton* btnProceed;
@property float defaultHeight;
@property UILabel* labelViewHeading;
- (void)setDelegate:(id)delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imageProductTitle;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview_images;
@property (weak, nonatomic) IBOutlet UITableView *tableview_images;
@property (weak, nonatomic) IBOutlet UIImageView *imageProductDesc;
//@property (weak, nonatomic) IBOutlet UIImageView *imageCamera;
@property (weak, nonatomic) IBOutlet UIImageView *imageRegular;
@property (weak, nonatomic) IBOutlet UIImageView *imageSales;

@property (weak, nonatomic) IBOutlet UIImageView *imageProduct;

@property (weak, nonatomic) IBOutlet UIButton *buttonManagingStock;
@property (weak, nonatomic) IBOutlet UITextField *tfProductTitle;
@property (weak, nonatomic) IBOutlet UITextField *tfShortDescription;
@property (weak, nonatomic) IBOutlet UITextView *textViewFulDescription;
@property (weak, nonatomic) IBOutlet UITextField *tfRegularPrice;
@property (weak, nonatomic) IBOutlet UITextField *tfSalesPrice;
@property (weak, nonatomic) IBOutlet UIButton *buttonSubmit;

@property (weak, nonatomic) IBOutlet UIView *viewCategory;
@property (nonatomic, copy) NSArray *chosenImages;


@property BOOL checked;


- (void)setData:(id)productInfo;
@property ProductInfo* productObject;
@property BOOL isProductImageSelected;
@property id categoryObj;
@property NSMutableDictionary* productJson;
@property NSMutableArray* imageArray;
@property NSMutableDictionary* uploadJson;
@property ANTagsView* categoryTitleView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constantViewCategoryHeight;
@property (weak, nonatomic) IBOutlet ANTagsView *viewCategoryNames;
@end
