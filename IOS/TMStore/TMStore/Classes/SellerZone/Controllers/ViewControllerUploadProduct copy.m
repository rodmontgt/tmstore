//
//  ViewControllerUploadProduct.m
//  TMStore
//
//  Created by Rajshekhar on 19/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "ViewControllerUploadProduct.h"
#import "Variables.h"
#import "Utility.h"
#import "AnalyticsHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "VCSelectCategory.h"
#import "VCAttributes.h"
#import "ProductImage.h"
#import "DataManager.h"
#import "SellerZoneManager.h"
#import "UIView+LocalizeConstrint.h"
@interface ViewControllerUploadProduct ()<UIActionSheetDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UITextViewDelegate,UITextFieldDelegate>{
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
    IBOutlet UIButton *buttonProductImage;
    IBOutlet UIView *viewBasicInfo;
    IBOutlet UIView *viewImages;
    IBOutlet UIView *viewDescription;
    IBOutlet UIView *viewPrice;
    IBOutlet UIView *viewAttributes;
    IBOutlet UIView *viewStock;
}
@end

@implementation ViewControllerUploadProduct

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:@"New Product"];
    
    _labelViewHeading = [[UILabel alloc] init] ;
    [_labelViewHeading setFrame:CGRectMake(0, 20, [[MyDevice sharedManager] screenSize].width, _navigationBar.frame.size.height)];
    [_labelViewHeading setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_labelViewHeading setUIFont:kUIFontType24 isBold:false];
    [_labelViewHeading setTextColor:[Utility getUIColor:kUIColorThemeFont]];
    [_labelViewHeading setTextAlignment:NSTextAlignmentCenter];
    [_labelViewHeading setText:@"    "];
    [self.view addSubview:_labelViewHeading];
    
    [_navigationBar setClipsToBounds:false];
    [_lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    [_navigationBar setBarTintColor:[Utility getUIColor:kUIColorBgHeader]];
    customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customBackButton setImage:[[UIImage imageNamed:@"img_arrow_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [customBackButton addTarget:self action:@selector(barButtonBackPressed:)forControlEvents:UIControlEventTouchUpInside];
    [customBackButton setTitle:[NSString stringWithFormat:@"  %@  ", Localize(@"i_back")] forState:UIControlStateNormal];
    [customBackButton setTintColor:[Utility getUIColor:kUIColorThemeFont]];
    [customBackButton setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [customBackButton.titleLabel setUIFont:kUIFontType18 isBold:false];
    
    [customBackButton sizeToFit];
    [_previousItemHeading setCustomView:customBackButton];
    [_previousItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType18 isBold:false], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    //set tintcolr to images
    [self.imageProductTitle setImage:[self.imageProductTitle.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self.imageProductTitle setTintColor:[UIColor colorWithRed:93/255.0 green:92/255.0 blue:98/255.0 alpha:1]];
    
    [self.imageProductDesc setImage:[self.imageProductDesc.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self.imageProductDesc setTintColor:[UIColor colorWithRed:93/255.0 green:92/255.0 blue:98/255.0 alpha:1]];
    
//    [self.imageCamera setImage:[self.imageCamera.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
//    [self.imageCamera setTintColor:[UIColor colorWithRed:93/255.0 green:92/255.0 blue:98/255.0 alpha:1]];
    [buttonProductImage setBackgroundColor:[UIColor clearColor]];
    [buttonProductImage.imageView setImage:[buttonProductImage.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [buttonProductImage setTintColor:[UIColor colorWithRed:93/255.0 green:92/255.0 blue:98/255.0 alpha:1]];
    
    [self.imageRegular setImage:[self.imageRegular.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self.imageRegular setTintColor:[UIColor colorWithRed:93/255.0 green:92/255.0 blue:98/255.0 alpha:1]];
    
    [self.imageSales setImage:[self.imageSales.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self.imageSales setTintColor:[UIColor colorWithRed:93/255.0 green:92/255.0 blue:98/255.0 alpha:1]];
    
    
    
    
    
    if (self.productObject == nil) {
        self.productObject = [[ProductInfo alloc] init:false];
    }
    [[SellerZoneManager getInstance] setTempProduct:self.productObject];
    self.uploadJson =  [[NSMutableDictionary alloc] init];
    self.productJson = [[NSMutableDictionary alloc] init];
    [self.uploadJson setValue:self.productJson forKey:@"product"];
    
    [self fillData];
    

    
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.textViewFulDescription.delegate = self;
    self.textViewFulDescription.layer.cornerRadius = 5.0;
    self.textViewFulDescription.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textViewFulDescription.layer.borderWidth = 1.0;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIView* scrollViewChild = [_scrollView.subviews objectAtIndex:0];
    CGRect rect = scrollViewChild.frame;
    rect.size.height = CGRectGetMaxY(_buttonSubmit.frame) + 20;
    scrollViewChild.frame = rect;
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width,MAX(_scrollView.contentSize.height, CGRectGetMaxY(scrollViewChild.frame)))];
    
    
    // viewBasicInfo.layer.borderWidth = 0.5;
    // viewBasicInfo.layer.borderColor = [UIColor lightGrayColor].CGColor;
    viewBasicInfo.layer.shadowOpacity = 0.0f;
    [Utility showShadow:viewBasicInfo];
    
    //viewImages.layer.borderWidth = 0.5;
    //viewImages.layer.borderColor = [UIColor lightGrayColor].CGColor;
    viewImages.layer.shadowOpacity = 0.0f;
    [Utility showShadow:viewImages];
    
    //viewCategory.layer.borderWidth = 0.5;
    // viewCategory.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    
    // viewDescription.layer.borderWidth = 0.5;
    //viewDescription.layer.borderColor = [UIColor lightGrayColor].CGColor;
    viewDescription.layer.shadowOpacity = 0.0f;
    [Utility showShadow:viewDescription];
    
    // viewPrice.layer.borderWidth = 0.5;
    // viewPrice.layer.borderColor = [UIColor lightGrayColor].CGColor;
    viewPrice.layer.shadowOpacity = 0.0f;
    [Utility showShadow:viewPrice];
    
    //viewAttributes.layer.borderWidth = 0.5;
    // viewAttributes.layer.borderColor = [UIColor lightGrayColor].CGColor;
    viewAttributes.layer.shadowOpacity = 0.0f;
    [Utility showShadow:viewAttributes];
    
    //viewStock.layer.borderWidth = 0.5;
    //viewStock.layer.borderColor = [UIColor lightGrayColor].CGColor;
    viewStock.layer.shadowOpacity = 0.0f;
    [Utility showShadow:viewStock];
    
    
    [_buttonSubmit setTitle:Localize(@"SUBMIT") forState:UIControlStateNormal];
    [_buttonSubmit setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    [_buttonSubmit setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    _buttonSubmit.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
    [_buttonSubmit.titleLabel setUIFont:kUIFontType18 isBold:false];

    [self addCategories:self.viewCategory];
    self.viewCategory.layer.shadowOpacity = 0.0f;
    [Utility showShadow:self.viewCategory];
}
- (void)fillData {
    if (self.productObject) {
        [self.currentItemHeading setTitle:@"Edit Product"];
        [self.tfProductTitle setText:self.productObject._title];
        if (self.productObject._regular_price > 0.0f) {
            [self.tfRegularPrice setText:[NSString stringWithFormat:@"%.2f",self.productObject._regular_price]];
        } else {
            [self.tfRegularPrice setText:@""];
        }
        
        if (self.productObject._sale_price > 0.0f) {
            [self.tfSalesPrice setText:[NSString stringWithFormat:@"%.2f",self.productObject._sale_price]];
        } else {
            [self.tfSalesPrice setText:@""];
        }
        
        
        
        if (_productObject._images && [_productObject._images count] > 0) {
            ProductImage *pImage = [_productObject._images objectAtIndex:0];
            [_imageProduct sd_setImageWithURL:[NSURL URLWithString:pImage._src] placeholderImage:[UIImage imageNamed:@"btn_home.png"]];
        } else {
            [_imageProduct sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"btn_home.png"]];
        }
        
        
        [self.textViewFulDescription setText:[NSString stringWithFormat:@"%@",self.productObject._description]];
        [self.tfShortDescription setText:[NSString stringWithFormat:@"%@",self.productObject._short_description]];
        
        [self.tfProductTitle setUIFont:kUIFontType16 isBold:false];
        [self.tfShortDescription setUIFont:kUIFontType16 isBold:false];
        [self.tfRegularPrice setUIFont:kUIFontType16 isBold:false];
        [self.tfSalesPrice setUIFont:kUIFontType16 isBold:false];
        
        _checked = self.productObject._managing_stock;
        if (_checked) {
            [_buttonManagingStock setImage:[[UIImage imageNamed:@"managing_icon_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        } else {
            [_buttonManagingStock setImage:[[UIImage imageNamed:@"managing_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        }
        _buttonManagingStock.tintColor = [UIColor darkGrayColor];
        
        [self addCategories:self.viewCategory];
    }
}
- (IBAction)barButtonBackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)uploadProductImageAction:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Upload Images from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Camera" otherButtonTitles:@"Gallery", nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // In this case the device is an iPad.
        [actionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
        
    }
    else{
        // In this case the device is an iPhone/iPod Touch.
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0f target: self
                                                          selector: @selector(camera:) userInfo: nil repeats: NO];
        
        //          [self camera];
    }else if (buttonIndex == 1){
        // [self photoLibrary];
        NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0f target: self
                                                          selector: @selector(photoLibrary:) userInfo: nil repeats: NO];
        
    }if  (actionSheet.cancelButtonIndex == buttonIndex) {
        return;
    }
    
}

- (void)camera:(float)dt {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}
- (void)photoLibrary:(float)dt{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}
#pragma mark - imagePickerController-Delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *chosenImage =  info[UIImagePickerControllerOriginalImage];
    [self uploadImage:chosenImage];
}
- (void)uploadImage:(UIImage*)image {
    [[[DataManager sharedManager] tmDataDoctor] uploadImageToServer:image success:^(NSString *imgUrl) {
        //        self.imageCamera.image = image;//todo
        self.isProductImageSelected = true;
//        [Utility showShadow:self.imageCamera];//todo
        
        if (self.imageArray == nil) {
            self.imageArray = [[NSMutableArray alloc] init];
        }
        int position = (int)[self.imageArray count];
        NSMutableDictionary* imgDict = [[NSMutableDictionary alloc] init];
        [imgDict setValue:imgUrl forKey:@"src"];
        [imgDict setValue:[NSNumber numberWithInt:position] forKey:@"position"];
        [self.imageArray addObject:imgDict];
        
        
        
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:[self.imageArray count]];
//        [buttonProductImage setFrame:CGRectMake(self.imageCamera.frame.origin.x+self.imageCamera.frame.size.width, self.imageCamera.frame.origin.y, self.imageCamera.frame.size.width, self.imageCamera.frame.size.height)];
//        [buttonProductImage setImage:[UIImage imageNamed:@"camera _icon.png"] forState:UIControlStateNormal];
//        [buttonProductImage setTintColor:[UIColor colorWithRed:93/255.0 green:92/255.0 blue:98/255.0 alpha:1]];
//        [buttonProductImage addTarget:self action:@selector(uploadProductImageAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
    } failure:^(NSString *error) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failure!" message:@"Image uploading failed. Please retry." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self uploadImage:image];
            }
        }];
    }];

}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (IBAction)selectCategoryAction:(id)sender {
    
    VCSelectCategory *vcCategory=[[VCSelectCategory alloc] initWithNibName:@"VCSelectCategory" bundle:nil];
    [vcCategory setData:self.categoryObj];
    [self presentViewController:vcCategory animated:YES completion:nil];
    
}

- (IBAction)addAttributesAction:(id)sender {
    VCAttributes *vcAttributes=[[VCAttributes alloc] initWithNibName:@"VCAttributes" bundle:nil];
    [self presentViewController:vcAttributes animated:YES completion:nil];
}
- (IBAction)buttonManagingAction:(id)sender {
    _checked = !_checked;
    if (_checked) {
        [sender setImage:[[UIImage imageNamed:@"managing_icon_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    } else {
        [sender setImage:[[UIImage imageNamed:@"managing_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    }
    ((UIButton*)sender).tintColor = [UIColor darkGrayColor];
}
- (IBAction)submitAction:(id)sender {
    //check for product title
    if (self.tfProductTitle == nil || [self.tfProductTitle.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Please Enter Product Title" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    } else {
        [self.productJson setValue:self.tfProductTitle.text forKey:@"title"];
    }
    
    //check for regular price
    if (self.tfRegularPrice == nil || [self.tfRegularPrice.text isEqualToString:@""]){
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Please Enter Product Regular Price" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert1 show];
        return;
    } else {
        [self.productJson setValue:[NSNumber numberWithFloat:[self.tfRegularPrice.text floatValue]] forKey:@"regular_price"];
    }
    
    //check for sale price
    if (self.tfSalesPrice != nil && ![self.tfSalesPrice.text isEqualToString:@""]) {
        float regularPrice = [self.tfRegularPrice.text floatValue];
        float salePrice = [self.tfSalesPrice.text floatValue];
        if(salePrice >= regularPrice){
            UIAlertView *alert3 = [[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Sale Price always less than Regular Price" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert3 show];
            return;
        } else {
             [self.productJson setValue:[NSNumber numberWithFloat:[self.tfSalesPrice.text floatValue]] forKey:@"sale_price"];
        }
    }
    
    [self.productJson setValue:@"simple" forKey:@"type"];
    if (self.imageArray) {
        [self.productJson setValue:self.imageArray forKey:@"images"];
    }
    
    
    if (self.tfShortDescription != nil && ![self.tfShortDescription.text isEqualToString:@""]){
        [self.productJson setValue:self.tfShortDescription.text forKey:@"short_description"];
    }
    
    if (self.textViewFulDescription != nil && ![self.textViewFulDescription.text isEqualToString:@""]){
        [self.productJson setValue:self.textViewFulDescription.text forKey:@"description"];
    }
    
    //upload tempProduct
    [self uploadProduct];
}
- (void)addCategories:(UIView*)superView {
    CGRect rect = self.viewCategoryNames.frame;
    if (self.categoryTitleView != nil) {
        [self.categoryTitleView removeFromSuperview];
        self.categoryTitleView = nil;
    }
    self.categoryTitleView = [[ANTagsView alloc] initWithTags:[self.productObject szGetCategoryNames] frame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width * .75f, rect.size.height) delegate:self];
    [self.categoryTitleView setTagCornerRadius:10];
    [self.categoryTitleView setTagBackgroundColor:[UIColor grayColor]];
    [self.categoryTitleView setTagTextColor:[UIColor whiteColor]];
    [self.categoryTitleView setBackgroundColor:[UIColor clearColor]];
    [superView addSubview:self.categoryTitleView];
    self.constantViewCategoryHeight.constant = self.categoryTitleView.frame.size.height + self.categoryTitleView.frame.origin.y;
    [UIView animateWithDuration:1.0f animations:^{
        [self.view setNeedsUpdateConstraints];
    } completion:^(BOOL finished) {
        if (finished) {
            self.viewCategory.layer.shadowOpacity = 0.0f;
            [Utility showShadow:self.viewCategory];
        }
    }];
}
- (void)clickedOnLabel:(NSString*)string {
    NSLog(@"clickedOnLabel:%@", string);
}
- (void)uploadProduct {
    //upload tempProduct
    [[[DataManager sharedManager] tmDataDoctor] uploadProduct:self.productObject._id uploadDict:self.uploadJson success:^(id data) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Your Details are Saved" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        SellerZoneManager* sz = [SellerZoneManager getInstance];
        sz.tempProduct = data;
    } failure:^(NSString *error) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failure!" message:@"Product uploading failed. Please retry." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self uploadProduct];
            }
        }];
    }];
}
- (void)setData:(id)productInfo {
    self.productObject = productInfo;
}
//#pragma mark : Collection View Datasource
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    return 5;
//}
//
////- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
////
////    return CGSizeMake(300, 300);
////}
//
//- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//
//
//    static NSString *cellIdentifier = @"UploadProductCollectionImageCell";
//
//    UploadProductCollectionImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
//    [cell.buttonProductImage addTarget:self action:@selector(uploadProductImageAction:) forControlEvents:UIControlEventTouchUpInside];
//    cell.productImage.image = chosenImage;
//    return cell;
//}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}
@end
