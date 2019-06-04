//
//  ViewControllerBottomBar.m
//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerBottomBar.h"
#import "Utility.h"
#import "Cart.h"
#import "Wishlist.h"
#import "UILabel+LocalizeConstrint.h"
#define VCName @"ViewControllerBottomBar"


//0:"home", 1:"wishlist", 2:"cart", 3:"search", 4:"opinion" 5:"my account"
//6:"hotline/livechat"
#define TEST_LIVE_CHAT_BUTTON 0
enum BOTTOM_BAR_ITEMS {
    BOTTOM_BAR_ITEM_HOME = 0,
    BOTTOM_BAR_ITEM_WISHLIST = 1,
    BOTTOM_BAR_ITEM_CART = 2,
    BOTTOM_BAR_ITEM_SEARCH = 3,
    BOTTOM_BAR_ITEM_OPINION = 4,
    BOTTOM_BAR_ITEM_MY_ACCOUNT = 5,
    BOTTOM_BAR_ITEM_LIVE_CHAT = 6,
    BOTTOM_BAR_ITEM_TOTAL
};
@interface ViewControllerBottomBar ()

@end

@implementation ViewControllerBottomBar

#pragma mark - View Life Cycle

- (void)initButtons {
    
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    Addons* addons = [Addons sharedManager];
    _homeMenuArray = [[NSMutableArray alloc] init];
    if ([[MyDevice sharedManager] isIpad]) {
        [_homeMenuArray addObject:[NSNumber numberWithInt:BOTTOM_BAR_ITEM_HOME]];
        [_homeMenuArray addObject:[NSNumber numberWithInt:BOTTOM_BAR_ITEM_SEARCH]];
        if (addons.enable_cart == true) {
            [_homeMenuArray addObject:[NSNumber numberWithInt:BOTTOM_BAR_ITEM_CART]];
        }
        [_homeMenuArray addObject:[NSNumber numberWithInt:BOTTOM_BAR_ITEM_WISHLIST]];
        if (addons.enable_cart == false) {
            [_homeMenuArray addObject:[NSNumber numberWithInt:BOTTOM_BAR_ITEM_MY_ACCOUNT]];
        }
    } else {
        [_homeMenuArray addObject:[NSNumber numberWithInt:BOTTOM_BAR_ITEM_HOME]];
        [_homeMenuArray addObject:[NSNumber numberWithInt:BOTTOM_BAR_ITEM_OPINION]];
        if (addons.enable_cart == true) {
            [_homeMenuArray addObject:[NSNumber numberWithInt:BOTTOM_BAR_ITEM_CART]];
        }
        [_homeMenuArray addObject:[NSNumber numberWithInt:BOTTOM_BAR_ITEM_WISHLIST]];
        if (addons.enable_cart == false) {
            [_homeMenuArray addObject:[NSNumber numberWithInt:BOTTOM_BAR_ITEM_MY_ACCOUNT]];
        }
    }
    
    if (addons.home_menu_items && (int)[addons.home_menu_items count] > 0) {
        _homeMenuArray = [[NSMutableArray alloc] initWithArray:addons.home_menu_items];
    }
#if TEST_LIVE_CHAT_BUTTON
    [_homeMenuArray addObject:[NSNumber numberWithInt:BOTTOM_BAR_ITEM_LIVE_CHAT]];
#endif
    
    if ([[MyDevice sharedManager] isIpad] || [[ProductDetailsConfig sharedInstance]show_opinion_section] == false) {
        NSNumber* objToRemove = nil;
        for (NSNumber* num in _homeMenuArray) {
            int caseNumber = [num intValue];
            if (caseNumber == BOTTOM_BAR_ITEM_OPINION) {
                objToRemove = num;
                break;
            }
        }
        [_homeMenuArray removeObject:objToRemove];
    }
    if (addons.enable_cart == false){
        NSNumber* objToRemove = nil;
        for (NSNumber* num in _homeMenuArray) {
            int caseNumber = [num intValue];
            if (caseNumber == BOTTOM_BAR_ITEM_CART) {
                objToRemove = num;
                break;
            }
        }
        [_homeMenuArray removeObject:objToRemove];
    }
    
    
    UIImage *normal, *selected, *highlighted, *focused;
    for (NSNumber* num in _homeMenuArray) {
        int caseNumber = [num intValue];
        NSString* imgIconNormal = @"";
        NSString* imgIconSelected = @"";
        NSString* text = @"";
        UIButton* button = nil;
        UILabel* label = nil;
        BOOL isEnabled = true;
        switch (caseNumber) {
            case BOTTOM_BAR_ITEM_HOME:
                imgIconNormal = @"btn_home_bottom";
                imgIconSelected = @"btn_home_bottom_on";
                text = Localize(@"title_shop");
                label = _labelHome;
                button = _buttonHome;
                [button addTarget:mainVC action:@selector(btnClickedHome:) forControlEvents:UIControlEventTouchUpInside];
                break;
            case BOTTOM_BAR_ITEM_LIVE_CHAT:
                imgIconNormal = @"btn_live_chat_bottom";
                imgIconSelected = @"btn_live_chat_bottom_on";
                text = Localize(@"live_chat");
                label = _labelLiveChat;
                button = _buttonLiveChat;
                [button addTarget:mainVC action:@selector(btnClickedLiveChat:) forControlEvents:UIControlEventTouchUpInside];
                break;
            case BOTTOM_BAR_ITEM_CART:
                imgIconNormal = @"btn_cart_bottom";
                imgIconSelected = @"btn_cart_bottom_on";
                text = Localize(@"title_mycart");
                label = _labelCart;
                button = _buttonCart;
                [button addTarget:mainVC action:@selector(btnClickedCart:) forControlEvents:UIControlEventTouchUpInside];
                break;
            case BOTTOM_BAR_ITEM_MY_ACCOUNT:
                imgIconNormal = @"btn_my_account_bottom";
                imgIconSelected = @"btn_my_account_bottom_on";
                text = Localize(@"title_profile");
                label = _labelMyAccount;
                button = _buttonMyAccount;
                [button addTarget:mainVC action:@selector(btnClickedMyAccount:) forControlEvents:UIControlEventTouchUpInside];
                break;
            case BOTTOM_BAR_ITEM_OPINION:
                imgIconNormal = @"btn_opinion_bottom";
                imgIconSelected = @"btn_opinion_bottom_on";
                text = Localize(@"title_poll");
                label = _labelOpinion;
                button = _buttonOpinion;
                [button addTarget:mainVC action:@selector(btnClickedOpinion:) forControlEvents:UIControlEventTouchUpInside];
                break;
            case BOTTOM_BAR_ITEM_SEARCH:
                imgIconNormal = @"btn_search_bottom";
                imgIconSelected = @"btn_search_bottom_on";
                text = Localize(@"title_search");
                label = _labelSearch;
                button = _buttonSearch;
                [button addTarget:mainVC action:@selector(btnClickedSearch:) forControlEvents:UIControlEventTouchUpInside];
                break;
            case BOTTOM_BAR_ITEM_WISHLIST:
                imgIconNormal = @"btn_wishlist_bottom";
                imgIconSelected = @"btn_wishlist_bottom_on";
                text = Localize(@"menu_title_wishlist");
                label = _labelWishlist;
                button = _buttonWishlist;
                [button addTarget:mainVC action:@selector(btnClickedWishlist:) forControlEvents:UIControlEventTouchUpInside];
                break;
            default:
                break;
        }
        
        if (isEnabled) {
            button.enabled = true;
            label.enabled = true;
            button.hidden = false;
            label.hidden = false;
            
            [self.view addSubview:button];
            button.tag = caseNumber;
            [_buttons addObject:button];
            
            [self.view addSubview:label];
            label.tag = caseNumber;
            [_labels addObject:label];
            
            normal = [[UIImage imageNamed:imgIconNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            selected = [[UIImage imageNamed:imgIconSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            highlighted = [[UIImage imageNamed:imgIconSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            focused = [[UIImage imageNamed:imgIconSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [button setUIImage:normal forState:UIControlStateNormal];
            [button setUIImage:selected forState:UIControlStateSelected];
            [button setUIImage:highlighted forState:UIControlStateHighlighted];
            [button setUIImage:focused forState:UIControlStateFocused];
            button.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [label setUIFont:kUIFontType16 isBold:false];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = text;
        }
    }
    
    for (UIButton* b in _buttons) {
        if (b.tag == BOTTOM_BAR_ITEM_HOME) {
            [b setSelected:true];
            [self buttonClicked:b];
        }
    }
}
- (void)arrangeUI {
    float viewH = self.view.frame.size.height;
    float viewW = self.view.frame.size.width;
    
    
    if (_homeMenuArray == nil) {
        [self initButtons];
    }
    int number_of_buttons = (int)[_homeMenuArray count];
    float buttonX, buttonY, buttonW, buttonH;
    float labelX, labelY, labelW, labelH;
    buttonH = viewH * 1.0f;
    if ([[MyDevice sharedManager] isIpad]) {
        buttonW = 100;
    } else {
        buttonW = (viewW * 0.96f) / number_of_buttons;
    }
    buttonX = (viewW - (number_of_buttons * buttonW)) / 2;
    buttonY = 0;
    labelH = viewH;// * .3f;
    labelW = buttonW;
    labelX = buttonX;
    if ([[MyDevice sharedManager] isIpad]) {
        labelY = viewH * .55f;
    } else {
        labelY = viewH * .6f;
    }
    
    
    
    for (UIButton* b in _buttons) {
        b.layer.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        buttonX += buttonW;
        b.enabled = true;
        float height = viewH * .15f;
        float heightB = self.view.frame.size.height * .5f;
        b.imageEdgeInsets = UIEdgeInsetsMake(height, 0, heightB, 0);
//        b.layer.borderWidth = 1;
    }
    for (UILabel* l in _labels) {
        [l sizeToFitUI];
        l.frame = CGRectMake(labelX, labelY, labelW, l.frame.size.height);
        labelX += buttonW;
        l.enabled = true;
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [self arrangeUI];
}
- (void)viewDidLoad {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    _homeMenuArray = nil;
    _buttons = [[NSMutableArray alloc] init];
    _labels = [[NSMutableArray alloc] init];
    
    _buttonCart = [[UIButton alloc] init];
    _buttonHome = [[UIButton alloc] init];
    _buttonLiveChat = [[UIButton alloc] init];
    _buttonMyAccount = [[UIButton alloc] init];
    _buttonOpinion = [[UIButton alloc] init];
    _buttonSearch = [[UIButton alloc] init];
    _buttonWishlist = [[UIButton alloc] init];
    
    _labelCart = [[UILabel alloc] init];
    _labelHome = [[UILabel alloc] init];
    _labelLiveChat = [[UILabel alloc] init];
    _labelMyAccount = [[UILabel alloc] init];
    _labelOpinion = [[UILabel alloc] init];
    _labelSearch = [[UILabel alloc] init];
    _labelWishlist = [[UILabel alloc] init];
    
    
    _buttonCart.enabled = false;
    _buttonHome.enabled = false;
    _buttonLiveChat.enabled = false;
    _buttonMyAccount.enabled = false;
    _buttonOpinion.enabled = false;
    _buttonSearch.enabled = false;
    _buttonWishlist.enabled = false;
    
    _buttonCart.hidden = true;
    _buttonHome.hidden = true;
    _buttonLiveChat.hidden = true;
    _buttonMyAccount.hidden = true;
    _buttonOpinion.hidden = true;
    _buttonSearch.hidden = true;
    _buttonWishlist.hidden = true;
    
    
    _labelCart.enabled = false;
    _labelHome.enabled = false;
    _labelLiveChat.enabled = false;
    _labelMyAccount.enabled = false;
    _labelOpinion.enabled = false;
    _labelSearch.enabled = false;
    _labelWishlist.enabled = false;
    
    _labelCart.hidden = true;
    _labelHome.hidden = true;
    _labelLiveChat.hidden = true;
    _labelMyAccount.hidden = true;
    _labelOpinion.hidden = true;
    _labelSearch.hidden = true;
    _labelWishlist.hidden = true;
    
    
    
    self.view.backgroundColor = [Utility getUIColor:kUIColorBgFooter];
    float lineHeight = 1.0f;
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, lineHeight)];
    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lineView.backgroundColor = [Utility getUIColor:kUIColorBorder];
    [self.view addSubview:lineView];
    
    
    UILabel* tempLabel = [[UILabel alloc] init];
    [tempLabel setUIFont:kUIFontType10 isBold:true];
    float fontHeight = [tempLabel.font lineHeight];
    fontHeight *= 1.25f;
    
    [self arrangeUI];
    
    float cartPosX = _buttonCart.imageView.center.x + fontHeight * 0.45f;
    float WishlistPosX = _buttonWishlist.imageView.center.x + fontHeight * 0.45f;
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        cartPosX = _buttonCart.imageView.center.x - fontHeight * 1.45f;
        WishlistPosX = _buttonWishlist.imageView.center.x- fontHeight * 1.45f;
    }
    
    float posY = _buttonCart.frame.origin.y + 2;
    float bgdiff = 1;
    
    _nnBgCart = [[UIImageView alloc] init];
    [_nnBgCart setUIImage:[[UIImage imageNamed:@"notification_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    _nnBgCart.tintColor = [Utility getUIColor:kUIColorBgFooter];
    [_buttonCart addSubview:_nnBgCart];
    _nnBgCart.frame = CGRectMake(cartPosX - bgdiff, posY - bgdiff, fontHeight + bgdiff*2, fontHeight + bgdiff*2);

    
    
    _nBgCart = [[UIImageView alloc] init];
    [_nBgCart setUIImage:[[UIImage imageNamed:@"notification_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    _nBgCart.tintColor = [Utility getUIColor:kUIColorThemeButtonSelected];
    [_buttonCart addSubview:_nBgCart];
    _nBgCart.frame = CGRectMake(cartPosX, posY, fontHeight, fontHeight);
    
    _nnBgWishlist = [[UIImageView alloc] init];
    [_nnBgWishlist setUIImage:[[UIImage imageNamed:@"notification_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    _nnBgWishlist.tintColor = [Utility getUIColor:kUIColorBgFooter];
    [_buttonWishlist addSubview:_nnBgWishlist];
    _nnBgWishlist.frame = CGRectMake(WishlistPosX - bgdiff, posY - bgdiff, fontHeight + bgdiff * 2, fontHeight + bgdiff * 2);
    
    _nBgWishlist = [[UIImageView alloc] init];
    [_nBgWishlist setUIImage:[[UIImage imageNamed:@"notification_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    _nBgWishlist.tintColor = [Utility getUIColor:kUIColorThemeButtonSelected];
    [_buttonWishlist addSubview:_nBgWishlist];
    _nBgWishlist.frame = CGRectMake(WishlistPosX, posY, fontHeight, fontHeight);
    
    _nLabelCart = [[UILabel alloc] init];
    [_nLabelCart setUIFont:kUIFontType10 isBold:true];
    _nLabelCart.textColor = [Utility getUIColor:kUIColorBgFooter];
    [_buttonCart addSubview:_nLabelCart];
    [_nLabelCart sizeToFitUI];
    _nLabelCart.center = _nBgCart.center;
    
    _nLabelWishlist = [[UILabel alloc] init];
    [_nLabelWishlist setUIFont:kUIFontType10 isBold:true];
    _nLabelWishlist.textColor = [Utility getUIColor:kUIColorBgFooter];
    [_buttonWishlist addSubview:_nLabelWishlist];
    [_nLabelWishlist sizeToFitUI];
    _nLabelWishlist.center = _nBgWishlist.center;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotificationCount:) name:@"UPDATE_NOTIFICATION_COUNT" object:nil];
    [self updateNotificationCount:nil];
}

- (void)updateNotificationCount:(NSNotification*)notification {
    int cartItemCount = [Cart getNotificationItemCount];
    int wishlistItemCount = [Wishlist getNotificationItemCount];
    
    [_nLabelCart setText:[NSString stringWithFormat:@"%d", cartItemCount]];
    [_nLabelCart sizeToFitUI];
    _nLabelCart.center = _nBgCart.center;
    
    [_nLabelWishlist setText:[NSString stringWithFormat:@"%d", wishlistItemCount]];
    [_nLabelWishlist sizeToFitUI];
    _nLabelWishlist.center = _nBgWishlist.center;

    
    if (cartItemCount == 0) {
        [_nBgCart setHidden:true];
        [_nnBgCart setHidden:true];
        [_nLabelCart setHidden:true];
    }else{
        [_nBgCart setHidden:false];
        [_nnBgCart setHidden:false];
        [_nLabelCart setHidden:false];
    }
    
    if (wishlistItemCount == 0) {
        [_nBgWishlist setHidden:true];
        [_nnBgWishlist setHidden:true];
        [_nLabelWishlist setHidden:true];
    }else{
        [_nBgWishlist setHidden:false];
        [_nnBgWishlist setHidden:false];
        [_nLabelWishlist setHidden:false];
    }
}
- (void)buttonClicked:(UIButton*)button{
    for (UIButton* b in _buttons) {
        if (b.isEnabled) {
            if(b.isSelected) {
                b.tintColor = [Utility getUIColor:kUIColorThemeButtonSelected];
            }else{
                b.tintColor = [Utility getUIColor:kUIColorThemeButtonNormal];
            }
        } else {
            b.tintColor = [Utility getUIColor:kUIColorThemeButtonDisable];
        }
    }
    
    [self arrangeUI];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    [self arrangeUI];
}
- (void)didReceiveMemoryWarning {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
}
 #pragma mark - Rotation
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self arrangeUI];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self arrangeUI];
}
@end
