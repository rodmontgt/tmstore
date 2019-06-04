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
#import "ProductImage.h"
#import "DataManager.h"
#import "SellerZoneManager.h"
#import "UIView+LocalizeConstrint.h"
#import "CellProductImage.h"
#import "AppUser.h"
#import "ViewSelectedAttributes.h"
#import "VCAttributes.h"
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
    NSMutableArray * productImgSources;

    IBOutlet UILabel *labelBasicInfo;
    IBOutlet UILabel *labelProductImage;
    IBOutlet UILabel *labelCategory;
    IBOutlet UILabel *labelFullDescription;
    IBOutlet UILabel *labelPricing;
    IBOutlet UIButton *buttonSelectCategory;

}
@end

@implementation ViewControllerUploadProduct
- (void)viewDidLoad {
    [super viewDidLoad];
    [SelSZAtt resetAllSelSZAtt];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:Localize(@"title_new_product")];

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
    UIImage* buttonImg = [[UIImage imageNamed:@"camera _icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [buttonProductImage setImage:buttonImg forState:UIControlStateNormal];
    [buttonProductImage setImage:buttonImg forState:UIControlStateSelected];
    //    [buttonProductImage setTintColor:[UIColor colorWithRed:93/255.0 green:92/255.0 blue:98/255.0 alpha:1]];
    [buttonProductImage setTintColor:self.view.tintColor];

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

    productImgSources = [[NSMutableArray alloc] init];
    if (self.productObject && self.productObject._images) {
        for (ProductImage* pImage in self.productObject._images) {
            [productImgSources addObject:pImage._src];
        }
    }

    self.viewHorizontalTableView.delegate = self;
    [self.viewHorizontalTableView.tableView registerNib:[UINib nibWithNibName:@"CellProductImage" bundle:nil] forCellReuseIdentifier:@"CellProductImage"];



    viewBasicInfo.layer.shadowOpacity = 0.0f;
    viewImages.layer.shadowOpacity = 0.0f;
    viewDescription.layer.shadowOpacity = 0.0f;
    viewPrice.layer.shadowOpacity = 0.0f;
    viewAttributes.layer.shadowOpacity = 0.0f;
    viewStock.layer.shadowOpacity = 0.0f;
    self.viewCategory.layer.shadowOpacity = 0.0f;


    labelBasicInfo.text = Localize(@"label_basic_info");
    labelProductImage.text = Localize(@"label_product_images");
    labelCategory.text = Localize(@"label_category");
    labelFullDescription.text = Localize(@"label_full_description");
    labelPricing.text = Localize(@"label_pricing");
    [_buttonSubmit setTitle:Localize(@"submit") forState:UIControlStateNormal];
    [buttonSelectCategory setTitle:Localize(@"txt_select_category") forState:UIControlStateNormal];

    [_tfProductTitle setPlaceholder:Localize(@"hint_product_title")];
    [_tfShortDescription setPlaceholder:Localize(@"hint_short_description")];
    [_tfSalesPrice setPlaceholder:Localize(@"hint_sale_price")];
    [_tfRegularPrice setPlaceholder:Localize(@"hint_regular_price")];


}
- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    self.textViewFulDescription.delegate = self;
    self.textViewFulDescription.layer.cornerRadius = 5.0;
    self.textViewFulDescription.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textViewFulDescription.layer.borderWidth = 1.0;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIView* scrollViewChild = self.scrollViewChildView;
    CGRect rect = scrollViewChild.frame;
    rect.size.height = CGRectGetMaxY(_buttonSubmit.frame) + 20;
    scrollViewChild.frame = rect;
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, rect.size.height)];


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
    //    [Utility showShadow:viewAttributes];

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
    [self addAttributes:nil];

}
- (void)doneWithNumberPad:(UIBarButtonItem*)button {
    if (_textFieldFirstResponder) {
        [_textFieldFirstResponder resignFirstResponder];
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _textFieldFirstResponder = textField;
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)doneWithDeviceKeyPad:(UIBarButtonItem*)button {
    if (_textViewFirstResponder) {
        [_textViewFirstResponder resignFirstResponder];
    }
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    _textViewFirstResponder = textView;
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}

- (void)addDoneButtonTextField:(UITextField*)view{
    if ([[MyDevice sharedManager] isIphone]) {
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        numberToolbar.backgroundColor = [UIColor lightGrayColor];
        UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc]initWithTitle:Localize(@"done") style:UIBarButtonItemStyleBordered target:self action:@selector(doneWithNumberPad:)];
        numberToolbar.items = @[
                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                doneBtn];
        [numberToolbar sizeToFit];
        view.inputAccessoryView = numberToolbar;
    }
}
- (void)addDoneButtonTextView:(UITextView*)view{
    if ([[MyDevice sharedManager] isIphone]) {
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        numberToolbar.backgroundColor = [UIColor lightGrayColor];
        UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc]initWithTitle:Localize(@"done") style:UIBarButtonItemStyleBordered target:self action:@selector(doneWithDeviceKeyPad:)];
        numberToolbar.items = @[
                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                doneBtn];
        [numberToolbar sizeToFit];
        view.inputAccessoryView = numberToolbar;
    }
}
- (void)fillData {
    if (self.productObject) {
        [self addDoneButtonTextView:self.textViewFulDescription];
        [self addDoneButtonTextField:self.tfSalesPrice];
        [self addDoneButtonTextField:self.tfRegularPrice];
        [self addDoneButtonTextField:self.tfProductTitle];
        [self addDoneButtonTextField:self.tfShortDescription];

        NSString* currencySymbol = [[Utility sharedManager] getCurrencySymbol];
        [self.labelCurrencyRegularPrice setText:currencySymbol];
        [self.labelCurrencySalePrice setText:currencySymbol];
        [self.currentItemHeading setTitle:Localize(@"title_new_product")];
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

        if (/*self.productObject._attributes
             && [self.productObject._attributes count] > 0
             && */ self.productObject._categories
            && [self.productObject._categories count] > 0
            && [[SZAttribute getAllSZAttributesNames] count] == 0) {
            [[[DataManager sharedManager] tmDataDoctor] getAllAttributesForCategories:_productObject.szGetCategoryIds success:^{
                [self reloadAttributes];
            } failure:^(NSString *error) {
            }];
        } else {
            [self reloadAttributes];
        }

        if (_productObject._images && [_productObject._images count] > 0) {
            ProductImage *pImage = [_productObject._images objectAtIndex:0];
            [_imageProduct sd_setImageWithURL:[NSURL URLWithString:pImage._src] placeholderImage:[UIImage imageNamed:@"btn_home.png"]];
        } else {
            [_imageProduct sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"btn_home.png"]];
        }

        NSString * htmlStringFull = self.productObject._description;
        NSAttributedString * attrStrfull = [[NSAttributedString alloc] initWithData:[htmlStringFull dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [self.textViewFulDescription setAttributedText:attrStrfull];

        NSString * htmlStringShort = self.productObject._short_description;
        NSAttributedString * attrStrShort = [[NSAttributedString alloc] initWithData:[htmlStringShort dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [self.tfShortDescription setAttributedText:attrStrShort];

        // [self.textViewFulDescription setText:[NSString stringWithFormat:@"%@",self.productObject._description]];
        //        [self.tfShortDescription setText:[NSString stringWithFormat:@"%@",self.productObject._short_description]];
        // TODO
        [self.textViewFulDescription setFont:[UIFont boldSystemFontOfSize:16]];

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
                                                          selector: @selector(cameraType:) userInfo: NULL repeats: NO];
    }else if (buttonIndex == 1){

        NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0f target: self
                                                          selector: @selector(photoLibraryType:) userInfo: NULL repeats: NO];

    }if  (actionSheet.cancelButtonIndex == buttonIndex) {
        return;
    }

}

- (void)cameraType:(float)dt {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;

    [self presentViewController:picker animated:YES completion:NULL];

}
- (void)photoLibraryType:(float)dt{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:picker animated:YES completion:NULL];
}
#pragma mark - imagePickerController-Delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *chosenImage =  info[UIImagePickerControllerOriginalImage];
    [self uploadImage:chosenImage];
}
-(UIImage*)resizeImage:(UIImage*)image {
    Addons* addons = [Addons sharedManager];
    float maxWidth = addons.multiVendor.upload_image_width;
    float maxHeight = addons.multiVendor.upload_image_height;

    if (image.size.width > maxWidth || image.size.height > maxHeight) {
        int width = image.size.width;
        int height = image.size.height
        ;
        float ratioBitmap = (float) width / (float) height;
        float ratioMax = (float) maxWidth / (float) maxHeight;

        int finalWidth = maxWidth;
        int finalHeight = maxHeight;

        if (ratioMax > ratioBitmap) {
            finalWidth = (int) ((float) maxHeight * ratioBitmap);
        } else {
            finalHeight = (int) ((float) maxWidth / ratioBitmap);
        }

        CGSize newSize = CGSizeMake(finalWidth, finalHeight);

        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    return image;
}
- (void)uploadImage:(UIImage*)image {
    long currentTime1 = [Utility getCurrentMilliseconds];
    NSLog(@"IMAGE_UPLOAD time 1 : %ld", currentTime1);
    [[[DataManager sharedManager] tmDataDoctor] uploadImageToServer:[self resizeImage:image] success:^(NSString *imgUrl) {
        [productImgSources addObject:imgUrl];
        long currentTime2 = [Utility getCurrentMilliseconds];
        NSLog(@"IMAGE_UPLOAD time 2 : %ld", currentTime2);
        NSLog(@"IMAGE_UPLOAD time total : %ld", currentTime2 - currentTime1);
        [self.viewHorizontalTableView.tableView reloadData];
    } failure:^(NSString *error) {
        long currentTime2 = [Utility getCurrentMilliseconds];
        NSLog(@"IMAGE_UPLOAD time 2 : %ld", currentTime2);
        NSLog(@"IMAGE_UPLOAD time total : %ld", currentTime2 - currentTime1);
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Localize(@"i_error") message:Localize(@"Error while Uploading Image") delegate:self cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];
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
    NSMutableArray* cIds = [[NSMutableArray alloc] init];
    NSMutableArray* allCategoriesSelected = [self.productObject szGetCategoryIds];
    if (allCategoriesSelected) {
        for (NSString* str in allCategoriesSelected) {
            [cIds addObject:[NSString stringWithFormat:@"%@", str]];
        }
    }
    if (cIds && [cIds count] > 0) {
        VCAttributes *vcAttributes = [[VCAttributes alloc] initWithNibName:@"VCAttributes" bundle:nil];
        [self presentViewController:vcAttributes animated:YES completion:nil];
        [vcAttributes loadAllAttributesForCategories:cIds];

    }
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

        NSString* msgStr = [NSString stringWithFormat:@"%@ %@", Localize(@"invalid"), Localize(@"hint_product_title")];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            msgStr = [NSString stringWithFormat:@"%@ %@", Localize(@"hint_product_title"), Localize(@"invalid")];
        }
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Localize(@"i_error") message:msgStr delegate:self cancelButtonTitle:Localize(@"done") otherButtonTitles:nil, nil];
        [alert show];
        return;
    } else {
        [self.productJson setValue:self.tfProductTitle.text forKey:@"title"];
    }
    //check for regular price
    if (self.tfRegularPrice == nil || [self.tfRegularPrice.text isEqualToString:@""]){

        NSString* msgStr1 = [NSString stringWithFormat:@"%@ %@", Localize(@"invalid"), Localize(@"hint_regular_price")];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            msgStr1 = [NSString stringWithFormat:@"%@ %@", Localize(@"hint_regular_price"), Localize(@"invalid")];
        }
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:Localize(@"i_error") message:msgStr1 delegate:self cancelButtonTitle:Localize(@"done") otherButtonTitles:nil, nil];
        [alert1 show];
        return;
    } else {
        [self.productJson setValue:[NSNumber numberWithFloat:[self.tfRegularPrice.text floatValue]] forKey:@"regular_price"];
    }

    //check for sale price
    if (self.tfSalesPrice != nil && ![self.tfSalesPrice.text isEqualToString:@""]) {
        NSString* msgStr2 = [NSString stringWithFormat:@"%@ %@", Localize(@"invalid"), Localize(@"error_high_sale_price")];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            msgStr2 = [NSString stringWithFormat:@"%@ %@", Localize(@"error_high_sale_price"), Localize(@"invalid")];
        }
        float regularPrice = [self.tfRegularPrice.text floatValue];
        float salePrice = [self.tfSalesPrice.text floatValue];
        if(salePrice >= regularPrice){
            UIAlertView *alert3 = [[UIAlertView alloc]initWithTitle:Localize(@"i_error") message:msgStr2 delegate:self cancelButtonTitle:Localize(@"done") otherButtonTitles:nil, nil];
            [alert3 show];
            return;
        } else {
            [self.productJson setValue:[NSNumber numberWithFloat:[self.tfSalesPrice.text floatValue]] forKey:@"sale_price"];
        }
    }

    [self.productJson setValue:@"simple" forKey:@"type"];


    //add attributes
    NSMutableArray* attributes = [[NSMutableArray alloc] init];
    [self.productJson setValue:attributes forKey:@"attributes"];
    NSMutableArray* allSelSZAtt = [SelSZAtt getAllSelSZAtt];
    int i = 0;
    for (SelSZAtt* selSZAtt in allSelSZAtt) {
        if (selSZAtt.attribute && selSZAtt.options && [selSZAtt.options count] > 0) {
            NSMutableDictionary* dictAttribute = [[NSMutableDictionary alloc] init];
            [attributes addObject:dictAttribute];
            [dictAttribute setValue:selSZAtt.attribute.name forKey:@"name"];
            [dictAttribute setValue:selSZAtt.attribute.slug forKey:@"slug"];
            [dictAttribute setValue:[NSNumber numberWithInt:i] forKey:@"position"];
            [dictAttribute setValue:[NSNumber numberWithBool:true] forKey:@"visible"];
            [dictAttribute setValue:[NSNumber numberWithBool:false] forKey:@"variation"];
            NSMutableArray* optionsArray = [[NSMutableArray alloc] init];
            for (SZAttributeOption* option in selSZAtt.options) {
                [optionsArray addObject:option.name];
            }
            [dictAttribute setValue:optionsArray forKey:@"options"];
            i++;
        }
    }


    //    "attributes": [
    //                   {
    //                       "name": "Colori",
    //                       "slug": "pa_colori",
    //                       "position": 0,
    //                       "visible": true,
    //                       "variation": true,
    //                       "options": [
    //                                   "Crema",
    //                                   "Blu",
    //                                   "Bianco"
    //                                   ]
    //                   },
    //                   {
    //                       "name": "Marca",
    //                       "slug": "pa_marca",
    //                       "position": 1,
    //                       "visible": true,
    //                       "variation": true,
    //                       "options": [
    //                                   "cbrand1",
    //                                   "abrand1"
    //                                   ]
    //                   }
    //                   ],

    self.imageArray = [[NSMutableArray alloc] init];
    int position = 0;
    if (productImgSources && [productImgSources count] > 0) {
        for (NSString* imgUrl in productImgSources) {
            NSMutableDictionary* imgDict = [[NSMutableDictionary alloc] init];
            [imgDict setValue:imgUrl forKey:@"src"];
            [imgDict setValue:[NSNumber numberWithInt:position] forKey:@"position"];
            [self.imageArray addObject:imgDict];
            position++;
        }
        [self.productJson setValue:self.imageArray forKey:@"images"];
    }

    if (self.tfShortDescription != nil && ![self.tfShortDescription.text isEqualToString:@""]){
        [self.productJson setValue:self.tfShortDescription.text forKey:@"short_description"];
    }

    if (self.textViewFulDescription != nil && ![self.textViewFulDescription.text isEqualToString:@""]){
        [self.productJson setValue:self.textViewFulDescription.text forKey:@"description"];
    }


    [self.productJson setValue:[self.productObject szGetCategoryIds] forKey:@"categories"];


    Addons* addons = [Addons sharedManager];
    if (addons.multiVendor && addons.multiVendor.multiVendor_shop_settings) {
        ShopSettings* ss = addons.multiVendor.multiVendor_shop_settings;
        [self.productJson setValue:ss.publish_status forKey:@"status"];
    } else {
        [self.productJson setValue:@"pending" forKey:@"status"];
    }

    if (addons.multiVendor && addons.multiVendor.multiVendor_shop_settings) {
        ShopSettings* ss = addons.multiVendor.multiVendor_shop_settings;
        [self.productJson setObject:[NSNumber numberWithBool:ss.manage_stock]
                             forKey:@"managing_stock"];
    }
    [self.productJson setObject:[NSNumber numberWithBool:YES]
                         forKey:@"in_stock"];

    //upload tempProduct
    [self uploadProduct];
}
- (void)removeBtnClicked:(UIButton*)sender {
    SelSZAtt* selSZAtt = [sender.layer valueForKey:@"SelSZAtt"];
    if (selSZAtt) {
        [[SelSZAtt getAllSelSZAtt] removeObject:selSZAtt];
        UIView* sprView = sender.superview;
        CGRect rect = sprView.frame;
        rect.size.height = 0;
        sprView.frame = rect;
        sprView.hidden = true;
        [self rearrangeHeightAttributeView];
    }
}
- (void)rearrangeHeightAttributeView {
    NSArray* array = [self.viewSelectedAttributes subviews];
    float posY = 0;
    for (UIView* v in array) {
        if ([v isKindOfClass:[ViewSelectedAttributes class]]) {
            ViewSelectedAttributes* view = (ViewSelectedAttributes*)v;
            CGRect rect = view.frame;
            rect.origin.y = posY;
            rect.size.height = CGRectGetMaxY(view.lblAttributeOptions.frame) + 20;
            if (view.hidden) {
                rect.size.height = 0;
            }
            view.frame = rect;
            [view updateConstraints];
            posY = CGRectGetMaxY(view.frame);
        }
    }
    self.constraintSelectedAttributeViewHeight.constant = posY;
    self.constraintAttributeViewHeight.constant = posY + 130;
    [UIView animateWithDuration:1.0f animations:^{
        [_scrollView setFrame:CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, MAX(self.view.frame.size.height,_scrollView.frame.size.height))];
        [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, MAX(_scrollView.contentSize.height, self.view.frame.size.height))];
        [self.view setNeedsUpdateConstraints];
        viewAttributes.layer.shadowOpacity = 0.0f;
        //        [Utility showShadow:viewAttributes];
    } completion:^(BOOL finished) {
        viewAttributes.layer.shadowOpacity = 0.0f;
        //        [Utility showShadow:viewAttributes];
        if (finished) {
            viewAttributes.layer.shadowOpacity = 0.0f;
            //            [Utility showShadow:viewAttributes];
            viewAttributes.hidden = false;
        }
    }];
    viewAttributes.layer.shadowOpacity = 0.0f;
    //    [Utility showShadow:viewAttributes];
    viewAttributes.hidden = false;
}

-(void)reloadAttributes{

    NSMutableArray * attributes = [[NSMutableArray alloc]init];
    [attributes addObjectsFromArray:self.productObject._attributes];

    if (self.productObject._extraAttributes && [self.productObject._extraAttributes count] > 0){
        [attributes addObjectsFromArray:self.productObject._extraAttributes];
    }

    for (Attribute *attribute in attributes) {
        SZAttribute* szAttribute = [SZAttribute getSZAttributeBySlug:attribute._slug];
        if (szAttribute) {
            szAttribute.name = attribute._name;
            szAttribute.slug = attribute._slug;

            SelSZAtt* selSZAtt = [SelSZAtt getSelSZAttForSZAttribute:szAttribute];

            for (NSString*option in attribute._options) {
                SZAttributeOption* szAttOption = [[SZAttributeOption alloc]init];
                szAttOption.name = option;
                szAttOption.slug = option;

                if (![selSZAtt.options containsObject:szAttOption]) {
                    [selSZAtt.options addObject:szAttOption];
                }
            }
        }
    }
    [self addAttributes:nil];
}
- (void)addAttributes:(UIView*)superView {
    [_scrollView.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    [_scrollView setBackgroundColor:[UIColor whiteColor]];

    NSArray* array = [self.viewSelectedAttributes subviews];
    for (UIView* v in array) {
        if ([v isKindOfClass:[ViewSelectedAttributes class]]) {
            ViewSelectedAttributes* vObj = (ViewSelectedAttributes*)v;
            [vObj.btnRemove addTarget:self action:@selector(removeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        [v removeFromSuperview];
    }
    float posY = 0;
    NSMutableArray* selSZAttAll = [SelSZAtt getAllSelSZAtt];
    for (SelSZAtt* selSZAtt in selSZAttAll) {
        if (selSZAtt.options == nil || [selSZAtt.options count] == 0) {
            continue;
        }
        ViewSelectedAttributes* view = [self addSelecetedAttributeView];
        CGRect rect = view.frame;
        rect.size.width = self.viewSelectedAttributes.frame.size.width;
        view.frame = rect;
        [view updateConstraints];
        [view.btnRemove.layer setCornerRadius:view.btnRemove.frame.size.width/2];
        [view.btnRemove addTarget:self action:@selector(removeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view.btnRemove.layer setValue:selSZAtt forKey:@"SelSZAtt"];
        [self.viewSelectedAttributes addSubview:view];
        view.lblAttributeName.text = selSZAtt.attribute.name;

        NSString* strOptions = @"";
        int maxCount = (int)[selSZAtt.options count];
        int i = 0;
        for (SZAttributeOption* opt in selSZAtt.options) {
            strOptions = [strOptions stringByAppendingString:opt.name];
            if (i != maxCount - 1) {
                strOptions = [strOptions stringByAppendingString:@", "];
            }
            i++;
        }
        view.lblAttributeOptions.text = strOptions;
        [view.lblAttributeOptions setNumberOfLines:0];
        [view.lblAttributeOptions setLineBreakMode:NSLineBreakByWordWrapping];
        [view.lblAttributeOptions sizeToFit];
        [view.lblAttributeOptions setClipsToBounds:YES];
        rect.origin.y = posY;
        rect.size.height = CGRectGetMaxY(view.lblAttributeOptions.frame) + 20;
        view.frame = rect;
        posY = CGRectGetMaxY(view.frame);
        [view setBackgroundColor:[UIColor clearColor]];
    }
    self.constraintSelectedAttributeViewHeight.constant = posY;
    self.constraintAttributeViewHeight.constant = posY + 130;


    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, MAX(MAX(_scrollView.contentSize.height, self.view.frame.size.height), CGRectGetMaxY(_buttonSubmit.frame) + 100))];
    [UIView animateWithDuration:1.0f animations:^{
        [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, MAX(MAX(_scrollView.contentSize.height, self.view.frame.size.height), CGRectGetMaxY(_buttonSubmit.frame) + 100))];
        [self.view setNeedsUpdateConstraints];
    } completion:^(BOOL finished) {
        if (finished) {
            viewAttributes.layer.shadowOpacity = 0.0f;
            //            [Utility showShadow:viewAttributes];
            viewAttributes.hidden = false;
            [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, MAX(MAX(_scrollView.contentSize.height, self.view.frame.size.height), CGRectGetMaxY(_buttonSubmit.frame) + 100))];
        }
    }];
}
- (ViewSelectedAttributes*)addSelecetedAttributeView {
    UINib *customNib = [UINib nibWithNibName:@"ViewSelectedAttributes" bundle:nil];
    ViewSelectedAttributes *customView = [[customNib instantiateWithOwner:self options:nil] objectAtIndex:0];
    return customView;
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
    self.viewCategory.layer.shadowOpacity = 0.0f;
    [Utility showShadow:self.viewCategory];
    [self.view setNeedsUpdateConstraints];

    [UIView animateWithDuration:0.0f delay:1.0f options:0 animations:^{

    } completion:^(BOOL finished) {
        self.viewCategory.layer.shadowOpacity = 0.0f;
        [Utility showShadow:self.viewCategory];
    }];
}
- (void)clickedOnLabel:(NSString*)string {
    NSLog(@"clickedOnLabel:%@", string);
}
- (void)linkProductWithSeller {
    AppUser* appUser = [AppUser sharedManager];
    SellerZoneManager* sz = [SellerZoneManager getInstance];
    [[[DataManager sharedManager] tmDataDoctor] linkProductWithSeller:sz.tempProduct._id sellerId:appUser._id success:^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Localize(@"i_success") message:Localize(@"product_upload_successful") delegate:self cancelButtonTitle:Localize(@"done") otherButtonTitles:nil, nil];
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self barButtonBackPressed:nil];
        }];

    } failure:^(NSString *error) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Localize(@"i_error") message:@"Linking product with seller failed. Please retry." delegate:self cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self linkProductWithSeller];
            }
        }];
    }];
}
- (void)uploadProduct {
    //upload tempProduct
    [[[DataManager sharedManager] tmDataDoctor] uploadProduct:self.productObject._id uploadDict:self.uploadJson success:^(id data) {
        SellerZoneManager* sz = [SellerZoneManager getInstance];
        sz.tempProduct = data;
        [self linkProductWithSeller];
    } failure:^(NSString *error) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Localize(@"i_error") message:Localize(@"product_upload_error") delegate:self cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];
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
#pragma mark UITableView Delegate & DataSource (Product Images)
- (NSInteger)PTEHorizontalTableView:(PTEHorizontalTableView *)horizontalTableView numberOfRowsInSection:(NSInteger)section {
    return productImgSources.count;
}
- (UITableViewCell *)PTEHorizontalTableView:(PTEHorizontalTableView *)horizontalTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"CellProductImage";
    CellProductImage *cell = [horizontalTableView.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[CellProductImage alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    if (productImgSources && [productImgSources count] > (int)(indexPath.row)) {
        NSString* imgSrc = [productImgSources objectAtIndex:indexPath.row];
        //        [Utility setImage:cell.img_product url:imgSrc resizeType:0 isLocal:false highPriority:true];
        [cell.img_product.layer setBorderColor:self.view.tintColor.CGColor];
        [cell.img_product.layer setBorderWidth:1];
        [cell.activityIndicator startAnimating];
        [cell.img_product sd_setImageWithURL:[NSURL URLWithString:imgSrc] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error == nil) {
                [cell.activityIndicator stopAnimating];
            }
        }];
        [cell.btn_remove.layer setValue:imgSrc forKey:@"IMG_SRC_OBJECT"];
    }
    return cell;
}
- (CGFloat)PTEHorizontalTableView:(PTEHorizontalTableView *)horizontalTableView widthForCellAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}
- (void)PTEHorizontalTableView:(PTEHorizontalTableView *)horizontalTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected row -> %ld",(long)indexPath.row);
    //    [horizontalTableView.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (IBAction)eventBtnRemove:(id)sender {
    NSLog(@"eventBtnRemove");
    UIButton* btn_remove = sender;
    NSString* imgSrc = [btn_remove.layer valueForKey:@"IMG_SRC_OBJECT"];
    int objIndex = -1;
    if (imgSrc && productImgSources) {
        objIndex = (int)[productImgSources indexOfObject:imgSrc];
        if (objIndex != -1 && objIndex < (int)[productImgSources count]) {
            [productImgSources removeObjectAtIndex:objIndex];
        }
    }
    [self.viewHorizontalTableView.tableView reloadData];
}

#pragma mark UITableView Delegate & DataSource (Selected Attributes)

@end

