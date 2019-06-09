//
//  Utility.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 06/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "Utility.h"
#import "CommonInfo.h"
#import "LayoutManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DataManager.h"
#import "ProductImage.h"
#import "ProductInfo.h"
#import "Opinion.h"
#import <sys/sysctl.h>
#import "Addons.h"
#import "UIAlertView+NSCookbook.h"
#import <STHTTPRequest/STHTTPRequest.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "Constants.h"
#import "ViewControllerLeft.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

#define ENABLE_NEW_TRANSITION 0

#if (ENABLE_BRANCH)
#if (WORKING_BRANCH_VERSION_0_11_6)
#import "Branch.h"
#endif
#if (WORKING_BRANCH_VERSION_0_11_11)
#import <Branch/Branch.h>
#import <Branch/BranchUniversalObject.h>
#import <Branch/BranchLinkProperties.h>
//#import "BranchUniversalObject.h"
//#import "BranchLinkProperties.h"
#endif
#endif

@implementation Utility

#if ENABLE_NTP
@synthesize netAssociation = _netAssociation;
@synthesize netClock =_netClock;
#endif
static BOOL CURRENCY_POSITION_AT_LAST = false;
static NSString* CURRENCY_POSITION_WITH_SPACE = @" ";
static NSString* CURRENCY_SYMBOL = @"";
static BOOL multiStoreAppEnable = false;
static BOOL multiStoreAppEnableTMStore = false;
static BOOL sellerOnlyAppEnable = false;
static BOOL nearBySearchEnable = false;
+ (id)sharedManager {
    static Utility *shareUtilitydManager = nil;
    @synchronized(self) {
        if (shareUtilitydManager == nil)
            shareUtilitydManager = [[self alloc] init];
    }
    return shareUtilitydManager;
}
- (id)init {
    if (self = [super init]) {
        _deviceModel = @"";
        self.pushedViewControllers = [[NSMutableArray alloc] init];
        SDWebImageManager *manager  = [SDWebImageManager sharedManager];
        manager.imageDownloader.downloadTimeout = 180.0;
        
//        UITabBarController *tabBar = [[UITabBarController alloc] init];
//        CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
//        _bottomBarHeight = tabBar.tabBar.frame.size.height;
//        _statusBarHeight = MIN(statusBarSize.width, statusBarSize.height);
//        _topBarHeight = _bottomBarHeight + _statusBarHeight;
        
        
        _bottomBarHeight = 50;
        _statusBarHeight = 20;
        _topBarHeight = 70;
        
        
        
        _alertForDemoApp = [[UIAlertView alloc] initWithTitle:Localize(@"demo_version")
                                                      message:@""
                                                     delegate:nil
                                            cancelButtonTitle:Localize(@"i_cok")
                                            otherButtonTitles:nil];
        _userAgentForPostMethod = @"";
        _spinnerView = nil;
        
        
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"slugifyProperties" ofType:@"strings"];
        NSData *plistData = [NSData dataWithContentsOfFile:path];
        NSString *error; NSPropertyListFormat format;
        NSDictionary *dictionary = [NSPropertyListSerialization propertyListFromData:plistData
                                                                    mutabilityOption:NSPropertyListImmutable
                                                                              format:&format
                                                                    errorDescription:&error];
        _slugify_keys = nil;
        _slugify_values = nil;
        if (dictionary) {
            _slugify_keys = [[NSMutableArray alloc] initWithArray:[dictionary allKeys]];
            _slugify_values = [[NSMutableArray alloc] init];
            for (NSString* key in _slugify_keys) {
                [_slugify_values addObject:[dictionary objectForKey:key]];
            }
        }
        
    }
    return self;
}


- (long long)getUnixTimeInMS{
#if ENABLE_NTP
    self->_netClock = [NetworkClock sharedNetworkClock];
    NSTimeInterval sec = [self->_netClock.networkTime timeIntervalSince1970];
    long long millis = sec * 1000;
#else
    long long millis = 0;
#endif
    return (millis);
}
- (NSString *)getUnixTimeString{
    NSString* nsstr = [NSString stringWithFormat:@"%lld", [self getUnixTimeInMS]];
    return (nsstr);
}
- (NSMutableAttributedString *)getStrikethroughString:(NSString *)str {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:str];
    [attributeString addAttribute:NSStrikethroughStyleAttributeName value:@1 range:NSMakeRange(0, [attributeString length])];
    return attributeString;
}
- (NSString *)getCurrencyWithSign:(float)value currencyCode:(NSString*)currencyCode{
    BOOL isCurrency = true;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    if (isCurrency) {
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setCurrencyCode:currencyCode];
    } else {
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    }
    //    if ([[Addons sharedManager] language] && [[[Addons sharedManager] language] isLocalizationEnabled]) {
    //        NSString* userLocale = [[NSUserDefaults standardUserDefaults] valueForKey:USER_LOCALE];
    //        NSString* defaultLocale = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULT_LOCALE];
    //        NSString* selectedLocale = @"";
    //        if (userLocale && ![userLocale isEqualToString:@""]) {
    //            selectedLocale = userLocale;
    //        } else if (defaultLocale && ![defaultLocale isEqualToString:@""]) {
    //            selectedLocale = defaultLocale;
    //        } else {
    //            selectedLocale = @"en_US";
    //        }
    //        [numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:selectedLocale]];
    //    } else {
    NSString* selectedLocale = @"en_US";
    [numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:selectedLocale]];
    
    if ([[CommonInfo sharedManager]->_thousand_separator isEqualToString:@""]) {
        [CommonInfo sharedManager]->_thousand_separator = @",";
    }
    [numberFormatter setCurrencyGroupingSeparator:[CommonInfo sharedManager]->_thousand_separator];
    if ([[CommonInfo sharedManager]->_decimal_separator isEqualToString:@""]) {
        [CommonInfo sharedManager]->_decimal_separator = @".";
    }
    [numberFormatter setCurrencyDecimalSeparator:[CommonInfo sharedManager]->_decimal_separator];
    [numberFormatter setDecimalSeparator:[CommonInfo sharedManager]->_decimal_separator];
    [numberFormatter setGroupingSeparator:[CommonInfo sharedManager]->_thousand_separator];
    //    }
    [numberFormatter setGroupingSize:3];
    [numberFormatter setUsesGroupingSeparator:YES];
    [numberFormatter setMinimumFractionDigits:[CommonInfo sharedManager]->_price_num_decimals];
    [numberFormatter setMaximumFractionDigits:[CommonInfo sharedManager]->_price_num_decimals];
    NSString *theString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:value]];
    return theString;
}
- (NSString *)useNumberFormatter:(float)value isCurrency:(BOOL)isCurrency {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    if (isCurrency) {
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setCurrencyCode:[CommonInfo sharedManager]->_currency];
    } else {
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    }
    //    if ([[Addons sharedManager] language] && [[[Addons sharedManager] language] isLocalizationEnabled]) {
    //        NSString* userLocale = [[NSUserDefaults standardUserDefaults] valueForKey:USER_LOCALE];
    //        NSString* defaultLocale = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULT_LOCALE];
    //        NSString* selectedLocale = @"";
    //        if (userLocale && ![userLocale isEqualToString:@""]) {
    //            selectedLocale = userLocale;
    //        } else if (defaultLocale && ![defaultLocale isEqualToString:@""]) {
    //            selectedLocale = defaultLocale;
    //        } else {
    //            selectedLocale = @"en_US";
    //        }
    //        [numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:selectedLocale]];
    //    } else {
    NSString* selectedLocale = @"en_US";
    [numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:selectedLocale]];
    if ([[CommonInfo sharedManager]->_thousand_separator isEqualToString:@""]) {
        [CommonInfo sharedManager]->_thousand_separator = @",";
    }
    [numberFormatter setCurrencyGroupingSeparator:[CommonInfo sharedManager]->_thousand_separator];
    if ([[CommonInfo sharedManager]->_decimal_separator isEqualToString:@""]) {
        [CommonInfo sharedManager]->_decimal_separator = @".";
    }
    [numberFormatter setCurrencyDecimalSeparator:[CommonInfo sharedManager]->_decimal_separator];
    [numberFormatter setDecimalSeparator:[CommonInfo sharedManager]->_decimal_separator];
    [numberFormatter setGroupingSeparator:[CommonInfo sharedManager]->_thousand_separator];
    //    }
    [numberFormatter setGroupingSize:3];
    [numberFormatter setUsesGroupingSeparator:YES];
    [numberFormatter setMinimumFractionDigits:[CommonInfo sharedManager]->_price_num_decimals];
    [numberFormatter setMaximumFractionDigits:[CommonInfo sharedManager]->_price_num_decimals];
    NSString *theString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:value]];
    return theString;
}
- (NSString *)convertToString:(float)value isCurrency:(BOOL)isCurrency symbolAtLast:(BOOL)symbolAtLast {
    NSString *str = [self useNumberFormatter:value isCurrency:isCurrency];
    if (isCurrency) {
        str = [self changeSymbolPosition:str];
    }
    return str;
}
- (NSString *)convertToString:(float)value isCurrency:(BOOL)isCurrency {
    NSString *str = [self useNumberFormatter:value isCurrency:isCurrency];
    if (isCurrency) {
        str = [self changeSymbolPosition:str];
    }
    return str;
}
- (NSString *)getCurrencyWithSign:(float)value currencyCode:(NSString*)currencyCode symbolAtLast:(BOOL)symbolAtLast {
    NSString* str = [self getCurrencyWithSign:value currencyCode:currencyCode];
    if (true) {
        str = [self changeSymbolPosition:str];
    }
    return str;
}
- (NSMutableAttributedString *)convertToStringStrikethrough:(float)value isCurrency:(BOOL)isCurrency {
    NSString *str = [self useNumberFormatter:value isCurrency:isCurrency];
    if (isCurrency) {
        str = [self changeSymbolPosition:str];
    }
    return [self getStrikethroughString:str];
}
- (NSString*)getCurrencySymbol {
    return CURRENCY_SYMBOL;
}
- (void)initCurrencySymbol {
    NSString* tempStr = [self useNumberFormatter:0.0f isCurrency:true];
    if ([[CommonInfo sharedManager]->_decimal_separator isEqualToString:@""]) {
        [CommonInfo sharedManager]->_decimal_separator = @".";
    }
    NSString* decimalsString = @"";
    for (int i = 0; i < [CommonInfo sharedManager]->_price_num_decimals; i++) {
        decimalsString = [decimalsString stringByAppendingString:@"0"];
    }
    
    if ([CommonInfo sharedManager]->_price_num_decimals == 0) {
        tempStr = [tempStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"0"] withString:@""];
    } else {
        tempStr = [tempStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"0%@%@", [CommonInfo sharedManager]->_decimal_separator, decimalsString] withString:@""];
    }
    CURRENCY_SYMBOL = tempStr;
    
    NSString* stringCurrencySymbol = [CommonInfo sharedManager]->_currency_format;
    [CommonInfo sharedManager]->_currency_format = [Utility getNormalStringFromAttributed:stringCurrencySymbol];
    
    NSString * htmlString = [NSString stringWithFormat:@"%@", [CommonInfo sharedManager]->_currency_format];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    [CommonInfo sharedManager]->_currency_format = [NSString stringWithFormat:@"%@", [attrStr string]];
    
}
- (void)initCurrencyPosition {
    CommonInfo* commonInfo = [CommonInfo sharedManager];
    CURRENCY_POSITION_WITH_SPACE = @" ";
    CURRENCY_POSITION_AT_LAST = false;
    
    if (![commonInfo->_currency_position isEqualToString:@""]) {
        if (![Utility containsString:commonInfo->_currency_position substring:@"space"]) {
            CURRENCY_POSITION_WITH_SPACE = @"";
        }
        if ([Utility containsString:commonInfo->_currency_position substring:@"right"]) {
            CURRENCY_POSITION_AT_LAST = true;
        }
    }
}
- (NSString*)changeSymbolPosition:(NSString*)str {
    //    if ([[Addons sharedManager] language] && [[[Addons sharedManager] language] isLocalizationEnabled]) {
    //        return str;
    //    }
    
    
    CommonInfo* commonInfo = [CommonInfo sharedManager];
    if (CURRENCY_POSITION_AT_LAST) {
        str = [str stringByReplacingOccurrencesOfString:CURRENCY_SYMBOL withString:@""];
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%@%@",CURRENCY_POSITION_WITH_SPACE, commonInfo->_currency_format]];
    } else {
        str = [str stringByReplacingOccurrencesOfString:CURRENCY_SYMBOL withString:[NSString stringWithFormat:@"%@%@", commonInfo->_currency_format, CURRENCY_POSITION_WITH_SPACE]];
    }
    return str;
}
+ (UIColor *)colorWithHex:(int)color {
    float red = (color & 0xff000000) >> 24;
    float green = (color & 0x00ff0000) >> 16;
    float blue = (color & 0x0000ff00) >> 8;
    float alpha = (color & 0x000000ff);
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}


+ (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}
+ (UIColor *)colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha
{
    // Convert hex string to an integer
    unsigned int hexint = [self intFromHexString:hexStr];
    
    // Create color object, specifying alpha as well
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    
    return color;
}




+ (CGSize)makeSize:(CGSize)originalSize fitInSize:(CGSize)boxSize
{
    CGSize newSize = CGSizeMake(boxSize.width, originalSize.height / originalSize.width * boxSize.width);
    return newSize;
}

+ (SDWebImageOptions)getImageDownloadOption {
   return
//    SDWebImageScaleDownLargeImages |
    SDWebImageAllowInvalidSSLCertificates |
//    SDWebImageHighPriority |
    SDWebImageRetryFailed;
}
+ (void)setImageNew:(UIImageView*)uiImageView url:(NSString *)url resizeType:(int)resizeType highPriority:(BOOL)highPriority parentCell:(CCollectionViewCell *)parentCell collectionViewLayout:(id)collectionViewLayout collectionView:(UICollectionView*)collectionView component:(NSInteger)component indexpath:(NSIndexPath*)indexpath vc:(ViewControllerCategories*)vc {
#if ENABLE_SHOW_ALL_IMAGES
    if([[Addons sharedManager] show_all_images] == false){
        return;
    }
#endif
    RLOG_DESC(@"====setImage1====url=====%@", url);
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        uiImageView.transform = CGAffineTransformMakeScale(-1, 1);
    }
    UIImageView *placeholderImage1 = (UIImageView *)[uiImageView.superview viewWithTag:10000];
    UIImageView *placeholderImage2 = (UIImageView *)[uiImageView viewWithTag:10000];
    if (placeholderImage1) {
        [placeholderImage1 setUIImage:[Utility getPlaceholderImage:0]];
        [placeholderImage1 setHidden:false];
    }else if (placeholderImage2){
        [placeholderImage2 setUIImage:[Utility getPlaceholderImage:0]];
        [placeholderImage2 setHidden:false];
    }else{
        placeholderImage2 = [[UIImageView alloc] initWithImage:[Utility getPlaceholderImage:0]];
        [placeholderImage2 setTag:10000];
        [placeholderImage2 setFrame:CGRectMake(0, 0, uiImageView.frame.size.width, uiImageView.frame.size.height)];
        [placeholderImage2 setContentMode:UIViewContentModeCenter];
        [uiImageView addSubview:placeholderImage2];
    }
    
//    RLOG(@"ResizedImage1 => %@", url);
//    url = [[Utility sharedManager] resizeImageInPath:url resizeType:resizeType];
//    RLOG(@"ResizedImage2 => %@", url);

//TODO IMAGE_RESIZE
    
    RLOG(@"ResizedImage1 => %@", url);
    url = [[Utility sharedManager] getResizedImageUrl:url];
    RLOG(@"ResizedImage2 => %@", url);
    
    
    if ([url isEqualToString:@""]) {
        [uiImageView setUIImage:[Utility getPlaceholderImage:1]];
        [uiImageView setContentMode:UIViewContentModeCenter];
        UIImageView *placeholderImage1 = (UIImageView *)[uiImageView.superview viewWithTag:10000];
        UIImageView *placeholderImage2 = (UIImageView *)[uiImageView viewWithTag:10000];
        if (placeholderImage1) {
            [placeholderImage1 setHidden:true];
        }
        if (placeholderImage2) {
            [placeholderImage2 setHidden:true];
        }
        return;
    }
    
    SDWebImageOptions dwldOption = [Utility getImageDownloadOption];
    if (highPriority) {
        dwldOption = [Utility getImageDownloadOption] | SDWebImageHighPriority;
    }
    NSURL* nsurl = [Utility getNSUrlForImagePath:url];
    
    [uiImageView sd_setImageWithURL:nsurl placeholderImage:nil options:dwldOption progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        UIImageView *placeholderImage = (UIImageView *)[uiImageView viewWithTag:10000];
        if (placeholderImage){
            [placeholderImage setFrame:CGRectMake(0, 0, uiImageView.frame.size.width, uiImageView.frame.size.height)];
        }
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            NSLog(@"error=%@", error);
        } else {
            UIImageView *placeholderImage1 = (UIImageView *)[uiImageView.superview viewWithTag:10000];
            UIImageView *placeholderImage2 = (UIImageView *)[uiImageView viewWithTag:10000];
            if (placeholderImage1) {
                [placeholderImage1 setHidden:true];
            }
            if (placeholderImage2) {
                [placeholderImage2 setHidden:true];
            }
            ProductInfo* pInfo = [parentCell.layer valueForKey:@"PRODUCT_INFO"];
            if(pInfo){
                if ([[MyDevice sharedManager] isLandscape]) {
                    if (pInfo.updatedCardSizeL.width == 0) {
                        if(pInfo.originalCardSizeL.width == 0) {
                            pInfo.originalCardSizeL = parentCell.frame.size;
                        }
                        float imgViewHeight = uiImageView.frame.size.height / uiImageView.frame.size.width * pInfo.originalCardSizeL.width;
                        float cellViewHeight = pInfo.originalCardSizeL.height;
                        float cellViewWidth = pInfo.originalCardSizeL.width;
                        CGSize newSize = [Utility makeSize:image.size fitInSize:CGSizeMake(cellViewWidth, imgViewHeight)];
                        float diffH = newSize.height - imgViewHeight;
                        cellViewHeight += (int)diffH;
                        
                        pInfo.updatedCardSizeL = CGSizeMake(cellViewWidth, cellViewHeight);
                        [uiImageView setContentMode:UIViewContentModeScaleAspectFit];
                        //                    [collectionView reloadItemsAtIndexPaths:@[indexpath]];
                        
                    }
                    else {
                        [uiImageView setContentMode:UIViewContentModeScaleAspectFit];
                        [collectionView setAlwaysBounceVertical:true];
                        [collectionView setAlwaysBounceHorizontal:false];
                        [collectionView setDirectionalLockEnabled:true];
                        collectionView.showsHorizontalScrollIndicator = false;
                    }
                } else {
                    if (pInfo.updatedCardSizeP.width == 0) {
                        if(pInfo.originalCardSizeP.width == 0) {
                            pInfo.originalCardSizeP = parentCell.frame.size;
                        }
                        float imgViewHeight = uiImageView.frame.size.height / uiImageView.frame.size.width * pInfo.originalCardSizeP.width;
                        float cellViewHeight = pInfo.originalCardSizeP.height;
                        float cellViewWidth = pInfo.originalCardSizeP.width;
                        CGSize newSize = [Utility makeSize:image.size fitInSize:CGSizeMake(cellViewWidth, imgViewHeight)];
                        float diffH = newSize.height - imgViewHeight;
                        cellViewHeight += (int)diffH;
                        pInfo.updatedCardSizeP = CGSizeMake(cellViewWidth, cellViewHeight);
                        [uiImageView setContentMode:UIViewContentModeScaleAspectFit];
                        //                    [collectionView reloadItemsAtIndexPaths:@[indexpath]];
                    }
                    else {
                        [uiImageView setContentMode:UIViewContentModeScaleAspectFit];
                        [collectionView setAlwaysBounceVertical:true];
                        [collectionView setAlwaysBounceHorizontal:false];
                        [collectionView setDirectionalLockEnabled:true];
                        collectionView.showsHorizontalScrollIndicator = false;
                    }
                }
            }
        }
    }];
}
+ (void)setImage:(UIImageView*)uiImageView url:(NSString *)url resizeType:(int)resizeType isLocal:(BOOL)isLocal highPriority:(BOOL)highPriority {
#if ENABLE_SHOW_ALL_IMAGES
    if([[Addons sharedManager] show_all_images] == false){
        return;
    }
#endif
    
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        uiImageView.transform = CGAffineTransformMakeScale(-1, 1);
    }
    BOOL isAnimated = false;
    if (isAnimated) {
        //TODO IMAGE_RESIZE
        NSURL* nsurl = [Utility getNSUrlForImagePath:[[Utility sharedManager]resizeProductImage:url]];
        [uiImageView sd_setImageWithURL:nsurl placeholderImage:nil options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            UIActivityIndicatorView *activity = nil;
            activity = (UIActivityIndicatorView *)[uiImageView viewWithTag:100000];
            if (!activity) {
                activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [activity setTag:100000];
                [activity setHidesWhenStopped:YES];
                [activity setCenter:CGPointMake(uiImageView.frame.size.width/2.0f,uiImageView.frame.size.height/2.0f)];
                [uiImageView addSubview:activity];
            }
            else {
                [activity setCenter:CGPointMake(uiImageView.frame.size.width/2.0f,uiImageView.frame.size.height/2.0f)];
            }
            [activity startAnimating];
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[uiImageView viewWithTag:100000];
            if ([activity isKindOfClass:[UIActivityIndicatorView class]]) {
                [activity stopAnimating];
            }
        }];
    }
    else {
        UIImageView *placeholderImage1 = (UIImageView *)[uiImageView.superview viewWithTag:10000];
        UIImageView *placeholderImage2 = (UIImageView *)[uiImageView viewWithTag:10000];
        if (placeholderImage1) {
            [placeholderImage1 setUIImage:[Utility getPlaceholderImage:0]];
            [placeholderImage1 setHidden:false];
        }else if (placeholderImage2){
            [placeholderImage2 setUIImage:[Utility getPlaceholderImage:0]];
            [placeholderImage2 setHidden:false];
        }else{
            placeholderImage2 = [[UIImageView alloc] initWithImage:[Utility getPlaceholderImage:0]];
            [placeholderImage2 setTag:10000];
            [placeholderImage2 setFrame:CGRectMake(0, 0, uiImageView.frame.size.width, uiImageView.frame.size.height)];
            [placeholderImage2 setContentMode:UIViewContentModeCenter];
            [uiImageView addSubview:placeholderImage2];
        }
        if (isLocal) {
            [uiImageView setUIImage:[UIImage imageNamed:url]];
            UIImageView *placeholderImage1 = (UIImageView *)[uiImageView.superview viewWithTag:10000];
            UIImageView *placeholderImage2 = (UIImageView *)[uiImageView viewWithTag:10000];
            if (placeholderImage1) {
                [placeholderImage1 setHidden:true];
            }
            if (placeholderImage2) {
                [placeholderImage2 setHidden:true];
            }
        }
        else{
            //            [uiImageView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:url] andPlaceholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            //                UIImageView *placeholderImage = (UIImageView *)[uiImageView viewWithTag:10000];
            //                if (placeholderImage){
            //                    [placeholderImage setFrame:CGRectMake(0, 0, uiImageView.frame.size.width, uiImageView.frame.size.height)];
            //                }
            //            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //                UIImageView *placeholderImage1 = (UIImageView *)[uiImageView.superview viewWithTag:10000];
            //                UIImageView *placeholderImage2 = (UIImageView *)[uiImageView viewWithTag:10000];
            //                if (placeholderImage1) {
            //                    [placeholderImage1 setHidden:true];
            //                }
            //                if (placeholderImage2) {
            //                    [placeholderImage2 setHidden:true];
            //                }
            //            }];
            
            
//            url = [[Utility sharedManager] resizeImageInPath:url resizeType:resizeType];
            
            //TODO IMAGE_RESIZE
            RLOG(@"====TODO RESIZE_IMAGE 1 ====url=====%@", url);
            url = [[Utility sharedManager] resizeProductImage:url];
            RLOG(@"====TODO RESIZE_IMAGE 2 ====url=====%@", url);

            if ([url isEqualToString:@""]) {
                [uiImageView setUIImage:[Utility getPlaceholderImage:1]];
                [uiImageView setContentMode:UIViewContentModeCenter];
                UIImageView *placeholderImage1 = (UIImageView *)[uiImageView.superview viewWithTag:10000];
                UIImageView *placeholderImage2 = (UIImageView *)[uiImageView viewWithTag:10000];
                if (placeholderImage1) {
                    [placeholderImage1 setHidden:true];
                }
                if (placeholderImage2) {
                    [placeholderImage2 setHidden:true];
                }
                return;
            }
            SDWebImageOptions dwldOption = [Utility getImageDownloadOption];
            if (highPriority) {
                dwldOption = [Utility getImageDownloadOption] | SDWebImageHighPriority;
            }
            NSURL* nsurl = [Utility getNSUrlForImagePath:url];
            [uiImageView sd_setImageWithURL:nsurl placeholderImage:nil options:dwldOption progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                UIImageView *placeholderImage = (UIImageView *)[uiImageView viewWithTag:10000];
                if (placeholderImage){
                    [placeholderImage setFrame:CGRectMake(0, 0, uiImageView.frame.size.width, uiImageView.frame.size.height)];
                }
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (error) {
                    NSLog(@"error=%@", error);
                } else {
                    UIImageView *placeholderImage1 = (UIImageView *)[uiImageView.superview viewWithTag:10000];
                    UIImageView *placeholderImage2 = (UIImageView *)[uiImageView viewWithTag:10000];
                    if (placeholderImage1) {
                        [placeholderImage1 setHidden:true];
                    }
                    if (placeholderImage2) {
                        [placeholderImage2 setHidden:true];
                    }
                }
            }];
        }
    }
}
+ (NSURL*)getNSUrlForImagePath:(NSString*)imgUrl {
    NSURL* nsurl = [NSURL URLWithString:[imgUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
//    NSCharacterSet *set = [NSCharacterSet URLFragmentAllowedCharacterSet];
//    NSURL* nsurl = [NSURL URLWithString:[imgUrl stringByAddingPercentEncodingWithAllowedCharacters:set]];
    return nsurl;
}
+ (void)setImage:(UIImageView*)uiImageView url:(NSString *)url placeholderImage:(UIImage*)placeholderImage {
#if ENABLE_SHOW_ALL_IMAGES
    if([[Addons sharedManager] show_all_images] == false){
        return;
    }
#endif
    RLOG_DESC(@"====setImage3====url=====%@", url);
    SDWebImageOptions dwldOption = [Utility getImageDownloadOption];
    NSURL* nsurl = [Utility getNSUrlForImagePath:url];
    [uiImageView sd_setImageWithURL:nsurl placeholderImage:placeholderImage options:dwldOption progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
}
+ (void)setImage:(UIImageView*)uiImageView url:(NSString *)url resizeType:(int)resizeType isLocal:(BOOL)isLocal {
    [Utility setImage:uiImageView url:url resizeType:resizeType isLocal:isLocal highPriority:false];
}
+ (UIImage *)getSplashBgImage{
    return [UIImage imageNamed:[[LayoutManager sharedManager] imagePath_SplashBg]];
}
+ (UIImage *)getSplashFgImage{
    return [UIImage imageNamed:[[LayoutManager sharedManager] imagePath_SplashFg]];
}
+ (UIImage *)getAppIconImage{
    return [UIImage imageNamed:[[LayoutManager sharedManager] imagePath_AppIcon]];
}

+ (UIImage *)getPlaceholderImage:(int)type{
    UIImage *image = nil;
    
    if ([[LayoutManager sharedManager] usePlaceHolderImage]) {
        if (type == 1) {
            image = [UIImage imageNamed:@"placeholder"];
        }else{
            image = [UIImage imageNamed:[[LayoutManager sharedManager] imagePath_PlaceHolder]];
        }
        
        //        image = [UIImage animatedImageNamed:@"Spinner/s-" duration:1.0f];
    }else{
        float maxColor = 255.0f;
        srandomdev();
        PlaceHolderColor* phColor = [[LayoutManager sharedManager] placeHolderColorRange];
        int minRange_r = phColor->red_min;  int maxRange_r = phColor->red_max;
        int minRange_g = phColor->green_min;  int maxRange_g = phColor->green_max;
        int minRange_b = phColor->blue_min;  int maxRange_b = phColor->blue_max;
        
        float r = ((float)(random()%maxRange_r + minRange_r))/maxColor;
        float g = ((float)(random()%maxRange_g + minRange_g))/maxColor;
        float b = ((float)(random()%maxRange_b + minRange_b))/maxColor;
        UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0f];
        CGRect rect = CGRectMake(0, 0, 1, 1);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return image;
}

+ (CATransition*)pushAnimation {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.37f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    return transition;
}
+ (CATransition*)popAnimation {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.37f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromLeft;
    return transition;
}

- (RPPreviewViewController *)pushRecordingScreen:(UIViewController*)parentViewController recordVC:(RPPreviewViewController *)recordVC {
    RPPreviewViewController *newViewController = recordVC;
    newViewController.view.frame = parentViewController.view.frame;
    //animation for push screen
#if (ENABLE_NEW_TRANSITION)
    [newViewController.view.layer addAnimation:[Utility pushAnimation] forKey:nil];
#else
    UIView *containerView = parentViewController.view.window;
    [containerView.layer addAnimation:[Utility pushAnimation] forKey:nil];
#endif
    
    
    //add as child
    [parentViewController addChildViewController:newViewController];
    [parentViewController.view addSubview:newViewController.view];
    [newViewController didMoveToParentViewController:parentViewController];
    RLOG(@"pushedViewControllers count= %d", (int)[self.pushedViewControllers count]);
    return newViewController;
}
- (ViewControllerProduct *)pushProductScreen:(UIViewController*)parentViewController{
    UIStoryboard* sb = [Utility getStoryBoardObject];
    //create new viewcontroller
    ViewControllerProduct *newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_PRODUCT];
    newViewController.view.frame = parentViewController.view.frame;
    //animation for push screen
#if (ENABLE_NEW_TRANSITION)
    [newViewController.view.layer addAnimation:[Utility pushAnimation] forKey:nil];
#else
    UIView *containerView = parentViewController.view.window;
    [containerView.layer addAnimation:[Utility pushAnimation] forKey:nil];
#endif
    //add as child
    NSMutableArray* vcObjToRemove = [[NSMutableArray alloc] init];
    for (UIViewController* vcObj in parentViewController.childViewControllers) {
        if ([vcObj isKindOfClass:[ViewControllerProduct class]]) {
            [vcObj viewWillDisappear:true];
            [vcObjToRemove addObject:vcObj];
        }
    }
    for (UIViewController* vcObj in vcObjToRemove) {
        [vcObj removeFromParentViewController];
    }
    
    [parentViewController addChildViewController:newViewController];
    [parentViewController.view addSubview:newViewController.view];
    [newViewController didMoveToParentViewController:parentViewController];
    RLOG(@"pushedViewControllers count= %d", (int)[self.pushedViewControllers count]);
    return newViewController;
}
- (UIViewController *)pushScreenWithNewAnimation:(UIViewController*)parentViewController type:(int)type {
    
    ViewControllerHome* vcHome = [ViewControllerHome getInstance];
    if (vcHome) {
        vcHome.isHomeScreenPresented = false;
    }
    
    UIStoryboard* sb = [Utility getStoryBoardObject];
    //create new viewcontroller
    UIViewController *newViewController;
    switch (type) {
        case PUSH_SCREEN_TYPE_CATEGORY:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_CATEGORY];
            break;
        case PUSH_SCREEN_TYPE_CATEGORY_NEW:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_CATEGORY_NEW];
            break;
        case PUSH_SCREEN_TYPE_ADDRESS:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_ADDRESS];
            break;
        case PUSH_SCREEN_TYPE_PRODUCT:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_PRODUCT];
            break;
        case PUSH_SCREEN_TYPE_PROD_DESC:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_PROD_DESC];
            break;
        case PUSH_SCREEN_TYPE_LOGIN:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_LOGIN];
            break;
        case PUSH_SCREEN_TYPE_CART_CONFIRM:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_CART_CONFIRM];
            break;
        case PUSH_SCREEN_TYPE_CART_SHIPPING:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_CART_SHIPPING];
            break;
            
        case PUSH_SCREEN_TYPE_ORDER:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_ORDER];
            break;
        case PUSH_SCREEN_TYPE_SPONSOR_FRIEND:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_SPONSOR_FRIEND];
            break;
        case PUSH_SCREEN_TYPE_ORDER_RECEIPT:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_ORDER_RECEIPT];
            break;
        case PUSH_SCREEN_TYPE_WEBVIEW:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_WEBVIEW];
            break;
        case PUSH_SCREEN_TYPE_BARCODE_SCAN:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BARCODE_SCAN];
            break;
        case PUSH_SCREEN_TYPE_LOCATE_STORE:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_LOCATE_STORE];
            break;
        case PUSH_SCREEN_TYPE_SELLER_ZONE:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_SELLER_ZONE];
            break;
        case PUSH_SCREEN_TYPE_ADDRESS_MAP:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_ADDRESS_MAP];
            break;
        case PUSH_SCREEN_TYPE_CONTACT_US:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_CONTACT_US];
            break;
        case PUSH_SCREEN_TYPE_CONTACT_US_FORM:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_CONTACT_US_FORM];
            break;
        case PUSH_SCREEN_TYPE_RESERVATION_FORM:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_RESERVATION_FORM];
            break;
        case PUSH_SCREEN_TYPE_CHECKOUT:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_CHECKOUT];
            break;
        case PUSH_SCREEN_TYPE_GETCODE:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_GETCODE];
            break;
        case PUSH_SCREEN_TYPE_FILTER:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_FILTER];
            break;
        case PUSH_SCREEN_TYPE_MYCOPON:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_MYCOUPON];
            break;
        case PUSH_SCREEN_TYPE_MYCOPON_PRODUCT:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_MYCOUPON_PRODUCT];
            break;
        case PUSH_SCREEN_TYPE_NOTIFICATION:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_NOTIFICATION];
            break;
        case PUSH_SCREEN_TYPE_SETTING:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_SETTING];
            break;
        case PUSH_SCREEN_TYPE_SELLER_ITEM:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_SELLER_ITEM];
            break;
        case PUSH_SCREEN_TYPE_VC_PRODUCTS:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_PRODUCTS];
            break;
        case PUSH_SCREEN_TYPE_NEARBYSEARCH:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_NEARBYSEARCH];
            break;
        case PUSH_SCREEN_TYPE_CURRENCY:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_CURRENCY];
            break;
        default:
            break;
    }
    //remove previous view controllers
    newViewController.view.frame = parentViewController.view.frame;
    [newViewController.view.layer addAnimation:[Utility pushAnimation] forKey:nil];
    //add as child
    [parentViewController addChildViewController:newViewController];
    [parentViewController.view addSubview:newViewController.view];
    [newViewController didMoveToParentViewController:parentViewController];
    RLOG(@"pushedViewControllers count= %d", (int)[self.pushedViewControllers count]);
    return newViewController;
}
- (void)popScreenWithNewAnimation:(UIViewController*)childViewController{
    [UIView animateWithDuration:0.37f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         childViewController.view.frame = CGRectMake([[[UIApplication sharedApplication] delegate] window].frame.size.width, childViewController.view.frame.origin.y, childViewController.view.frame.size.width, childViewController.view.frame.size.height);
                     } completion:^(BOOL complete){
                         if (complete) {
                             [childViewController willMoveToParentViewController:nil];
                             [childViewController.view removeFromSuperview];
                             [childViewController removeFromParentViewController];
                         }
                     }];
}
- (ViewControllerCategories *)pushScreen:(UIViewController*)parentViewController{
    UIStoryboard* sb = [Utility getStoryBoardObject];
    //create new viewcontroller
    ViewControllerCategories *newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_CATEGORY];
    newViewController.view.frame = parentViewController.view.frame;
    //    CGRect rect = newViewController.view.frame;
    //    rect.origin.y = 200;
    //    newViewController.view.frame = rect;
    UIColor *color = parentViewController.view.backgroundColor;
    parentViewController.view.backgroundColor = [UIColor clearColor];
    //animation for push screen
#if (ENABLE_NEW_TRANSITION)
    [newViewController.view.layer addAnimation:[Utility pushAnimation] forKey:nil];
#else
    UIView *containerView = parentViewController.view.window;
    [containerView.layer addAnimation:[Utility pushAnimation] forKey:nil];
#endif
    
    //add as child
    [parentViewController addChildViewController:newViewController];
    [parentViewController.view addSubview:newViewController.view];
    [newViewController didMoveToParentViewController:parentViewController];
    
    return newViewController;
}

#if CATEGORY_VIEW_NEW_HACK_ENABLE
- (ViewControllerCategoriesNew *)pushScreenCategoryNew:(UIViewController*)parentViewController{
    UIStoryboard* sb = [Utility getStoryBoardObject];
    //create new viewcontroller
    ViewControllerCategoriesNew *newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_CATEGORY_NEW];
    newViewController.view.frame = parentViewController.view.frame;
    UIColor *color = parentViewController.view.backgroundColor;
    parentViewController.view.backgroundColor = [UIColor clearColor];
    //animation for push screen
#if (ENABLE_NEW_TRANSITION)
    [newViewController.view.layer addAnimation:[Utility pushAnimation] forKey:nil];
#else
    UIView *containerView = parentViewController.view.window;
    [containerView.layer addAnimation:[Utility pushAnimation] forKey:nil];
#endif
    
    //add as child
    [parentViewController addChildViewController:newViewController];
    [parentViewController.view addSubview:newViewController.view];
    [newViewController didMoveToParentViewController:parentViewController];
    return newViewController;
}

#endif

- (UIViewController *)pushOverScreenWithoutAnimation:(UIViewController*)parentViewController type:(int)type {
    UIViewController *newViewController = [self getNewViewController:type];
    newViewController.view.frame = parentViewController.view.frame;
    
    //add as child
    [parentViewController addChildViewController:newViewController];
    [parentViewController.view addSubview:newViewController.view];
    [newViewController didMoveToParentViewController:parentViewController];
    
    return newViewController;
}

- (UIViewController *)pushScreenWithoutAnimation:(UIViewController*)parentViewController type:(int)type {
    ViewControllerHome* vcHome = [ViewControllerHome getInstance];
    if (vcHome) {
        vcHome.isHomeScreenPresented = false;
    }
    return [self pushScreenWithoutAnimation:parentViewController type:type newViewController:nil];
}

- (UIViewController *)pushScreenWithoutAnimation:(UIViewController*)parentViewController type:(int)type newViewController:(UIViewController *)newViewController {
    if (newViewController == nil) {
        newViewController = [self getNewViewController:type];
    }
    
    //remove previous view controllers
    for (UIViewController* pushedViewController in self.pushedViewControllers) {
        [self popScreenWithoutAnimation:pushedViewController];
        [self.pushedViewControllers removeObject:pushedViewController];
    }
    
    [self.pushedViewControllers addObject:newViewController];
    
    newViewController.view.frame = parentViewController.view.frame;
    
    //add as child
    [parentViewController addChildViewController:newViewController];
    [parentViewController.view addSubview:newViewController.view];
    [newViewController didMoveToParentViewController:parentViewController];
    
    return newViewController;
}

- (UIViewController *)getNewViewController:(int)type {
    UIStoryboard *sb = [Utility getStoryBoardObject];
    UIViewController *newViewController = nil;
    switch (type) {
        case PUSH_SCREEN_TYPE_CATEGORY:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_CATEGORY];
            break;
        case PUSH_SCREEN_TYPE_CATEGORY_NEW:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_CATEGORY_NEW];
            break;
        case PUSH_SCREEN_TYPE_ADDRESS:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_ADDRESS];
            break;
        case PUSH_SCREEN_TYPE_PRODUCT:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_PRODUCT];
            break;
        case PUSH_SCREEN_TYPE_PROD_DESC:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_PROD_DESC];
            break;
        case PUSH_SCREEN_TYPE_LOGIN:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_LOGIN];
            break;
        case PUSH_SCREEN_TYPE_CART_CONFIRM:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_CART_CONFIRM];
            break;
        case PUSH_SCREEN_TYPE_CART_SHIPPING:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_CART_SHIPPING];
            break;
        case PUSH_SCREEN_TYPE_ORDER:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_ORDER];
            break;
        case PUSH_SCREEN_TYPE_ORDER_RECEIPT:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_ORDER_RECEIPT];
            break;
        case PUSH_SCREEN_TYPE_WEBVIEW:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_WEBVIEW];
            break;
        case PUSH_SCREEN_TYPE_BARCODE_SCAN:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BARCODE_SCAN];
            break;
        case PUSH_SCREEN_TYPE_LOCATE_STORE:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_LOCATE_STORE];
            break;
        case PUSH_SCREEN_TYPE_SELLER_ZONE:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_SELLER_ZONE];
            break;
        case PUSH_SCREEN_TYPE_ADDRESS_MAP:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_ADDRESS_MAP];
            break;
        case PUSH_SCREEN_TYPE_CONTACT_US:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_CONTACT_US];
            break;
        case PUSH_SCREEN_TYPE_CONTACT_US_FORM:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_CONTACT_US_FORM];
            break;
        case PUSH_SCREEN_TYPE_RESERVATION_FORM:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_RESERVATION_FORM];
            break;
        case PUSH_SCREEN_TYPE_CHECKOUT:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_CHECKOUT];
            break;
        case PUSH_SCREEN_TYPE_GETCODE:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_GETCODE];
            break;
        case PUSH_SCREEN_TYPE_FILTER:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_FILTER];
            break;
        case PUSH_SCREEN_TYPE_MYCOPON:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_MYCOUPON];
            break;
        case PUSH_SCREEN_TYPE_MYCOPON_PRODUCT:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_MYCOUPON_PRODUCT];
            break;
        case PUSH_SCREEN_TYPE_SETTING:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_SETTING];
            break;
        case PUSH_SCREEN_TYPE_SPONSOR_FRIEND:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_BACK_BTN_SPONSOR_FRIEND];
            break;
        case PUSH_SCREEN_TYPE_VC_PRODUCTS:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_PRODUCTS];
            break;
        case PUSH_SCREEN_TYPE_NOTIFICATION:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_NOTIFICATION];
            break;
        case PUSH_SCREEN_TYPE_NEARBYSEARCH:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_NEARBYSEARCH];
            break;
        case PUSH_SCREEN_TYPE_CURRENCY:
            newViewController = [sb instantiateViewControllerWithIdentifier:VC_CURRENCY];
        default:
            break;
    }
    return newViewController;
}

- (void)popScreen:(UIViewController*)childViewController{
#if (ENABLE_NEW_TRANSITION)
    
    //////////////////TYPE1////////////////////
    //    [childViewController willMoveToParentViewController:nil];
    //    [UIView animateWithDuration:0.8
    //                          delay:0.0
    //         usingSpringWithDamping:0.6
    //          initialSpringVelocity:0.3
    //                        options:UIViewAnimationOptionCurveEaseIn
    //                     animations:^{
    //                         childViewController.view.frame = CGRectMake([[[UIApplication sharedApplication] delegate] window].frame.size.width-50, childViewController.view.frame.origin.y, childViewController.view.frame.size.width, childViewController.view.frame.size.height);
    //                     } completion:^(BOOL complete){
    //                         [childViewController.view removeFromSuperview];
    //                         [childViewController removeFromParentViewController];
    //                     }];
    
    //////////////////TYPE2////////////////////
    //    [childViewController.view.layer addAnimation:[Utility popAnimation] forKey:nil];
    //    [childViewController willMoveToParentViewController:nil];
    //    [UIView animateWithDuration:0.4f animations:^{
    //    } completion:^(BOOL finished) {
    //        if (finished) {
    //
    //            [childViewController.view removeFromSuperview];
    //            [childViewController removeFromParentViewController];
    //        }
    //    }];
    
    //////////////////TYPE3////////////////////
    //    [childViewController willMoveToParentViewController:nil];
    //    [childViewController.view.layer addAnimation:[Utility popAnimation] forKey:nil];
    //    [UIView animateWithDuration:0.4f animations:^{
    //    } completion:^(BOOL finished) {
    //        if (finished) {
    //            [childViewController.view removeFromSuperview];
    //            [childViewController removeFromParentViewController];
    //        }
    //    }];
    
    ////////////////TYPE4////////////////////
    RLOG(@"childViewController start = %@", childViewController);
    //    [childViewController.view.layer addAnimation:[Utility popAnimation] forKey:nil];
    [UIView animateWithDuration:0.37f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         childViewController.view.frame = CGRectMake([[[UIApplication sharedApplication] delegate] window].frame.size.width, childViewController.view.frame.origin.y, childViewController.view.frame.size.width, childViewController.view.frame.size.height);
                         //                         [childViewController.view.layer setOpacity:0.99f];
                     } completion:^(BOOL complete){
                         if (complete) {
                             RLOG(@"childViewController complete = %@", childViewController);
                             [childViewController willMoveToParentViewController:nil];
                             [childViewController.view removeFromSuperview];
                             //                             [childViewController viewWillDisappear];
                             [childViewController removeFromParentViewController];
                         }
                     }];
#else
    //    [childViewController viewWillDisappear:true];
    UIView *containerView = childViewController.view.window;
    [containerView.layer addAnimation:[Utility popAnimation] forKey:nil];
    //remove from parent
    [childViewController willMoveToParentViewController:nil];
    [childViewController.view removeFromSuperview];
    [childViewController removeFromParentViewController];
#endif
}
- (void)popScreenWithoutAnimation:(UIViewController*)childViewController{
#if ENABLE_NEW_TRANSITION
    [self popScreen:childViewController];
#else
    //    UIView *containerView = childViewController.view.window;
    //    [containerView.layer addAnimation:[Utility popAnimation] forKey:nil];
    //remove from parent
    //    [childViewController viewWillDisappear:true];
    [childViewController willMoveToParentViewController:nil];
    [childViewController.view removeFromSuperview];
    [childViewController removeFromParentViewController];
#endif
}
+ (void)getUIFont:(int)type isBold:(BOOL)isBold appliedOnLable:(UILabel*)appliedOnLable {
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        appliedOnLable.transform = CGAffineTransformMakeScale(-1, 1);
    }
    appliedOnLable.font = [Utility getUIFont:type isBold:isBold];
}
+ (UIFont*)getUIFont:(int)type isBold:(BOOL)isBold{
    NSString* fontName;
    float fSize = 12.0f;
    float extraSize = 1.0f;
    //for alegreyasans
    //    if (isBold) {
    //        fontName = @"ALEGREYASANS-BOLD";
    //    } else {
    //        fontName = @"ALEGREYASANS-REGULAR";
    //    }
    
    //////for helvetica neu
    if (isBold) {
        fontName = @"HelveticaNeue-Medium";
    } else {
        fontName = @"HelveticaNeue-Light";
    }
    
    
    //asquared && premihair && groce wheels
    if ([MY_APPID isEqualToString:@"1151746673"] ||
        [MY_APPID isEqualToString:@"1148317682"] ||
        [MY_APPID isEqualToString:@"1172871780"])
    {
        //////    for futura
        if (isBold) {
            fontName = @"Futura-Medium";//system
        } else {
            fontName = @"Futura T OT";
        }
        extraSize = 1.15f;
        
    }
    
    
    
    float ratioFont = 1.0f;
    if ([[MyDevice sharedManager] isIpad]) {
        fSize = type + 8;
        ratioFont = 1.0f;
    }else{
        fSize = type + 9;
        ratioFont = 0.77f;
    }
    fSize *= ratioFont;
    fSize *= extraSize;
    
    
    
    return [UIFont fontWithName:fontName size:(int)fSize];
}
static UIColor *themeBlueColor;
static UIColor *themeHeaderBg;
static UIColor *themeFooterBg;
static UIColor *themeColor;
static UIColor *themeButtonNormalColor;
static UIColor *themeButtonSelectedColor;
static UIColor *themeButtonDisabledColor;
static UIColor *themeBigButtonBg;
static UIColor *themeBigButtonFont;
static UIColor *themeBannerIndicatorSelectedColor;
static UIColor *themeBannerIndicatorNormalColor;
static UIColor *themeColorHViewHeaderBg;
static UIColor *themeColorHViewHeaderFont;

+ (void)setThemeBlueColor{
    //if header color is white then it is blue color
    //otherwise theme color
    const CGFloat* colors = CGColorGetComponents( themeHeaderBg.CGColor );
    CGFloat red = colors[0];
    CGFloat green = colors[1];
    CGFloat blue = colors[2];
    CGFloat alpha = colors[3];
    
    if (red == 1.0f && green == 1.0f && blue == 1.0f && alpha == 1.0f) {
        themeBlueColor = themeColor;
    } else {
        themeBlueColor =  UIColorFromRGB(0x269CDB);
    }
}
+ (void)setThemeColorHorizontalViewBg:(UIColor *)value{
    themeColorHViewHeaderBg = value;
}
+ (void)setThemeColorHorizontalViewFont:(UIColor *)value{
    themeColorHViewHeaderFont = value;
}
+ (void)setThemeHeaderBg:(UIColor *)value{
    themeHeaderBg = value;
}
+ (void)setThemeFooterBg:(UIColor *)value{
    themeFooterBg = value;
}
+ (void)setThemeColor:(UIColor *)value{
    themeColor = value;
}
+ (void)setThemeButtonNormalColor:(UIColor *)value{
    themeButtonNormalColor = value;
}
+ (void)setThemeButtonSelectedColor:(UIColor *)value{
    themeButtonSelectedColor = value;
}
+ (void)setThemeButtonDisabledColor:(UIColor *)value{
    themeButtonDisabledColor = value;
}
+ (void)setThemeBigButtonBg:(UIColor *)value{
    themeBigButtonBg = value;
}
+ (void)setThemeBigButtonFont:(UIColor *)value{
    themeBigButtonFont = value;
}
+ (void)setThemeBannerIndicatorSelectedColor:(UIColor *)value {
    //here value is not in use
    CGColorRef color = [themeColor CGColor];
    int numComponents = (int)CGColorGetNumberOfComponents(color);
    if (numComponents == 4) {
        const CGFloat *components = CGColorGetComponents(color);
        CGFloat r = components[0];
        CGFloat g = components[1];
        CGFloat b = components[2];
        themeBannerIndicatorSelectedColor = [UIColor colorWithRed:r green:g blue:b alpha:0.5f];
    }
}
+ (void)setThemeBannerIndicatorNormalColor:(UIColor *)value {
    //here value is not in use
    CGColorRef color = [themeButtonDisabledColor CGColor];
    int numComponents = (int)CGColorGetNumberOfComponents(color);
    if (numComponents == 4) {
        const CGFloat *components = CGColorGetComponents(color);
        CGFloat r = components[0];
        CGFloat g = components[1];
        CGFloat b = components[2];
        themeBannerIndicatorNormalColor = [UIColor colorWithRed:r green:g blue:b alpha:0.5f];
    }
}







+ (UIColor*)getUIColor:(int)tag{
    //    int themeC = 0xFF0000;
    //    _themeHeaderBg               = 0xFFFFFF;
    //    _themeFooterBg               = 0xFFFFFF;
    //    _themeColor                  = 0x269CDB;
    //    int themeButtonNormalColor      = 0xb6b6b6;
    //    int themeButtonSelectedColor    = 0x269CDB;
    //    int themeButtonDisabledColor    = 0xEAEAEA;
    //    int themeBigButtonBg            = 0x269CDB;
    //    int themeBigButtonFont          = 0xFFFFFF;
    
    switch (tag) {
            //changable
        case kUIColorBlue:
            return themeBlueColor;
            break;
        case kUIColorCartSelected:
            return UIColorFromRGB(0x09BC00);
            break;
        case kUIColorWishlistSelected:
            return UIColorFromRGB(0xF05259);
            break;
        case kUIColorThemeButtonNormal:
        case kUIColorThemeButtonBorderNormal:
            return themeButtonNormalColor;
            break;
        case kUIColorThemeButtonSelected:
        case kUIColorThemeButtonBorderSelected:
            return themeButtonSelectedColor;
            break;
        case kUIColorThemeButtonDisable:
        case kUIColorThemeButtonBorderDisable:
            return themeButtonDisabledColor;
            break;
        case kUIColorThemeFont:
            return themeColor;
            break;
        case kUIColorBuyButtonNormalBg:
            return themeBigButtonBg;
            break;
        case kUIColorBuyButtonFont:
            return themeBigButtonFont;
            break;
        case kUIColorBgHeader:
            return themeHeaderBg;
            break;
        case kUIColorBgFooter:
            return themeFooterBg;
            break;
        case kUIColorBannerSelectedPageIndicator:
            return themeBannerIndicatorSelectedColor;
            break;
        case kUIColorBannerNormalPageIndicator:
            return themeBannerIndicatorNormalColor;
            break;
            
            
            //remains as it is
        case kUIColorTextFieldBorder:
            return UIColorFromRGB(0x999999);
            break;
        case kUIColorFontLight:
            return UIColorFromRGB(0x6F6F6F);
            break;
            
        case kUIColorFontDark:
            //            return UIColorFromRGB(0x222222);
            return UIColorFromRGB(0x424242);
            break;
        case kUIColorFontPriceOld:
            return UIColorFromRGB(0xafafaf);
            break;
        case kUIColorBgTheme:
            return UIColorFromRGB(0xF7F7F7);
            break;
        case kUIColorBorder:
            return UIColorFromRGB(0xEAEAEA);
            break;
        case kUIColorFontListViewLevel0:
            return UIColorFromRGB(0x2b2b2b);
            break;
        case kUIColorFontListViewLevel1:
            return UIColorFromRGB(0x5d5d5d);
            break;
        case kUIColorFontListViewLevel2Plus:
            return UIColorFromRGB(0x828282);
            break;
        case kUIColorBannerBg:
            return UIColorFromRGB(0xFFFFFF);
            break;
        case kUIColorTransparent:
            return [Utility colorWithHex:0x000000AA];
            break;
        case kUIColorClear:
            return [Utility colorWithHex:0xFFFFFF00];
            break;
        case kUIColorFontSubTitle:
            return [UIColor darkGrayColor];//UIColorFromRGB(0x828282);
            break;
        case kUIColorBgSubTitle:
            return [Utility colorWithHex:0xFFFFFF00];
            break;
        case kUIColorHViewHeaderBg:
            return themeColorHViewHeaderBg;
            break;
        case kUIColorHViewHeaderFont:
            return themeColorHViewHeaderFont;
            break;
        default:
            return UIColorFromRGB(0x269CDB);
            break;
    }
    return UIColorFromRGB(0x000000FF);
}

- (float)getTopBarHeight{
    return _topBarHeight;
}
- (float)getBottomBarHeight{
    return _bottomBarHeight;
}
- (float)getStatusBarHeight{
    return _statusBarHeight;
}
+ (NSString*)getNormalStringFromAttributed:(NSString*)str {
    if ([str isEqualToString:@""]) {
        return @"     ";
    }
    if ([Utility containsString:str substring:@"&amp;"]) {
        str = [str stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    }
    if ([Utility containsString:str substring:@"&Amp;"]) {
        str = [str stringByReplacingOccurrencesOfString:@"&Amp;" withString:@"&"];
    }
    if ([Utility containsString:str substring:@"&#038;"]) {
        str = [str stringByReplacingOccurrencesOfString:@"&#038;" withString:@"&"];
    }
    return str;
    
    //    NSString * htmlString = [NSString stringWithFormat:@"<b>%@</b>", str];
    //    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    //    if ([[attrStr string] isEqualToString:@""]) {
    //        return @"     ";
    //    }
    //    NSString* strR = [NSString stringWithFormat:@"%@", [attrStr string]];
    //
    //
    //    return strR;
}

- (void)shareBranchButtonClicked:(ProductInfo*)pInfo button:(UIButton*)button {
#if ENABLE_BRANCH
    NSString* shareUrl = [NSString stringWithFormat:@"%@%d", [[[DataManager sharedManager] tmDataDoctor] productPageBaseUrl], pInfo._id];
    NSString* imgUrl = @"";
    if(pInfo._images && [pInfo._images count] > 0){
        imgUrl = ((ProductImage*)[pInfo._images objectAtIndex:0])._src;
    }
    NSString * htmlString = pInfo._short_description;
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    NSString *strDesc = [attrStr string];
#if (WORKING_BRANCH_VERSION_0_11_11)
    BranchUniversalObject *branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:shareUrl];
    [branchUniversalObject setTitle:[NSString stringWithFormat:@"%@",pInfo._titleForOuterView]];
    [branchUniversalObject setContentDescription:strDesc];
    [branchUniversalObject setImageUrl:imgUrl];
    //    [branchUniversalObject addMetadataKey:@"color" value:@"blue"];
    BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];
    [linkProperties addControlParam:@"$desktop_url" withValue:shareUrl];
    [linkProperties addControlParam:@"$ios_url" withValue:shareUrl];
    [linkProperties addControlParam:@"$android_url" withValue:shareUrl];
    UIBarButtonItem* b = [[UIBarButtonItem alloc] init];
    [b setCustomView:button];
    [branchUniversalObject showShareSheetWithLinkProperties:linkProperties andShareText:Localize(@"i_check_this") fromViewController:nil anchor:b completion:^(NSString *activityType, BOOL completed) {
        if (completed) {
            RLOG(@"==shared==%@==",activityType);
        }
    }];
    //    [branchUniversalObject showShareSheetWithLinkProperties:linkProperties
    //                                               andShareText:@"Hey check this out!"
    //                                         fromViewController:self
    //                                                andCallback:^{
    //                                                    RLOG(@"finished presenting");
    //                                                }];
#endif
#if (WORKING_BRANCH_VERSION_0_11_6)
#endif
#endif
}

- (void)shareOpinionButtonClicked:(ProductInfo*)pInfo pollId:(NSString*)pollId productUrl:(NSString*)productUrl {
    
    [Opinion addProduct:pInfo._id pollId:pollId likeCount:pInfo.pollLikeCount dislikeCount:pInfo.pollDislikeCount];
    
    
    //    NSString* productLinkUrl = [NSString stringWithFormat:@"%@", productUrl];
    //    productLinkUrl = @"http://playcontest.in/demo/wordpress/?p=523";
    // the above string is of url type becauce of "?p=523" and whatsapp ios referred it as url and because url and text both are of different type of sending option, so we can use either url or text.So instead of sending this kind of url, we use permalink url of the product.
    
    NSString* productLinkUrl = [NSString stringWithFormat:@"%@", pInfo._permalink];
    RLOG(@"productLinkUrl = %@", productLinkUrl);
    
    
    NSString* merchantId = [[DataManager sharedManager] merchantObjectId];
    //    NSString* appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    
    NSString* stringAppDisplayName = Localize(@"app_display_name");
    if ([stringAppDisplayName isEqualToString:@""] || [stringAppDisplayName isEqualToString:@"app_display_name"]) {
        stringAppDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    }
    NSString* appName = stringAppDisplayName;
    
    NSString* viaString;
    if (appName && [appName isEqualToString:@""] == false) {
        viaString = [NSString stringWithFormat:Localize(@"i_via_str"), appName];
    }else{
        viaString = @"";
    }
    NSString* likeLinkUrl       = [NSString stringWithFormat:@"http://thetmstore.com/L/%@/%@", merchantId, pollId];
    NSString* dislikeLinkUrl    = [NSString stringWithFormat:@"http://thetmstore.com/U/%@/%@", merchantId, pollId];
    
    NSString* textToShare =[NSString stringWithFormat:@"\n%@\n%@:%@\n%@\n\n%@\n\n%@\n%@\n\n%@\n%@\n\n%@",
                            pInfo._title,
                            Localize(@"price"),
                            [pInfo getPriceNewString],
                            productLinkUrl,
                            Localize(@"msg_opinion_product"),
                            Localize(@"msg_opinion_like"),
                            likeLinkUrl,
                            Localize(@"msg_opinion_dislike"),
                            dislikeLinkUrl,
                            viaString
                            ];
    
    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",textToShare];
    NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        RLOG(@"whatsappURL = %@", whatsappURL);
        [[UIApplication sharedApplication] openURL: whatsappURL];
    } else {
        // Cannot open whatsapp
    }
}

- (void)shareWhatsAppButtonClicked:(ProductInfo*)pInfo pollId:(NSString*)pollId productUrl:(NSString*)productUrl {
    
    [Opinion addProduct:pInfo._id pollId:pollId likeCount:pInfo.pollLikeCount dislikeCount:pInfo.pollDislikeCount];
    
    
    //    NSString* productLinkUrl = [NSString stringWithFormat:@"%@", productUrl];
    //    productLinkUrl = @"http://playcontest.in/demo/wordpress/?p=523";
    // the above string is of url type becauce of "?p=523" and whatsapp ios referred it as url and because url and text both are of different type of sending option, so we can use either url or text.So instead of sending this kind of url, we use permalink url of the product.
    
    NSString* productLinkUrl = [NSString stringWithFormat:@"%@", pInfo._permalink];
    RLOG(@"productLinkUrl = %@", productLinkUrl);
    
    
    NSString* merchantId = [[DataManager sharedManager] merchantObjectId];
    //    NSString* appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    
    NSString* stringAppDisplayName = Localize(@"app_display_name");
    if ([stringAppDisplayName isEqualToString:@""] || [stringAppDisplayName isEqualToString:@"app_display_name"]) {
        stringAppDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    }
    NSString* appName = stringAppDisplayName;
    
    NSString* viaString;
    if (appName && [appName isEqualToString:@""] == false) {
        viaString = [NSString stringWithFormat:Localize(@"i_via_str"), appName];
    }else{
        viaString = @"";
    }
    NSString* likeLinkUrl       = [NSString stringWithFormat:@"http://thetmstore.com/L/%@/%@", merchantId, pollId];
    NSString* dislikeLinkUrl    = [NSString stringWithFormat:@"http://thetmstore.com/U/%@/%@", merchantId, pollId];
    
    NSString* textToShare =[NSString stringWithFormat:@"\n%@\n%@",
                            pInfo._title,
                            productUrl
//                            Localize(@"price"),
//                            pInfo._priceNewString,
//                            productLinkUrl,
//                            Localize(@"msg_opinion_product"),
//                            Localize(@"msg_opinion_like"),
//                            likeLinkUrl,
//                            Localize(@"msg_opinion_dislike"),
//                            dislikeLinkUrl,
//                            viaString
                            ];
    
    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",textToShare];
    NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        RLOG(@"whatsappURL = %@", whatsappURL);
        [[UIApplication sharedApplication] openURL: whatsappURL];
    } else {
        // Cannot open whatsapp
    }
}

- (void)startRecording {
#if (IS_RECORD_APP_ENABLE)
    if([[[UIDevice currentDevice] systemVersion] floatValue] > 9.0f) {
        _recordingState = kRECORDING_ENABLE;
        [[RPScreenRecorder sharedRecorder] startRecordingWithMicrophoneEnabled:true handler:^(NSError*error){
            RLOG(@"RPScreenRecorder startRecordingWithMicrophoneEnabled");
            if (error) {
                _recordingState = kRECORDING_DISABLE;
                RLOG(@"replaykit error: %@", error);
            }
        }];
    }
#endif
}
- (void)stopRecording {
#if (IS_RECORD_APP_ENABLE)
    if([[[UIDevice currentDevice] systemVersion] floatValue] > 9.0f) {
        _recordingState = kRECORDING_DISABLE;
        [[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
            RLOG(@"RPScreenRecorder stopRecordingWithHandler :\n previewViewController = %@", previewViewController);
            ViewControllerMain* mainVC = [ViewControllerMain getInstance];
            mainVC.containerTop.hidden = YES;
            mainVC.containerCenter.hidden = YES;
            mainVC.containerCenterWithTop.hidden = NO;
            mainVC.vcBottomBar.buttonHome.selected = NO;
            mainVC.vcBottomBar.buttonCart.selected = NO;
            mainVC.vcBottomBar.buttonWishlist.selected = NO;
            mainVC.vcBottomBar.buttonSearch.selected = NO;
            [mainVC.vcBottomBar buttonClicked:nil];
            [previewViewController.editButtonItem setTitle:@"1Cancel"];
            [previewViewController.navigationItem setTitle:@"2Cancel"];
            
            [[Utility sharedManager] pushRecordingScreen:mainVC.vcCenterTop recordVC:previewViewController];
        }];
    }
#endif
}



- (BOOL)checkForDemoApp:(BOOL)showMsg {
    if ([[DataManager sharedManager] appType] == APP_TYPE_DEMO) {
        if (showMsg) {
            [_alertForDemoApp show];
        }
        return true;
    }
    return false;
}
- (BOOL)checkForPaidApp {
    if ([[DataManager sharedManager] appType] == APP_TYPE_PAID) {
        return true;
    }
    return false;
}
- (NSString*)getCategoryViewString {
    return [[Utility sharedManager] getCategoryViewString:0];
}
- (NSString*)getCategoryViewString:(int)indexId{
    switch ([[DataManager sharedManager] layoutIdCategoryView]) {
        case C_LAYOUT_DEFAULT:
            return CategoryCellType1;
            break;
        case C_LAYOUT_RIGHTSIDE:
            return CategoryCellType2;
            break;
        case C_LAYOUT_LEFTRIGHTSIDE:
            return CategoryCellType2;
            break;
        case C_LAYOUT_FULL:
            return CategoryCellType1;
            break;
        default:
            break;
    }
    return CategoryCellType1;
}
- (NSString*)getProductViewString{
    Addons* addons = [Addons sharedManager];
    
    switch ([[DataManager sharedManager] layoutIdProductView]) {
        case P_LAYOUT_DEFAULT:
            if(addons.show_cart_with_product){
                return ProductCellType1_Cart;
            }else{
                return ProductCellType1;
            }
            break;
        case P_LAYOUT_FULL_ICON_BUTTON:
            if(addons.show_cart_with_product){
                return ProductCellType2_Cart;
            }else{
                return ProductCellType2;
            }
            break;
        case P_LAYOUT_FULL_RECT_BUTTON:
            if(addons.show_cart_with_product){
                return ProductCellType3_Cart;
            }else{
                return ProductCellType3;
            }
            break;
        case P_LAYOUT_ZIGZAG:
            if(addons.show_cart_with_product){
                return ProductCellType1_Cart;
            }else{
                return ProductCellType1;
            }
            break;
        case P_LAYOUT_GROCERY:
        {
            Addons* addons = [Addons sharedManager];
            addons.show_cart_with_product = true;
            return ProductCellType4_Cart;
        } break;
        case P_LAYOUT_DISCOUNT:
        {
            Addons* addons = [Addons sharedManager];
            addons.show_cart_with_product = true;
            if (ENABLE_DISCOUNT_LAYOUT_TYPE1) {
                return ProductCellType5_Cart_FLEXIBLE;
            }
            else if (ENABLE_DISCOUNT_LAYOUT_TYPE2) {
                return ProductCellType5_Cart;
            }
        } break;
        default:
            break;
    }
    return ProductCellType1;
}
- (NSString*)getHorizontalViewString{
    Addons* addons = [Addons sharedManager];
    //    switch ([[DataManager sharedManager] layoutIdHorizontalView]) {
    //        case P_LAYOUT_DEFAULT:
    //            return ProductCellType1;
    //            break;
    //        case P_LAYOUT_FULL_ICON_BUTTON:
    //            return ProductCellType2;
    //            break;
    //        case P_LAYOUT_FULL_RECT_BUTTON:
    //            return ProductCellType3;
    //            break;
    //        case P_LAYOUT_ZIGZAG:
    //            return ProductCellType1;
    //            break;
    //        default:
    //            break;
    //    }
    if(addons.show_cart_with_product){
        return ProductCellType1_Cart;
    }else{
        return ProductCellType1;
    }
}
- (NSString*)getBundleViewString {
    Addons* addons = [Addons sharedManager];
    if(addons.show_cart_with_product){
        return ProductCellTypeBundle;
    }else{
        return ProductCellTypeBundle;
    }
}
- (NSString*)getMixNMatchViewString {
    Addons* addons = [Addons sharedManager];
    if(addons.show_cart_with_product){
        return ProductCellTypeMixMatch;
    }else{
        return ProductCellTypeMixMatch;
    }
}
- (UIActivityIndicatorView*)startGrayLoadingBar:(BOOL)willRotate {
    if (_spinnerView == nil) {
        _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_spinnerView startAnimating];
    }
    [_spinnerView removeFromSuperview];
    //    _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //    [_spinnerView startAnimating];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_spinnerView];
    [_spinnerView setFrame:CGRectMake(
                                      0,
                                      0,
                                      _spinnerView.frame.size.width,
                                      _spinnerView.frame.size.height)];
    CGRect frame = [[UIApplication sharedApplication] keyWindow].frame;
    _spinnerView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    if (willRotate) {
        _spinnerView.center = CGPointMake(frame.size.height/2, frame.size.width/2);
    }
    
    //    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    //    MRProgressOverlayView * mrPOV = [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:NO];
    //    mrPOV.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0f];
    //    UIActivityIndicatorView* activityIndicator = ((UIActivityIndicatorView*) (mrPOV.modeView));
    //    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    //    mrPOV.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
    //    if (willRotate) {
    //        CGRect frame = [[UIApplication sharedApplication] keyWindow].frame;
    //        mrPOV.center = CGPointMake(frame.size.height/2, frame.size.width/2);
    //    }
    return _spinnerView;
}
- (void)stopGrayLoadingBar {
    [_spinnerView removeFromSuperview];
    //    _spinnerView = nil;
    //    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:NO];
}
- (NSString*)getUserAgent{
    if ([_userAgentForPostMethod isEqualToString:@""]) {
        UIWebView* webV= [[UIWebView alloc] init];
        _userAgentForPostMethod = [NSString stringWithFormat:@"%@", [webV stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]];
    }
    return _userAgentForPostMethod;
}

- (NSString*)resizeImageInPath:(NSString*)path resizeType:(int)resizeType {
//    return path;
    NSArray *tempArray = [path componentsSeparatedByString:@"?"];
    NSString* imgPath = [tempArray objectAtIndex:0];
    if (imgPath == nil || [imgPath isEqualToString:@""]) {
        return @"";
    }
    
    float width = 0;
    float deviceFactor = 1.0f;
    if ([[MyDevice sharedManager] isIpad]) {
        deviceFactor = 1.0f;
    } else {
        deviceFactor = 0.5f;
    }
    switch (resizeType) {
        case kRESIZE_TYPE_BANNER:
            width = 512.0f * deviceFactor;
            break;
        case kRESIZE_TYPE_CATEGORY_THUMBNAIL:
            width = 264.0f * deviceFactor;
            break;
        case kRESIZE_TYPE_PRODUCT_THUMBNAIL:
            width = 264.0f * deviceFactor;
            break;
        case kRESIZE_TYPE_PRODUCT_BANNER:
            width = 512.0f * deviceFactor;
            break;
        default:
            width = 264.0f * deviceFactor;
            break;
    }
    if (width!=0) {
        //resized image
        imgPath = [NSString stringWithFormat:@"%@?fit=%d%%2C%d", imgPath, (int)width, (int)width];
    } else {
        //full sized image
        imgPath = [NSString stringWithFormat:@"%@", imgPath];
    }
    RLOG(@"CPATH:%@", imgPath);
    return imgPath;
}


- (NSString*) getExtension:(NSString*) fileName {
    unsigned long index = [fileName rangeOfString:@"." options:NSBackwardsSearch].location;
    return index <= 0 ? @"" : [fileName substringFromIndex:index];
}

- (NSString*)getResizedImageUrl:(NSString*) src_url {
    if(![[Addons sharedManager] resize_product_thumbs]){
        return src_url;
    }

    NSString* dst_url = src_url;
    if([src_url containsString:@"-150x150"] && ![src_url containsString:@"resize="]) {
        dst_url = [[src_url componentsSeparatedByString:@"-150x150"] objectAtIndex:0];
        dst_url = [NSString stringWithFormat:@"%@%@", dst_url, [self getExtension:src_url]];
        dst_url = [NSString stringWithFormat:@"%@%@", dst_url, @"?fit=500%2C500"];
        RLOG(@"ResizedImage : %@", dst_url);
    }
    return dst_url;
}

- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target
                                        withString:(NSString *)replacement{
    
    NSString *str = [target stringByReplacingOccurrencesOfString:@"//"
                                         withString:@"https://"];
    return str;
}

- (NSString*)getScaledImageUrl:(NSString*) src_url {
    NSString* dst_url = [self getResizedImageUrl:src_url];
    if([dst_url isEqualToString:src_url]) {
        dst_url = [self resizeProductImage:src_url];
    }
    return dst_url;
}

- (NSString*)resizeProductImage:(NSString*) src_url {
    if(![[Addons sharedManager] resize_product_images]){
        return src_url;
    }
    
    if (src_url == nil || [src_url isEqualToString:@""]) {
        return src_url;
    }
    
    NSArray* tokens = [src_url componentsSeparatedByString:@"-"];
    if([tokens count] > 1) {
        NSString* token = [tokens lastObject];
        if( [token containsString:@"x"] && ![token containsString:@"?fit="]) {
            NSString* ext = [self getExtension:token];
            if([ext length] > 0) {
                // Aspect ratio will be applied using images default width and height.
                NSString* target = [NSString stringWithFormat:@"-%@", token];
                NSString* replacement = [NSString stringWithFormat:@"%@%@", ext, @"?fit=512x512"];
                src_url = [src_url stringByReplacingOccurrencesOfString:target withString:replacement];
                RLOG(@"ResizedImage : %@", src_url);
            }
        }
    }
    return src_url;
}

enum BORDER_SIDES {
    BORDER_ON_TOP,
    BORDER_ON_BOTTOM,
    BORDER_ON_LEFT,
    BORDER_ON_RIGHT,
    BORDER_ON_TOP_BOTTOM,
    BORDER_ON_LEFT_RIGHT,
    BORDER_ON_TOP_LEFT,
    BORDER_ON_TOP_RIGHT,
    BORDER_ON_BOTTOM_LEFT,
    BORDER_ON_BOTTOM_RIGHT,
    BORDER_ON_TOP_BOTTOM_LEFT,
    BORDER_ON_TOP_BOTTOM_RIGHT,
    BORDER_ON_TOP_LEFT_RIGHT,
    BORDER_ON_BOTTOM_LEFT_RIGHT,
    BORDER_ON_ALL_SIDES
};
+ (void)showShadow:(UIView*)view {
    if (view) {
        [Utility showShadow:view enableBorder:true borderSides:BORDER_ON_ALL_SIDES];
    }
}
+ (void)showShadow:(UIView*)view enableBorder:(BOOL)enableBorder borderSides:(int)borderSides {
    /*
     if (enableBorder) {
     switch (borderSides) {
     case BORDER_ON_TOP:{
     
     } break;
     case BORDER_ON_BOTTOM:{
     
     } break;
     case BORDER_ON_LEFT:{
     
     } break;
     case BORDER_ON_RIGHT:{
     
     } break;
     case BORDER_ON_TOP_BOTTOM:{
     
     } break;
     case BORDER_ON_LEFT_RIGHT:{
     
     } break;
     case BORDER_ON_TOP_LEFT:{
     
     } break;
     case BORDER_ON_TOP_RIGHT:{
     
     } break;
     case BORDER_ON_BOTTOM_LEFT:{
     
     } break;
     case BORDER_ON_BOTTOM_RIGHT:{
     
     } break;
     case BORDER_ON_TOP_BOTTOM_LEFT:{
     
     } break;
     case BORDER_ON_TOP_BOTTOM_RIGHT:{
     
     } break;
     case BORDER_ON_TOP_LEFT_RIGHT:{
     
     } break;
     case BORDER_ON_BOTTOM_LEFT_RIGHT:{
     
     } break;
     case BORDER_ON_ALL_SIDES:{
     //                view.layer.borderColor = [[Utility getUIColor:kUIColorBorder] CGColor];
     //                view.layer.borderWidth = 2;
     } break;
     default:
     break;
     }
     }
     */
    //    view.layer.borderColor = [[Utility getUIColor:kUIColorBorder] CGColor];
    //    view.layer.borderWidth = 2;
    if (view.layer.shadowOpacity != 0.2f) {
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
        view.layer.masksToBounds = NO;
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        if ([[MyDevice sharedManager] isIpad]) {
            view.layer.shadowOffset = CGSizeMake(0.0f, 2.4f);
            view.layer.shadowOpacity = 0.2f;
            view.layer.shadowRadius = 1.2f;
        }else{
            view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
            view.layer.shadowOpacity = 0.2f;
            view.layer.shadowRadius = 1.0f;
        }
        
        view.layer.shadowPath = shadowPath.CGPath;
        //    view.layer.shouldRasterize = YES;
    }
    
}

- (NSString*)getDeviceModel {
    if ([_deviceModel isEqualToString:@""]) {
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
        _deviceModel = [self platformType:platform];
    }
    
    RLOG(@"Device Type ----> %@",_deviceModel);
    return _deviceModel;
}
- (NSString *) platformType:(NSString *)platform
{
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4 (GSM)";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPod7,1"])      return @"iPod Touch 6G";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (GSM)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air (CDMA)";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini Retina (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini Retina (Cellular)";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([platform isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (Cellular)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    if ([platform isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7-inch (WiFi)";
    if ([platform isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7-inch (Cellular)";
    if ([platform isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9-inch (WiFi)";
    if ([platform isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9-inch (Cellular)";
    
    if ([platform isEqualToString:@"i386"])         return [UIDevice currentDevice].model;
    if ([platform isEqualToString:@"x86_64"])       return [UIDevice currentDevice].model;
    
    return platform;
}
- (UIColor*)getTextFieldBorderColor{
    return [Utility getUIColor:kUIColorTextFieldBorder];
}
+ (MRProgressOverlayView*)createCustomizedLoadingBar:(NSString*)title isBottomAlign:(BOOL)isBottomAlign isClearViewEnabled:(BOOL)isClearViewEnabled isShadowEnabled:(BOOL)isShadowEnabled {
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    title = [NSString stringWithFormat:@"%@", title];
    MRProgressOverlayView* overlayView = [[MRProgressOverlayView alloc] init];
    [overlayView setTitleLabelText:title];
    [[[UIApplication sharedApplication] keyWindow] addSubview:overlayView];
    overlayView.mode = MRProgressOverlayViewModeIndeterminateSmall;
    overlayView.isMannualPositionEnable = true;
    CGSize viewSize = [[MyDevice sharedManager] screenSize];
    if (isBottomAlign) {
        overlayView.mannualBound = CGRectMake(0, 0, viewSize.width, viewSize.height * 2);
        overlayView.mannualPosition = CGPointMake(viewSize.width * 0.5f, viewSize.height * 0.85f);
    }else{
        overlayView.mannualBound = CGRectMake(0, 0, viewSize.width, viewSize.height);
        overlayView.mannualPosition = CGPointMake(viewSize.width * 0.5f, viewSize.height * 0.5f);
    }
    overlayView.isClearViewEnabled = isClearViewEnabled;
    UIView* dV = [overlayView getDialogView];
    
    
    dV.backgroundColor = [UIColor whiteColor];
    dV.layer.borderWidth = 0.5f;
    dV.layer.borderColor = [Utility getUIColor:kUIColorBorder].CGColor;
    
    if (isShadowEnabled) {
        dV.layer.shadowColor = [UIColor blackColor].CGColor;
        if ([[MyDevice sharedManager] isIpad]) {
            dV.layer.shadowOffset = CGSizeMake(0.0f, 2.4f);
            dV.layer.shadowOpacity = 0.2f;
            dV.layer.shadowRadius = 1.2f;
        }else{
            dV.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
            dV.layer.shadowOpacity = 0.2f;
            dV.layer.shadowRadius = 1.0f;
        }
    }else{
        dV.layer.shadowOpacity = 0.0f;
        dV.layer.shadowRadius = 0.0f;
    }
    //    [overlayView.titleLabel setUIFont:kUIFontType18 isBold:false];
    [overlayView.titleLabel setFont:[Utility getUIFont:kUIFontType18 isBold:false]];
    [overlayView show:true];
    return overlayView;
    
    
}
+ (void)showProgressView:(NSString*) message {
    [Utility createCustomizedLoadingBar:message isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
}
+ (void)hideProgressView {
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
}
+ (void)showToast:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil, nil];
    [alert show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    });
}
+ (BOOL)containsString:(NSString *)string substring:(NSString*)substring {
    //RLOG(@"%s", __PRETTY_FUNCTION__);
    return [string rangeOfString:substring].location != NSNotFound;
}
- (NSString*)getSlugifyString:(NSString*)str{
    NSString* tempStr = [NSString stringWithFormat:@"%@", str];
    tempStr = [tempStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //custom/built-in replacement
    if (_slugify_keys){
        for (int i = 0; i < (int)[_slugify_keys count]; i++) {
            tempStr = [tempStr stringByReplacingOccurrencesOfString:_slugify_keys[i] withString:_slugify_values[i]];
        }
    }
    //normalize
    {
        NSError *error1 = nil;
        NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:@"[^\\p{ASCII}]+" options:NSRegularExpressionCaseInsensitive error:&error1];
        NSString* strtempStr = [regex1 stringByReplacingMatchesInString:tempStr options:0 range:NSMakeRange(0, [tempStr length]) withTemplate:@""];
        if (strtempStr != nil && ![strtempStr isEqualToString:@""]) {
            tempStr = strtempStr;
        }
        
        NSError *error2 = nil;
        NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:@"(?:[^\\w+]|\\s|\\+)+" options:NSRegularExpressionCaseInsensitive error:&error2];
        tempStr = [regex2 stringByReplacingMatchesInString:tempStr options:0 range:NSMakeRange(0, [tempStr length]) withTemplate:@"-"];
        
        
        NSError *error3 = nil;
        NSRegularExpression *regex3 = [NSRegularExpression regularExpressionWithPattern:@"^-|-$" options:NSRegularExpressionCaseInsensitive error:&error3];
        tempStr = [regex3 stringByReplacingMatchesInString:tempStr options:0 range:NSMakeRange(0, [tempStr length]) withTemplate:@""];
        
    }
    //to lowercase
    {
        tempStr = [tempStr lowercaseString];
        
    }
    return tempStr;
}
+ (BOOL)slugify:(NSString*)name1 name2:(NSString*)name2 {
    NSString* nameA = [[Utility sharedManager] getSlugifyString:name1];
    NSString* nameB = [[Utility sharedManager] getSlugifyString:name2];
    if ([nameA isEqualToString:nameB]) {
        return true;
    }
    return false;
}
+ (BOOL)compareAttributeNames:(NSString*)name1 name2:(NSString*)name2 {
    if (name1 == nil || name2 == nil) {
        return false;
    }
    
    if ([Utility slugify:name1 name2:name2]) {
        return true;
    }
    
    if ([[name1 lowercaseString] isEqualToString:[name2 lowercaseString]]) {
        return true;
    }
    NSString* nameToCompare1 = [NSString stringWithFormat:@"%@", [name1 lowercaseString]];
    NSString* nameToCompare2 = [NSString stringWithFormat:@"%@", [name2 lowercaseString]];
    
    //HACK ONLY FOR BARAKAR RESTAURANT
    NSString* appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    if (1)//[appName isEqualToString:@"Barakat Restaurant"])
    {
        if ([Utility containsString:nameToCompare1 substring:@" add"]) {
            NSArray* foo = [nameToCompare1 componentsSeparatedByString:@" add"];
            NSString* firstBit = [foo objectAtIndex: 0];
            nameToCompare1 = firstBit;
        }
        if ([Utility containsString:nameToCompare2 substring:@" add"]) {
            NSArray* foo = [nameToCompare2 componentsSeparatedByString:@" add"];
            NSString* firstBit = [foo objectAtIndex: 0];
            nameToCompare2 = firstBit;
        }
    }
    
    if (1)//[appName isEqualToString:@"Veganantics"])
    {
        if ([Utility containsString:nameToCompare1 substring:@" x "]) {
            nameToCompare1 = [nameToCompare1 stringByReplacingOccurrencesOfString:@" x " withString:@"-"];
        }
        if ([Utility containsString:nameToCompare2 substring:@" x "]) {
            nameToCompare2 = [nameToCompare2 stringByReplacingOccurrencesOfString:@" x " withString:@"-"];
        }
    }
    
    
    
    
    if ((nameToCompare1.length > 3) && [[nameToCompare1 substringToIndex:3] isEqualToString:@"pa_"]) {
        nameToCompare1 = [nameToCompare1 substringFromIndex:3];
    }
    if ((nameToCompare2.length > 3) && [[nameToCompare2 substringToIndex:3] isEqualToString:@"pa_"]) {
        nameToCompare2 = [nameToCompare2 substringFromIndex:3];
    }
    
    if ([nameToCompare1 isEqualToString:nameToCompare2]) {
        return true;
    }
    
    if ((int)[[nameToCompare1 componentsSeparatedByString:@"%"]count] > 3) {
        @try {
            NSString *encoded = nameToCompare1;
            NSString *decoded = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)encoded, CFSTR(""), kCFStringEncodingUTF8);
            //            RLOG(@"decodedString %@", decoded);
            nameToCompare1 = decoded;
        }
        @catch (NSException *exception) {
            //            RLOG(@"%@", exception);
        }
    }
    
    if ((int)[[nameToCompare2 componentsSeparatedByString:@"%"]count] > 3) {
        @try {
            NSString *encoded = nameToCompare2;
            NSString *decoded = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)encoded, CFSTR(""), kCFStringEncodingUTF8);
            //            RLOG(@"decodedString %@", decoded);
            nameToCompare2 = decoded;
        }
        @catch (NSException *exception) {
            //            RLOG(@"%@", exception);
        }
    }
    if ([nameToCompare1 isEqualToString:nameToCompare2]) {
        return true;
    }
    nameToCompare1 = [nameToCompare1 stringByReplacingOccurrencesOfString:@"-" withString:@""];
    nameToCompare2 = [nameToCompare2 stringByReplacingOccurrencesOfString:@"-" withString:@""];
    nameToCompare1 = [nameToCompare1 stringByReplacingOccurrencesOfString:@"_" withString:@""];
    nameToCompare2 = [nameToCompare2 stringByReplacingOccurrencesOfString:@"_" withString:@""];
    
    NSError *error1 = nil;
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:NSRegularExpressionCaseInsensitive error:&error1];
    nameToCompare1 = [regex1 stringByReplacingMatchesInString:nameToCompare1 options:0 range:NSMakeRange(0, [nameToCompare1 length]) withTemplate:@""];
    //    RLOG(@"%@", nameToCompare1);
    
    NSError *error2 = nil;
    NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:NSRegularExpressionCaseInsensitive error:&error2];
    nameToCompare2 = [regex2 stringByReplacingMatchesInString:nameToCompare2 options:0 range:NSMakeRange(0, [nameToCompare2 length]) withTemplate:@""];
    //    RLOG(@"%@", nameToCompare2);
    
    
    if ([nameToCompare1 isEqualToString:nameToCompare2]) {
        return true;
    }
    return false;
}
+ (NSString*)getStringIfFormatted:(NSString*)str {
    if ((str.length > 3) && [[str substringToIndex:3] isEqualToString:@"pa_"]) {
        str = [str substringFromIndex:3];
    }
    if ((int)[[str componentsSeparatedByString:@"%"]count] > 3) {
        @try {
            NSString *encoded = str;
            NSString *decoded = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)encoded, CFSTR(""), kCFStringEncodingUTF8);
            //            RLOG(@"decodedString %@", decoded);
            str = decoded;
        }
        @catch (NSException *exception) {
            //            RLOG(@"%@", exception);
        }
    }
    return str;
    
}
+ (void)changeInputLanguage:(NSString*)selectedLocale {
    if ([[TMLanguage sharedManager] isLanguageKeyboardEnabled]) {
#if ENABLE_KEYBOARD_CHANGE
        NSArray *langOrder = [NSArray arrayWithObjects:selectedLocale, nil];
        [[NSUserDefaults standardUserDefaults] setObject:langOrder forKey:@"AppleLanguages"];
        UITextField* tempTextField = [[UITextField alloc] init];
        if (![tempTextField isKeyboardAvailable]) {
            [[TMLanguage sharedManager] setAskForLanguageChange:KEYBOARD_CHANGE_NONE];
        }
#endif
    }
}
- (void)openSagepayPaymentGatewayDirectly:(id)delegate {
}
+ (BOOL)isNetworkAvailable {
    if ([[AFNetworkReachabilityManager sharedManager] isReachable]) {
        //        if ([AFNetworkReachabilityManager sharedManager].isReachableViaWiFi)
        //            RLOG(@"Network reachable via WWAN");
        //        else
        //            RLOG(@"Network reachable via Wifi");
        return YES;
    }
    else {
        RLOG(@"Network is not reachable");
        return NO;
    }
}
+ (id)getJsonObject:(id)responseObject {
    NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    
    if ([jsonString isEqualToString:@"{\"errors\":[{\"code\":\"woocommerce_api_invalid_customer_email\",\"message\":\"Invalid customer email\"}]}"]) {
        RLOG(@"login bug is here");
    }
    if (!([Utility containsString:jsonString substring:@"{"] && [Utility containsString:jsonString substring:@"}"])) {
        RLOG(@"Invalid Json");
        return nil;
    }else {
        NSRange startCurlyBraket = [jsonString rangeOfString:@"{" options:0];
        jsonString = [jsonString substringFromIndex:startCurlyBraket.location];
        NSRange endCurlyBraket = [jsonString rangeOfString:@"}" options:NSBackwardsSearch];
        jsonString = [jsonString substringToIndex:endCurlyBraket.location + 1];
        jsonString = [[jsonString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        return json;
    }
    return nil;
}

+ (id)getJsonArray:(id)responseObject {
    NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    RLOG(@"jsonString2 = %@", jsonString);
    if (!([Utility containsString:jsonString substring:@"["] && [Utility containsString:jsonString substring:@"]"])) {
        RLOG(@"Invalid Json");
        return nil;
    }else {
        NSRange startCurlyBraket = [jsonString rangeOfString:@"[" options:0];
        jsonString = [jsonString substringFromIndex:startCurlyBraket.location];
        NSRange endCurlyBraket = [jsonString rangeOfString:@"]" options:NSBackwardsSearch];
        jsonString = [jsonString substringToIndex:endCurlyBraket.location + 1];
        jsonString = [[jsonString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        return json;
    }
    return nil;
}

+ (NSAttributedString*)createLinkAttributedString:(NSString*)string {
    int fontSize = 3;
    if ([[MyDevice sharedManager] isIpad]) {
        fontSize = 5;
    }
    NSString* fontFace = @"HelveticaNeue-Light";
    //asquared && premihair && groce wheels
    if ([MY_APPID isEqualToString:@"1151746673"] ||
        [MY_APPID isEqualToString:@"1148317682"] ||
        [MY_APPID isEqualToString:@"1172871780"])
    {
        fontFace = @"Futura T OT";
    }
    NSString * htmlString2 = [NSString stringWithFormat:@"<font size=\"%d\" face=\"%@\" color=\"#424242\"><a href=\"change-underline-color.php\" style=\"text-decoration: none; border-bottom: 1px solid #FF0000;\">%@</a>", fontSize, fontFace, string];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        htmlString2 = [NSString stringWithFormat:@"<font size=\"%d\" face=\"%@\" color=\"#424242\"> <a href=\"change-underline-color.php\" style=\"text-decoration: none; border-bottom: 1px solid #FF0000;\">%@</a>", fontSize, fontFace, string];
    }
    NSAttributedString * attrStr2 = [[NSAttributedString alloc] initWithData:[htmlString2 dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    return attrStr2;
}
+ (NSAttributedString*)createUnderlineAttributedString:(NSString*)string {
    int fontSize = 3;
    if ([[MyDevice sharedManager] isIpad]) {
        fontSize = 5;
    }
    NSString* fontFace = @"HelveticaNeue-Light";
    //asquared && premihair && groce wheels
    if ([MY_APPID isEqualToString:@"1151746673"] ||
        [MY_APPID isEqualToString:@"1148317682"] ||
        [MY_APPID isEqualToString:@"1172871780"])
    {
        fontFace = @"Futura T OT";
    }
    NSString * htmlString2 = [NSString stringWithFormat:@"<font size=\"%d\" face=\"%@\" color=\"#424242\"><a href=\"change-underline-color.php\" style=\"text-decoration: none; border-bottom: 1px solid #424242;\">%@</a>", fontSize, fontFace, string];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        htmlString2 = [NSString stringWithFormat:@"<font size=\"%d\" face=\"%@\" color=\"#424242\"> <a href=\"change-underline-color.php\" style=\"text-decoration: none; border-bottom: 1px solid #424242;\">%@</a>", fontSize, fontFace, string];
    }
    NSAttributedString * attrStr2 = [[NSAttributedString alloc] initWithData:[htmlString2 dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    return attrStr2;
}
- (void)checkShowLoginAtStartCondition {
#if ENABLE_LOGIN_AT_HOME
    AppUser* appUser = [AppUser sharedManager];
    Addons* addons = [Addons sharedManager];
    DataManager* dm = [DataManager sharedManager];
    if(appUser._isUserLoggedIn){
    }
    else if (!dm.isShowLoginPopUpHomeScreen && addons.show_login_at_start){
        if (addons.cancellable_login) {
            dm.isShowLoginPopUpHomeScreen = true;
        }
        ViewControllerMain* mainVC = [ViewControllerMain getInstance];
        ViewControllerLeft* leftVC = (ViewControllerLeft*)(mainVC.revealController.rearViewController);
        [leftVC showLoginPopup:true];
    }
#endif
}
- (BOOL)canDevicePlaceAPhoneCall {
    /*
     
     Returns YES if the device can place a phone call
     
     */
    
    // Check if the device can place a phone call
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
        // Device supports phone calls, lets confirm it can place one right now
        CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [netInfo subscriberCellularProvider];
        NSString *mnc = [carrier mobileNetworkCode];
        if (([mnc length] == 0) || ([mnc isEqualToString:@"65535"])) {
            // Device cannot place a call at this time.  SIM might be removed.
            return NO;
        } else {
            // Device can place a phone call
            return YES;
        }
    } else {
        // Device does not support phone calls
        return  NO;
    }
}
static id storyBoardObj = nil;
+ (id)getStoryBoardObject {
    
    @synchronized(self) {
        if (storyBoardObj == nil)
            storyBoardObj = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    }
    return storyBoardObj;
}
+ (id)resetStoryBoardObject {
    storyBoardObj = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    return storyBoardObj;
}
static id vcByIdentifier = nil;
+ (void)resetViewControllersByIdentifier {
    if (vcByIdentifier) {
        [vcByIdentifier removeAllObjects];
    }
    vcByIdentifier = nil;
}
+ (id)getViewControllersByIdentifier {
    
    @synchronized(self) {
        if (vcByIdentifier == nil)
            vcByIdentifier = [NSMutableDictionary dictionary];
    }
    return vcByIdentifier;
}
- (BOOL)isValidEmailId:(NSString*)email {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
+ (BOOL)isMultiStoreApp {
    multiStoreAppEnable = false;
    //check whether app is multistore or not
    {
        NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:@"tmstore" ofType:@"plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathAndFileName])
        {
            NSDictionary *dictRoot = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tmstore" ofType:@"plist"]];
            multiStoreAppEnable = GET_VALUE_BOOL(dictRoot, @"isMultiStore");
            
        }
    }
    return multiStoreAppEnable;
}
+ (BOOL)isNearBySearch {
    nearBySearchEnable = false;
    //check whether app is isNearBySearch or not
    {
        NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:@"tmstore" ofType:@"plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathAndFileName])
        {
            NSDictionary *dictRoot = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tmstore" ofType:@"plist"]];
            nearBySearchEnable = GET_VALUE_BOOL(dictRoot, @"isNearBySearch");

        }
    }
    return nearBySearchEnable;
}
+ (BOOL)isSellerOnlyApp {
    Addons* addons = [Addons sharedManager];
    sellerOnlyAppEnable = addons.enable_seller_only_app;
//#if ENABLE_DEBUGGING
//    return true;
//#endif
    return sellerOnlyAppEnable;
}

+ (BOOL)isMultiStoreAppTMStore {
    multiStoreAppEnableTMStore = false;
    //check whether app is multistore or not
    {
        NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:@"tmstore" ofType:@"plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathAndFileName])
        {
            NSDictionary *dictRoot = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tmstore" ofType:@"plist"]];
            multiStoreAppEnableTMStore = GET_VALUE_BOOL(dictRoot, @"isMultiStoreTMStore");
            
        }
    }
    return multiStoreAppEnableTMStore;
}
+ (NSString *)formattedTimeString:(float)totalMilliSeconds {
    unsigned int totalSeconds = ((unsigned int)totalMilliSeconds) /1000;
    unsigned int seconds = totalSeconds % 60;
    unsigned int minutes = (totalSeconds / 60) % 60;
    unsigned int hours = totalSeconds / 3600;
    if (hours == 0) {
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

- (void)substractButtonClicked:(UIButton*)button {
    ProductInfo* pInfo = (ProductInfo*)[button.layer valueForKey:@"PINFO_OBJ"];
    CCollectionViewCell* cell = (CCollectionViewCell*)[button.layer valueForKey:@"CELL_OBJ"];
    if (pInfo._variations && [pInfo._variations count] > 0) { } else {
        Cart* cInfo = [Cart getCartFromProduct:pInfo variationId:-1 variationIndex:-1];
        if(cInfo.count > 1) {
            cInfo.count -= 1;
        } else {
            [Cart removeProduct:pInfo variationId:-1 variationIndex:-1];
        }
    }
    [cell refreshCell:pInfo];
}
- (void)addButtonClicked:(UIButton*)button {
    ProductInfo* pInfo = (ProductInfo*)[button.layer valueForKey:@"PINFO_OBJ"];
    CCollectionViewCell* cell = (CCollectionViewCell*)[button.layer valueForKey:@"CELL_OBJ"];
    if (pInfo._variations && [pInfo._variations count] > 0) { } else {
        [Cart addProduct:pInfo variationId:-1 variationIndex:-1 selectedVariationAttributes:nil];
    }
    [cell refreshCell:pInfo];
}
- (void)addShowAppInfoGesture:(id)delegate {
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAppInfo:)];
    gesture.numberOfTapsRequired = 1;
    gesture.numberOfTouchesRequired = 4;
    [((UIViewController*)delegate).view addGestureRecognizer:gesture];
}
- (void)showAppInfo:(UITapGestureRecognizer*)gesture {
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSString *receiptURLString = [receiptURL path];
    BOOL isRunningTestFlightBeta =  ([receiptURLString rangeOfString:@"sandboxReceipt"].location != NSNotFound);
    NSString* appStatus = @"Debug";
    if (isRunningTestFlightBeta == false) {
        appStatus = @"Live";
    }
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    
    //    NSLog(@"appInfo = %@", str);
    NSString* stringAppDisplayName = Localize(@"app_display_name");
    if ([stringAppDisplayName isEqualToString:@""] || [stringAppDisplayName isEqualToString:@"app_display_name"]) {
        stringAppDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    }
    NSString* appName = stringAppDisplayName;
    
    
    NSString* str = [NSString stringWithFormat:@"%@\n%@-%@(%@)", appName,appStatus, appVersionString, appBuildString];
    
    
    UIAlertView* appInfoAlert = [[UIAlertView alloc] initWithTitle:str message:@"" delegate:self cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil, nil];
    [appInfoAlert show];
}
+ (UIViewController*)topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}
+ (NSString*)getInitials:(NSString*)fullName limit:(int)limit {
    NSString *src = [NSString stringWithFormat:@"%@", fullName];
    NSString *result = @"";
    @try {
        if ([src length] > limit) {
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^A-Za-z0-9 ]" options:0 error:&error];
            src = [src uppercaseString];
            src = [regex stringByReplacingMatchesInString:src options:0 range:NSMakeRange(0, [src length]) withTemplate:@""];
            NSArray* tokens = [src componentsSeparatedByString:@" "];
            for (int i = 0; i < [tokens count]; i++) {
                if (limit > 0 && i >= limit) {
                    break;
                }
                
                NSString *token = tokens[i];
                if (![token isEqualToString:@""]) {
                    result = [NSString stringWithFormat:@"%@%@", result, [token substringToIndex:1]];
                }
            }
            if ([tokens count] < limit && [src length] > limit) {
                result = [NSString stringWithFormat:@"%@", [src substringToIndex:limit]];
            }
        }else {
            result = [src uppercaseString];
        }
    } @catch (NSException *exception) {
        result = @"NA";
    }
    if ([result isEqualToString:@""]) {
        result = @"NA";
    }
    return result;
}

- (CCollectionViewCell*)setProductCellDataCategoryScreen:(UICollectionView *)collectionView cell:(CCollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath isCategory:(BOOL)isCategory childCount:(int)childCount showFilterdResult:(BOOL)showFilterdResult cInfo:(CategoryInfo*)cInfo nibName:(NSString*)nibName target:(id)target dataSource:(NSMutableArray*)dataSource {
    return [[Utility sharedManager]
            setProductCellDataCategoryScreen:collectionView
            cell:cell
            indexPath:indexPath
            isCategory:isCategory
            childCount:childCount
            showFilterdResult:showFilterdResult
            cInfo:cInfo
            nibName:nibName
            target:target
            dataSource:dataSource
            appliedUserFilter:nil];
}

- (CCollectionViewCell*)setProductCellDataCategoryScreen:(UICollectionView *)collectionView cell:(CCollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath isCategory:(BOOL)isCategory childCount:(int)childCount showFilterdResult:(BOOL)showFilterdResult cInfo:(CategoryInfo*)cInfo nibName:(NSString*)nibName target:(id)target dataSource:(NSMutableArray*)dataSource appliedUserFilter:(UserFilter*)userFilter {
    //    RLOG(@"====***====CELL FOR ITEM AT INDEX PATH = %d", (int)indexPath.row);
    if (isCategory && childCount > 0) {
        if(cell == nil) {
            NSArray *nib = [[ NSBundle mainBundle] loadNibNamed:nibName owner:target options:nil];
            cell = [nib objectAtIndex:0];
        }
        if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_ZIGZAG || [[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY) {
            cell.layer.shadowOpacity = 0.0f;
        } else {
            [Utility showShadow:cell];
        }
        [[cell productDistance] setUIFont:kUIFontType14 isBold:false];
        [[cell productDistance] setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [[cell productName] setUIFont:kUIFontType16 isBold:false];
        [[cell productName] setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [[cell productPriceOriginal] setUIFont:kUIFontType14 isBold:false];
        [[cell productPriceFinal] setUIFont:kUIFontType14 isBold:false];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [[cell productName] setTextAlignment:NSTextAlignmentRight];
            [[cell productPriceOriginal] setTextAlignment:NSTextAlignmentRight];
            [[cell productPriceFinal] setTextAlignment:NSTextAlignmentRight];
            [[cell productDistance] setTextAlignment:NSTextAlignmentRight];

        }
              ProductInfo *pInfo = nil;
        
#if PROMO_ENABLE_IN_SHOW_ALL_VIEWS
        if (indexPath.row >= childCount && [[DataManager sharedManager] promoEnable]) {
            [[cell productName] setText:@""];
            [[cell productPriceOriginal] setText:@""];
            [[cell buttonWishlist] setHidden:true];
            [[cell buttonCart] setHidden:true];
            [[cell productPriceFinal] setText:@""];
            if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_ZIGZAG) {
                [Utility setImageNew:cell.productImg url:[[DataManager sharedManager] promoUrlImgPath] resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL highPriority:true parentCell:cell collectionViewLayout:[collectionView collectionViewLayout] collectionView:collectionView component:indexPath.row indexpath:indexPath vc:target];
                [Utility showShadow:cell];
            }
            else if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY) {
                cell.layer.shadowOpacity = 0.0f;
                [Utility showShadow:cell];
            } else {
                [Utility setImage:cell.productImg url:[[DataManager sharedManager] promoUrlImgPath] resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
            }
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(promoTapped:)];
            singleTap.numberOfTapsRequired = 1;
            singleTap.numberOfTouchesRequired = 1;
            [cell.productImg addGestureRecognizer:singleTap];
            [cell.productImg setUserInteractionEnabled:YES];
        } else
#endif
        {
            if ([dataSource count] > indexPath.row) {
                pInfo = (ProductInfo *)[dataSource objectAtIndex:indexPath.row];
                if (pInfo == nil) {
                    return nil;
                }
            }
            [[cell productName] setText:pInfo._titleForOuterView];
            if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY) {
                CGRect pNFrame = cell.productName.frame;
                [[cell productName] setNumberOfLines:0];
                [[cell productName] sizeToFitUI];
                if (cell.productName.frame.size.height < pNFrame.size.height) {
                    cell.productName.frame = pNFrame;
                }
            }
            [[cell productPriceOriginal] setAttributedText:[pInfo getPriceOldString]];
            [[cell productPriceFinal] setText:[pInfo getPriceNewString]];
            if ([pInfo._images count] == 0) {
                [pInfo._images addObject:[[ProductImage alloc] init]];
            }
            if (([[GuestConfig sharedInstance] hide_price] && ![AppUser isSignedIn]) || [[Addons sharedManager] hide_price]) {
                [[cell productPriceOriginal] setText:@""];
                [[cell productPriceFinal] setText:@""];
                [cell.productPriceOriginal sizeToFitUI];
                [cell.productPriceFinal sizeToFitUI];
            } else {
                [cell.productPriceOriginal sizeToFitUI];
                [cell.productPriceFinal sizeToFitUI];
            }
            ProductImage *pImage = [pInfo._images objectAtIndex:0];
            if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_ZIGZAG) {
                [Utility setImageNew:cell.productImg url:pImage._src resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL highPriority:true parentCell:cell collectionViewLayout:[collectionView collectionViewLayout] collectionView:collectionView component:indexPath.row indexpath:indexPath vc:target];
                cell.layer.shadowOpacity = 0.0f;
                [Utility showShadow:cell];
            } else if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY) {
                cell.layer.shadowOpacity = 0.0f;
                [Utility showShadow:cell];
            } else {
                if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY || [[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_DISCOUNT) {
                    
                } else {
                    [Utility setImage:cell.productImg url:pImage._src resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
                }
            }
            if ([cell buttonWishlist].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"wishlist_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                UIImage* selected = [[UIImage imageNamed:@"wishlist_icon_pressed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [[cell buttonWishlist] setUIImage:normal forState:UIControlStateNormal];
                [[cell buttonWishlist] setUIImage:selected forState:UIControlStateSelected];
            }
            [[cell buttonWishlist] addTarget:[Utility sharedManager] action:@selector(wishlistButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [[cell buttonWishlist] setTag:pInfo._id];
            [[Utility sharedManager] initWishlistButton:[cell buttonWishlist]];
            
            if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY ||
                [[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_DISCOUNT) {
                if ([cell.layer valueForKey:@"UITapGestureRecognizer"]) {
                    [cell removeGestureRecognizer:((UITapGestureRecognizer*)[cell.layer valueForKey:@"UITapGestureRecognizer"])];
                }
                [cell setTag:pInfo._id];
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(bannerTapped:)];
                singleTap.numberOfTapsRequired = 1;
                singleTap.numberOfTouchesRequired = 1;
                [cell addGestureRecognizer:singleTap];
                [singleTap.view.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell setUserInteractionEnabled:YES];
                [cell.layer setValue:singleTap forKey:@"UITapGestureRecognizer"];
                [cell.layer setValue:pInfo._titleForOuterView forKey:@"PNAME"];
            } else {
                if ([cell.productImg.layer valueForKey:@"UITapGestureRecognizer"]) {
                    [cell.productImg removeGestureRecognizer:((UITapGestureRecognizer*)[cell.productImg.layer valueForKey:@"UITapGestureRecognizer"])];
                }
                [cell.productImg setTag:pInfo._id];
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(bannerTapped:)];
                singleTap.numberOfTapsRequired = 1;
                singleTap.numberOfTouchesRequired = 1;
                [cell.productImg addGestureRecognizer:singleTap];
                [singleTap.view.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.productImg setUserInteractionEnabled:YES];
                [cell.productImg.layer setValue:singleTap forKey:@"UITapGestureRecognizer"];
                [cell.productImg.layer setValue:pInfo._titleForOuterView forKey:@"PNAME"];
            }
            
            if ([cell buttonAdd].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.buttonAdd setBackgroundImage:normal forState:UIControlStateNormal];
            }
            if ([cell buttonSubstract].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.buttonSubstract setBackgroundImage:normal forState:UIControlStateNormal];
            }
            
            SellerInfo* sellerInfo = pInfo.sellerInfo;
            cell.productDistance.hidden = YES;
            
            if([[Addons sharedManager] enable_location_in_filters]
               && sellerInfo != nil && sellerInfo.shopLatitude > 0 && sellerInfo.shopLongitude > 0
               && userFilter != nil && userFilter.locationFilter_myLoc_lat > 0 && userFilter.locationFilter_myLoc_lng > 0) {
                CLLocation *locA = [[CLLocation alloc] initWithLatitude:sellerInfo.shopLatitude longitude:sellerInfo.shopLongitude];
                CLLocation *locB = [[CLLocation alloc] initWithLatitude:userFilter.locationFilter_myLoc_lat longitude:userFilter.locationFilter_myLoc_lng];
                cell.productDistance.hidden = NO;
                NSNumber* distance = [NSNumber numberWithDouble:[locA distanceFromLocation:locB] / 1000];
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                formatter.maximumFractionDigits = 2;
                formatter.minimumSignificantDigits = 1;
                 formatter.maximumSignificantDigits = 2;
                [cell.productDistance setText:[NSString stringWithFormat:Localize(@"distance"),[formatter stringFromNumber:distance]]];
                
//                UILabel *LabelDistance = [[UILabel alloc] initWithFrame:CGRectMake(0,(cell.productPriceFinal.frame.origin.y)+10,cell.frame.size.width,20.0)];
                
//                UILabel *LabelDistance = [[UILabel alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width * 0.02f,cell.productPriceFinal.frame.origin.y+65,cell.frame.size.width *0.85f,20.0)];
//               // self.view.frame.size.width * 0.01f
//                [LabelDistance setText:[NSString stringWithFormat:Localize(@"distance"),[formatter stringFromNumber:distance]]];
//                 LabelDistance.hidden = NO;
//                [LabelDistance setBackgroundColor:[UIColor redColor]];
//                 [LabelDistance setUIFont:kUIFontType14 isBold:false];
//                 [LabelDistance setTextColor:[Utility getUIColor:kUIColorFontDark]];
//                 [LabelDistance setTextAlignment:NSTextAlignmentLeft];
//
//
//                
//                [cell addSubview:LabelDistance];
            }
        }
        
        if (pInfo) {
            pInfo.cellObj = cell;
            if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_DISCOUNT){
                if (ENABLE_DISCOUNT_LAYOUT_TYPE1) {
                    [cell.labelProductDescription setNumberOfLines:0];
                }
                
                [cell.labelProductDescription setText:[[pInfo getDescriptionAttributedString] string]];
                UIImage* discountBG = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.imgDiscountBg setImage:discountBG];
                [cell.imgDiscountBg setTintColor:[Utility getUIColor:kUIColorBuyButtonFont]];
                [cell.labelDiscount setTextColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                [cell.imgDiscountBg.layer setBorderColor:[Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor];
                [cell.imgDiscountBg.layer setBorderWidth:1];
//                cell.imgDiscountBg.layer.cornerRadius = cell.imgDiscountBg.frame.size.height/2.0;
                

                if ([[MyDevice sharedManager] isIpad]) {
//                    cell.imgDiscountBg.layer.cornerRadius = 70/2.0;
                    cell.imgDiscountBg.layer.cornerRadius = cell.imgDiscountBg.frame.size.height/2.0;
//                    [cell.labelDiscount setFont:[UIFont systemFontOfSize:16]];
                    [cell.labelDiscount setUIFont:kUIFontType16 isBold:false];
                    [cell.labelDiscount setUIFont:kUIFontType16 isBold:true];


                } else {
//                    cell.imgDiscountBg.layer.cornerRadius = 50/2.0;
                    cell.imgDiscountBg.layer.cornerRadius = cell.imgDiscountBg.frame.size.height/2.0;
//                    [cell.labelDiscount setFont:[UIFont systemFontOfSize:10]];
                    [cell.labelDiscount setUIFont:kUIFontType10 isBold:false];
                    [cell.labelDiscount setUIFont:kUIFontType10 isBold:true];

                }
                
               // [cell.labelDiscount setUIFont:kUIFontType20 isBold:false];
               
                [cell.productPriceOriginal setUIFont:kUIFontType16 isBold:false];
                [cell.productPriceFinal setUIFont:kUIFontType16 isBold:false];
                [cell.productName setUIFont:kUIFontType18 isBold:true];
                [cell.labelProductDescription setUIFont:kUIFontType16 isBold:false];
                [cell.productName setTintColor:[Utility getUIColor:kUIColorBlue]];
                float discountPercent = [pInfo getDiscountPercent:-1];
                if (discountPercent == 0.0f)
                {
                    [cell.imgDiscountBg setHidden:true];
                    [cell.labelDiscount setHidden:true];
                } else {
                    [cell.imgDiscountBg setHidden:false];
                    [cell.labelDiscount setHidden:false];
            
                    [cell.labelDiscount setText:[NSString stringWithFormat:@"%d%% %@", (int)discountPercent, Localize(@"off")]];
                }
                if (ENABLE_DISCOUNT_LAYOUT_TYPE1) {
                    pInfo.cellObj = cell;
                    [cell.labelProductDescription sizeToFitUI];
                    if(cell.btnShowMore){
                        cell.btnShowMore.hidden = true;
                        CGRect btnShowMoreRect = cell.btnShowMore.frame;
                        btnShowMoreRect.size.height = 0;
                        cell.btnShowMore.frame = btnShowMoreRect;
                    }
                }
                if(cell.btnShowMore){
                    [cell.btnShowMore removeTarget:target action:@selector(showMoreClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.btnShowMore addTarget:target action:@selector(showMoreClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.btnShowMore setTag:pInfo._id];
                }
            }
            
            [cell.layer setValue:target forKey:@"VC"];
            [cell.layer setValue:pInfo forKey:@"PRODUCT_INFO"];
            [cell.layer setValue:pInfo forKey:@"PINFO_OBJ"];
            [cell.buttonAdd.layer setValue:pInfo forKey:@"PINFO_OBJ"];
            [cell.buttonAdd.layer setValue:cell forKey:@"CELL_OBJ"];
            [cell.buttonCart.layer setValue:pInfo forKey:@"PINFO_OBJ"];
            [cell.buttonCart setTitle:Localize(@"toggle_cart_on") forState:UIControlStateNormal];
            [cell.buttonCart.layer setValue:cell forKey:@"CELL_OBJ"];
            [cell.buttonSubstract.layer setValue:pInfo forKey:@"PINFO_OBJ"];
            [cell.buttonSubstract.layer setValue:cell forKey:@"CELL_OBJ"];
            [cell.textFieldAmt.layer setValue:pInfo forKey:@"PINFO_OBJ"];
            [cell.textFieldAmt.layer setValue:cell forKey:@"CELL_OBJ"];
            [cell.buttonCart addTarget:target action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.buttonAdd addTarget:target action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.buttonSubstract addTarget:target action:@selector(substractButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [cell.layer setValue:nil forKey:@"PRODUCT_INFO"];
            [cell.layer setValue:nil forKey:@"PINFO_OBJ"];
        }
        
        
        switch ([[DataManager sharedManager] layoutIdProductView]) {
            case P_LAYOUT_DEFAULT:
                break;
            case P_LAYOUT_FULL_ICON_BUTTON:
                break;
            case P_LAYOUT_GROCERY:
            {
                if (cell.buttonCart.imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                    UIImage* normal = [[UIImage imageNamed:@"button_square"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    [cell.buttonCart setBackgroundImage:normal forState:UIControlStateNormal];
                    [cell.buttonCart setShowsTouchWhenHighlighted:true];
                }
                if ([cell buttonAdd].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                    UIImage* normal = [[UIImage imageNamed:@"button_square"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    [cell.buttonAdd setBackgroundImage:normal forState:UIControlStateNormal];
                    [cell.buttonAdd setShowsTouchWhenHighlighted:true];
                }
                if ([cell buttonSubstract].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                    UIImage* normal = [[UIImage imageNamed:@"button_square"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    [cell.buttonSubstract setBackgroundImage:normal forState:UIControlStateNormal];
                }
                
                cell.backgroundColor = [UIColor whiteColor];
                cell.productImg.hidden = true;
                cell.productImgDummy.hidden = true;
                cell.productPriceOriginal.hidden = true;
                cell.buttonWishlist.hidden = true;
                cell.buttonWishlist.enabled = false;
                cell.productPriceFinal.hidden = false;
                cell.productName.hidden = false;
                cell.buttonCart.hidden = false;
                cell.buttonCart.enabled = true;
                [cell.buttonCart setTitle:@"+" forState:UIControlStateNormal];
                cell.viewAddToCart.backgroundColor = [UIColor clearColor];
                [cell.buttonCart.imageView setContentMode:UIViewContentModeScaleAspectFit];
                [cell.buttonAdd.imageView setContentMode:UIViewContentModeScaleAspectFit];
                [cell.buttonCart setContentMode:UIViewContentModeScaleAspectFit];
                [cell.buttonAdd setContentMode:UIViewContentModeScaleAspectFit];
                
                
                
                float oldHeight = cell.frame.size.height;
                float newHeight = MAX(75, cell.productName.frame.size.height + 20);
                {
                    CGRect cellRect = cell.frame;
                    cellRect.size.height = newHeight;
                    if ([[MyDevice sharedManager] isLandscape]) {
                        pInfo.updatedCardSizeL = cellRect.size;
                    } else {
                        pInfo.updatedCardSizeP = cellRect.size;
                    }
                    cell.frame = cellRect;
                    cell.layer.shadowOpacity = 0.0f;
                    [Utility showShadow:cell];
                }
                [collectionView.collectionViewLayout invalidateLayout];
                [collectionView layoutIfNeeded];
            }break;
            case P_LAYOUT_DISCOUNT:
            {
                if (cell.buttonCart.imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                    UIImage* normal = [[UIImage imageNamed:@"button_square"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    [cell.buttonCart setBackgroundImage:normal forState:UIControlStateNormal];
                    [cell.buttonCart setShowsTouchWhenHighlighted:true];
                }
                if ([cell buttonAdd].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                    UIImage* normal = [[UIImage imageNamed:@"button_square"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    [cell.buttonAdd setBackgroundImage:normal forState:UIControlStateNormal];
                    [cell.buttonAdd setShowsTouchWhenHighlighted:true];
                }
                if ([cell buttonSubstract].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                    UIImage* normal = [[UIImage imageNamed:@"button_square"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    [cell.buttonSubstract setBackgroundImage:normal forState:UIControlStateNormal];
                }
                
                cell.backgroundColor = [UIColor whiteColor];
                cell.productImg.hidden = true;
                cell.productImgDummy.hidden = true;
                cell.productPriceOriginal.hidden = true;
                cell.buttonWishlist.hidden = true;
                cell.buttonWishlist.enabled = false;
                cell.productPriceFinal.hidden = false;
                cell.productName.hidden = false;
                cell.buttonCart.hidden = false;
                cell.buttonCart.enabled = true;
                [cell.buttonCart setTitle:@"+" forState:UIControlStateNormal];
                cell.viewAddToCart.backgroundColor = [UIColor clearColor];
                [cell.buttonCart.imageView setContentMode:UIViewContentModeScaleAspectFit];
                [cell.buttonAdd.imageView setContentMode:UIViewContentModeScaleAspectFit];
                [cell.buttonCart setContentMode:UIViewContentModeScaleAspectFit];
                [cell.buttonAdd setContentMode:UIViewContentModeScaleAspectFit];
                if (ENABLE_DISCOUNT_LAYOUT_TYPE1) {
                    float newHeight = 10 + cell.productName.frame.size.height + 10 + cell.labelProductDescription.frame.size.height + 0 + cell.btnShowMore.frame.size.height + 10 + cell.imgDiscountBg.frame.size.height + 10;
                    CGRect cellRect = cell.frame;
                    cellRect.size.height = newHeight;
                    if ([[MyDevice sharedManager] isLandscape]) {
                        pInfo.updatedCardSizeL = cellRect.size;
                    } else {
                        pInfo.updatedCardSizeP = cellRect.size;
                    }
                    cell.frame = cellRect;
                    cell.layer.shadowOpacity = 0.0f;
                    [Utility showShadow:cell];
                    [collectionView.collectionViewLayout invalidateLayout];
                    [collectionView layoutIfNeeded];
                }
            }
                break;
            case P_LAYOUT_FULL_RECT_BUTTON:
                [cell.buttonWishlist setImage:nil forState:UIControlStateNormal];
                [cell.buttonWishlist setImage:nil forState:UIControlStateSelected];
                [cell.buttonWishlist setImage:nil forState:UIControlStateHighlighted];
                
                cell.buttonWishlist.backgroundColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
                [cell.buttonWishlist.titleLabel setTextColor:[Utility getUIColor:kUIColorBuyButtonFont]];
                if ([[MyDevice sharedManager] isIpad]) {
                    [cell.buttonWishlist.titleLabel setUIFont:kUIFontType14 isBold:false];
                }else{
                    [cell.buttonWishlist.titleLabel setUIFont:kUIFontType14 isBold:true];
                }
                [cell.buttonWishlist.titleLabel setTextAlignment:NSTextAlignmentCenter];
                [cell.buttonWishlist setAttributedTitle:[[NSAttributedString alloc] initWithString:Localize(@"toggle_wishlist_on")] forState:UIControlStateNormal];
                [cell.buttonWishlist setAttributedTitle:[[NSAttributedString alloc] initWithString:Localize(@"toggle_wishlist_off")] forState:UIControlStateSelected];
                
                break;
            case P_LAYOUT_ZIGZAG:
                break;
            default:
                break;
        }
    }
    
    
    
    return cell;
}

- (CGSize)getProductCellSizeCategoryScreen:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath propCollectionView:(LayoutProperties*)propCollectionView showFilterdResult:(BOOL)showFilterdResult cInfo:(CategoryInfo*)cInfo dataSource:(NSMutableArray*)dataSource {
    NSMutableArray *array = [LayoutProperties CardPropertiesForProductView];
    float cardHorizontalSpacing = [[array objectAtIndex:0] floatValue];
    float cardVerticalSpacing = [[array objectAtIndex:1] floatValue];
    float cardWidth = [[array objectAtIndex:2] floatValue];
    float cardHeight = [[array objectAtIndex:3] floatValue];
    float insetLeft = [[array objectAtIndex:4] floatValue];
    float insetRight = [[array objectAtIndex:5] floatValue];
    float insetTop = [[array objectAtIndex:6] floatValue];
    float insetBottom = [[array objectAtIndex:7] floatValue];
    collectionView.contentInset = UIEdgeInsetsMake(insetTop, insetLeft, insetBottom, insetRight);
    
    if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_ZIGZAG ||
        [[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY) {
        CHTCollectionViewWaterfallLayout *layout = (CHTCollectionViewWaterfallLayout *)[collectionView collectionViewLayout];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [layout setMinimumColumnSpacing:cardHorizontalSpacing];
        [layout setMinimumInteritemSpacing:cardVerticalSpacing];
        propCollectionView._insetTop = insetTop;
        propCollectionView._insetLeft = 0;
        propCollectionView._insetBottom = insetBottom;
        propCollectionView._insetRight = 0;
    } else {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[collectionView collectionViewLayout];
        layout.minimumInteritemSpacing = cardHorizontalSpacing;
        layout.minimumLineSpacing = cardVerticalSpacing;
        propCollectionView._insetTop =  insetTop;
        propCollectionView._insetLeft =  insetLeft;
        propCollectionView._insetBottom =  insetBottom;
        propCollectionView._insetRight =  insetRight;
    }
    
    CGSize cardSize = CGSizeMake(cardWidth, cardHeight);
    
    BOOL isCardSizeUpdated = false;
    if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_ZIGZAG ||
        [[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY ) {
        if ((int)[dataSource count] >indexPath.row) {
            ProductInfo *pInfo = (ProductInfo *)[dataSource objectAtIndex:indexPath.row];
            if (pInfo) {
                if ([[MyDevice sharedManager] isLandscape]) {
                    if (pInfo.updatedCardSizeL.width != 0 ) {
                        cardSize = pInfo.updatedCardSizeL;
                        isCardSizeUpdated = true;
                    }
                } else {
                    if (pInfo.updatedCardSizeP.width != 0 ) {
                        cardSize = pInfo.updatedCardSizeP;
                        isCardSizeUpdated = true;
                    }
                }
            }
        }
    }
    if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_DISCOUNT) {
        if (ENABLE_DISCOUNT_LAYOUT_TYPE1) {
            if ((int)[dataSource count] >indexPath.row) {
                ProductInfo *pInfo = (ProductInfo *)[dataSource objectAtIndex:indexPath.row];
                if (pInfo) {
                    CCollectionViewCell *cell=(CCollectionViewCell *)(pInfo.cellObj);
                    if(cell) {
                        float newHeight = 10 + cell.productName.frame.size.height + 10 + cell.labelProductDescription.frame.size.height + 0 + cell.btnShowMore.frame.size.height + 10 + cell.imgDiscountBg.frame.size.height + 10;
                        CGRect cellRect = cell.frame;
                        cellRect.size.height = newHeight;
                        cell.frame = cellRect;
                        cell.layer.shadowOpacity = 0.0f;
                        [Utility showShadow:cell];
                        cardSize = cell.frame.size;
                    }
                }
            }
        }
    }
    
    if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_ZIGZAG ||
        [[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY) {
        if(isCardSizeUpdated)
        {
            CCollectionViewCell *cell=(CCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
            if (cell) {
                cell.layer.shadowOpacity = 0.0f;
                [Utility showShadow:cell];
            }
        }
    }
    return cardSize;
}
- (id)initProductCellCategoryScreen:(UICollectionView*)viewUserDefined propCollectionView:(LayoutProperties*)propCollectionView layout:(UICollectionViewFlowLayout *)layout nibName:(NSString*)nibName{
    if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_ZIGZAG) {
        CHTCollectionViewWaterfallLayout *layoutNew = [[CHTCollectionViewWaterfallLayout alloc] init];
        layoutNew.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layoutNew.minimumColumnSpacing = 20;
        layoutNew.minimumInteritemSpacing = 30;
        if ([[MyDevice sharedManager] isIphone]) {
            layoutNew.columnCount = 2;
        } else {
            if ([[MyDevice sharedManager] isLandscape]) {
                layoutNew.columnCount = 4;
            } else {
                layoutNew.columnCount = 3;
            }
        }
        viewUserDefined = [[UICollectionView alloc] initWithFrame:[propCollectionView getFrameRect] collectionViewLayout:layoutNew];
        [viewUserDefined setAlwaysBounceVertical:true];
        [viewUserDefined setAlwaysBounceHorizontal:false];
        [viewUserDefined setDirectionalLockEnabled:true];
        viewUserDefined.showsHorizontalScrollIndicator = false;
        PRINT_RECT_STR(@"_viewUserDefinedFrame = ", viewUserDefined.frame);
    }
    else if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY) {
        CHTCollectionViewWaterfallLayout *layoutNew = [[CHTCollectionViewWaterfallLayout alloc] init];
        layoutNew.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layoutNew.minimumColumnSpacing = 0;
        layoutNew.minimumInteritemSpacing = 0;
        
        if ([[MyDevice sharedManager] isIphone]) {
            layoutNew.columnCount = 1;
        } else {
            if ([[MyDevice sharedManager] isLandscape]) {
                layoutNew.columnCount = 1;
            } else {
                layoutNew.columnCount = 1;
            }
        }
        viewUserDefined = [[UICollectionView alloc] initWithFrame:[propCollectionView getFrameRect] collectionViewLayout:layoutNew];
        [viewUserDefined setAlwaysBounceVertical:true];
        [viewUserDefined setAlwaysBounceHorizontal:false];
        [viewUserDefined setDirectionalLockEnabled:true];
        viewUserDefined.showsHorizontalScrollIndicator = false;
        
        PRINT_RECT_STR(@"_viewUserDefinedFrame = ", viewUserDefined.frame);
    }
    else{
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        viewUserDefined = [[UICollectionView alloc] initWithFrame:[propCollectionView getFrameRect] collectionViewLayout:layout];
        
    }
    
    [viewUserDefined registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellWithReuseIdentifier:@"CollectionCell"];
    return viewUserDefined;
}
- (void)initWishlistButton:(UIButton*)button {
    ProductInfo* pInfo = [ProductInfo getProductWithId:(int)[button tag]];
    BOOL itemIsInWishlist = [Wishlist hasItem:pInfo];
    if (itemIsInWishlist) {
        [button setSelected:true];
        [button setTintColor:[Utility getUIColor:kUIColorWishlistSelected]];
    }else{
        [button setSelected:false];
        [button setTintColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
    }
}
- (void)wishlistButtonClicked:(UIButton*)button {
    int productId = (int)[button tag];
    ProductInfo* pInfo = [ProductInfo getProductWithId:productId];
    BOOL itemIsInWishlist = [Wishlist hasItem:pInfo];
    if (itemIsInWishlist) {
        RLOG(@"Button Clicked:removeFormWishlist");
        [button setSelected:false];
        [button setTintColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
        [Wishlist removeProduct:pInfo productId:productId variationId:-1];
    }else{
        RLOG(@"Button Clicked:addToWishlist");
        [button setSelected:true];
        [button setTintColor:[Utility getUIColor:kUIColorWishlistSelected]];
        [Wishlist addProduct:pInfo];
    }
}
+ (NSString*)getAppName {
    NSString* stringAppDisplayName = Localize(@"app_display_name");
    if ([stringAppDisplayName isEqualToString:@""] || [stringAppDisplayName isEqualToString:@"app_display_name"]) {
        stringAppDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    }
    NSString* appName = stringAppDisplayName;
    return appName;
}

+ (long) getCurrentMilliseconds {
    return (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970]) * 1000;
}

@end
