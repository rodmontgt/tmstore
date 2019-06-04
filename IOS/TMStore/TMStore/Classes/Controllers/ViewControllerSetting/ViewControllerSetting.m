//
//  ViewControllerSetting.m
//  TMStore
//
//  Created by Twist Mobile on 07/03/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "ViewControllerSetting.h"
#import "Utility.h"
#import "Variables.h"
#import "ParseHelper.h"
#import "CurrencyItem.h"
#import "CurrencyHelper.h"
#import "Cart.h"
#import "ProductInfo.h"
#import "Variation.h"
#import "CommonInfo.h"
#import "CurrencyViewController.h"
#import "ViewControllerMain.h"

static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;

@interface ViewControllerSetting (){
    CurrencyItem *selectedCurrencyItem;
}

@end

@implementation ViewControllerSetting

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
    [_labelViewHeading setText:[NSString stringWithFormat:@"%@",Localize(@"title_settings")]];
    [self.view addSubview:_labelViewHeading];

    [_navigationBar setClipsToBounds:false];
    [_lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
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
    application =(AppDelegate*)[UIApplication sharedApplication].delegate;
    viewsAdded =[[NSMutableArray alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:@"LANGUAGE_CHANGED" object:nil];
    _chkBoxLanguage = [[NSMutableArray alloc] init];
    _chkBoxCurrency = [[NSMutableArray alloc] init];
    [self loadViewDA];
    [_labelNotification setText:[NSString stringWithFormat:@"%@",application.notification]];
}
-(void)viewDidAppear:(BOOL)animated{
    [self viewDidLoad];
    [application checkForNotificationPermission];
    [_labelNotification setText:[NSString stringWithFormat:@"%@",application.notification]];
}
- (void)loadViewDA {
    for (UIView* view in viewsAdded) {
        [view removeFromSuperview];
    }
    [self.scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];

    [viewsAdded removeAllObjects];
    [self CreatNotificatinViewOnOFF];
    [self createLanguageSelectionView];
    [self createCurrencySwitcherView];
    [self resetMainScrollView];
}

#pragma mark - Create View

-(void)CreatNotificatinViewOnOFF{

    UIView *view =[[UIView alloc] init];

    [view setBackgroundColor:[UIColor whiteColor]];
    float viewPosX = [UIScreen mainScreen].bounds.size.width *0.04f;
    float viewPosY = [UIScreen mainScreen].bounds.size.width *0.04f;
    float viewWidth =[UIScreen mainScreen].bounds.size.width * (1.0f - 0.08f);
    float ONOFFWidth = 100;
    float ItemsPosX = [UIScreen mainScreen].bounds.size.width * 0.04f;
    float itemPosY = view.frame.size.width * 0.00f;

    [view setFrame:CGRectMake(viewPosX, viewPosY, viewWidth, 0)];
    UIButton *ButtonNotification =[[UIButton alloc]init];
    if ([[MyDevice sharedManager] isIpad]) {
        [[ButtonNotification titleLabel] setUIFont:kUIFontType19 isBold:false];
    } else {
        [[ButtonNotification titleLabel] setUIFont:kUIFontType18 isBold:false];
    }
    [ButtonNotification setTitle:Localize(@"title_notification") forState:UIControlStateNormal];
    [ButtonNotification setTitleColor:[Utility getUIColor:kUIColorFontListViewLevel0] forState:UIControlStateNormal];
    ButtonNotification.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [ButtonNotification setFrame:CGRectMake(ItemsPosX, itemPosY, viewWidth, 0)];
    [ButtonNotification sizeToFit];
    [ButtonNotification setFrame:CGRectMake(ItemsPosX, itemPosY, viewWidth, ButtonNotification.frame.size.height)];

    [view addSubview:ButtonNotification];
    [ButtonNotification addTarget:self action:@selector(openNotificationSettiong) forControlEvents:UIControlEventTouchUpInside];

    view.layer.cornerRadius = 8;
    view.layer.masksToBounds = YES;
    view.backgroundColor = [UIColor whiteColor];



    _labelNotification= [[UILabel alloc] init];
    if ([[MyDevice sharedManager] isIpad]) {
        [_labelNotification setUIFont:kUIFontType19 isBold:false];
    } else {
        [_labelNotification setUIFont:kUIFontType18 isBold:false];
    }
    [_labelNotification setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [view addSubview:_labelNotification];
    _labelNotification.textAlignment = NSTextAlignmentRight;

    [_labelNotification setFrame:CGRectMake(viewWidth - ONOFFWidth - 2*ItemsPosX, itemPosY,ONOFFWidth, [[_labelNotification font] lineHeight]*1.5)];
    [_labelNotification setText:[NSString stringWithFormat:@"%@",application.notification]];

    UIImageView *imageRightArrow = [[UIImageView alloc]init];
    imageRightArrow.image =[UIImage imageNamed:@"img_arrow_back"];
    imageRightArrow.image = [imageRightArrow.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [imageRightArrow setTintColor:[UIColor colorWithRed:199.0f/225.0f green:199.0f/225.0f blue:204.0f/225.0f alpha:1.0]];

    imageRightArrow.contentMode = UIViewContentModeCenter;
    imageRightArrow.transform = CGAffineTransformMakeScale(-1, 1);
    [view addSubview:imageRightArrow];

    float viewHeight =CGRectGetMaxY(ButtonNotification.frame) *1.2;

    float linePosY = viewHeight - 3;
    UILabel* labelLine= [[UILabel alloc] init];
    labelLine.backgroundColor =[UIColor colorWithRed:195.0f/225.0f green:195.0f/225.0f blue:195.0f/225.0f alpha:1.0];
    float linePosX = ItemsPosX;
    [labelLine setFrame:CGRectMake(linePosX, linePosY, viewWidth, 1)];
    [view addSubview:labelLine];
    [view setFrame:CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight)];
    imageRightArrow.frame = CGRectMake(view.frame.size.width - view.frame.size.height, view.frame.size.height*.1f, view.frame.size.height * .8, view.frame.size.height * .8f);

    [self.scrollView addSubview:view];
    [viewsAdded addObject:view];
    //    [Utility showShadow:view];
    [self resetMainScrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnteredInForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}


-(void)createLanguageSelectionView{
    Addons* addons = [Addons sharedManager];
    int numberOfLanguages = 1;
    if(addons.language && addons.language.titles && [addons.language.titles count] > 0) {
        numberOfLanguages = (int)[addons.language.titles count];
    }

    UIView *view =[[UIView alloc] init];

    [view setBackgroundColor:[UIColor whiteColor]];
    float viewPosX = [UIScreen mainScreen].bounds.size.width *0.04f;
    float viewPosY = [UIScreen mainScreen].bounds.size.width *0.04f;
    float viewWidth =[UIScreen mainScreen].bounds.size.width * (1.0f - 0.08f);
    float ONOFFWidth = 100;
    float ItemsPosX = [UIScreen mainScreen].bounds.size.width * 0.04f;
    float itemPosY = view.frame.size.width * 0.00f;

    [view setFrame:CGRectMake(viewPosX, viewPosY, viewWidth, 0)];

    UIButton *ButtonLanguage =[[UIButton alloc]init];
    if ([[MyDevice sharedManager] isIpad]) {
        [[ButtonLanguage titleLabel] setUIFont:kUIFontType19 isBold:false];
    } else {
        [[ButtonLanguage titleLabel] setUIFont:kUIFontType18 isBold:false];
    }
    [ButtonLanguage setTitle:Localize(@"title_language") forState:UIControlStateNormal];
    [ButtonLanguage setTitleColor:[Utility getUIColor:kUIColorFontListViewLevel0] forState:UIControlStateNormal];
    ButtonLanguage.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [ButtonLanguage setFrame:CGRectMake(ItemsPosX, itemPosY, viewWidth, 0)];
    [ButtonLanguage sizeToFit];
    [ButtonLanguage setFrame:CGRectMake(ItemsPosX, itemPosY, viewWidth, ButtonLanguage.frame.size.height)];
    [view addSubview:ButtonLanguage];
    [ButtonLanguage addTarget:self action:@selector(showLanguageSelectionScreen) forControlEvents:UIControlEventTouchUpInside];

    UILabel* labelSelectLan= [[UILabel alloc] init];
    [labelSelectLan setUIFont:kUIFontType22 isBold:false];
    [labelSelectLan setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [view addSubview:labelSelectLan];
    [self.scrollView addSubview:view];
    [labelSelectLan setFrame:CGRectMake(ItemsPosX, itemPosY,viewWidth, [[labelSelectLan font] lineHeight]*1.5)];
    labelSelectLan.layer.borderColor = [Utility getUIColor:kUIColorBorder].CGColor;
    NSString* localeTitle = [[NSUserDefaults standardUserDefaults] valueForKey:USER_LOCAL_TITLE];
    if (localeTitle == nil || [localeTitle isEqualToString:@""]) {
        localeTitle = @"English";
        [[NSUserDefaults standardUserDefaults] setValue:@"English" forKey:USER_LOCAL_TITLE];
    }

    [labelSelectLan setText:[NSString stringWithFormat:@"%@",localeTitle]];
    [view addSubview:labelSelectLan];

    view.layer.cornerRadius = 8;
    view.layer.masksToBounds = YES;
    view.backgroundColor = [UIColor whiteColor];

    [labelSelectLan sizeToFitUI];
    ItemsPosX = viewWidth - labelSelectLan.frame.size.width - ItemsPosX *2 ;
    float viewHeight =CGRectGetMaxY(ButtonLanguage.frame) *1.2;

    UIImageView *imageRightArrow = [[UIImageView alloc]init];
    imageRightArrow.image =[UIImage imageNamed:@"img_arrow_back"];
    imageRightArrow.image = [imageRightArrow.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [imageRightArrow setTintColor:[UIColor colorWithRed:199.0f/225.0f green:199.0f/225.0f blue:204.0f/225.0f alpha:1.0]];
    imageRightArrow.contentMode = UIViewContentModeCenter;
    imageRightArrow.transform = CGAffineTransformMakeScale(-1, 1);
    if (numberOfLanguages > 1) {
        [view addSubview:imageRightArrow];
    }

    [labelSelectLan setFrame:CGRectMake(ItemsPosX, itemPosY, labelSelectLan.frame.size.width, viewHeight)];
    [view setFrame:CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight)];
    imageRightArrow.frame = CGRectMake(view.frame.size.width - view.frame.size.height, view.frame.size.height*.1f, view.frame.size.height * .8, view.frame.size.height * .8f);

    [self.scrollView addSubview:view];
    [viewsAdded addObject:view];
    [self resetMainScrollView];
}
- (void)createCurrencySwitcherView{

    if (![[Addons sharedManager]enable_currency_switcher]) {
        return;
    }

    UIView *view =[[UIView alloc] init];

    [view setBackgroundColor:[UIColor whiteColor]];
    float viewPosX = [UIScreen mainScreen].bounds.size.width *0.04f;
    float viewPosY = [UIScreen mainScreen].bounds.size.width *0.04f;
    float viewWidth =[UIScreen mainScreen].bounds.size.width * (1.0f - 0.08f);

    float ItemsPosX = [UIScreen mainScreen].bounds.size.width * 0.04f;
    float itemPosY = view.frame.size.width * 0.00f;

    [view setFrame:CGRectMake(viewPosX, viewPosY, viewWidth, 0)];
    UIButton *ButtonCurrency =[[UIButton alloc]init];
    if ([[MyDevice sharedManager] isIpad]) {
        [[ButtonCurrency titleLabel] setUIFont:kUIFontType19 isBold:false];
    } else {
        [[ButtonCurrency titleLabel] setUIFont:kUIFontType18 isBold:false];
    }
    [ButtonCurrency setTitle:Localize(@"title_currency") forState:UIControlStateNormal];
    [ButtonCurrency setTitleColor:[Utility getUIColor:kUIColorFontListViewLevel0] forState:UIControlStateNormal];
    ButtonCurrency.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [ButtonCurrency setFrame:CGRectMake(ItemsPosX, itemPosY, viewWidth, 0)];
    [ButtonCurrency sizeToFit];
    [ButtonCurrency setFrame:CGRectMake(ItemsPosX, itemPosY, viewWidth, ButtonCurrency.frame.size.height)];
    [view addSubview:ButtonCurrency];
    [ButtonCurrency addTarget:self action:@selector(showCurrencySelectionScreen) forControlEvents:UIControlEventTouchUpInside];

    UILabel* labelSelectCurrency= [[UILabel alloc] init];
    [labelSelectCurrency setUIFont:kUIFontType22 isBold:false];
    [labelSelectCurrency setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [view addSubview:labelSelectCurrency];
    [self.scrollView addSubview:view];
    [labelSelectCurrency setFrame:CGRectMake(ItemsPosX, itemPosY,viewWidth, [[labelSelectCurrency font] lineHeight]*1.5)];
    labelSelectCurrency.layer.borderColor = [Utility getUIColor:kUIColorBorder].CGColor;

    NSString* currentCurrency = [[NSUserDefaults standardUserDefaults] valueForKey:@"APP_CURRENCY"];
    if (currentCurrency == nil || [currentCurrency isEqualToString:@""]) {
        currentCurrency = [CommonInfo sharedManager] -> _currency;
    }
    [labelSelectCurrency setText:[NSString stringWithFormat:@"%@",currentCurrency]];
    [view addSubview:labelSelectCurrency];

    view.layer.cornerRadius = 8;
    view.layer.masksToBounds = YES;
    view.backgroundColor = [UIColor whiteColor];

    [labelSelectCurrency sizeToFitUI];
    ItemsPosX = viewWidth - labelSelectCurrency.frame.size.width - ItemsPosX *2 ;
    float viewHeight =CGRectGetMaxY(ButtonCurrency.frame) *1.2;

    UIImageView *imageRightArrow = [[UIImageView alloc]init];
    imageRightArrow.image =[UIImage imageNamed:@"img_arrow_back"];
    imageRightArrow.image = [imageRightArrow.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [imageRightArrow setTintColor:[UIColor colorWithRed:199.0f/225.0f green:199.0f/225.0f blue:204.0f/225.0f alpha:1.0]];
    imageRightArrow.contentMode = UIViewContentModeCenter;
    imageRightArrow.transform = CGAffineTransformMakeScale(-1, 1);
    [view addSubview:imageRightArrow];

    [labelSelectCurrency setFrame:CGRectMake(ItemsPosX, itemPosY, labelSelectCurrency.frame.size.width, viewHeight)];
    [view setFrame:CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight)];
    imageRightArrow.frame = CGRectMake(view.frame.size.width - view.frame.size.height, view.frame.size.height*.1f, view.frame.size.height * .8, view.frame.size.height * .8f);

    [self.scrollView addSubview:view];
    [viewsAdded addObject:view];
    [self resetMainScrollView];
}

- (void)appWillEnteredInForeground:(NSNotification *)notification {
    [application checkForNotificationPermission];
    [self loadViewDA];
}

#pragma mark - All Button Actions

- (IBAction)barButtonBackPressed:(id)sender {
    [[Utility sharedManager] popScreen:self];
    if ([self.view tag] == PUSH_SCREEN_TYPE_NOTIFICATION) {
        return;
    }
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC resetPreviousState];
}
-(void)openNotificationSettiong{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}
#pragma mark Localization
- (void)languageSelectedDone:(id)sender {

    if(self.popupControllerLanguage != nil) {
        [self.popupControllerLanguage dismissPopupControllerAnimated:YES];
    }
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    [[NSUserDefaults standardUserDefaults] setValue:_selectedLocale forKey:USER_LOCALE];
    [[NSUserDefaults standardUserDefaults] setValue:_selectedLocaleTitle forKey:USER_LOCAL_TITLE];

    [[TMLanguage sharedManager] refreshLanguage];
    [Utility changeInputLanguage:_selectedLocale];
}
/*
- (void)currencySelectedDone:(id)sender {
    if(self.popupControllerCurrency != nil) {
        [self.popupControllerCurrency dismissPopupControllerAnimated:YES];
    }

    if (selectedCurrencyItem == nil) {
        return;
    }

    NSString *currencyName = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_CURRENCY"];
    if (![selectedCurrencyItem.name isEqualToString:currencyName]) {
        [CurrencyHelper setSelectedCurrencyItem:selectedCurrencyItem];

        [CommonInfo sharedManager] -> _currency = selectedCurrencyItem.name;

        //format html text and returns plain text.
        selectedCurrencyItem.symbol = [[[NSAttributedString alloc] initWithData:[selectedCurrencyItem.symbol dataUsingEncoding:NSUnicodeStringEncoding]
                                                        options:@ {NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                             documentAttributes:nil
                                                          error:nil] string];
        [CommonInfo sharedManager] -> _currency_format = selectedCurrencyItem.symbol;


        CurrencyItem *lastCurrencyItem = [CurrencyHelper getCurrencyItemWithName:currencyName];
        if (lastCurrencyItem != nil) {
            float rate =  selectedCurrencyItem.rate /lastCurrencyItem.rate;
            if([Cart getAll] != nil) {
                for (Cart *cart in [Cart getAll]) {
                    [cart setProductPrice:cart.productPrice * rate];
                }
            }

            for (ProductInfo *product in [ProductInfo getAll]) {
                if (product == nil) {
                    continue;
                }

                product._price = product._price * rate;
                product._regular_price = product._regular_price * rate;
                product._sale_price = product._sale_price * rate;
                product._priceMax = product._priceMax * rate;
                product._priceMin = product._priceMin * rate;

                if (product._variations) {
                    for (Variation *variation in product._variations) {
                        if (variation == nil) {
                            continue;
                        }

                        variation._price = variation._price * rate;
                        variation._regular_price = variation._regular_price * rate;
                        variation._sale_price = variation._sale_price * rate;
                    }
                }
            }
        }

        [ProductInfo resetAllProductLocalizedStrings];

        [[NSUserDefaults standardUserDefaults] setValue:selectedCurrencyItem.name forKey:@"APP_CURRENCY"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
        
        [self refreshViewController];
    }
}
*/
- (void)languageChanged:(NSNotification*)notification {
    [self refreshViewController];
}
- (void)refreshViewController {
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    [ViewControllerMain resetInstance];//rpj
    UIStoryboard *sb = [Utility getStoryBoardObject];//rpj
                                                     //    [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];

    SWRevealViewController *mainRevealController = [sb instantiateViewControllerWithIdentifier:VC_SWREVEAL];
    UIViewController *mainViewController = [sb instantiateViewControllerWithIdentifier:VC_MAIN];
    UIViewController *rightViewController = [sb instantiateViewControllerWithIdentifier:VC_RIGHT];
    UIViewController *leftViewController = [sb instantiateViewControllerWithIdentifier:VC_LEFT];
    mainRevealController = [[SWRevealViewController alloc] initWithRearViewController:leftViewController frontViewController:mainViewController];
    if ([[Addons sharedManager] multiVendor_enable] &&
        [[Addons sharedManager] multiVendor_screen_type] == MULTIVENDOR_SCREEN_SELLER) {
        [mainRevealController setRightViewController:rightViewController];
    }
    RLOG(@"rightViewController = %@", rightViewController);
    [[UIApplication sharedApplication].keyWindow setRootViewController:mainRevealController];
}
- (void)chkBoxLanguageClicked:(id)sender {
    UIButton* senderButton = (UIButton*)sender;
    [senderButton setSelected:YES];
    for (UIButton* button in _chkBoxLanguage) {
        if(button != senderButton){
            [button setSelected:NO];
        }
    }
    if ([senderButton isSelected]) {
        _selectedLocale = [senderButton.layer valueForKey:@"MY_LOCALE"];
        _selectedLocaleTitle =[senderButton.layer valueForKey:@"MY_LOCALE_TITLE"];
        [[ParseHelper sharedManager] downloadLanguageFileInBg:_selectedLocale];
    }
}
/*
- (void)chkBoxCurrencyClicked:(id)sender {
    UIButton* senderButton = (UIButton*)sender;
    [senderButton setSelected:YES];
    for (UIButton* button in _chkBoxCurrency) {
        if(button != senderButton){
            [button setSelected:NO];
        }
    }
    if ([senderButton isSelected]) {
        selectedCurrencyItem = [senderButton.layer valueForKey:@"SELECTED_CURRENCY_ITEM"];
    }

}
 */
- (void)showLanguageSelectionScreen {
    Addons* addons = [Addons sharedManager];
    if(addons.language && addons.language.titles && [addons.language.titles count] > 0) {
        if ([addons.language.titles count] == 1) {
            return;
        }
    } else {
        return;
    }
    if(self.popupControllerLanguage == nil) {
        float widthView = [[MyDevice sharedManager] screenSize].width - [[MyDevice sharedManager] screenSize].width * 0.1f;
        float heightView = [[MyDevice sharedManager] screenSize].height - [[MyDevice sharedManager] screenSize].width * 0.1f;

        if ([[MyDevice sharedManager] isIpad]) {
            widthView = [[MyDevice sharedManager] screenWidthInPortrait] * 0.65f;
            heightView = [[MyDevice sharedManager] screenHeightInPortrait] * 0.63f;

        }else if ([[MyDevice sharedManager] isIphone]) {
            widthView = [[MyDevice sharedManager] screenSize].width * 0.96f;
            heightView = [[MyDevice sharedManager] screenSize].height * 0.70f;
        }

        UIView* viewMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView)];
        viewMain.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
        //    _mainViewRegister = viewMain;

        UIView* viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView * 0.05f)];
        viewTop.backgroundColor = [UIColor whiteColor];
        //    viewMain.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
        [viewMain addSubview:viewTop];

        self.popupControllerLanguage = [[CNPPopupController alloc] initWithContents:@[viewMain]];
        self.popupControllerLanguage.theme = [CNPPopupTheme addressTheme];
        self.popupControllerLanguage.theme.popupStyle = CNPPopupStyleCentered;
        self.popupControllerLanguage.theme.size = CGSizeMake(widthView, heightView);
        self.popupControllerLanguage.theme.maxPopupWidth = widthView;
        self.popupControllerLanguage.delegate = self;
        self.popupControllerLanguage.theme.shouldDismissOnBackgroundTouch = true;
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            self.popupControllerLanguage.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
        }

        UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16) textStr:Localize(@"select_language")];
        [_labelTitle setTextAlignment:NSTextAlignmentCenter];

        float leftItemsPosX = viewMain.frame.size.width * 0.10f;
        float itemPosY = viewMain.frame.size.width * 0.04f + viewTop.frame.size.height;
        float itemPosYOriginal = viewMain.frame.size.width * 0.04f + viewTop.frame.size.height;
        UILabel* labelTemp= [[UILabel alloc] init];
        [labelTemp setUIFont:kUIFontType24 isBold:false];
        float fontHeight = [[labelTemp font] lineHeight];

        Addons* addons = [Addons sharedManager];
        if(addons.language&& addons.language.titles && [addons.language.titles count] > 0) {
            {
                for (int i = 0; i < (int)[addons.language.titles count]; i++) {
                    CGRect frame = CGRectMake(leftItemsPosX + 10, itemPosY, viewMain.frame.size.width, fontHeight);
                    itemPosY+=(frame.size.height + fontHeight * 0.5f);
                }
            }
        }
        itemPosY += itemPosYOriginal;

        self.popupControllerLanguage.theme.size = CGSizeMake(widthView, itemPosY);
        CGRect viewMainFrame = viewMain.frame;
        viewMainFrame.size = CGSizeMake(widthView, itemPosY);
        viewMain.frame = viewMainFrame;


        itemPosY = itemPosYOriginal;
        if(addons.language&& addons.language.titles && [addons.language.titles count] > 0) {
            for (int i = 0; i < (int)[addons.language.titles count]; i++) {
                UIButton* button = [[UIButton alloc] init];
                button.frame = CGRectMake(leftItemsPosX + 10, itemPosY, viewMain.frame.size.width, fontHeight);
                [button addTarget:self action:@selector(chkBoxLanguageClicked:) forControlEvents:UIControlEventTouchUpInside];
                [viewMain addSubview:button];

                [button setUIImage:[UIImage imageNamed:@"radiobtn_unselected"] forState:UIControlStateNormal];
                [button setUIImage:[UIImage imageNamed:@"radiobtn_selected"] forState:UIControlStateSelected];
                [button setTitle:[NSString stringWithFormat:@"%@", addons.language.titles[i]] forState:UIControlStateNormal];
                [button setTitleEdgeInsets:UIEdgeInsetsMake(0, viewMain.frame.size.width * 0.04f, 0, 0)];
                [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
                [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateSelected];
                [button.titleLabel setUIFont:kUIFontType20 isBold:false];
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                [button.layer setValue:addons.language.locales[i] forKey:@"MY_LOCALE"];
                [button.layer setValue:addons.language.titles[i] forKey:@"MY_LOCALE_TITLE"];

                [_chkBoxLanguage addObject:button];

                NSString* selecetedLocale = addons.language.defaultLocale;
                NSString* selecetedtitle = [NSString stringWithFormat:@"%@", addons.language.titles[i]];
                if ([[TMLanguage sharedManager] isUserLanguageSet]) {
                    selecetedLocale = [[NSUserDefaults standardUserDefaults] valueForKey:USER_LOCALE];
                    selecetedtitle = [[NSUserDefaults standardUserDefaults] valueForKey:USER_LOCAL_TITLE];
                }
                if ([selecetedLocale isEqualToString:addons.language.locales[i]]) {
                    [button setSelected:true];
                }
                itemPosY += (button.frame.size.height + fontHeight * 0.5f);
            }

            for (UIButton* button in _chkBoxLanguage) {
                if (button.isSelected) {
                    [self chkBoxLanguageClicked:button];
                }
            }
            if ((int)[_chkBoxLanguage count] == 1) {
                UIButton* button = (UIButton*)[_chkBoxLanguage objectAtIndex:0];
                [button setSelected:true];
                [self chkBoxLanguageClicked:button];
            }
        }

        UIButton* _buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16)];
        [viewTop addSubview:_buttonCancel];
        [_buttonCancel addTarget:self action:@selector(languageSelectedDone:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonCancel setTitle:Localize(@"i_cok") forState:UIControlStateNormal];
        [[_buttonCancel titleLabel] setUIFont:kUIFontType18 isBold:false];
        [_buttonCancel setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
        [_buttonCancel setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 16)];
        _buttonCancel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [viewMain addSubview:_buttonCancel];
    }
    [self.popupControllerLanguage presentPopupControllerAnimated:YES];
}
- (void)showCurrencySelectionScreen{

    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    mainVC.containerTop.hidden = YES;
    mainVC.containerCenter.hidden = YES;
    mainVC.containerCenterWithTop.hidden = NO;
    mainVC.vcBottomBar.buttonHome.selected = YES;
    mainVC.vcBottomBar.buttonCart.selected = NO;
    mainVC.vcBottomBar.buttonWishlist.selected = NO;
    mainVC.vcBottomBar.buttonSearch.selected = NO;
    [mainVC.vcBottomBar buttonClicked:nil];

    CurrencyViewController* vcCurrency = (CurrencyViewController*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_CURRENCY];



/*
    selectedCurrencyItem = nil;
    NSMutableArray *currencyItemArray = [CurrencyItem currencyItemList];
    if ([currencyItemArray count] <= 1) {
        return;
    }

    if(self.popupControllerCurrency == nil) {
        float widthView = [[MyDevice sharedManager] screenSize].width - [[MyDevice sharedManager] screenSize].width * 0.1f;
        float heightView = [[MyDevice sharedManager] screenSize].height - [[MyDevice sharedManager] screenSize].width * 0.1f;

        if ([[MyDevice sharedManager] isIpad]) {
            widthView = [[MyDevice sharedManager] screenWidthInPortrait] * 0.65f;
            heightView = [[MyDevice sharedManager] screenHeightInPortrait] * 0.63f;

        }else if ([[MyDevice sharedManager] isIphone]) {
            widthView = [[MyDevice sharedManager] screenSize].width * 0.96f;
            heightView = [[MyDevice sharedManager] screenSize].height * 0.70f;
        }

        UIView* viewMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView)];
        viewMain.backgroundColor = [Utility getUIColor:kUIColorBgTheme];


        UIView* viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView * 0.05f)];
        viewTop.backgroundColor = [UIColor whiteColor];
        [viewMain addSubview:viewTop];

        self.popupControllerCurrency = [[CNPPopupController alloc] initWithContents:@[viewMain]];
        self.popupControllerCurrency.theme = [CNPPopupTheme addressTheme];
        self.popupControllerCurrency.theme.popupStyle = CNPPopupStyleCentered;
        self.popupControllerCurrency.theme.size = CGSizeMake(widthView, heightView);
        self.popupControllerCurrency.theme.maxPopupWidth = widthView;
        self.popupControllerCurrency.delegate = self;
        self.popupControllerCurrency.theme.shouldDismissOnBackgroundTouch = true;
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            self.popupControllerCurrency.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
        }
        UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16) textStr:Localize(@"change_currency")];
        [_labelTitle setTextAlignment:NSTextAlignmentCenter];

        float leftItemsPosX = viewMain.frame.size.width * 0.10f;
        float itemPosY = viewMain.frame.size.width * 0.04f + viewTop.frame.size.height;
        float itemPosYOriginal = viewMain.frame.size.width * 0.04f + viewTop.frame.size.height;
        UILabel* labelTemp= [[UILabel alloc] init];
        [labelTemp setUIFont:kUIFontType24 isBold:false];
        float fontHeight = [[labelTemp font] lineHeight];


        for (int i = 0; i < [currencyItemArray count]; i++) {
            CGRect frame = CGRectMake(leftItemsPosX + 10, itemPosY, viewMain.frame.size.width, fontHeight);
            itemPosY+=(frame.size.height + fontHeight * 0.5f);
        }

        itemPosY += itemPosYOriginal;

        self.popupControllerCurrency.theme.size = CGSizeMake(widthView, itemPosY);
        CGRect viewMainFrame = viewMain.frame;
        viewMainFrame.size = CGSizeMake(widthView, itemPosY);
        viewMain.frame = viewMainFrame;

        itemPosY = itemPosYOriginal;

        NSString *lastSelectedCurrencyName = [[NSUserDefaults standardUserDefaults]stringForKey:@"APP_CURRENCY"];

        for (int i = 0; i < [currencyItemArray count]; i++) {

            CurrencyItem *currencyItem = [currencyItemArray objectAtIndex:i];

            UIButton* button = [[UIButton alloc] init];
            button.frame = CGRectMake(leftItemsPosX + 10, itemPosY, viewMain.frame.size.width, fontHeight);
            [button addTarget:self action:@selector(chkBoxCurrencyClicked:) forControlEvents:UIControlEventTouchUpInside];
            [viewMain addSubview:button];
            UIImageView *image = [[UIImageView alloc]init];
            image.frame = CGRectMake(leftItemsPosX - 40, itemPosY, 40, fontHeight);
            [Utility setImage:image url:currencyItem.flag resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
            if (image != nil && image) {
                 [viewMain addSubview:image];
            }
            [button setUIImage:[UIImage imageNamed:@"radiobtn_unselected"] forState:UIControlStateNormal];
            [button setUIImage:[UIImage imageNamed:@"radiobtn_selected"] forState:UIControlStateSelected];
            [button setTitle:[NSString stringWithFormat:@"%@ (%@)", currencyItem.name,currencyItem.desc] forState:UIControlStateNormal];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(0, viewMain.frame.size.width * 0.04f, 0, 0)];
            [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
            [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateSelected];
            [button.titleLabel setUIFont:kUIFontType20 isBold:false];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            [button.layer setValue:currencyItem forKey:@"SELECTED_CURRENCY_ITEM"];

            [_chkBoxCurrency addObject:button];

            if ([lastSelectedCurrencyName isEqualToString:currencyItem.name]) {
                [button setSelected:true];
            }
            itemPosY += (button.frame.size.height + fontHeight * 0.5f);
        }

        for (UIButton* button in _chkBoxCurrency) {
            if (button.isSelected) {
                [self chkBoxCurrencyClicked:button];
            }
        }
        if ((int)[_chkBoxCurrency count] == 1) {
            UIButton* button = (UIButton*)[_chkBoxCurrency objectAtIndex:0];
            [button setSelected:true];
            [self chkBoxCurrencyClicked:button];
        }
        UIButton* _buttonOK = [[UIButton alloc] initWithFrame:CGRectMake(0, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16)];
        [viewTop addSubview:_buttonOK];
        [_buttonOK addTarget:self action:@selector(currencySelectedDone:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonOK setTitle:Localize(@"i_cok") forState:UIControlStateNormal];
        [[_buttonOK titleLabel] setUIFont:kUIFontType18 isBold:false];
        [_buttonOK setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
        [_buttonOK setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 16)];
        _buttonOK.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [viewMain addSubview:_buttonOK];
    }
    [self.popupControllerCurrency presentPopupControllerAnimated:YES];
    */
}
- (UILabel*)createLabel:(UIView*)parentView fontType:(int)fontType fontColorType:(int)fontColorType frame:(CGRect)frame textStr:(NSString*)textStr {
    UILabel* label = [[UILabel alloc] init];
    if (CGRectEqualToRect(frame, CGRectMake(0, 0, 0, 0))) {
        frame = parentView.frame;
    }
    [label setUIFont:fontType isBold:false];
    [label setTextColor:[Utility getUIColor:fontColorType]];
    [label setFrame:frame];
    [label setText:textStr];
    [parentView addSubview:label];
    return label;
}

#pragma mark - CNPPopupController Delegate
- (void)popupController:(CNPPopupController *)controller didDismissWithButtonTitle:(NSString *)title {
    RLOG(@"Dismissed with button title: %@", title);
}
- (void)popupControllerDidPresent:(CNPPopupController *)controller {
    RLOG(@"Popup controller presented.");
}

#pragma mark - Adjust Orientation
- (void)beforeRotation {
    UIView* lastView = [viewsAdded lastObject];
    for(UIView *view in viewsAdded)
    {
        [UIView animateWithDuration:0.1f animations:^{
            [view setAlpha:0.0f];
        }completion:^(BOOL finished){
            [view removeFromSuperview];
            if (view == lastView) {
                [_scrollView setAlpha:0.0f];
                [viewsAdded removeAllObjects];
                [self loadViewDA];
                for(UIView *vieww in viewsAdded)
                {
                    [vieww setAlpha:0.0f];
                }
                [_scrollView setAlpha:1.0f];
            }
        }];
    }
}
- (void)afterRotation {
    for(UIView *vieww in viewsAdded)
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
- (void)resetMainScrollView {
    float globalPosY = 0.0f;
    UIView* tempView = nil;
    int i = 0;
    for (tempView in viewsAdded) {
        CGRect rect = [tempView frame];
        if (i == 0) {
            globalPosY = 10;
        }
        rect.origin.y = globalPosY;
        
        [tempView setFrame:rect];
        globalPosY += rect.size.height;
        
        if ([tempView tag] == kTagForGlobalSpacing) {
            globalPosY += -2;// [LayoutProperties globalVerticalMargin];
        }
        i++;
    }
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, globalPosY)];
}
- (void)backgroundTouchEventRegistered:(CNPPopupController *)controller {
    RLOG(@"backgroundTouchEventRegistered:");
}

@end
