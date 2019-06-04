//
//  ViewControllerOrderReceipt.m
//  eMobileApp
//
//  Created by Rishabh Jain on 25/11/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerOrderReceipt.h"
#import "AppUser.h"
#import "Attribute.h"
#import "Order.h"
#import "DataManager.h"
#import "CommonInfo.h"
#import "Cart.h"
#import "ViewControllerOrder.h"
#import "ParseHelper.h"
#import "Variables.h"
#import "AnalyticsHelper.h"
#if ENABLE_FMAS
#import "WrapperController.h"
#import "FMASViewController.h"
#endif
#import "UIAlertView+NSCookbook.h"

static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;

#if ENABLE_FMAS
    @interface ViewControllerOrderReceipt () <FMASDelegate>
#else
    @interface ViewControllerOrderReceipt ()
#endif
{
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
}
@end


@implementation ViewControllerOrderReceipt

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:@"   "];
    
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
    
    [self initVariables];
    //    [[[DataManager sharedManager] tmMulticastDelegate] addDelegate:self];
}
-(void)viewDidAppear:(BOOL)animated{
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"OrderReceipt Screen"];
#endif
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
    [self loadAllViews];
}
- (void)resetMainScrollView {
    float globalPosY = 0.0f;
    UIView* tempView = nil;
    int i = 0;
    for (tempView in _viewsAdded) {
        CGRect rect = [tempView frame];
        if (i == 0) {
            globalPosY = 10;
        }
        rect.origin.y = globalPosY;
        
        [tempView setFrame:rect];
        globalPosY += rect.size.height;
        
        if ([tempView tag] == kTagForGlobalSpacing) {
            globalPosY += [LayoutProperties globalVerticalMargin];
        }
        i++;
    }
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, globalPosY)];
}
- (IBAction)barButtonBackPressed:(id)sender {
    [[Utility sharedManager] popScreen:self];
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC btnClickedHome:nil];
    //    [mainVC resetPreviousState];
}
- (void)initVariables {
    _viewsAdded = [[NSMutableArray alloc] init];
    //    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    //    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    //    [_lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
}
- (void)loadAllViews {
    for (UIView* view in _viewsAdded) {
        [view removeFromSuperview];
    }
    [_viewsAdded removeAllObjects];
    [_labelViewHeading setText:Localize(@"title_myorders")];
    
    
    UILabel* label = [[UILabel alloc] init];
    [label setText:Localize(@"your_order_placed")];
    //0x1B5E20
    UIColor* colorText = [UIColor colorWithRed:27.0f/255.0f green:94.0f/255.0f blue:32.0f/255.0f alpha:1.0f];
    [label setTextColor:colorText];
    [label setUIFont:[Utility getUIFont:kUIFontType14 isBold:true]];
    [label setTag:kTagForNoSpacing];
    [label sizeToFitUI];
    label.frame = CGRectMake(self.view.frame.size.width * .02f, self.view.frame.size.width * .02f, self.view.frame.size.width * .96f, label.frame.size.height + self.view.frame.size.width * .02f);
    [label setTextAlignment:NSTextAlignmentCenter];
    [_scrollView addSubview:label];
    [_viewsAdded addObject:label];
    
    
    AppUser* appUser = [AppUser sharedManager];
    int i = 0;
    //    RLOG(@"===========ORDERS============\n%@", appUser._ordersArray);
    for (Order* order in appUser._ordersArray) {
        if (order._id == appUser._last_order_id) {
#if ENABLE_FIREBASE_TAG_MANAGER
            [[AnalyticsHelper sharedInstance] registerOrderEvent:order];
            [[AnalyticsHelper sharedInstance] registerPaymentMethord:order];
#endif
            UIView* vieww = [self createOrderSummery:i order:order viewMain:nil];
            [Utility showShadow:vieww];
            vieww.hidden = false;
            break;
        }
    }
    float buttonPosX = self.view.frame.size.width * 0.25f;
    float buttonPosY = 0;
    float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
    float buttonWidth = self.view.frame.size.width * 0.5f;
    UIButton *btnMyOrders = [[UIButton alloc] initWithFrame:CGRectMake(buttonPosX, buttonPosY, buttonWidth, buttonHeight)];
    [btnMyOrders setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [[btnMyOrders titleLabel] setUIFont:kUIFontType22 isBold:false];
    [btnMyOrders setTitle:Localize(@"title_myorders") forState:UIControlStateNormal];
    [btnMyOrders setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    [btnMyOrders addTarget:self action:@selector(myOrders:) forControlEvents:UIControlEventTouchUpInside];
    [btnMyOrders setTag:kTagForGlobalSpacing];
    [_scrollView addSubview:btnMyOrders];
    [_viewsAdded addObject:btnMyOrders];
#if ENABLE_FMAS
    [self trymeview];
#endif
    [self resetMainScrollView];
}
- (UIView*)addBorder:(UIView*)view{
    UIView* viewBorder = [[UIView alloc] init];
    [viewBorder setFrame:CGRectMake(0, 0, view.frame.size.width, 1)];
    [viewBorder setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    return viewBorder;
}
/*
- (UIView*)createOrderSummery:(int)listId order:(Order*)order viewMain:(UIView*)viewMain {
    RLOG(@"===========createOrderSummery============%d", order._id);
    ///header
    BOOL isCurrencySymbolAtLast = true;
    
    float globalPosY = 0;
    float globalPosX = 0;
    float globalWidth = self.view.frame.size.width * 0.96f;
    
    if (viewMain == nil) {
        viewMain = [[UIView alloc] init];
        [viewMain setTag:kTagForGlobalSpacing];
        [_scrollView addSubview:viewMain];
        [_viewsAdded addObject:viewMain];
        viewMain.hidden = true;
    }else{
        for (UIView* view in [viewMain subviews]) {
            [view removeFromSuperview];
        }
    }
    [viewMain setFrame:CGRectMake(self.view.frame.size.width * 0.02f, 0, self.view.frame.size.width * 0.96f, globalPosY)];
    [viewMain setBackgroundColor:[UIColor whiteColor]];
    
    UIView* viewTop = [[UIView alloc] init];
    [viewTop setFrame:CGRectMake(globalPosX, globalPosY, globalWidth, 50)];
    [viewTop setBackgroundColor:[UIColor whiteColor]];
    [viewMain addSubview:viewTop];
    globalPosY += 50;
    //    [viewTop.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [viewTop.layer setBorderWidth:1];
    //    [viewTop setTag:kTagForNoSpacing];
    //    [_scrollView addSubview:viewTop];
    //    [_viewsAdded addObject:viewTop];
    
    //    "pending": "Pending Payment",
    //    "processing": "Processing",
    //    "on-hold": "On Hold",
    //    "completed": "Completed",
    //    "cancelled": "Cancelled",
    //    "refunded": "Refunded",
    //    "failed": "Failed"
    
    
    
    
    
    
    
    UILabel* labelOrderId = [[UILabel alloc] init];
    [labelOrderId setFrame:CGRectMake(self.view.frame.size.width * 0.02f, 0, viewTop.frame.size.width, 50)];
    [labelOrderId setUIFont:kUIFontType16 isBold:true];
    [labelOrderId setTextColor:[Utility getUIColor:kUIColorFontDark]];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelOrderId setText:[NSString stringWithFormat:@"%@ :%@", order._order_number_str, Localize(@"i_orderid")]];
        [labelOrderId setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelOrderId setText:[NSString stringWithFormat:@"%@: %@", Localize(@"i_orderid"),order._order_number_str]];
        [labelOrderId setTextAlignment:NSTextAlignmentLeft];
    }
    
    [viewTop addSubview:labelOrderId];
    
    UILabel* labelOrderDate = [[UILabel alloc] init];
    [labelOrderDate setFrame:CGRectMake(0, 0, viewTop.frame.size.width*.98f, 50)];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelOrderDate setTextAlignment:NSTextAlignmentLeft];
    } else {
        [labelOrderDate setTextAlignment:NSTextAlignmentRight];
    }
    [labelOrderDate setUIFont:kUIFontType16 isBold:false];
    [labelOrderDate setTextColor:[Utility getUIColor:kUIColorFontDark]];
    NSDate* date = order._created_at;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd"];
    NSString* temp = [dateFormat stringFromDate:date];
    [dateFormat setDateFormat:@"YY"];
    NSString* temp1 = [dateFormat stringFromDate:date];
    [labelOrderDate setText:[NSString stringWithFormat:@"%@,'%@", temp, temp1]];
    
    
    //    [dateFormat setDateFormat:@"MM/dd/YY"];
    //    NSString* temp2 = [dateFormat stringFromDate:date];
    //    [labelOrderDate setText:[NSString stringWithFormat:@"%@", temp2]];
    
    
    [viewTop addSubview:labelOrderDate];
    
    
    
    
    
    
    ///items
    int lineItemsCount = (int)[[order _line_items] count];
    if (lineItemsCount > 0) {
        for (LineItem* lineItem in order._line_items) {
            if (order._id == 828)
            {
                RLOG(@"order._id = %d", order._id);
            }
            UIView* lineItemView = [self addView:lineItem currencyCode:order._currency isCurrencySymbolAtLast:isCurrencySymbolAtLast];
            [viewMain addSubview:lineItemView];
            [lineItemView addSubview:[self addBorder:lineItemView]];
            CGRect rect = lineItemView.frame;
            rect.origin.y = globalPosY;
            rect.origin.x = 0;
            lineItemView.frame = rect;
            globalPosY += lineItemView.frame.size.height;
        }
    }
    
    
    //other views
    UIView* viewOther = [[UIView alloc] init];
    [viewOther setFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.96f, 0)];
    [viewOther setBackgroundColor:[UIColor whiteColor]];
    //    [viewOther.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [viewOther.layer setBorderWidth:1];
    [viewOther setTag:kTagForNoSpacing];
    [viewOther addSubview:[self addBorder:viewOther]];
    //    [_scrollView addSubview:viewOther];
    //    [_viewsAdded addObject:viewOther];
    
    float netWidth = viewOther.frame.size.width * 0.96f;
    float startPointX = viewOther.frame.size.width * 0.02f;
    float startPointY = viewOther.frame.size.width * 0.02f;
    float netHeight = 25;
    
    //for tax
    if (order._total_tax != 0.0f)
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelH setText:[NSString stringWithFormat:Localize(@"Total Tax")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:order._total_tax currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    
    //for shipping tax
    if (order._total_shipping != 0.0f)
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelH setText:[NSString stringWithFormat:Localize(@"i_total_shipping_cost")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:order._total_shipping currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    //for extra charges
    if (order._fee_lines && [order._fee_lines count] > 0)
    {
        float totalExtraCharges = 0.0f;
        for (FeeLine* feeline in order._fee_lines) {
            totalExtraCharges += feeline.total;
        }
        
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelH setText:[NSString stringWithFormat:Localize(@"Total Extra Charges")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:totalExtraCharges currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    
    //for discount
    if (order._total_discount != 0.0f)
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelH setText:[NSString stringWithFormat:Localize(@"total_savings")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setText:[NSString stringWithFormat:@"- %@",[[Utility sharedManager] getCurrencyWithSign:order._total_discount currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    startPointY += viewOther.frame.size.width * 0.02f;
    if (0) {
        UIView* viewHorizontalBar = [[UIView alloc] init];
        [viewHorizontalBar setFrame:CGRectMake(0, startPointY, viewOther.frame.size.width, 2)];
        [viewHorizontalBar setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
        [viewOther addSubview:viewHorizontalBar];
        startPointY += 2;
        startPointY += viewOther.frame.size.width * 0.02f;
    }
    //for total
    startPointY += viewOther.frame.size.width * 0.02f;
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:true];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelH setText:[NSString stringWithFormat:Localize(@"i_grand_total")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:true];
        [label setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [label setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:[order._total floatValue] currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    startPointY += viewOther.frame.size.width * 0.02f;
    
    if (0) {
        UIView* viewHorizontalBar1 = [[UIView alloc] init];
        [viewHorizontalBar1 setFrame:CGRectMake(0, startPointY, viewOther.frame.size.width, 2)];
        [viewHorizontalBar1 setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
        [viewOther addSubview:viewHorizontalBar1];
        startPointY += 2;
        startPointY += viewOther.frame.size.width * 0.02f;
    }
    
    //for line items count
    if (0)
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelH setText:[NSString stringWithFormat:Localize(@"i_total_items")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [label setText:[NSString stringWithFormat:@"%d",order._total_line_items_quantity]];
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
        startPointY += viewOther.frame.size.width * 0.02f;
    }
    
    
    
    [viewOther setFrame:CGRectMake(0, globalPosY, self.view.frame.size.width * 0.96f, startPointY)];
    [viewMain addSubview:viewOther];
    globalPosY += viewOther.frame.size.height;
    
    if ([order._status isEqualToString:@"pending"] ||
        [order._status isEqualToString:@"processing"] ||
        [order._status isEqualToString:@"on-hold"] ||
        [order._status isEqualToString:@"completed"]) {
        
        UIView* viewProgress = [[UIView alloc] init];
        [viewProgress setFrame:CGRectMake(globalPosX, globalPosY, globalWidth, 75)];
        [viewProgress setBackgroundColor:[UIColor whiteColor]];
        
        [viewProgress addSubview:[self addBorder:viewProgress]];
        //        [viewProgress.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        //        [viewProgress.layer setBorderWidth:1];
        [viewMain addSubview:viewProgress];
        globalPosY += 75;
        int j = -1;
        if ([order._status isEqualToString:@"pending"]) {
            j = 0;
        }
        if ([order._status isEqualToString:@"processing"]) {
            j = 1;
        }
        if ([order._status isEqualToString:@"on-hold"]) {
            j = 0;
        }
        if ([order._status isEqualToString:@"completed"]) {
            j = 3;
        }
        for (int i = 0; i < 3; i++) {
            UIView* imgView = [[UIView alloc] init];
            [imgView setFrame:CGRectMake(0, 0, viewProgress.frame.size.width * 0.25f, viewProgress.frame.size.height * 0.25f * 0.25f)];
            imgView.center = CGPointMake(viewProgress.frame.size.width * 0.25f + i * viewProgress.frame.size.width * 0.25f, viewProgress.frame.size.height*.33f);
            [viewProgress addSubview:imgView];
            
            if (i < j) {
                imgView.backgroundColor = [Utility getUIColor:kUIColorBlue];//[Utility getUIColor:kUIColorThemeButtonSelected];
            } else {
                imgView.backgroundColor = [Utility getUIColor:kUIColorBorder];//[Utility getUIColor:kUIColorThemeButtonNormal];
            }

            
        }
        for (int i = 0; i < 4; i++) {
            UIImageView* imgView = [[UIImageView alloc] init];
            [imgView setFrame:CGRectMake(0, 0, viewProgress.frame.size.height * 0.25f, viewProgress.frame.size.height * 0.25f)];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            imgView.center = CGPointMake(viewProgress.frame.size.width * 0.125f + i * viewProgress.frame.size.width * 0.25f, viewProgress.frame.size.height*.33f);
            [viewProgress addSubview:imgView];
            
            
            UILabel* label = [[UILabel alloc] init];
            [label setFrame:CGRectMake(self.view.frame.size.width * 0.02f, 0, viewTop.frame.size.width, viewProgress.frame.size.height)];
            [label setUIFont:kUIFontType14 isBold:false];
            [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
            switch (i) {
                case 0:
                    [label setText:[NSString stringWithFormat:Localize(@"approval")]];
                    if ([order._status isEqualToString:@"on-hold"]) {
                        [label setText:[NSString stringWithFormat:Localize(@"onhold")]];
                    }
                    break;
                case 1:
                    [label setText:[NSString stringWithFormat:Localize(@"processing")]];
                    break;
                case 2:
                    [label setText:[NSString stringWithFormat:Localize(@"shipping")]];
                    break;
                case 3:
                    [label setText:[NSString stringWithFormat:Localize(@"delivered")]];
                    break;
            }
            [label sizeToFitUI];
            label.center = CGPointMake(viewProgress.frame.size.width * 0.125f + i * viewProgress.frame.size.width * 0.25f, viewProgress.frame.size.height*.66f);
            [viewProgress addSubview:label];
            
            if (i <= j) {
                [imgView setUIImage:[[UIImage imageNamed:@"checked_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                imgView.tintColor = [Utility getUIColor:kUIColorBlue];//[Utility getUIColor:kUIColorThemeButtonSelected];
            } else {
                [imgView setUIImage:[[UIImage imageNamed:@"checked_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                imgView.tintColor = [Utility getUIColor:kUIColorBorder];//[Utility getUIColor:kUIColorThemeButtonNormal];
            }
        }
    }
    
    
    
    
    
    
    
    
#if SHOW_ACCOUNT_DETAILS_ORDER_RECEIPT_SCREEN
    /////account details///////////
    BOOL showAccountDetails = false;
    TMPaymentSDK* tmPaymentSDK = [[DataManager sharedManager] tmPaymentSDK];
    TMPaymentGateway* paymentGatewaySelected = nil;
    if(tmPaymentSDK.paymentGateways) {
        for (TMPaymentGateway* paymentGateway in tmPaymentSDK.paymentGateways) {
            if ([paymentGateway.paymentId isEqualToString:order._payment_details._method_id]) {
                showAccountDetails = true;
                paymentGatewaySelected = paymentGateway;
                break;
            }
        }
    }
    if (showAccountDetails) {
        NSString* mthdTitle = order._payment_details._method_title;
        UIView* viewPaymentDetails = [[UIView alloc] init];
        [viewPaymentDetails setFrame:CGRectMake(globalPosX, globalPosY, globalWidth, 75)];
        [viewPaymentDetails setBackgroundColor:[UIColor whiteColor]];
        [viewPaymentDetails addSubview:[self addBorder:viewPaymentDetails]];
        [viewMain addSubview:viewPaymentDetails];
        float startX = viewPaymentDetails.frame.size.width * 0.02f;
        float diffY = viewPaymentDetails.frame.size.width * 0.02f;
        float startY = viewPaymentDetails.frame.size.width * 0.02f;
        
        if (![mthdTitle isEqualToString:@""]) {
            UILabel* labelH = [[UILabel alloc] init];
            [labelH setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelH setUIFont:kUIFontType14 isBold:true];
            [labelH setTextColor:[Utility getUIColor:kUIColorFontDark]];
            [labelH setText:[NSString stringWithFormat:@"%@: %@", Localize(@"payment_method"), order._payment_details._method_title]];
            labelH.lineBreakMode = NSLineBreakByWordWrapping;
            labelH.numberOfLines = 0;
            [labelH sizeToFitUI];
            [viewPaymentDetails addSubview:labelH];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelH setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelH setTextAlignment:NSTextAlignmentLeft];
            }
            startY += (labelH.frame.size.height + diffY);
        }
        NSString* accountDetails = [paymentGatewaySelected getAccountDetailsString];
        NSString* accountInstruction = paymentGatewaySelected.paymentInstruction;
        if (![order._status isEqualToString:@"on-hold"]) {
            accountDetails = @"";
            accountInstruction = @"";
        }
        if (![accountInstruction isEqualToString:@""]) {
            UILabel* labelInstruction = [[UILabel alloc] init];
            [labelInstruction setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelInstruction setUIFont:kUIFontType14 isBold:false];
            [labelInstruction setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [labelInstruction setText:accountInstruction];
            [viewPaymentDetails addSubview:labelInstruction];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelInstruction setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelInstruction setTextAlignment:NSTextAlignmentLeft];
            }
            labelInstruction.lineBreakMode = NSLineBreakByWordWrapping;
            labelInstruction.numberOfLines = 0;
            [labelInstruction sizeToFitUI];
            startY += (labelInstruction.frame.size.height + diffY);
        }
        if (![accountDetails isEqualToString:@""]) {
            UILabel* labelAccountDetails = [[UILabel alloc] init];
            [labelAccountDetails setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelAccountDetails setUIFont:kUIFontType14 isBold:false];
            [labelAccountDetails setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [labelAccountDetails setText:accountDetails];
            [viewPaymentDetails addSubview:labelAccountDetails];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelAccountDetails setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelAccountDetails setTextAlignment:NSTextAlignmentLeft];
            }
            labelAccountDetails.lineBreakMode = NSLineBreakByWordWrapping;
            labelAccountDetails.numberOfLines = 0;
            [labelAccountDetails sizeToFitUI];
            startY += (labelAccountDetails.frame.size.height + diffY);
        }
        if (![mthdTitle isEqualToString:@""] || ![accountInstruction isEqualToString:@""] || ![accountDetails isEqualToString:@""]) {
            globalPosY += (startY);
        }else{
            [viewPaymentDetails removeFromSuperview];
        }
    }    //////////////////////////////
#endif
    
    
#if SHOW_ORDER_NOTE
    /////account details///////////
    BOOL showOrderNote = true;
    
    if (showOrderNote) {
        
        UIView* viewParent = [[UIView alloc] init];
        [viewParent setFrame:CGRectMake(globalPosX, globalPosY, globalWidth, 75)];
        [viewParent setBackgroundColor:[UIColor whiteColor]];
        [viewParent addSubview:[self addBorder:viewParent]];
        [viewMain addSubview:viewParent];
        float startX = viewParent.frame.size.width * 0.02f;
        float diffY = viewParent.frame.size.width * 0.02f;
        float startY = viewParent.frame.size.width * 0.02f;
        
        if (1) {
            UILabel* labelH = [[UILabel alloc] init];
            [labelH setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelH setUIFont:kUIFontType14 isBold:true];
            [labelH setTextColor:[Utility getUIColor:kUIColorFontDark]];
            [labelH setText:[NSString stringWithFormat:@"%@:", Localize(@"order_note")]];
            labelH.lineBreakMode = NSLineBreakByWordWrapping;
            labelH.numberOfLines = 0;
            [labelH sizeToFitUI];
            [viewParent addSubview:labelH];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelH setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelH setTextAlignment:NSTextAlignmentLeft];
            }
            startY += (labelH.frame.size.height + diffY);
        }
        
        NSString* orderNoteDesc = order._note;
        if (![orderNoteDesc isEqualToString:@""]) {
            UILabel* labelOrderNote = [[UILabel alloc] init];
            [labelOrderNote setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelOrderNote setUIFont:kUIFontType14 isBold:false];
            [labelOrderNote setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [labelOrderNote setText:orderNoteDesc];
            [viewParent addSubview:labelOrderNote];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelOrderNote setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelOrderNote setTextAlignment:NSTextAlignmentLeft];
            }
            labelOrderNote.lineBreakMode = NSLineBreakByWordWrapping;
            labelOrderNote.numberOfLines = 0;
            [labelOrderNote sizeToFitUI];
            startY += (labelOrderNote.frame.size.height + diffY);
        }
        if (![orderNoteDesc isEqualToString:@""]) {
            globalPosY += (startY);
        }else{
            [viewParent removeFromSuperview];
        }
    }
    //////////////////////////////
#endif
    
    
    
    
    
    //track buttons
    UIView* viewBottom = [[UIView alloc] init];
    [viewBottom setFrame:CGRectMake(globalPosX, globalPosY, self.view.frame.size.width * 0.96f, 50)];
    [viewBottom setBackgroundColor:[UIColor whiteColor]];
    //    [viewBottom.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [viewBottom.layer setBorderWidth:1];
    //    [viewBottom setTag:kTagForNoSpacing];
    //    [_scrollView addSubview:viewBottom];
    //    [_viewsAdded addObject:viewBottom];
    [viewBottom addSubview:[self addBorder:viewBottom]];
    
    netWidth = viewBottom.frame.size.width;
    startPointX = 0;
    netHeight = viewBottom.frame.size.height ;//* 0.5f;
    
    
    [viewMain addSubview:viewBottom];
    globalPosY += viewBottom.frame.size.height;
    CGRect rectMain = viewMain.frame;
    rectMain.size.height = globalPosY;
    viewMain.frame = rectMain;
    
    if (0) {
        UILabel* labelTotalQuantityH = [[UILabel alloc] init];
        [labelTotalQuantityH setFrame:CGRectMake(startPointX + netWidth * .0f, 0, netWidth * .25f, netHeight)];
        [labelTotalQuantityH setUIFont:kUIFontType18 isBold:false];
        [labelTotalQuantityH setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelTotalQuantityH setText:[NSString stringWithFormat:Localize(@"label_quantity")]];
        [viewBottom addSubview:labelTotalQuantityH];
        [labelTotalQuantityH setTextAlignment:NSTextAlignmentCenter];
        [labelTotalQuantityH.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        [labelTotalQuantityH.layer setBorderWidth:1];
        
        UILabel* labelTotalQuantity = [[UILabel alloc] init];
        [labelTotalQuantity setFrame:CGRectMake(startPointX + netWidth * .25f, 0, netWidth * .25f, netHeight)];
        [labelTotalQuantity setUIFont:kUIFontType18 isBold:false];
        [labelTotalQuantity setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelTotalQuantity setText:[NSString stringWithFormat:@"%d", order._total_line_items_quantity]];
        [viewBottom addSubview:labelTotalQuantity];
        [labelTotalQuantity setTextAlignment:NSTextAlignmentCenter];
        [labelTotalQuantity.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        [labelTotalQuantity.layer setBorderWidth:1];
        
        UILabel* labelTotalPriceH = [[UILabel alloc] init];
        [labelTotalPriceH setFrame:CGRectMake(startPointX + netWidth * .5f, 0, netWidth * .25f, netHeight)];
        [labelTotalPriceH setUIFont:kUIFontType18 isBold:false];
        [labelTotalPriceH setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelTotalPriceH setText:[NSString stringWithFormat:Localize(@"Total")]];
        [viewBottom addSubview:labelTotalPriceH];
        [labelTotalPriceH setTextAlignment:NSTextAlignmentCenter];
        [labelTotalPriceH.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        [labelTotalPriceH.layer setBorderWidth:1];
        
        UILabel* labelTotalPrice = [[UILabel alloc] init];
        [labelTotalPrice setFrame:CGRectMake(startPointX + netWidth * .75f, 0, netWidth * .25f, netHeight)];
        [labelTotalPrice setUIFont:kUIFontType16 isBold:false];
        [labelTotalPrice setTextColor:[Utility getUIColor:kUIColorFontDark]];
        //    [labelTotalPrice setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:[order._total floatValue] currencyCode:order._currency]]];
        [labelTotalPrice setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:[order._total floatValue] currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        
        [viewBottom addSubview:labelTotalPrice];
        [labelTotalPrice setTextAlignment:NSTextAlignmentCenter];
        [labelTotalPrice.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        [labelTotalPrice.layer setBorderWidth:1];
        
    }
    
    
    
    
    
    
    
    
    
    UIButton *buttonCancelOrder = [[UIButton alloc] initWithFrame:CGRectMake(netWidth*0.02f, 0, netWidth/2, netHeight)];
    [[buttonCancelOrder titleLabel] setUIFont:kUIFontType16 isBold:false];
    [buttonCancelOrder setTitle:Localize(@"i_cancel_order") forState:UIControlStateNormal];
    [buttonCancelOrder setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [[buttonCancelOrder titleLabel] sizeToFitUI];
    CGSize size = LABEL_SIZE([buttonCancelOrder titleLabel]);
    buttonCancelOrder.frame = CGRectMake(netWidth*0.02f, 0, size.width, netHeight);
    [buttonCancelOrder setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateDisabled];
    [buttonCancelOrder setContentMode:UIViewContentModeLeft];
    //    [buttonCancelOrder setImageEdgeInsets:UIEdgeInsetsMake(netHeight * .25f, 0, netHeight * .33f, 0)];
    [viewBottom addSubview:buttonCancelOrder];
    [buttonCancelOrder addTarget:self action:@selector(cancelOrder:) forControlEvents:UIControlEventTouchUpInside];
    //    [buttonCancelOrder.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [buttonCancelOrder.layer setBorderWidth:1];
    [buttonCancelOrder.layer setValue:order forKey:@"MY_OBJECT"];
    [buttonCancelOrder.layer setValue:viewMain forKey:@"MY_VIEW"];
    
    UIButton *buttonTrackOrder = [[UIButton alloc] initWithFrame:CGRectMake(netWidth/2, 0, netWidth/2, netHeight)];
    
    [buttonCancelOrder.layer setValue:buttonCancelOrder forKey:@"ORDER_BUTTON_OBJECT"];
    [buttonCancelOrder.layer setValue:buttonTrackOrder forKey:@"TRACK_BUTTON_OBJECT"];
    
    [[buttonTrackOrder titleLabel] setUIFont:kUIFontType18 isBold:false];
    [buttonTrackOrder setTitle:Localize(@"track_order") forState:UIControlStateNormal];
    [buttonTrackOrder setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [buttonTrackOrder setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateDisabled];
    [buttonTrackOrder setUIImage:[UIImage imageNamed:@"track-icon.png"] forState:UIControlStateNormal];
    [buttonTrackOrder setUIImage:[UIImage imageNamed:@"track-icon.png"] forState:UIControlStateSelected];
    [buttonTrackOrder setContentMode:UIViewContentModeScaleAspectFit];
    [[buttonTrackOrder imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [buttonTrackOrder setImageEdgeInsets:UIEdgeInsetsMake(netHeight * .25f, 0, netHeight * .33f, 0)];
    if(0){
        [viewBottom addSubview:buttonTrackOrder];
    }
    [buttonTrackOrder addTarget:self action:@selector(trackOrder:) forControlEvents:UIControlEventTouchUpInside];
    [buttonTrackOrder.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [buttonTrackOrder.layer setBorderWidth:1];
    buttonTrackOrder.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    buttonTrackOrder.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    buttonTrackOrder.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    [buttonTrackOrder.layer setValue:order forKey:@"MY_OBJECT"];
    
    //    UIView* viewTemp = [[UIView alloc] init];
    //    [viewTemp setFrame:CGRectMake(self.view.frame.size.width * 0.02f, 0, self.view.frame.size.width * 0.96f, self.view.frame.size.height * 0.10f)];
    //    [_scrollView addSubview:viewTemp];
    //    [_viewsAdded addObject:viewTemp];
    
 
    if([order._status isEqualToString:@"failed"] ||
       [order._status isEqualToString:@"pending"]
       ){
        [buttonCancelOrder setEnabled:true];
        [buttonTrackOrder setEnabled:true];
    } else {
        NSString* orderStatusStr = @"";
        if([order._status isEqualToString:@"completed"]) {
            orderStatusStr = Localize(@"completed");
        }
        else if([order._status isEqualToString:@"cancelled"]) {
            orderStatusStr = Localize(@"cancelled");
        }
        else if([order._status isEqualToString:@"refunded"]) {
            orderStatusStr = Localize(@"refunded");
        }
        else if([order._status isEqualToString:@"failed"]) {
            orderStatusStr = Localize(@"failed");
        }
        else if([order._status isEqualToString:@"processing"]) {
            orderStatusStr = Localize(@"processing");
        }
        else if([order._status isEqualToString:@"pending"]) {
            orderStatusStr = Localize(@"pending");
        }
        else if([order._status isEqualToString:@"on-hold"]) {
            orderStatusStr = Localize(@"onhold");
        }
        
        [buttonCancelOrder setTitle:[NSString stringWithFormat:Localize(@"i_order_val"), orderStatusStr] forState:UIControlStateDisabled];
        CGRect rect = CGRectMake(0, 0, netWidth, netHeight);
        buttonCancelOrder.frame = rect;
        [buttonCancelOrder setEnabled:false];
        [buttonTrackOrder setHidden:true];
    }
    
    return viewMain;
}
*/
- (UIView*)createOrderSummery:(int)listId order:(Order*)order viewMain:(UIView*)viewMain {
    RLOG(@"===========createOrderSummery============%d", order._id);
    ///header
    BOOL isCurrencySymbolAtLast = true;
    
    float globalPosY = 0;
    float globalPosX = 0;
    float globalWidth = self.view.frame.size.width * 0.96f;
    
    if (viewMain == nil) {
        viewMain = [[UIView alloc] init];
        [viewMain setTag:kTagForGlobalSpacing];
        [_scrollView addSubview:viewMain];
        [_viewsAdded addObject:viewMain];
        viewMain.hidden = true;
    }else{
        for (UIView* view in [viewMain subviews]) {
            [view removeFromSuperview];
        }
    }
    
    [viewMain setFrame:CGRectMake(self.view.frame.size.width * 0.02f, 0, self.view.frame.size.width * 0.96f, globalPosY)];
    [viewMain setBackgroundColor:[UIColor whiteColor]];
    
    
    UIView* viewTop = [[UIView alloc] init];
    [viewTop setFrame:CGRectMake(globalPosX, globalPosY, globalWidth, 50)];
    [viewTop setBackgroundColor:[UIColor whiteColor]];
    [viewMain addSubview:viewTop];
    globalPosY += 50;
    //    [viewTop.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [viewTop.layer setBorderWidth:1];
    //    [viewTop setTag:kTagForNoSpacing];
    //    [_scrollView addSubview:viewTop];
    //    [_viewsAdded addObject:viewTop];
    
    //    "pending": "Pending Payment",
    //    "processing": "Processing",
    //    "on-hold": "On Hold",
    //    "completed": "Completed",
    //    "cancelled": "Cancelled",
    //    "refunded": "Refunded",
    //    "failed": "Failed"
    
    
    
    
    
    
    
    UILabel* labelOrderId = [[UILabel alloc] init];
    [labelOrderId setFrame:CGRectMake(self.view.frame.size.width * 0.02f, 0, viewTop.frame.size.width, 50)];
    [labelOrderId setUIFont:kUIFontType16 isBold:true];
    [labelOrderId setTextColor:[Utility getUIColor:kUIColorFontDark]];
    
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelOrderId setText:[NSString stringWithFormat:@"%@ :%@", order._order_number_str, Localize(@"i_orderid")]];
        [labelOrderId setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelOrderId setText:[NSString stringWithFormat:@"%@: %@", Localize(@"i_orderid"),order._order_number_str]];
        [labelOrderId setTextAlignment:NSTextAlignmentLeft];
    }
    
    [viewTop addSubview:labelOrderId];
    
    UILabel* labelOrderDate = [[UILabel alloc] init];
    [labelOrderDate setFrame:CGRectMake(0, 0, viewTop.frame.size.width*.98f, 50)];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelOrderDate setTextAlignment:NSTextAlignmentLeft];
    } else {
        [labelOrderDate setTextAlignment:NSTextAlignmentRight];
    }
    [labelOrderDate setUIFont:kUIFontType16 isBold:false];
    [labelOrderDate setTextColor:[Utility getUIColor:kUIColorFontDark]];
    NSDate* date = order._created_at;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSString* userLocale = [[NSUserDefaults standardUserDefaults] valueForKey:USER_LOCALE];
    NSString* defaultLocale = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULT_LOCALE];
    NSString* selectedLocale = @"";
    if (userLocale && ![userLocale isEqualToString:@""]) {
        selectedLocale = userLocale;
    } else if (defaultLocale && ![defaultLocale isEqualToString:@""]) {
        selectedLocale = defaultLocale;
    } else {
        selectedLocale = @"en_US";
    }
    [dateFormat setLocale:[NSLocale localeWithLocaleIdentifier:selectedLocale]];
    
    [dateFormat setDateFormat:[[Addons sharedManager]date_format]];
    NSString* temp = [dateFormat stringFromDate:date];
    [labelOrderDate setText:[NSString stringWithFormat:@"%@", temp]];
    [viewTop addSubview:labelOrderDate];
    
    ///items
    int lineItemsCount = (int)[[order _line_items] count];
    if (lineItemsCount > 0) {
        for (LineItem* lineItem in order._line_items) {
            if (order._id == 828)
            {
                RLOG(@"order._id = %d", order._id);
            }
            UIView* lineItemView = [self addView:lineItem currencyCode:order._currency isCurrencySymbolAtLast:isCurrencySymbolAtLast];
            [viewMain addSubview:lineItemView];
            [lineItemView addSubview:[self addBorder:lineItemView]];
            CGRect rect = lineItemView.frame;
            rect.origin.y = globalPosY;
            rect.origin.x = 0;
            lineItemView.frame = rect;
            globalPosY += lineItemView.frame.size.height;
        }
    }
    
    
    //other views
    UIView* viewOther = [[UIView alloc] init];
    [viewOther setFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.96f, 0)];
    [viewOther setBackgroundColor:[UIColor whiteColor]];
    //    [viewOther.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [viewOther.layer setBorderWidth:1];
    [viewOther setTag:kTagForNoSpacing];
    [viewOther addSubview:[self addBorder:viewOther]];
    //    [_scrollView addSubview:viewOther];
    //    [_viewsAdded addObject:viewOther];
    
    float netWidth = viewOther.frame.size.width * 0.96f;
    float startPointX = viewOther.frame.size.width * 0.02f;
    float startPointY = viewOther.frame.size.width * 0.02f;
    float netHeight = 25;
    
    //for tax
    if (order._total_tax != 0.0f)
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelH setText:[NSString stringWithFormat:Localize(@"total_tax")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:order._total_tax currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    
    //for shipping tax
    if (order._total_shipping != 0.0f)
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelH setText:[NSString stringWithFormat:Localize(@"i_total_shipping_cost")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:order._total_shipping currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    
    
    //for extra charges
    if (order._fee_lines && [order._fee_lines count] > 0)
    {
        float totalExtraCharges = 0.0f;
        for (FeeLine* feeline in order._fee_lines) {
            totalExtraCharges += feeline.total;
        }
        
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelH setText:[NSString stringWithFormat:Localize(@"Total Extra Charges")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:totalExtraCharges currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    
    
    //for discount
    if (order._total_discount != 0.0f)
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelH setText:[NSString stringWithFormat:Localize(@"total_savings")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setText:[NSString stringWithFormat:@"- %@",[[Utility sharedManager] getCurrencyWithSign:order._total_discount currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    //for reward points [not to be shown in receipt only in my order]
    if([[Addons sharedManager] enable_custom_points] && 0) {
        UILabel* labelPointsEarned = [[UILabel alloc] init];
        [labelPointsEarned setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelPointsEarned setUIFont:kUIFontType16 isBold:false];
        [labelPointsEarned setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelPointsEarned setText:[NSString stringWithFormat:@"%@: %d",Localize(@"i_points_earned"), order.pointsEarned]];
        [viewOther addSubview:labelPointsEarned];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelPointsEarned setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelPointsEarned setTextAlignment:NSTextAlignmentLeft];
        }
        UILabel* labelPointsRedeemed = [[UILabel alloc] init];
        [labelPointsRedeemed setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelPointsRedeemed setUIFont:kUIFontType16 isBold:false];
        [labelPointsRedeemed setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelPointsRedeemed setText:[NSString stringWithFormat:@"%@: %d",Localize(@"i_points_redeemed"), order.pointsRedeemed]];
        [viewOther addSubview:labelPointsRedeemed];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelPointsRedeemed setTextAlignment:NSTextAlignmentLeft];
        } else {
            [labelPointsRedeemed setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    startPointY += viewOther.frame.size.width * 0.02f;
    
#if SHOW_DATE_TIME_SLOT
    {
        Addons* addons = [Addons sharedManager];
        BOOL showDateSlot = (addons.deliverySlotsCopiaPlugin && addons.deliverySlotsCopiaPlugin.isEnabled) ? true : false ;
        BOOL showTimeSlot = showDateSlot ? true : (addons.localPickupTimeSelectPlugin && addons.localPickupTimeSelectPlugin.isEnabled) ? true : false ;
        if (showDateSlot) {
            UILabel* label = [[UILabel alloc] init];
            [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
            [label setUIFont:kUIFontType16 isBold:false];
            [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [viewOther addSubview:label];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [label setTextAlignment:NSTextAlignmentRight];
            } else {
                [label setTextAlignment:NSTextAlignmentLeft];
            }
            [label setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"delivery_date"), order.deliveryDateString]];
            [label sizeToFitUI];
            
            UIActivityIndicatorView* spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [viewOther addSubview:spinnerView];
            [spinnerView setFrame:CGRectMake(
                                             CGRectGetMaxX(label.frame),
                                             0,
                                             spinnerView.frame.size.width,
                                             spinnerView.frame.size.height)];
            spinnerView.center = CGPointMake(spinnerView.center.x, label.center.y);
            
            if (order.deliveryDateString && ![order.deliveryDateString isEqualToString:@""]) {
                [spinnerView stopAnimating];
            } else {
                [spinnerView startAnimating];
            }
            startPointY += netHeight;
        }
        if (showTimeSlot) {
            UILabel* label = [[UILabel alloc] init];
            [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
            [label setUIFont:kUIFontType16 isBold:false];
            [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [viewOther addSubview:label];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [label setTextAlignment:NSTextAlignmentRight];
            } else {
                [label setTextAlignment:NSTextAlignmentLeft];
            }
            [label setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"delivery_time"), order.deliveryTimeString]];
            [label sizeToFitUI];
            UIActivityIndicatorView* spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [viewOther addSubview:spinnerView];
            [spinnerView setFrame:CGRectMake(
                                             CGRectGetMaxX(label.frame),
                                             0,
                                             spinnerView.frame.size.width,
                                             spinnerView.frame.size.height)];
            spinnerView.center = CGPointMake(spinnerView.center.x, label.center.y);
            if (order.deliveryTimeString && ![order.deliveryTimeString isEqualToString:@""]) {
                [spinnerView stopAnimating];
            } else {
                [spinnerView startAnimating];
            }
            startPointY += netHeight;
        }
    }
#endif
    
    if (0) {
        UIView* viewHorizontalBar = [[UIView alloc] init];
        [viewHorizontalBar setFrame:CGRectMake(0, startPointY, viewOther.frame.size.width, 2)];
        [viewHorizontalBar setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
        [viewOther addSubview:viewHorizontalBar];
        startPointY += 2;
        startPointY += viewOther.frame.size.width * 0.02f;
    }
    //for total
    startPointY += viewOther.frame.size.width * 0.02f;
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:true];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelH setText:[NSString stringWithFormat:Localize(@"i_grand_total")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:true];
        [label setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [label setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:[order._total floatValue] currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    startPointY += viewOther.frame.size.width * 0.02f;
    if (0) {
        UIView* viewHorizontalBar1 = [[UIView alloc] init];
        [viewHorizontalBar1 setFrame:CGRectMake(0, startPointY, viewOther.frame.size.width, 2)];
        [viewHorizontalBar1 setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
        [viewOther addSubview:viewHorizontalBar1];
        startPointY += 2;
        startPointY += viewOther.frame.size.width * 0.02f;
    }
    //for line items count
    if (0)
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelH setText:[NSString stringWithFormat:Localize(@"i_total_items")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [label setText:[NSString stringWithFormat:@"%d",order._total_line_items_quantity]];
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
        startPointY += viewOther.frame.size.width * 0.02f;
    }
    [viewOther setFrame:CGRectMake(0, globalPosY, self.view.frame.size.width * 0.96f, startPointY)];
    [viewMain addSubview:viewOther];
    globalPosY += viewOther.frame.size.height;
    
    if ([order._status isEqualToString:@"pending"] ||
        [order._status isEqualToString:@"processing"] ||
        [order._status isEqualToString:@"on-hold"] ||
        [order._status isEqualToString:@"completed"]) {
        
        UIView* viewProgress = [[UIView alloc] init];
        [viewProgress setFrame:CGRectMake(globalPosX, globalPosY, globalWidth, 75)];
        [viewProgress setBackgroundColor:[UIColor whiteColor]];
        
        [viewProgress addSubview:[self addBorder:viewProgress]];
        //        [viewProgress.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        //        [viewProgress.layer setBorderWidth:1];
        [viewMain addSubview:viewProgress];
        globalPosY += 75;
        int j = -1;
        if ([order._status isEqualToString:@"pending"]) {
            j = 0;
        }
        if ([order._status isEqualToString:@"processing"]) {
            j = 1;
        }
        if ([order._status isEqualToString:@"on-hold"]) {
            j = 0;
        }
        if ([order._status isEqualToString:@"completed"]) {
            j = 3;
        }
        for (int i = 0; i < 3; i++) {
            UIView* imgView = [[UIView alloc] init];
            [imgView setFrame:CGRectMake(0, 0, viewProgress.frame.size.width * 0.25f, viewProgress.frame.size.height * 0.25f * 0.25f)];
            imgView.center = CGPointMake(viewProgress.frame.size.width * 0.25f + i * viewProgress.frame.size.width * 0.25f, viewProgress.frame.size.height*.33f);
            [viewProgress addSubview:imgView];
            
            if (i < j) {
                imgView.backgroundColor = [Utility getUIColor:kUIColorBlue];//[Utility getUIColor:kUIColorThemeButtonSelected];
            } else {
                imgView.backgroundColor = [Utility getUIColor:kUIColorBorder];//[Utility getUIColor:kUIColorThemeButtonNormal];
            }
            
            
        }
        for (int i = 0; i < 4; i++) {
            UIImageView* imgView = [[UIImageView alloc] init];
            [imgView setFrame:CGRectMake(0, 0, viewProgress.frame.size.height * 0.25f, viewProgress.frame.size.height * 0.25f)];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            imgView.center = CGPointMake(viewProgress.frame.size.width * 0.125f + i * viewProgress.frame.size.width * 0.25f, viewProgress.frame.size.height*.33f);
            [viewProgress addSubview:imgView];
            
            
            UILabel* label = [[UILabel alloc] init];
            [label setFrame:CGRectMake(self.view.frame.size.width * 0.02f, 0, viewTop.frame.size.width, viewProgress.frame.size.height)];
            [label setUIFont:kUIFontType14 isBold:false];
            [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
            switch (i) {
                case 0:
                    [label setText:[NSString stringWithFormat:Localize(@"approval")]];
                    if ([order._status isEqualToString:@"on-hold"]) {
                        [label setText:[NSString stringWithFormat:Localize(@"onhold")]];
                    }
                    break;
                case 1:
                    [label setText:[NSString stringWithFormat:Localize(@"processing")]];
                    break;
                case 2:
                    [label setText:[NSString stringWithFormat:Localize(@"shipping")]];
                    break;
                case 3:
                    [label setText:[NSString stringWithFormat:Localize(@"delivered")]];
                    break;
                    
                default:
                    break;
            }
            [label sizeToFitUI];
            label.center = CGPointMake(viewProgress.frame.size.width * 0.125f + i * viewProgress.frame.size.width * 0.25f, viewProgress.frame.size.height*.66f);
            [viewProgress addSubview:label];
            
            if (i <= j) {
                [imgView setUIImage:[[UIImage imageNamed:@"checked_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                imgView.tintColor = [Utility getUIColor:kUIColorBlue];//[Utility getUIColor:kUIColorThemeButtonSelected];
            } else {
                [imgView setUIImage:[[UIImage imageNamed:@"checked_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                imgView.tintColor = [Utility getUIColor:kUIColorBorder];//[Utility getUIColor:kUIColorThemeButtonNormal];
            }
        }
    }
    
    
    
    
    
#if SHOW_ACCOUNT_DETAILS_ORDER_SCREEN
    /////account details///////////
    BOOL showAccountDetails = false;
    TMPaymentSDK* tmPaymentSDK = [[DataManager sharedManager] tmPaymentSDK];
    TMPaymentGateway* paymentGatewaySelected = nil;
    if(tmPaymentSDK.paymentGateways) {
        for (TMPaymentGateway* paymentGateway in tmPaymentSDK.paymentGateways) {
            if ([paymentGateway.paymentId isEqualToString:order._payment_details._method_id]) {
                showAccountDetails = true;
                paymentGatewaySelected = paymentGateway;
                break;
            }
        }
    }
    if (showAccountDetails) {
        NSString* mthdTitle = order._payment_details._method_title;
        UIView* viewPaymentDetails = [[UIView alloc] init];
        [viewPaymentDetails setFrame:CGRectMake(globalPosX, globalPosY, globalWidth, 75)];
        [viewPaymentDetails setBackgroundColor:[UIColor whiteColor]];
        [viewPaymentDetails addSubview:[self addBorder:viewPaymentDetails]];
        [viewMain addSubview:viewPaymentDetails];
        float startX = viewPaymentDetails.frame.size.width * 0.02f;
        float diffY = viewPaymentDetails.frame.size.width * 0.02f;
        float startY = viewPaymentDetails.frame.size.width * 0.02f;
        
        if (![mthdTitle isEqualToString:@""]) {
            UILabel* labelH = [[UILabel alloc] init];
            [labelH setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelH setUIFont:kUIFontType14 isBold:true];
            [labelH setTextColor:[Utility getUIColor:kUIColorFontDark]];
            [labelH setText:[NSString stringWithFormat:@"%@: %@", Localize(@"payment_method"), order._payment_details._method_title]];
            labelH.lineBreakMode = NSLineBreakByWordWrapping;
            labelH.numberOfLines = 0;
            [labelH sizeToFitUI];
            [viewPaymentDetails addSubview:labelH];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelH setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelH setTextAlignment:NSTextAlignmentLeft];
            }
            startY += (labelH.frame.size.height + diffY);
        }
        NSString* accountDetails = [paymentGatewaySelected getAccountDetailsString];
        NSString* accountInstruction = paymentGatewaySelected.paymentInstruction;
        if (![order._status isEqualToString:@"on-hold"]) {
            accountDetails = @"";
            accountInstruction = @"";
        }
        if (![accountInstruction isEqualToString:@""]) {
            UILabel* labelInstruction = [[UILabel alloc] init];
            [labelInstruction setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelInstruction setUIFont:kUIFontType14 isBold:false];
            [labelInstruction setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [labelInstruction setText:accountInstruction];
            [viewPaymentDetails addSubview:labelInstruction];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelInstruction setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelInstruction setTextAlignment:NSTextAlignmentLeft];
            }
            labelInstruction.lineBreakMode = NSLineBreakByWordWrapping;
            labelInstruction.numberOfLines = 0;
            [labelInstruction sizeToFitUI];
            startY += (labelInstruction.frame.size.height + diffY);
        }
        if (![accountDetails isEqualToString:@""]) {
            UILabel* labelAccountDetails = [[UILabel alloc] init];
            [labelAccountDetails setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelAccountDetails setUIFont:kUIFontType14 isBold:false];
            [labelAccountDetails setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [labelAccountDetails setText:accountDetails];
            [viewPaymentDetails addSubview:labelAccountDetails];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelAccountDetails setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelAccountDetails setTextAlignment:NSTextAlignmentLeft];
            }
            labelAccountDetails.lineBreakMode = NSLineBreakByWordWrapping;
            labelAccountDetails.numberOfLines = 0;
            [labelAccountDetails sizeToFitUI];
            startY += (labelAccountDetails.frame.size.height + diffY);
        }
        if (![mthdTitle isEqualToString:@""] || ![accountInstruction isEqualToString:@""] || ![accountDetails isEqualToString:@""]) {
            globalPosY += (startY);
        }else{
            [viewPaymentDetails removeFromSuperview];
        }
    }
    //////////////////////////////
#endif
    
#if SHOW_ORDER_NOTE
    /////account details///////////
    BOOL showOrderNote = true;
    
    if (showOrderNote) {
        
        UIView* viewParent = [[UIView alloc] init];
        [viewParent setFrame:CGRectMake(globalPosX, globalPosY, globalWidth, 75)];
        [viewParent setBackgroundColor:[UIColor whiteColor]];
        [viewParent addSubview:[self addBorder:viewParent]];
        [viewMain addSubview:viewParent];
        float startX = viewParent.frame.size.width * 0.02f;
        float diffY = viewParent.frame.size.width * 0.02f;
        float startY = viewParent.frame.size.width * 0.02f;
        
        if (0) {
            UILabel* labelH = [[UILabel alloc] init];
            [labelH setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelH setUIFont:kUIFontType14 isBold:true];
            [labelH setTextColor:[Utility getUIColor:kUIColorFontDark]];
            [labelH setText:[NSString stringWithFormat:@"%@:", Localize(@"order_note")]];
            labelH.lineBreakMode = NSLineBreakByWordWrapping;
            labelH.numberOfLines = 0;
            [labelH sizeToFitUI];
            [viewParent addSubview:labelH];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelH setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelH setTextAlignment:NSTextAlignmentLeft];
            }
            startY += (labelH.frame.size.height + diffY);
        }
        
        NSString* orderNoteDesc = order._note;
        if (![orderNoteDesc isEqualToString:@""]) {
            UILabel* labelOrderNote = [[UILabel alloc] init];
            [labelOrderNote setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelOrderNote setUIFont:kUIFontType14 isBold:false];
            [labelOrderNote setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [labelOrderNote setText:orderNoteDesc];
            [viewParent addSubview:labelOrderNote];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelOrderNote setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelOrderNote setTextAlignment:NSTextAlignmentLeft];
            }
            labelOrderNote.lineBreakMode = NSLineBreakByWordWrapping;
            labelOrderNote.numberOfLines = 0;
            [labelOrderNote sizeToFitUI];
            startY += (labelOrderNote.frame.size.height + diffY);
        }
        if (![orderNoteDesc isEqualToString:@""]) {
            globalPosY += (startY);
        }else{
            [viewParent removeFromSuperview];
        }
    }
    //////////////////////////////
#endif
    //track buttons
    UIView* viewBottom = [[UIView alloc] init];
    [viewBottom setFrame:CGRectMake(globalPosX, globalPosY, self.view.frame.size.width * 0.96f, 50)];
    [viewBottom setBackgroundColor:[UIColor whiteColor]];
    [viewBottom addSubview:[self addBorder:viewBottom]];
    netWidth = viewBottom.frame.size.width;
    startPointX = 0;
    netHeight = viewBottom.frame.size.height;//* 0.5f;
    [viewMain addSubview:viewBottom];
    globalPosY += viewBottom.frame.size.height;
    CGRect rectMain = viewMain.frame;
    rectMain.size.height = globalPosY;
    viewMain.frame = rectMain;
    [Utility showShadow:viewMain];
    if (0) {
        UILabel* labelTotalQuantityH = [[UILabel alloc] init];
        [labelTotalQuantityH setFrame:CGRectMake(startPointX + netWidth * .0f, 0, netWidth * .25f, netHeight)];
        [labelTotalQuantityH setUIFont:kUIFontType18 isBold:false];
        [labelTotalQuantityH setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelTotalQuantityH setText:[NSString stringWithFormat:Localize(@"label_quantity")]];
        [viewBottom addSubview:labelTotalQuantityH];
        [labelTotalQuantityH setTextAlignment:NSTextAlignmentCenter];
        [labelTotalQuantityH.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        [labelTotalQuantityH.layer setBorderWidth:1];
        UILabel* labelTotalQuantity = [[UILabel alloc] init];
        [labelTotalQuantity setFrame:CGRectMake(startPointX + netWidth * .25f, 0, netWidth * .25f, netHeight)];
        [labelTotalQuantity setUIFont:kUIFontType18 isBold:false];
        [labelTotalQuantity setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelTotalQuantity setText:[NSString stringWithFormat:@"%d", order._total_line_items_quantity]];
        [viewBottom addSubview:labelTotalQuantity];
        [labelTotalQuantity setTextAlignment:NSTextAlignmentCenter];
        [labelTotalQuantity.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        [labelTotalQuantity.layer setBorderWidth:1];
        UILabel* labelTotalPriceH = [[UILabel alloc] init];
        [labelTotalPriceH setFrame:CGRectMake(startPointX + netWidth * .5f, 0, netWidth * .25f, netHeight)];
        [labelTotalPriceH setUIFont:kUIFontType18 isBold:false];
        [labelTotalPriceH setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelTotalPriceH setText:[NSString stringWithFormat:Localize(@"Total")]];
        [viewBottom addSubview:labelTotalPriceH];
        [labelTotalPriceH setTextAlignment:NSTextAlignmentCenter];
        [labelTotalPriceH.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        [labelTotalPriceH.layer setBorderWidth:1];
        UILabel* labelTotalPrice = [[UILabel alloc] init];
        [labelTotalPrice setFrame:CGRectMake(startPointX + netWidth * .75f, 0, netWidth * .25f, netHeight)];
        [labelTotalPrice setUIFont:kUIFontType16 isBold:false];
        [labelTotalPrice setTextColor:[Utility getUIColor:kUIColorFontDark]];
        //    [labelTotalPrice setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:[order._total floatValue] currencyCode:order._currency]]];
        [labelTotalPrice setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:[order._total floatValue] currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        [viewBottom addSubview:labelTotalPrice];
        [labelTotalPrice setTextAlignment:NSTextAlignmentCenter];
        [labelTotalPrice.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        [labelTotalPrice.layer setBorderWidth:1];
    }
    UIButton *buttonCancelOrder = [[UIButton alloc] initWithFrame:CGRectMake(netWidth*0.02f, 0, netWidth/2, netHeight)];
    [[buttonCancelOrder titleLabel] setUIFont:kUIFontType16 isBold:false];
    [buttonCancelOrder setTitle:Localize(@"i_cancel_order") forState:UIControlStateNormal];
    [buttonCancelOrder setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [[buttonCancelOrder titleLabel] sizeToFitUI];
    CGSize size = LABEL_SIZE([buttonCancelOrder titleLabel]);
    buttonCancelOrder.frame = CGRectMake(netWidth*0.02f, 0, size.width, netHeight);
    [buttonCancelOrder setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateDisabled];
    [buttonCancelOrder setContentMode:UIViewContentModeLeft];
    [viewBottom addSubview:buttonCancelOrder];
    [buttonCancelOrder addTarget:self action:@selector(cancelOrder:) forControlEvents:UIControlEventTouchUpInside];
    [buttonCancelOrder.layer setValue:order forKey:@"MY_OBJECT"];
    [buttonCancelOrder.layer setValue:viewMain forKey:@"MY_VIEW"];
    UIButton *buttonTrackOrder = [[UIButton alloc] initWithFrame:CGRectMake(netWidth/2, 0, netWidth/2, netHeight)];
    [buttonCancelOrder.layer setValue:buttonCancelOrder forKey:@"ORDER_BUTTON_OBJECT"];
    [buttonCancelOrder.layer setValue:buttonTrackOrder forKey:@"TRACK_BUTTON_OBJECT"];
    [[buttonTrackOrder titleLabel] setUIFont:kUIFontType18 isBold:false];
    [buttonTrackOrder setTitle:Localize(@"track_order") forState:UIControlStateNormal];
    [buttonTrackOrder setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [buttonTrackOrder setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateDisabled];
    [buttonTrackOrder setUIImage:[UIImage imageNamed:@"track-icon.png"] forState:UIControlStateNormal];
    [buttonTrackOrder setUIImage:[UIImage imageNamed:@"track-icon.png"] forState:UIControlStateSelected];
    [buttonTrackOrder setContentMode:UIViewContentModeScaleAspectFit];
    [[buttonTrackOrder imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [buttonTrackOrder setImageEdgeInsets:UIEdgeInsetsMake(netHeight * .25f, 0, netHeight * .33f, 0)];
    if(0){
        [viewBottom addSubview:buttonTrackOrder];
    }
    [buttonTrackOrder addTarget:self action:@selector(trackOrder:) forControlEvents:UIControlEventTouchUpInside];
    [buttonTrackOrder.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [buttonTrackOrder.layer setBorderWidth:1];
    buttonTrackOrder.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    buttonTrackOrder.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    buttonTrackOrder.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    [buttonTrackOrder.layer setValue:order forKey:@"MY_OBJECT"];
    if([order._status isEqualToString:@"failed"] ||
       [order._status isEqualToString:@"pending"]
       ){
        [buttonCancelOrder setEnabled:true];
        [buttonTrackOrder setEnabled:true];
    } else {
        BOOL isOrderAgainButtonEnable = false;//[[Addons sharedManager] order_again];
        NSString* orderStatusStr = @"";
        if([order._status isEqualToString:@"completed"]) {
            orderStatusStr = Localize(@"completed");
        }
        else if([order._status isEqualToString:@"cancelled"]) {
            orderStatusStr = Localize(@"cancelled");
        }
        else if([order._status isEqualToString:@"refunded"]) {
            orderStatusStr = Localize(@"refunded");
        }
        else if([order._status isEqualToString:@"failed"]) {
            orderStatusStr = Localize(@"failed");
        }
        else if([order._status isEqualToString:@"processing"]) {
            orderStatusStr = Localize(@"processing");
        }
        else if([order._status isEqualToString:@"pending"]) {
            orderStatusStr = Localize(@"pending");
        }
        else if([order._status isEqualToString:@"on-hold"]) {
            orderStatusStr = Localize(@"onhold");
        }
        if ([order._status isEqualToString:@"completed"] && isOrderAgainButtonEnable) {
            NSString* text = [NSString stringWithFormat:Localize(@"i_order_val"), orderStatusStr];
            text = [NSString stringWithFormat:@"%@ %@", text, Localize(@"order_again")];
            [buttonCancelOrder setTitle:text forState:UIControlStateNormal];
            CGRect rect = CGRectMake(0, 0, netWidth, netHeight);
            buttonCancelOrder.frame = rect;
            [buttonCancelOrder setEnabled:true];
            [buttonCancelOrder setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            [buttonCancelOrder setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
            [buttonCancelOrder removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            [buttonCancelOrder addTarget:self action:@selector(reOrder:) forControlEvents:UIControlEventTouchUpInside];
            [buttonCancelOrder.layer setValue:order forKey:@"ORDER_OBJ"];
        } else {
            [buttonCancelOrder setTitle:[NSString stringWithFormat:Localize(@"i_order_val"), orderStatusStr] forState:UIControlStateDisabled];
            CGRect rect = CGRectMake(0, 0, netWidth, netHeight);
            buttonCancelOrder.frame = rect;
            [buttonCancelOrder setEnabled:false];
            [buttonTrackOrder setHidden:true];
        }
    }
    
    
    
    
    
    NSString* orderNoteDesc = order._notePickupLocation;
    if (orderNoteDesc && ![orderNoteDesc isEqualToString:@""]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:orderNoteDesc delegate:self cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:/*Localize(@"copy")*/nil, nil];
        [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != 0) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = order._notePickupLocation;
            }
        }];
    }
    
    
    
    return viewMain;
}
- (void)cancelOrder:(UIButton*)sender {
    RLOG(@"cancel order....");
    _selectedButtonCancelOrder = sender;
    _alertViewCancelOrder = [[UIAlertView alloc] initWithTitle:Localize(@"cancel_order") message:Localize(@"i_order_cancel_permission") delegate:self cancelButtonTitle:Localize(@"btn_yes") otherButtonTitles:Localize(@"btn_no"), nil];
    [_alertViewCancelOrder show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Checks For Approval
    if (alertView == _alertViewCancelOrder) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:Localize(@"btn_yes")]) {
            Order* order = [_selectedButtonCancelOrder.layer valueForKey:@"MY_OBJECT"];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrderSuccess:) name:@"UPDATE_ORDER_SUCCESS" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrderFailed:) name:@"UPDATE_ORDER_FAILURE" object:nil];
            [[[DataManager sharedManager] tmDataDoctor] updateOrder:nil orderId:order._id orderStatus:@"cancelled" isPaid:false];
        } else {
            _selectedButtonCancelOrder = nil;
        }
    }
}
- (void)updateOrderSuccess:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATE_ORDER_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATE_ORDER_FAILURE" object:nil];
    RLOG(@"updateOrderSuccess");
    
    Order* order = [_selectedButtonCancelOrder.layer valueForKey:@"MY_OBJECT"];
    UIView* mainView = [_selectedButtonCancelOrder.layer valueForKey:@"MY_VIEW"];
    UIView* view = [self createOrderSummery:0 order:order viewMain:mainView];
    mainView.layer.shadowOpacity = 0.0f;
    [Utility showShadow:mainView];
    [self resetMainScrollView];
    //    order._status = @"cancelled";
    
    //    UIButton* buttonCancelOrder = [_selectedButtonCancelOrder.layer valueForKey:@"ORDER_BUTTON_OBJECT"];
    //    UIButton* buttonTrackOrder = [_selectedButtonCancelOrder.layer valueForKey:@"TRACK_BUTTON_OBJECT"];
    //
    //    if([order._status isEqualToString:@"processing"] ||
    //       [order._status isEqualToString:@"on-hold"] ||
    //       [order._status isEqualToString:@"pending"]
    //       ){
    //        [buttonCancelOrder setEnabled:true];
    //        [buttonTrackOrder setEnabled:true];
    //    } else {
    //        [buttonCancelOrder setTitle:[NSString stringWithFormat:@"Order %@",[order._status capitalizedString]] forState:UIControlStateDisabled];
    //
    //        CGRect rect = CGRectMake(0, 0, self.view.frame.size.width * .96f, 50);
    //        buttonCancelOrder.frame = rect;
    //        [buttonCancelOrder setEnabled:false];
    //        [buttonTrackOrder setHidden:true];
    //    }
    
    AppUser* appUser = [AppUser sharedManager];
    [appUser saveData];
    
    _selectedButtonCancelOrder = nil;
}
- (void)updateOrderFailed:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATE_ORDER_SUCCESS"   object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATE_ORDER_FAILURE"   object:nil];
    RLOG(@"updateOrderFailed");
    _selectedButtonCancelOrder = nil;
}
- (void)trackOrder:(UIButton*)button {
    //here open web view to track order....
    RLOG(@"here open web view to track order....");
}
- (UIView*)addView:(LineItem*)lineItem currencyCode:(NSString*)currencyCode isCurrencySymbolAtLast:(BOOL)isCurrencySymbolAtLast {
    NSString *productImgUrl = [LineItem getImgUrlOnProductId:lineItem._product_id];
    int productQuantity = lineItem._quantity;
    float productTotalPrice = lineItem._subtotal;
    NSString *productName = lineItem._name;
    NSMutableArray* productProperties = lineItem._meta;
    
    float fontHeight = 20;
    float padding = self.view.frame.size.width * 0.05f;
    float height = 0;
    float viewMaxWidth = self.view.frame.size.width * 0.96f;
    CGRect rect;
    
    UILabel* labelName = [[UILabel alloc] init];
    [labelName setFrame:CGRectMake(0, height, viewMaxWidth, labelName.frame.size.height)];
    [labelName setUIFont:kUIFontType18 isBold:false];
    [labelName setTextColor:[Utility getUIColor:kUIColorFontLight]];
    //    [labelName setText:productName];
    [labelName setText:[Utility getNormalStringFromAttributed:productName]];
    [labelName sizeToFitUI];
    [labelName setNumberOfLines:0];
    height += labelName.frame.size.height;
    rect = labelName.frame;
    rect.origin.x = padding;
    [labelName setFrame:rect];
    
    /////////////
    
    NSMutableString *properties = [NSMutableString string];
    int i = 0;
    for (ProductMetaItemProperties* pmip in productProperties) {
        if (i > 0) {
            NSString* str = [NSString stringWithFormat:@",\n"];
            [properties appendString:str];
        }
        NSString* str = [NSString stringWithFormat:@"%@ - %@", pmip._label , pmip._value ];
        [properties appendString:str];
        i++;
    }
    if ([properties isEqualToString:@""]){
        [properties appendString:Localize(@"not_available")];
    }
    
    UILabel* labelProp = [[UILabel alloc] init];
    [labelProp setFrame:CGRectMake(0, height, viewMaxWidth, labelProp.frame.size.height)];
    [labelProp setUIFont:kUIFontType14 isBold:false];
    [labelProp setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [labelProp setText:properties];
    [labelProp sizeToFitUI];
    [labelProp setNumberOfLines:0];
    height += labelProp.frame.size.height;
    rect = labelProp.frame;
    rect.origin.x = padding;
    [labelProp setFrame:rect];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelProp setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelProp setTextAlignment:NSTextAlignmentLeft];
    }
    
    //////////////
    UILabel* labelQuantity = [[UILabel alloc] init];
    [labelQuantity setFrame:CGRectMake(0, height, viewMaxWidth, fontHeight)];
    [labelQuantity setUIFont:kUIFontType16 isBold:false];
    [labelQuantity setTextColor:[Utility getUIColor:kUIColorFontLight]];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelQuantity setText:[NSString stringWithFormat:@"%d :%@", productQuantity, Localize(@"label_quantity")]];
    } else {
        [labelQuantity setText:[NSString stringWithFormat:@"%@: %d", Localize(@"label_quantity"),productQuantity]];
    }
    [labelQuantity sizeToFitUI];
    [labelQuantity setNumberOfLines:0];
    rect = labelQuantity.frame;
    rect.origin.x = padding;
    [labelQuantity setFrame:rect];
    
    ///////////
    
    ///////////
    UILabel* labelPrice = [[UILabel alloc] init];
    [labelPrice setFrame:CGRectMake(0, height, viewMaxWidth, fontHeight)];
    [labelPrice setUIFont:kUIFontType16 isBold:false];
    [labelPrice setTextColor:[Utility getUIColor:kUIColorFontLight]];
    float price = productTotalPrice;
    //    NSString *priceStr = [[Utility sharedManager] convertToString:price isCurrency:true symbolAtLast:true];
    [labelPrice setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:price currencyCode:currencyCode symbolAtLast:isCurrencySymbolAtLast]]];
    
    //    [labelPrice setText:[NSString stringWithFormat:@"%@", priceStr]];
    [labelPrice sizeToFitUI];
    [labelPrice setNumberOfLines:0];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelPrice setTextAlignment:NSTextAlignmentLeft];
    } else {
        [labelPrice setTextAlignment:NSTextAlignmentRight];
    }
    rect = labelPrice.frame;
    rect.origin.x = viewMaxWidth - CGRectGetMaxX(labelPrice.frame) - padding;
    [labelPrice setFrame:rect];
    height += labelPrice.frame.size.height;
    
    
    
    
    //    UILabel* labelPriceHeading = [[UILabel alloc] init];
    //    [labelPriceHeading setUIFont:kUIFontType16 isBold:false];
    //    [labelPriceHeading setTextColor:[Utility getUIColor:kUIColorFontLight]];
    //    [labelPriceHeading setText:[NSString stringWithFormat:@""]];
    //    [labelPriceHeading sizeToFitUI];
    //    [labelPriceHeading setNumberOfLines:0];
    
    
    
    
    UIView* mainView = [[UIView alloc] init];
    [mainView setBackgroundColor:[UIColor whiteColor]];
    [mainView setFrame:CGRectMake(self.view.frame.size.width * 0.02f, 0, viewMaxWidth, height + fontHeight)];
    [mainView addSubview:labelName];
    if (labelProp) {
        [mainView addSubview:labelProp];
    }
    [mainView addSubview:labelQuantity];
    [mainView addSubview:labelPrice];
    //    [mainView addSubview:labelPriceHeading];
    [mainView setTag:kTagForNoSpacing];
    CGRect temp = mainView.frame;
    temp.size.height = mainView.frame.size.height * 2;
    mainView.frame = temp;
    UIImageView* imgProduct = [[UIImageView alloc] init];
    imgProduct.frame = CGRectMake(self.view.frame.size.width * 0.02f, self.view.frame.size.width * 0.02f, mainView.frame.size.height - self.view.frame.size.width * 0.04f, mainView.frame.size.height - self.view.frame.size.width * 0.04f);
    [mainView addSubview:imgProduct];
    [Utility setImage:imgProduct url:productImgUrl resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
    [imgProduct.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [imgProduct.layer setBorderWidth:1];
    [imgProduct setContentMode:UIViewContentModeScaleAspectFill];
    [imgProduct setClipsToBounds:true];
    
    temp = labelName.frame;
    temp.origin.x = CGRectGetMaxX(imgProduct.frame) + self.view.frame.size.width * 0.02f;
    temp.origin.y = self.view.frame.size.width * 0.02f + self.view.frame.size.width * 0.02f;
    temp.size.width = viewMaxWidth - temp.origin.x - self.view.frame.size.width * 0.02f;
    labelName.frame = temp;
    
    temp = labelProp.frame;
    temp.origin.x = CGRectGetMaxX(imgProduct.frame) + self.view.frame.size.width * 0.02f;
    temp.origin.y = CGRectGetMaxY(labelName.frame) + self.view.frame.size.width * 0.02f;
    temp.size.width = viewMaxWidth - temp.origin.x - self.view.frame.size.width * 0.02f;
    
    //    self.view.frame.size.width * 0.96f - temp.origin.x;
    labelProp.frame = temp;
    [labelProp setNumberOfLines:0];
    labelProp.lineBreakMode = NSLineBreakByWordWrapping;
    [labelProp sizeToFitUI];
    //    labelProp.frame = temp;
    
    temp = labelQuantity.frame;
    temp.origin.x = CGRectGetMaxX(imgProduct.frame) + self.view.frame.size.width * 0.02f;
    temp.origin.y = CGRectGetMaxY(labelProp.frame) + self.view.frame.size.width * 0.02f;
    labelQuantity.frame = temp;
    
    temp = labelPrice.frame;
    temp.origin.x = mainView.frame.size.width - self.view.frame.size.width * 0.02f - labelPrice.frame.size.width;
    temp.origin.y = CGRectGetMaxY(labelProp.frame) + self.view.frame.size.width * 0.02f;
    labelPrice.frame = temp;
    
    //    temp = labelPrice.frame;
    //    temp.origin.x = mainView.frame.size.width - self.view.frame.size.width * 0.02f - labelPrice.frame.size.width;
    //    temp.origin.y = mainView.frame.size.height * 0.5f - temp.size.height * 0.5f;
    //    labelPriceHeading.frame = temp;
    
    CGRect newRect = mainView.frame;
    newRect.size.height = MAX(CGRectGetMaxY(imgProduct.frame) + self.view.frame.size.width * 0.02f, CGRectGetMaxY(labelPrice.frame) + self.view.frame.size.width * 0.02f);
    mainView.frame = newRect;
    
    
    
    return mainView;
}

- (void)myOrders:(UIButton*)button
{
    //here open my orders view controller....
    RLOG(@"here open my orders view controller....");
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    mainVC.containerTop.hidden = YES;
    mainVC.containerCenter.hidden = YES;
    mainVC.containerCenterWithTop.hidden = NO;
    mainVC.vcBottomBar.buttonHome.selected = YES;
    mainVC.vcBottomBar.buttonCart.selected = NO;
    mainVC.vcBottomBar.buttonWishlist.selected = NO;
    mainVC.vcBottomBar.buttonSearch.selected = NO;
    mainVC.revealController.panGestureEnable = false;
    [mainVC.vcBottomBar buttonClicked:nil];
    ViewControllerOrder* vcOrder = (ViewControllerOrder*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_ORDER];
    RLOG(@"vcOrder = %@", vcOrder);
}
-(void)trymeview{
    UIView *view =[[UIView alloc] init];
    
    [view setBackgroundColor:[UIColor whiteColor]];
    float viewPosX = [UIScreen mainScreen].bounds.size.width *0.02f;
    float viewPosY = 50;
    float viewWidth =[UIScreen mainScreen].bounds.size.width * (1.0f - 0.04f);
    
    float ItemsPosX = viewWidth * 0.02f;
    float itemPosY = view.frame.size.width * 0.02f;
    float itemsWidth =viewWidth * (1.0f - 0.04);
    float gapY = 10;
    
    UILabel* labelSelect = [[UILabel alloc] init];
    [labelSelect setUIFont:kUIFontType22 isBold:false];
    [labelSelect setTextColor:[Utility getUIColor:kUIColorFontLight]];
    labelSelect.textAlignment = NSTextAlignmentCenter;
    labelSelect.numberOfLines = 0;
    NSString *selectyoursize = Localize(@"txt_try_me_text");
    [labelSelect setText:[NSString stringWithFormat:@"%@",selectyoursize]];
    
    [labelSelect sizeToFitUI];
    [view addSubview:labelSelect];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    itemPosY = gapY ;
    float lableSelectHeight =labelSelect.frame.size.height;
    if ([[MyDevice sharedManager] isIpad]) {
        [labelSelect setFrame:CGRectMake(ItemsPosX, itemPosY,itemsWidth, lableSelectHeight)];
    }else{
        [labelSelect setFrame:CGRectMake(ItemsPosX, itemPosY,itemsWidth, lableSelectHeight *2)];
    }
    labelSelect.layer.borderColor = [Utility getUIColor:kUIColorBorder].CGColor;
    
    itemPosY = CGRectGetMaxY(labelSelect.frame) + gapY;
    UIButton *ButtonTryMe =[[UIButton alloc]init];
    if ([[MyDevice sharedManager] isIpad]) {
        [[ButtonTryMe titleLabel] setUIFont:kUIFontType19 isBold:false];
    } else {
        [[ButtonTryMe titleLabel] setUIFont:kUIFontType18 isBold:false];
    }
    [ButtonTryMe setTitle:Localize(@"try_me") forState:UIControlStateNormal];
    [ButtonTryMe setTitleColor:[Utility getUIColor:kUIColorFontListViewLevel0] forState:UIControlStateNormal];
    ButtonTryMe.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [ButtonTryMe setFrame:CGRectMake(ItemsPosX, itemPosY, itemsWidth, 50)];
    ButtonTryMe.layer.borderWidth = 1.0;
    ButtonTryMe.layer.borderColor = [Utility getUIColor:kUIColorThemeFont].CGColor;
    [view addSubview:ButtonTryMe];
    [ButtonTryMe addTarget:self action:@selector(initFindMeAShoeSDK:) forControlEvents:UIControlEventTouchUpInside];
    itemPosY = CGRectGetMaxY(ButtonTryMe.frame);
    float viewHeight = itemPosY + gapY;
    [view setFrame:CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight)];
    [Utility showShadow:view];
}
- (void)initFindMeAShoeSDK:(UIButton *)sender{
#if ENABLE_FMAS
    FMASViewController* fmasViewController =  [[FMASViewController alloc] initWithDelegate:self];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:fmasViewController];
    [self presentViewController:navigation animated:YES completion:nil];
#endif
}
#pragma mark - Adjust Orientation
- (void)beforeRotation {
    UIView* lastView = [_viewsAdded lastObject];
    for(UIView *view in _viewsAdded)
    {
        [UIView animateWithDuration:0.1f animations:^{
            [view setAlpha:0.0f];
        }completion:^(BOOL finished){
            [view removeFromSuperview];
            if (view == lastView) {
                [_scrollView setAlpha:0.0f];
                [_viewsAdded removeAllObjects];
                [self loadAllViews];
                for(UIView *vieww in _viewsAdded)
                {
                    [vieww setAlpha:0.0f];
                }
                [_scrollView setAlpha:1.0f];
            }
        }];
    }
}
- (void)afterRotation {
    for(UIView *vieww in _viewsAdded)
    {
        [UIView animateWithDuration:0.1f animations:^{
            [vieww setAlpha:1.0f];
        }completion:^(BOOL finished){
            
        }];
    }
}
- (void)adjustViewsForOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"====adjustViewsForOrientation====");
    [self beforeRotation];
}
- (void)adjustViewsAfterOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"====adjustViewsAfterOrientation====");
    [self afterRotation];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self adjustViewsAfterOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self adjustViewsForOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
- (void)setData:(NSDictionary*)dict {


}
@end
