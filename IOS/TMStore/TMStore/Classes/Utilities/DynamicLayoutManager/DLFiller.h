//
//  DLFiller.h
//  TMStore
//
//  Created by Rishabh Jain on 19/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DLManager.h"


//static int kTagForGlobalSpacing = 0;
//static int kTagForNoSpacing = -1;

@interface DLFiller : NSObject<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIWebViewDelegate>

@property DLManager* dlManager;
//@property UICollectionView *collectionviewHorizontal;
//@property UICollectionView *collectionviewVertical;
//@property UICollectionView *collectionviewCategoryTypeVertical;
//@property UICollectionView *collectionviewPopular;
//@property UIView *viewDynamic;

+ (id)getInstance;
- (void)fillWithData:(NSMutableArray*)dlObjects scrollView:(UIScrollView*)scrollView delegate:(id)delegate;

@property NSMutableArray* allHCorrousals;
@property NSMutableArray* allVCorrousals;

@property float vCorrousalExtraHeight;

@end
