//
//  DLFiller.m
//  TMStore
//
//  Created by Rishabh Jain on 19/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "DLFiller.h"
#import "DLManager.h"
#import "UIImageView+WebCache.h"
#import <SDWebImage/UIView+WebCache.h>
#import "UIImageView+AFNetworking.h"
#import "ProductCollectionViewCell.h"
#import "DynamicCellCategory.h"
#import "ProductInfo.h"
#import "ProductImage.h"
#import "AppUser.h"
#import "DataManager.h"
#import "AnalyticsHelper.h"
#import "ViewControllerHomeDynamic.h"
#import "DynamicViewAll.h"
#import "ViewDynamicHeader.h"
#import "ViewDynamicVAll.h"
#import "ViewControllerWebview.h"

static CGSize productCellSize;
static float productCellHSpacing;
static float productCellVSpacing;

#define MAX_CATEGORY_PRODUCTS_TO_SHOW_COUNT 10

@interface MyPair: NSObject
@property UIView* view;
@property float eHeight;
@property float posY;
@property float newPosY;

@end
@implementation MyPair



@end
@implementation DLFiller
+ (id)getInstance {
    static DLFiller *dlFiller = nil;
    @synchronized(self) {
        if (dlFiller == nil)
            dlFiller = [[self alloc] init];
    }
    return dlFiller;
}
- (id)init {
    if (self = [super init]) {

        self.dlManager = [[DLManager sharedManager] initializeDLManager];
    }
    return self;
}
- (CGSize)getProductCellSize {
    if (productCellSize.width == 0 && productCellSize.height == 0) {
        NSMutableArray* array = [LayoutProperties CardPropertiesForHorizontalView];
        float cardWidth = [[array objectAtIndex:2] floatValue];
        float cardHeight = [[array objectAtIndex:3] floatValue];
        productCellSize = CGSizeMake(cardWidth * 1.33f, cardHeight * 1.33f);
    }
    return productCellSize;
}
- (float)getProductCellHSpacing {
    if (productCellHSpacing == 0) {
        NSMutableArray* array = [LayoutProperties CardPropertiesForHorizontalView];
        float cardHorizontalSpacing = [[array objectAtIndex:0] floatValue];
        productCellHSpacing = cardHorizontalSpacing;
    }
    return productCellHSpacing;
}
- (float)getProductCellVSpacing {
    if (productCellVSpacing == 0) {
        NSMutableArray* array = [LayoutProperties CardPropertiesForHorizontalView];
        float cardVerticalSpacing = [[array objectAtIndex:1] floatValue];
        productCellVSpacing = cardVerticalSpacing;
    }
    return productCellVSpacing;
}
- (void)fillWithData:(NSMutableArray*)dlObjects scrollView:(UIScrollView*)scrollView delegate:(id)delegate {
    [scrollView.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    self.allHCorrousals = [[NSMutableArray alloc] init];
    self.allVCorrousals = [[NSMutableArray alloc] init];
    float tileW = [self.dlManager getTileSize].width;
    float tileH = [self.dlManager getTileSize].height;
    if(dlObjects && [dlObjects count] > 0) {
        for (DLObject* dlObject in dlObjects) {
            UIView* viewDynamic = [[UIView alloc] init];
            dlObject.dView = viewDynamic;
            [viewDynamic setFrame:CGRectMake(
                                             dlObject.col * tileW,
                                             dlObject.row * tileH ,//+ self.vCorrousalExtraHeight,
                                             tileW * dlObject.size_x,
                                             tileH * dlObject.size_y
                                             )];
            //[viewDynamic setBackgroundColor:dlObject.variable.tileStyle.bgColor];
            [viewDynamic setBackgroundColor:[UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f]];
            if (dlObject.variable) {
                switch (dlObject.variable.tileType) {
                    case DL_TILE_TYPE_PRODUCT:
                    {
                        NSMutableArray *arrayDLContent = dlObject.variable.content;
                        PagedImageScrollView* _vviewBanner = [[PagedImageScrollView alloc] initWithFrame:CGRectMake(0, 0, viewDynamic.frame.size.width, viewDynamic.frame.size.height)];
                        NSMutableArray* imageViewArray = [[NSMutableArray alloc] init];

                        for (int i= 0; i < arrayDLContent.count; i++) {
                            UIImageView *imageBanner = [[UIImageView alloc]init];
                            NSString *str = [[dlObject.variable.content objectAtIndex:i] imgUrl];
                            //                            [imageBanner setImageWithURL:[NSURL URLWithString:str]];
                            [Utility setImage:imageBanner url:str resizeType:0 isLocal:false highPriority:true];
                            [imageViewArray addObject:imageBanner];

                            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(redirectPageForProducts:)];
                            [viewDynamic addGestureRecognizer:tap];
                            [viewDynamic.layer setValue:dlObject.variable forKey:@"CV_DLVariable"];
                            [viewDynamic.layer setValue:[dlObject.variable.content objectAtIndex:i] forKey:@"Category_DLContent"];

                        }
                        if ([imageViewArray count] > 0) {
                            [_vviewBanner setScrollViewContentsWithImageViews:imageViewArray contentMode:UIViewContentModeScaleToFill];
                            [_vviewBanner reloadView:CGRectMake(0, 0, viewDynamic.frame.size.width, viewDynamic.frame.size.height-10)];
                            [_vviewBanner enableBannerChangeAutomatically];
                            [viewDynamic addSubview:_vviewBanner];
                        }
                    } break;
                    case DL_TILE_TYPE_CARROUSAL_HORIZONTAL:{
                        if (dlObject.variable) {
                            switch (dlObject.variable.scrollerFor) {
                                case DL_SCROLL_FOR_PRODUCT:{
                                    dlObject.variable.dataSourceProducts = [dlObject.variable getContentProducts];

                                    NSMutableArray* pIds = [[NSMutableArray alloc] init];
                                    for (ProductInfo* pInfo in dlObject.variable.dataSourceProducts) {
                                        [pIds addObject:[NSNumber numberWithInt:pInfo._id]];
                                    }
                                    [[[DataManager sharedManager] tmDataDoctor] fetchProductsFullDataFromPlugin:pIds success:^(id data) {
                                        if ([data isKindOfClass:[NSDictionary class]]) {
                                            NSDictionary* dataDict = data;
                                            dlObject.variable.dataSourceProducts = [[NSMutableArray alloc] init];
                                            if ([dataDict allValues] && [[dataDict allValues] count] > 0) {
                                                if([[[dataDict allValues] objectAtIndex:0] isKindOfClass:[ProductInfo class]]) {
                                                    dlObject.variable.dataSourceProducts = [[NSMutableArray alloc] initWithArray:[dataDict allValues]];
                                                }
                                            }
                                        } else {
                                            dlObject.variable.dataSourceProducts = data;
                                        }
                                        UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc] init];
                                        UICollectionView* cvHorizontalCategory = [[Utility sharedManager] initProductCellCategoryScreen:cvHorizontalCategory propCollectionView:[[LayoutProperties alloc] initWithCollectionViewValues:SCROLL_TYPE_SHOWFULL] layout:layout nibName:[[Utility sharedManager] getHorizontalViewString]];
                                        layout.sectionInset = UIEdgeInsetsMake(10, 10, 15, 15);

                                        cvHorizontalCategory.frame = CGRectMake(0, 0, viewDynamic.frame.size.width, viewDynamic.frame.size.height);

                                        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                                        [cvHorizontalCategory setDataSource:self];
                                        [cvHorizontalCategory setDelegate:self];
                                        [cvHorizontalCategory setShowsHorizontalScrollIndicator:true];
                                        [cvHorizontalCategory setScrollEnabled:YES];
                                        [cvHorizontalCategory setBounces:YES];
                                        [cvHorizontalCategory setAlwaysBounceHorizontal:YES];
                                        [cvHorizontalCategory setBackgroundColor:[UIColor clearColor]];
                                        [viewDynamic addSubview:cvHorizontalCategory];
                                        [cvHorizontalCategory.layer setValue:dlObject.variable forKey:@"CV_DLVariable"];
                                        [cvHorizontalCategory reloadData];
                                        [self.allHCorrousals addObject:cvHorizontalCategory];
                                    } failure:^{

                                    }];
                                }break;
                                case DL_SCROLL_FOR_CATEGORIES:{
                                    dlObject.variable.dataSourceProducts = [dlObject.variable getContentCategories];
                                    if (dlObject.variable.content == nil || dlObject.variable.content.count == 0) {
                                        dlObject.variable.dataSourceProducts = [CategoryInfo getAll];
                                    }
                                    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
                                    UICollectionView* cvHorizontal = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, viewDynamic.frame.size.width, viewDynamic.frame.size.height) collectionViewLayout:flowLayout];
                                    UINib *nib2 = [UINib nibWithNibName:@"DynamicCellCategoryType1" bundle:nil];
                                    [cvHorizontal registerNib:nib2 forCellWithReuseIdentifier:@"CategoryCellBelowName"];
                                    // flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 15, 15);
                                    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                                    [cvHorizontal setDataSource:self];
                                    [cvHorizontal setDelegate:self];
                                    [cvHorizontal setShowsHorizontalScrollIndicator:true];
                                    [cvHorizontal setScrollEnabled:YES];
                                    [cvHorizontal setBounces:YES];
                                    [cvHorizontal setAlwaysBounceHorizontal:YES];
                                    [cvHorizontal setBackgroundColor:dlObject.variable.tileStyle.bgColor];
                                    [cvHorizontal.layer setValue:dlObject.variable forKey:@"CV_DLVariable"];
                                    [viewDynamic addSubview:cvHorizontal];
                                    [self.allHCorrousals addObject:cvHorizontal];

                                }break;
                                case DL_SCROLL_FOR_CATEGORY:{
                                    int categoryId = 999999999;
                                    if (dlObject.variable.scrollerIds && [dlObject.variable.scrollerIds count] == 1) {
                                        categoryId = [[dlObject.variable.scrollerIds objectAtIndex:0] intValue];
                                    }

                                    switch (categoryId) {
                                        case DL_PROMOTIONAL_IDS_TRENDING:{
                                            dlObject.variable.dataSourceProducts = [ProductInfo getProducts:@"" isAscending:YES viewType:kHV_TYPES_TRENDINGS];
                                        }
                                            break;
                                        case DL_PROMOTIONAL_IDS_BESTDEALS:{
                                            dlObject.variable.dataSourceProducts = [ProductInfo getProducts:@"" isAscending:NO viewType:kHV_TYPES_BESTSELLINGS];
                                        }
                                            break;
                                        case DL_PROMOTIONAL_IDS_FRESHARRIVALS:{
                                            dlObject.variable.dataSourceProducts = [ProductInfo getProducts:@"" isAscending:NO viewType:kHV_TYPES_NEWARRIVALS];
                                        }
                                            break;
                                        case DL_PROMOTIONAL_IDS_RECENTLY_VIEWED:{
                                            dlObject.variable.dataSourceProducts = [ProductInfo getProducts:@"" isAscending:NO viewType:kHV_TYPES_TRENDINGS];
                                        }
                                            break;
                                        default:
                                            break;
                                    }

                                    if(categoryId > -1) {
                                        ViewDynamicVAll *vAll = [[[NSBundle mainBundle] loadNibNamed:@"ViewDynamicVAll" owner:self options:nil] objectAtIndex:0];
                                        vAll.frame = CGRectMake(0, 0, viewDynamic.frame.size.width, 53);
                                        vAll.labelHeader.text =dlObject.variable.tileTitle;
                                        [vAll.buttonVAll.layer setValue:dlObject.variable forKey:@"CV_DLVariable"];
                                        [vAll.buttonVAll addTarget:self action:@selector(buttonViewAllAction:) forControlEvents:UIControlEventTouchUpInside];
                                        [viewDynamic addSubview:vAll];

                                        float contentSizeH = viewDynamic.frame.size.height;
                                        int lineCount = 1;
                                        CGSize productCellSize = [self getProductCellSize];
                                        contentSizeH = lineCount * productCellSize.height + (lineCount+1) * [self getProductCellVSpacing] + 50;
                                        float oldHViewDynamic = viewDynamic.frame.size.height;
                                        CGRect rectVD = viewDynamic.frame;
                                        rectVD.size.height = contentSizeH;
                                        viewDynamic.frame = rectVD;
                                        float newHViewDynamic = viewDynamic.frame.size.height;

                                        dlObject.extraH = (newHViewDynamic - oldHViewDynamic);
                                        self.vCorrousalExtraHeight += (newHViewDynamic - oldHViewDynamic);
                                        vAll.frame = CGRectMake(0, 0, viewDynamic.frame.size.width, 53);


                                        [[[DataManager sharedManager] tmDataDoctor] fetchCategoriesDataNew:categoryId count:dlObject.variable.scrollerCount success:^(id data) {
                                            dlObject.variable.dataSourceProducts = data;

                                            UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc] init];
                                            UICollectionView* cvHorizontalCategory = [[Utility sharedManager] initProductCellCategoryScreen:cvHorizontalCategory propCollectionView:[[LayoutProperties alloc] initWithCollectionViewValues:SCROLL_TYPE_SHOWFULL] layout:layout nibName:[[Utility sharedManager] getHorizontalViewString]];
                                            layout.sectionInset = UIEdgeInsetsMake(10, 10, 15, 15);
                                            cvHorizontalCategory.frame = CGRectMake(0, 0, viewDynamic.frame.size.width, viewDynamic.frame.size.height);


                                            float contentSizeH = viewDynamic.frame.size.height;
                                            int lineCount = 1;
                                            CGSize productCellSize = [self getProductCellSize];
                                            contentSizeH = lineCount * productCellSize.height + (lineCount+1) * [self getProductCellVSpacing] + 50;
                                            float oldHViewDynamic = viewDynamic.frame.size.height;
                                            CGRect rectVD = viewDynamic.frame;
                                            rectVD.size.height = contentSizeH;
                                            viewDynamic.frame = rectVD;
                                            float newHViewDynamic = viewDynamic.frame.size.height;
                                            CGRect rectCV = cvHorizontalCategory.frame;
                                            rectCV.size.height = contentSizeH - 50;
                                            rectCV.origin.y = 50;
                                            cvHorizontalCategory.frame = rectCV;
                                            [self.allHCorrousals addObject:cvHorizontalCategory];

                                            vAll.frame = CGRectMake(0, 0, viewDynamic.frame.size.width, 53);

                                            [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                                            [cvHorizontalCategory setDataSource:self];
                                            [cvHorizontalCategory setDelegate:self];
                                            [cvHorizontalCategory setShowsHorizontalScrollIndicator:true];
                                            [cvHorizontalCategory setScrollEnabled:YES];
                                            [cvHorizontalCategory setBounces:YES];
                                            [cvHorizontalCategory setAlwaysBounceHorizontal:YES];
                                            [cvHorizontalCategory setBackgroundColor:dlObject.variable.tileStyle.bgColor];
                                            [cvHorizontalCategory setClipsToBounds:true];
                                            [viewDynamic addSubview:cvHorizontalCategory];
                                            [cvHorizontalCategory.layer setValue:dlObject.variable forKey:@"CV_DLVariable"];
                                            [cvHorizontalCategory reloadData];
                                            [self.allHCorrousals addObject:cvHorizontalCategory];

                                        } failure:^(NSString *error) {

                                        }];
                                    }
                                    else {
                                        UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc] init];
                                        UICollectionView* cvHorizontalCategory = [[Utility sharedManager] initProductCellCategoryScreen:cvHorizontalCategory propCollectionView:[[LayoutProperties alloc] initWithCollectionViewValues:SCROLL_TYPE_SHOWFULL] layout:layout nibName:[[Utility sharedManager] getHorizontalViewString]];
                                        layout.sectionInset = UIEdgeInsetsMake(10, 10, 15, 15);

                                        cvHorizontalCategory.frame = CGRectMake(0, 0, viewDynamic.frame.size.width, viewDynamic.frame.size.height);

                                        ViewDynamicVAll *vAll = [[[NSBundle mainBundle] loadNibNamed:@"ViewDynamicVAll" owner:self options:nil] objectAtIndex:0];
                                        vAll.frame = CGRectMake(0, 0, viewDynamic.frame.size.width, 53);
                                        vAll.labelHeader.text =dlObject.variable.tileTitle;
                                        [vAll.buttonVAll.layer setValue:dlObject.variable forKey:@"CV_DLVariable"];
                                        [vAll.buttonVAll addTarget:self action:@selector(buttonViewAllAction:) forControlEvents:UIControlEventTouchUpInside];
                                        [viewDynamic addSubview:vAll];

                                        float contentSizeH = viewDynamic.frame.size.height;
                                        int lineCount = 1;
                                        CGSize productCellSize = [self getProductCellSize];
                                        contentSizeH = lineCount * productCellSize.height + (lineCount+1) * [self getProductCellVSpacing] + 50;
                                        float oldHViewDynamic = viewDynamic.frame.size.height;
                                        CGRect rectVD = viewDynamic.frame;
                                        rectVD.size.height = contentSizeH;
                                        viewDynamic.frame = rectVD;
                                        float newHViewDynamic = viewDynamic.frame.size.height;
                                        CGRect rectCV = cvHorizontalCategory.frame;
                                        rectCV.size.height = contentSizeH - 50;
                                        rectCV.origin.y = 50;
                                        cvHorizontalCategory.frame = rectCV;
                                        dlObject.extraH = (newHViewDynamic - oldHViewDynamic);
                                        self.vCorrousalExtraHeight += (newHViewDynamic - oldHViewDynamic);
                                        [self.allHCorrousals addObject:cvHorizontalCategory];

                                        vAll.frame = CGRectMake(0, 0, viewDynamic.frame.size.width, 53);
                                        if ([dlObject.variable.tileTitle  isEqual: @""]) {
                                            vAll.frame = CGRectMake(0,0,0,0);
                                        }

                                        if (dlObject.variable.tileType == 4) {
                                            [vAll.buttonVAll setTitle:@"" forState:UIControlStateNormal];
                                            vAll.buttonVAll.titleLabel.text = @"";

                                        }
                                        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                                        [cvHorizontalCategory setDataSource:self];
                                        [cvHorizontalCategory setDelegate:self];
                                        [cvHorizontalCategory setShowsHorizontalScrollIndicator:true];
                                        [cvHorizontalCategory setScrollEnabled:YES];
                                        [cvHorizontalCategory setBounces:YES];
                                        [cvHorizontalCategory setAlwaysBounceHorizontal:YES];
                                        [cvHorizontalCategory setBackgroundColor:dlObject.variable.tileStyle.bgColor];
                                        [viewDynamic addSubview:cvHorizontalCategory];
                                        [cvHorizontalCategory.layer setValue:dlObject.variable forKey:@"CV_DLVariable"];
                                        [cvHorizontalCategory reloadData];
                                        [self.allHCorrousals addObject:cvHorizontalCategory];
                                    }
                                }break;
                                case DL_SCROLL_FOR_PROMOTIONAL:{
                                }break;
                                case DL_SCROLL_FOR_VENDOR:{
                                }break;
                                default:
                                    break;
                            }
                        }
                    }break;
                    case DL_TILE_TYPE_CARROUSAL_VERTICAL:
                    {

                        UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc] init];
                        UICollectionView* cvVertical = [[Utility sharedManager] initProductCellCategoryScreen:cvVertical propCollectionView:[[LayoutProperties alloc] initWithCollectionViewValues:SCROLL_TYPE_SHOWFULL] layout:layout nibName:[[Utility sharedManager] getHorizontalViewString]];
                        layout.sectionInset = UIEdgeInsetsMake(10, 10, 15, 15);
                        [cvVertical setDataSource:self];
                        [cvVertical setDelegate:self];
                        [cvVertical setScrollEnabled:false];
                        [cvVertical setBackgroundColor:dlObject.variable.tileStyle.bgColor];
                        [cvVertical.layer setValue:dlObject.variable forKey:@"CV_DLVariable"];
                        [viewDynamic addSubview:cvVertical];
                        [cvVertical setClipsToBounds:true];
                        float contentSizeH = viewDynamic.frame.size.height;
                        int contentElement = 0;

                        if (dlObject.variable) {
                            switch (dlObject.variable.scrollerFor) {
                                case DL_SCROLL_FOR_PRODUCT:{
                                    dlObject.variable.dataSourceProducts = [dlObject.variable getContentProducts];
                                    contentElement =(int)[dlObject.variable.dataSourceProducts count];// dlObject.variable.scrollerCount;

                                    int lineCount = contentElement % 3 + contentElement / 3;
                                    if (lineCount > 0) {
                                        CGSize productCellSize = [self getProductCellSize];
                                        contentSizeH = lineCount * productCellSize.height + (lineCount+1) * [self getProductCellVSpacing];
                                        float oldHViewDynamic = viewDynamic.frame.size.height;
                                        CGRect rectVD = viewDynamic.frame;
                                        rectVD.size.height = contentSizeH;
                                        viewDynamic.frame = rectVD;
                                        float newHViewDynamic = viewDynamic.frame.size.height;
                                        CGRect rectCV = cvVertical.frame;
                                        rectCV.size.height = contentSizeH;
                                        cvVertical.frame = rectCV;
                                        dlObject.extraH = (newHViewDynamic - oldHViewDynamic);
                                        self.vCorrousalExtraHeight += (newHViewDynamic - oldHViewDynamic);
                                    }
                                    [cvVertical reloadData];
                                    [self.allVCorrousals addObject:cvVertical];
                                }break;
                                case DL_SCROLL_FOR_CATEGORIES:{
                                    dlObject.variable.dataSourceProducts = [dlObject.variable getContentProducts];
                                }break;
                                case DL_SCROLL_FOR_CATEGORY:{
                                    int categoryId = 999999999;
                                    if (dlObject.variable.scrollerIds && [dlObject.variable.scrollerIds count] == 1) {
                                        categoryId = [[dlObject.variable.scrollerIds objectAtIndex:0] intValue];
                                    }
                                    switch (categoryId) {
                                        case DL_PROMOTIONAL_IDS_TRENDING:{
                                            dlObject.variable.dataSourceProducts = [ProductInfo getProducts:@"" isAscending:YES viewType:kHV_TYPES_TRENDINGS];
                                        }
                                            break;
                                        case DL_PROMOTIONAL_IDS_BESTDEALS:{
                                            dlObject.variable.dataSourceProducts = [ProductInfo getProducts:@"" isAscending:NO viewType:kHV_TYPES_BESTSELLINGS];
                                        }
                                            break;
                                        case DL_PROMOTIONAL_IDS_FRESHARRIVALS:{
                                            dlObject.variable.dataSourceProducts = [ProductInfo getProducts:@"" isAscending:NO viewType:kHV_TYPES_NEWARRIVALS];
                                        }
                                            break;
                                        case DL_PROMOTIONAL_IDS_RECENTLY_VIEWED:{
                                            dlObject.variable.dataSourceProducts = [ProductInfo getProducts:@"" isAscending:NO viewType:kHV_TYPES_TRENDINGS];
                                        }
                                            break;
                                        default:
                                            break;
                                    }
                                    if(categoryId > -1) {

                                        ViewDynamicVAll *vAll = [[[NSBundle mainBundle] loadNibNamed:@"ViewDynamicVAll" owner:self options:nil] objectAtIndex:0];
                                        vAll.frame = CGRectMake(0, 0, viewDynamic.frame.size.width, 53);
                                        vAll.labelHeader.text = dlObject.variable.tileTitle;
                                        [vAll.buttonVAll.layer setValue:dlObject.variable forKey:@"CV_DLVariable"];
                                        [vAll.buttonVAll addTarget:self action:@selector(buttonViewAllAction:) forControlEvents:UIControlEventTouchUpInside];
                                        [viewDynamic addSubview:vAll];

                                        contentElement = dlObject.variable.scrollerCount;//(int)[dlObject.variable.dataSourceProducts count];
                                        int lineCount = contentElement % 3 + contentElement / 3;
                                        if (lineCount > 0) {
                                            CGSize productCellSize = [self getProductCellSize];
                                            contentSizeH = lineCount * productCellSize.height + (lineCount+1) * [self getProductCellVSpacing] + 50;
                                            float oldHViewDynamic = viewDynamic.frame.size.height;
                                            CGRect rectVD = viewDynamic.frame;
                                            rectVD.size.height = contentSizeH;
                                            viewDynamic.frame = rectVD;
                                            float newHViewDynamic = viewDynamic.frame.size.height;
                                            dlObject.extraH = (newHViewDynamic - oldHViewDynamic);
                                            self.vCorrousalExtraHeight += (newHViewDynamic - oldHViewDynamic);
                                        }
                                        [cvVertical reloadData];
                                        [self.allVCorrousals addObject:cvVertical];

                                        vAll.frame = CGRectMake(0, 0, viewDynamic.frame.size.width, 53);

                                        [[[DataManager sharedManager] tmDataDoctor] fetchCategoriesDataNew:categoryId count:dlObject.variable.scrollerCount success:^(id data) {
                                            dlObject.variable.dataSourceProducts = data;

                                            __block contentSizeH = viewDynamic.frame.size.height;
                                            __block contentElement = 0;

                                            contentElement = dlObject.variable.scrollerCount;//(int)[dlObject.variable.dataSourceProducts count];
                                            int lineCount = contentElement % 3 + contentElement / 3;
                                            if (lineCount > 0) {
                                                CGSize productCellSize = [self getProductCellSize];
                                                contentSizeH = lineCount * productCellSize.height + (lineCount+1) * [self getProductCellVSpacing]+50;
                                                float oldHViewDynamic = viewDynamic.frame.size.height;
                                                CGRect rectVD = viewDynamic.frame;
                                                rectVD.size.height = contentSizeH;
                                                viewDynamic.frame = rectVD;
                                                float newHViewDynamic = viewDynamic.frame.size.height;
                                                CGRect rectCV = cvVertical.frame;
                                                rectCV.size.height = contentSizeH - 50;
                                                rectCV.origin.y = 50;
                                                cvVertical.frame = rectCV;

                                            }
                                            [cvVertical reloadData];
                                            [self.allVCorrousals addObject:cvVertical];
                                            vAll.frame = CGRectMake(0, 0, viewDynamic.frame.size.width, 53);

                                        } failure:^(NSString *error) {

                                        }];
                                    }
                                    else {
                                        ViewDynamicVAll *vAll = [[[NSBundle mainBundle] loadNibNamed:@"ViewDynamicVAll" owner:self options:nil] objectAtIndex:0];
                                        vAll.frame = CGRectMake(0, 0, viewDynamic.frame.size.width, 53);
                                        vAll.labelHeader.text =dlObject.variable.tileTitle;
                                        [vAll.buttonVAll.layer setValue:dlObject.variable forKey:@"CV_DLVariable"];
                                        [vAll.buttonVAll addTarget:self action:@selector(buttonViewAllAction:) forControlEvents:UIControlEventTouchUpInside];
                                        [viewDynamic addSubview:vAll];
                                        contentElement = dlObject.variable.scrollerCount;//(int)[dlObject.variable.dataSourceProducts count];
                                        int lineCount = contentElement % 3 + contentElement / 3;
                                        if (lineCount > 0) {
                                            CGSize productCellSize = [self getProductCellSize];
                                            contentSizeH = lineCount * productCellSize.height + (lineCount+1) * [self getProductCellVSpacing]+50;
                                            float oldHViewDynamic = viewDynamic.frame.size.height;
                                            CGRect rectVD = viewDynamic.frame;
                                            rectVD.size.height = contentSizeH;
                                            viewDynamic.frame = rectVD;
                                            float newHViewDynamic = viewDynamic.frame.size.height;
                                            dlObject.extraH = (newHViewDynamic - oldHViewDynamic);
                                            self.vCorrousalExtraHeight += (newHViewDynamic - oldHViewDynamic);
                                        }
                                        [cvVertical reloadData];
                                        [self.allVCorrousals addObject:cvVertical];
                                        vAll.frame = CGRectMake(0, 0, viewDynamic.frame.size.width, 53);
                                    }
                                }break;
                                case DL_SCROLL_FOR_PROMOTIONAL:{
                                }break;
                                case DL_SCROLL_FOR_VENDOR:{
                                }break;
                                default:
                                    break;
                            }
                        }
                    } break;
                    case DL_TILE_TYPE_CATEGORY:
                    {
                        switch (dlObject.variable.textStyle.alignmentV) {
                            case DL_TEXT_STYLE_ALIGN_V_BOTTOM:
                            {

                            }break;
                            case DL_TEXT_STYLE_ALIGN_V_ABOVE:
                            {
                                CCollectionViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CategoryCellType3" owner:self options:nil] lastObject];
                                cell.frame = CGRectMake(0, 0, viewDynamic.frame.size.width, viewDynamic.frame.size.height-2);
                                int _id = dlObject.variable.tileType_Id;
                                CategoryInfo *category = [CategoryInfo getWithId:_id];
                                NSString *strImage = category._image;
                                [Utility setImage:cell.productImg url:strImage resizeType:0 isLocal:false highPriority:true];
                                [cell.productImg setContentMode:UIViewContentModeScaleAspectFill];
                                [cell.productImg setClipsToBounds:true];
                                cell.productName.text = category._nameForOuterView;
                                [Utility showShadow:cell];
                                [viewDynamic addSubview:cell];

                            }break;
                            case DL_TEXT_STYLE_ALIGN_V_BELOW:
                            {
                                CCollectionViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CategoryCellType4" owner:self options:nil] lastObject];
                                cell.frame = CGRectMake(0, 0, viewDynamic.frame.size.width, viewDynamic.frame.size.height-2);
                                int _id = dlObject.variable.tileType_Id;
                                CategoryInfo *category = [CategoryInfo getWithId:_id];
                                NSString *strImage = category._image;
                                [Utility setImage:cell.productImg url:strImage resizeType:0 isLocal:false highPriority:true];
                                [cell.productImg setContentMode:UIViewContentModeScaleAspectFill];
                                [cell.productImg setClipsToBounds:true];
                                cell.productName.text = category._nameForOuterView;
                                [Utility showShadow:cell];
                                [viewDynamic addSubview:cell];


                            }break;
                            case DL_TEXT_STYLE_ALIGN_V_CENTER:
                            {
                                CCollectionViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CategoryCellType5" owner:self options:nil] lastObject];
                                cell.frame = CGRectMake(0, 0, viewDynamic.frame.size.width, viewDynamic.frame.size.height);
                                int _id = dlObject.variable.tileType_Id;
                                CategoryInfo *category = [CategoryInfo getWithId:_id];
                                NSString *strImage = category._image;
                                [Utility setImage:cell.productImg url:strImage resizeType:0 isLocal:false highPriority:true];
                                [cell.productImg setContentMode:UIViewContentModeScaleAspectFill];
                                [cell.productImg setClipsToBounds:true];
                                cell.productName.text = @"";
                                [Utility showShadow:cell];
                                [viewDynamic addSubview:cell];
                            }break;
                            case DL_TEXT_STYLE_ALIGN_V_HIDE:
                            {
                                CCollectionViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CategoryCellType5" owner:self options:nil] lastObject];
                                cell.frame = CGRectMake(0, 0, viewDynamic.frame.size.width, viewDynamic.frame.size.height);
                                int _id = dlObject.variable.tileType_Id;
                                CategoryInfo *category = [CategoryInfo getWithId:_id];
                                NSString *strImage = category._image;
                                [Utility setImage:cell.productImg url:strImage resizeType:0 isLocal:false highPriority:true];
                                [cell.productImg setContentMode:UIViewContentModeScaleAspectFill];
                                [cell.productImg setClipsToBounds:true];
                                cell.productName.text = @"";
                                [Utility showShadow:cell];
                                [viewDynamic addSubview:cell];

                            }break;
                            case DL_TEXT_STYLE_ALIGN_V_TOP:
                            {

                            }break;
                            default:
                                break;
                        }
                        switch (dlObject.variable.textStyle.alignmentH){
                            case DL_TEXT_STYLE_ALIGN_H_LEFT:
                            {

                            }break;
                            case DL_TEXT_STYLE_ALIGN_H_RIGHT:
                            {

                            }break;
                            case DL_TEXT_STYLE_ALIGN_H_CENTER:
                            {

                            }break;
                        }
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(redirectPageForCategories:)];
                        [viewDynamic addGestureRecognizer:tap];
                        [viewDynamic.layer setValue:dlObject.variable forKey:@"CV_DLVariable"];

                    } break;
                    default:
                        break;
                }
            }

            //[viewDynamic.layer setBorderWidth:0.5f];
            [scrollView addSubview:viewDynamic];
            NSLog(@"viewDynamic F = %.f, %.f", viewDynamic.frame.origin.y, viewDynamic.frame.size.height);
            NSLog(@"scrollView F = %.f, %.f", scrollView.frame.origin.y, scrollView.frame.size.height);
            NSLog(@"scrollView C = %.f, %.f", scrollView.contentOffset.y, scrollView.contentSize.height);
            [scrollView setContentSize:CGSizeMake(
                                                  MAX(scrollView.contentSize.width, CGRectGetMaxX(viewDynamic.frame)),
                                                  MAX(scrollView.contentSize.height, CGRectGetMaxY(viewDynamic.frame)))];
            NSLog(@"viewDynamic F = %.f, %.f", viewDynamic.frame.origin.y, viewDynamic.frame.size.height);
            NSLog(@"scrollView F = %.f, %.f", scrollView.frame.origin.y, scrollView.frame.size.height);
            NSLog(@"scrollView C = %.f, %.f", scrollView.contentOffset.y, scrollView.contentSize.height);
        }
    }
    [scrollView setScrollEnabled:true];
    [scrollView setShowsHorizontalScrollIndicator:true];
    [scrollView setShowsVerticalScrollIndicator:true];


    NSMutableArray* mPairs = [[NSMutableArray alloc] init];
    for (DLObject* dlObject in dlObjects) {
        MyPair* mPair = [[MyPair alloc] init];
        mPair.view = dlObject.dView;
        mPair.posY = dlObject.dView.frame.origin.y;
        mPair.eHeight = dlObject.extraH;
        [mPairs addObject:mPair];
        NSLog(@"UNSORTED OBJ:%@,%.f,%.f", mPair, mPair.posY, mPair.eHeight);
    }
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"posY" ascending:YES]];
    NSArray *sortedArray = [mPairs sortedArrayUsingDescriptors:sortDescriptors];
    for (MyPair* mPair in sortedArray) {
        NSLog(@"SORTED OBJ:%@,%.f,%.f", mPair, mPair.posY, mPair.eHeight);
    }

    for (MyPair* mPair in sortedArray) {
        float cummulativeExtraH = 0;
        for (MyPair* mPairLoop in sortedArray) {
            if (mPairLoop == mPair) {
                mPair.newPosY = mPair.posY +  cummulativeExtraH;
                NSLog(@"UPDATED OBJ:%@,%.f,%.f,%.f", mPair, mPair.posY, mPair.eHeight , mPair.newPosY);
                break;
            }
            cummulativeExtraH += mPairLoop.eHeight;
        }
    }
    for (MyPair* mPair in sortedArray) {
        mPair.posY = mPair.newPosY;
        CGRect rect = mPair.view.frame;
        rect.origin.y = mPair.newPosY;
        mPair.view.frame = rect;
        NSLog(@"UPDATED FINAL OBJ:%@,%.f,%.f", mPair, mPair.posY, mPair.eHeight);
    }

    MyPair* mPairLastObj = [sortedArray lastObject];
    [scrollView setContentSize:CGSizeMake(
                                          MAX(scrollView.contentSize.width, CGRectGetMaxX(mPairLastObj.view.frame)),
                                          MAX(scrollView.contentSize.height, CGRectGetMaxY(mPairLastObj.view.frame)))];

}
#pragma mark - Collectionview - Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    DLVariable* dlVariable = nil;
    if ([collectionView.layer valueForKey:@"CV_DLVariable"]) {
        dlVariable = [collectionView.layer valueForKey:@"CV_DLVariable"];
    }
    switch (dlVariable.tileType) {
        case DL_TILE_TYPE_CARROUSAL_HORIZONTAL:
            if (dlVariable && dlVariable.content) {
                //                return (int)[dlVariable.content count];
                return (int)[dlVariable.dataSourceProducts count];
            }
            break;
        case DL_TILE_TYPE_CARROUSAL_VERTICAL:
            if (dlVariable && dlVariable.content) {
                return (int)[dlVariable.dataSourceProducts count];
            }
            break;

        default:
            return (int)[dlVariable.dataSourceProducts count];
            break;
    }

    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DLVariable* dlVariable = nil;
    if ([collectionView.layer valueForKey:@"CV_DLVariable"]) {
        dlVariable = [collectionView.layer valueForKey:@"CV_DLVariable"];
    }
    switch (dlVariable.tileType) {
        case DL_TILE_TYPE_CARROUSAL_HORIZONTAL:
            if (dlVariable && dlVariable.dataSourceProducts && [dlVariable.dataSourceProducts count] > indexPath.row) {

                ProductInfo* pInfo = nil;
                CategoryInfo* cInfo = nil;
                NSMutableArray* elementArray = dlVariable.dataSourceProducts;
                if (elementArray && [elementArray count] > 0) {
                    id elementObj = [elementArray objectAtIndex:0];
                    if (elementObj && [elementObj isKindOfClass:[ProductInfo class]]) {
                        pInfo = [dlVariable.dataSourceProducts objectAtIndex:indexPath.row];
                    }
                    if (elementObj && [elementObj isKindOfClass:[CategoryInfo class]]) {
                        cInfo = [dlVariable.dataSourceProducts objectAtIndex:indexPath.row];
                    }
                }

                if (pInfo) {
                    // here product cell
                    static NSString *CellIdentifier = @"CollectionCell";
                    CCollectionViewCell *cell=(CCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
                    NSMutableArray* productsArray = dlVariable.dataSourceProducts;
                    cell = [[Utility sharedManager] setProductCellDataCategoryScreen:collectionView cell:cell indexPath:indexPath isCategory:true childCount:(int)[productsArray count] showFilterdResult:true cInfo:nil nibName:[[Utility sharedManager] getHorizontalViewString] target:self dataSource:productsArray];
                    [cell.productImg setContentMode:UIViewContentModeScaleAspectFill];
                    [Utility showShadow:cell];
                    if (cell == nil) {
                        return nil;
                    }
                    return cell;
                }
                if (cInfo) {
                    //here category cell
                    DynamicCellCategory *cell = (DynamicCellCategory *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCellBelowName" forIndexPath:indexPath];
                    //                    cell.categoryView.layer.borderWidth = 1 ;
                    //                    cell.categoryView.layer.cornerRadius = 5;
                    //                    cell.categoryView.layer.borderColor = dlVariable.tileStyle.bgColor.CGColor;
                    //                    cell.categoryView.layer.masksToBounds = true;
                    //                    cell.categoryView.backgroundColor = dlVariable.tileStyle.bgColor;
                    [Utility showShadow:cell];
                    [Utility setImage:cell.imageCategory url:cInfo._image resizeType:0 isLocal:false highPriority:true];
                    NSString *stringWithoutAmp = cInfo._nameForOuterView;
                    cell.labelCategoryName.text = stringWithoutAmp;
                    //cell.labelCategoryName.font = [UIFont systemFontOfSize:dlVariable.tileStyle.fontSize];
                    cell.labelCategoryName.textColor = dlVariable.tileStyle.textColor;
                    cell.labelCategoryName.textAlignment = NSTextAlignmentCenter;
                    [cell.imageCategory setContentMode:UIViewContentModeScaleAspectFill];

                    return cell;
                }
                return nil;
            }break;
        case DL_TILE_TYPE_CARROUSAL_VERTICAL:
            if (dlVariable) {
                static NSString *CellIdentifier = @"CollectionCell";
                CCollectionViewCell *cell=(CCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
                NSMutableArray* productsArray = dlVariable.dataSourceProducts;
                cell = [[Utility sharedManager] setProductCellDataCategoryScreen:collectionView cell:cell indexPath:indexPath isCategory:true childCount:(int)[productsArray count] showFilterdResult:true cInfo:nil nibName:[[Utility sharedManager] getHorizontalViewString] target:self dataSource:productsArray];

                if (cell == nil) {
                    return nil;
                }
                return cell;
            }break;

        default:
            break;
    }

    return nil;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DLVariable* dlVariable = nil;
    if ([collectionView.layer valueForKey:@"CV_DLVariable"]) {
        dlVariable = [collectionView.layer valueForKey:@"CV_DLVariable"];
    }
    switch (dlVariable.tileType) {
        case DL_TILE_TYPE_CARROUSAL_HORIZONTAL:{
            switch (dlVariable.scrollerFor) {
                case DL_SCROLL_FOR_PRODUCT:{
                    DLContent* dlContent = [dlVariable.dataSourceProducts objectAtIndex:indexPath.row];
                    ProductInfo *pInfo = [ProductInfo getProductWithId:dlContent._id];
                    [self clickOnProduct:pInfo currentItemData:nil cell:nil];
                }break;
                case DL_SCROLL_FOR_CATEGORIES:{
                    DLContent* dlContent = [dlVariable.dataSourceProducts objectAtIndex:indexPath.row];
                    CategoryInfo *cInfo = [CategoryInfo getWithId:dlContent._id];
                    [self clickOnCategory:cInfo currentItemData:nil];
                }break;
                case DL_SCROLL_FOR_CATEGORY:{
                    DLContent* dlContent = [dlVariable.dataSourceProducts objectAtIndex:indexPath.row];
                    ProductInfo *pInfo = [ProductInfo getProductWithId:dlContent._id];
                    [self clickOnProduct:pInfo currentItemData:nil cell:nil];
                }break;
                default:
                    break;
            }
        }break;
        case DL_TILE_TYPE_CARROUSAL_VERTICAL:{
            if (dlVariable) {
                DLContent* dlContent = [dlVariable.dataSourceProducts objectAtIndex:indexPath.row];
                ProductInfo *pInfo = [ProductInfo getProductWithId:dlContent._id];
                [self clickOnProduct:pInfo currentItemData:nil cell:nil];
            }
        }break;
        default:
            break;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DLVariable* dlVariable = nil;
    if ([collectionView.layer valueForKey:@"CV_DLVariable"]) {
        dlVariable = [collectionView.layer valueForKey:@"CV_DLVariable"];
    }
    switch (dlVariable.tileType) {
        case DL_TILE_TYPE_CARROUSAL_HORIZONTAL:{
            switch (dlVariable.scrollerFor) {
                case DL_SCROLL_FOR_PRODUCT:{
                    return CGSizeMake(collectionView.frame.size.height / 1.33f, collectionView.frame.size.height);
                }break;
                case DL_SCROLL_FOR_CATEGORIES:{
                    return CGSizeMake(collectionView.frame.size.height / 1.33f, collectionView.frame.size.height - 10);
                }break;
                case DL_SCROLL_FOR_CATEGORY:{
                    //return CGSizeMake(collectionView.frame.size.height / 1.70f, collectionView.frame.size.height - 10);
                    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[collectionView collectionViewLayout];
                    layout.minimumInteritemSpacing = [self getProductCellHSpacing];
                    layout.minimumLineSpacing = [self getProductCellVSpacing];
                    return [self getProductCellSize];

                }break;
                default:
                    break;
            }
        } break;
        case DL_TILE_TYPE_CARROUSAL_VERTICAL:{
            if (dlVariable) {
                UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[collectionView collectionViewLayout];
                layout.minimumInteritemSpacing = [self getProductCellHSpacing];
                layout.minimumLineSpacing = [self getProductCellVSpacing];
                return [self getProductCellSize];
            }
        } break;
        default:break;
    }
    return CGSizeMake(180, 180);

}

#pragma mark - Custom - Methods
- (void)clickOnCategory:(CategoryInfo*)categoryClicked currentItemData:(DataPass*)currentItemData{

    //self.isHomeScreenPresented = false;
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
    DataPass* clickedItemData = [[DataPass alloc] init];
    clickedItemData.itemId = categoryClicked._id;
    clickedItemData.isCategory = true;
    clickedItemData.isProduct = false;
    clickedItemData.hasChildCategory = [[categoryClicked getSubCategories] count];
    clickedItemData.childCount = (int)[[ProductInfo getOnlyForCategory:categoryClicked] count];
    clickedItemData.cInfo = categoryClicked;

    DataPass* previousItemData = [[DataPass alloc] init];
    previousItemData.itemId = currentItemData.cInfo._id;
    previousItemData.isCategory = currentItemData.isCategory;
    previousItemData.isProduct = currentItemData.isProduct;
    previousItemData.hasChildCategory = currentItemData.hasChildCategory;
    previousItemData.childCount = currentItemData.childCount;
    previousItemData.cInfo = currentItemData.cInfo;

    ViewControllerCategories* vcCategories = [[Utility sharedManager] pushScreen:mainVC.vcCenterTop];
    [vcCategories loadData:clickedItemData previousItem:previousItemData drillingLevel:0];
}
- (void)clickOnProduct:(id)productClicked currentItemData:(id)currentItemData cell:(id)cell {
    // self.isHomeScreenPresented = false;
    ProductInfo* pInfo = productClicked;
    DataPass* dPass = currentItemData;

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
    DataPass* clickedItemData = [[DataPass alloc] init];
    clickedItemData.itemId = pInfo._id;
    clickedItemData.isCategory = false;
    clickedItemData.isProduct = true;
    clickedItemData.hasChildCategory = false;
    clickedItemData.childCount = false;
    clickedItemData.pInfo = pInfo;

    DataPass* previousItemData = [[DataPass alloc] init];
    previousItemData.itemId = dPass.cInfo._id;
    previousItemData.isCategory = dPass.isCategory;
    previousItemData.isProduct = dPass.isProduct;
    previousItemData.hasChildCategory = dPass.hasChildCategory;
    previousItemData.childCount = dPass.childCount;
    previousItemData.cInfo = dPass.cInfo;

    ViewControllerProduct* vcProduct = [[Utility sharedManager] pushProductScreen:mainVC.vcCenterTop];
    [vcProduct loadData:clickedItemData previousItem:previousItemData drillingLevel:0];
    vcProduct.parentVC = self;
    vcProduct.parentCell = cell;
}
- (void)redirectPageForProducts: (UIGestureRecognizer *) gesture {

    DLVariable* dlVariable = nil;
    if ([gesture.view.layer valueForKey:@"CV_DLVariable"]) {
        dlVariable = [gesture.view.layer valueForKey:@"CV_DLVariable"];
    }
    DLContent *dlContent = nil;
    if ([gesture.view.layer valueForKey:@"Category_DLContent"]) {
        dlContent = [gesture.view.layer valueForKey:@"Category_DLContent"];
    }
    //    if (dlVariable && dlContent && dlContent.redirect_id == -1) {
    //        dlContent.redirect = DL_REDIRECT_NONE;
    //    }
    if (dlContent.redirect == DL_REDIRECT_NONE) {
        dlContent.redirect = DL_REDIRECT_NONE;
    } else if (dlContent.redirect == DL_REDIRECT_URL && dlContent.redirect_url && ![dlContent.redirect_url isEqualToString:@""]){
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
        ViewControllerWebview* vcWebview = (ViewControllerWebview*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_WEBVIEW];
        //        [vcWebview loadAllViews:@"http://naaniskitchen.com/about-us/"];
        [vcWebview loadAllViews:dlContent.redirect_url];
    }
    else if (dlContent.redirect == DL_REDIRECT_CATEGORY) {
        CategoryInfo *cInfo = [CategoryInfo getWithId:dlContent.redirect_id];
        [self clickOnCategory:cInfo currentItemData:nil];
    }


}
- (void)redirectPageForCategories: (UIGestureRecognizer *) gesture {

    DLVariable* dlVariable = nil;
    if ([gesture.view.layer valueForKey:@"CV_DLVariable"]) {
        dlVariable = [gesture.view.layer valueForKey:@"CV_DLVariable"];
    }
    if (dlVariable) {
        CategoryInfo *cInfo = [CategoryInfo getWithId:dlVariable.tileType_Id];
        [self clickOnCategory:cInfo currentItemData:nil];

    }
}


#pragma mark - Product - Methods

- (void)promoTapped:(UITapGestureRecognizer*)singleTap{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[DataManager sharedManager] promoUrlString]]];
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

- (void)bannerTapped:(UITapGestureRecognizer*)singleTap{
    Banner* banner = [singleTap.view.layer valueForKey:@"BANNER_OBJ"];
    id cell = [singleTap.view.layer valueForKey:@"CELL_OBJ"];
    if (banner) {
        int bannerId = banner.bannerId;
        int bannerType = banner.bannerType;
        switch (bannerType) {
            case BANNER_SIMPLE://do nothing
            {

            }break;
            case BANNER_PRODUCT://open product
            {
                int productId = bannerId;
                ProductInfo* pInfo = (ProductInfo*)[ProductInfo getProductWithId:productId];
                if (pInfo) {
                    [self clickOnProduct:pInfo currentItemData:nil cell:cell];
                } else {
                    ProductInfo* pInfo = [[ProductInfo alloc] init];
                    pInfo._id = productId;
                    [self clickOnProduct:pInfo currentItemData:nil  cell:cell];
#if ENABLE_FIREBASE_TAG_MANAGER
                    [[AnalyticsHelper sharedInstance] registerClickOnBanner:[NSString stringWithFormat:@"%d",pInfo._id]];
#endif
                }

            }break;
            case BANNER_CATEGORY://open category
            {
                int categoryId = bannerId;
                CategoryInfo *cInfo = [CategoryInfo getWithId:categoryId];
                [self clickOnCategory:cInfo currentItemData:nil];
#if ENABLE_FIREBASE_TAG_MANAGER
                [[AnalyticsHelper sharedInstance] registerClickOnBanner:[NSString stringWithFormat:@"%d",categoryId]];
#endif
            }break;
            case BANNER_WISHLIST://open wishlist
            {
                // self.isHomeScreenPresented = false;
                ViewControllerMain* mainVC = [ViewControllerMain getInstance];
                [mainVC btnClickedWishlist:nil];
            }break;
            case BANNER_CART://open cart
            {
                // self.isHomeScreenPresented = false;
                ViewControllerMain* mainVC = [ViewControllerMain getInstance];
                [mainVC btnClickedCart:nil];
            }break;
            default:
                break;
        }
        return;
    }

    int productId = (int)[singleTap.view tag];
    ProductInfo* pInfo = (ProductInfo*)[ProductInfo getProductWithId:productId];
    if (pInfo) {
        [self clickOnProduct:pInfo currentItemData:nil cell:cell];
    }
}
- (void)showMoreClicked:(UIButton*)button {
    int productId = (int)[button tag];
    ProductInfo* pInfo = [ProductInfo getProductWithId:productId];
    if (pInfo) {
        [self clickOnProduct:pInfo currentItemData:nil cell:nil];
    }

}
- (void)cartButtonClicked:(UIButton*)button {
    ProductInfo* pInfo = (ProductInfo*)[button.layer valueForKey:@"PINFO_OBJ"];
    CCollectionViewCell* cell = (CCollectionViewCell*)[button.layer valueForKey:@"CELL_OBJ"];
    if (cell.actIndicator.hidden == false) {
        return;
    }
    if (pInfo._isFullRetrieved == false) {
        RLOG(@"NOTIFY_PRODUCT_LOADED1 = CELL = %@", cell);
        [[NSNotificationCenter defaultCenter] addObserver:cell selector:@selector(updateCell:) name:@"NOTIFY_PRODUCT_LOADED" object:nil];

        [[DataManager sharedManager] fetchSingleProductData:nil productId:pInfo._id];
        [cell.actIndicator setHidden:false];
        [cell.buttonCart setHidden:true];
    } else {
        if (pInfo._variations && [pInfo._variations count] > 0) {
            //open new popup to choose variation and add to cart
            [self clickOnProduct:pInfo currentItemData:nil cell:cell];
        }else {
            int availState = [Cart getProductAvailibleState:pInfo variationId:-1];
            if (availState == PRODUCT_QTY_DEMAND || availState == PRODUCT_QTY_STOCK) {
                [Cart addProduct:pInfo variationId:-1 variationIndex:-1 selectedVariationAttributes:nil];
            }
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
- (void)buttonViewAllAction:(UIButton*)button{
    DLVariable* dlVariable = nil;
    if ([button.layer valueForKey:@"CV_DLVariable"]) {
        dlVariable = [button.layer valueForKey:@"CV_DLVariable"];
    }
    if (dlVariable) {
        int categoryId = 999999999;
        if (dlVariable.scrollerIds && [dlVariable.scrollerIds count] == 1) {
            categoryId = [[dlVariable.scrollerIds objectAtIndex:0] intValue];
        }
        if (categoryId > -1) {
            CategoryInfo *cInfo = [CategoryInfo getWithId:categoryId];
            [self clickOnCategory:cInfo currentItemData:nil];
        }
        /*
         else{
         CategoryInfo *cInfo = [CategoryInfo getWithId:categoryId];
         cInfo._name = @"New Arrivals";
         cInfo._nameForOuterView = @"New Arrivals";
         NSMutableArray* productsArray = dlVariable.dataSourceProducts;
         for (ProductInfo* pInfo in productsArray) {
         if ([pInfo._categories containsObject:cInfo] == false) {
         [pInfo._categories addObject:cInfo];
         }
         }
         [self clickOnCategory:cInfo currentItemData:nil];
         }*/
    }
}

@end

