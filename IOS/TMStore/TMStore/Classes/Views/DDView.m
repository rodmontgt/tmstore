//
//  DDView.m
//  TMStore
//
//  Created by Rishabh Jain on 25/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "DDView.h"
#import "Utility.h"
#import "TimeSlot.h"
@implementation DDView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithDelegate:(id)delegate
            parentView:(UIView*)parentView
          defaultValue:(NSString*)defaultValue
           dataObjects:(NSArray*)dataObjects
           dataStrings:(NSArray*)dataStrings {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.parentView = parentView;
        self.default_value = defaultValue;
        self.dataObjects = dataObjects;
        self.dataStrings = dataStrings;
        [self createViewNew];
    }
    return self;
}
/*
- (void)createView {
    CGRect frame = self.parentView.frame;
    float topMargin = frame.size.width * 0.01f;
    float leftMargin = frame.size.width * 0.01f;
    float rightMargin = frame.size.width * 0.01f;
    float bottomMargin = frame.size.width * 0.01f;
    float viewWidth = frame.size.width - leftMargin - rightMargin;
    float viewHeight = 0;
    float viewPosX = leftMargin;
    float viewPosY = topMargin;
    float leftMarginInsideView = frame.size.width * 0.10f;
    float rightMarginInsideView = frame.size.width * 0.10f;
    float widthInsideView = viewWidth - leftMarginInsideView - rightMarginInsideView;
    float gap = topMargin;
    float varPosY = topMargin + gap;
    UIFont* font = [Utility getUIFont:kUIFontType18 isBold:true];
    float fontHeight = [font lineHeight];
    self.frame = CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight);
    UIView* view = self;
//    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight)];
    [view setBackgroundColor:[UIColor whiteColor]];
//    [_scrollView addSubview:view];
//    [_viewsAdded addObject:view];
//    [view setTag:kTagForGlobalSpacing];
//    [view addSubview:[self addBorder:view]];
    
    self.buttonSelection = [[UIButton alloc] init];
    [self.buttonSelection setFrame:CGRectMake(leftMarginInsideView, varPosY, widthInsideView, fontHeight * 2.0f)];
    [self.buttonSelection setTitle:self.default_value forState:UIControlStateNormal];
    [self.buttonSelection setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
    [self.buttonSelection.titleLabel setUIFont:kUIFontType18 isBold:false];
    [self.buttonSelection addTarget:self action:@selector(selectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonSelection setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [self.buttonSelection setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.buttonSelection.layer setBorderWidth:1];
    [view addSubview:self.buttonSelection];
    
    
    self.buttonSelectionDownArrow = [[UIButton alloc] init];
    [self.buttonSelectionDownArrow setFrame:CGRectMake(leftMarginInsideView + widthInsideView - 50, varPosY, 50, fontHeight * 2.0f)];
    [self.buttonSelectionDownArrow addTarget:self action:@selector(selectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonSelectionDownArrow.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.buttonSelectionDownArrow setImage:[[UIImage imageNamed:@"img_arrow_down_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.buttonSelectionDownArrow setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [self.buttonSelectionDownArrow setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [view addSubview:self.buttonSelectionDownArrow];
    varPosY = gap + CGRectGetMaxY(self.buttonSelection.frame);
    
    
    viewHeight = gap + varPosY;
    [view setFrame:CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight)];
}
*/
- (void)createViewNew {
    CGRect frame = self.parentView.frame;
    float topMargin = frame.size.width * 0.01f;
    float leftMargin = frame.size.width * 0.01f;
    float rightMargin = frame.size.width * 0.01f;
    float bottomMargin = frame.size.width * 0.01f;
    float viewWidth = frame.size.width - leftMargin - rightMargin;
    float viewHeight = 0;
    float viewPosX = leftMargin;
    float viewPosY = topMargin;
//    float leftMarginInsideView = frame.size.width * 0.10f;
//    float rightMarginInsideView = frame.size.width * 0.10f;
//    float widthInsideView = viewWidth - leftMarginInsideView - rightMarginInsideView;
    float leftMarginInsideView = frame.size.width * 0.05f;
    float rightMarginInsideView = frame.size.width * 0.05f;
    float widthInsideView = viewWidth - leftMarginInsideView - rightMarginInsideView;
    
    
    
    float gap = topMargin;
    float varPosY = topMargin + gap;
    UIFont* font = [Utility getUIFont:kUIFontType18 isBold:true];
    float fontHeight = [font lineHeight];
    self.frame = CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight);
    UIView* view = self;
    //    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //    [_scrollView addSubview:view];
    //    [_viewsAdded addObject:view];
    //    [view setTag:kTagForGlobalSpacing];
    //    [view addSubview:[self addBorder:view]];
    
    
    self.labelSelection = [[UILabel alloc] init];
    [self.labelSelection setFrame:CGRectMake(leftMarginInsideView, varPosY, widthInsideView, fontHeight * 2.0f)];
    [self.labelSelection setText:@"Title"];
    [self.labelSelection setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [self.labelSelection setUIFont:kUIFontType18 isBold:true];
    [self.labelSelection setTextAlignment:NSTextAlignmentLeft];
//    [self.labelSelection.layer setBorderWidth:1];
    [view addSubview:self.labelSelection];
    
    
    
    
    self.buttonSelection = [[UIButton alloc] init];
    [self.buttonSelection setFrame:CGRectMake(leftMarginInsideView, varPosY, widthInsideView, fontHeight * 2.0f)];
    [self.buttonSelection setTitle:self.default_value forState:UIControlStateNormal];
    [self.buttonSelection setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
    [self.buttonSelection.titleLabel setUIFont:kUIFontType16 isBold:false];
    [self.buttonSelection addTarget:self action:@selector(selectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonSelection setTitleEdgeInsets:UIEdgeInsetsMake(15, 15, 0, 0)];
    [self.buttonSelection setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//    [self.buttonSelection.layer setBorderWidth:1];
    [view addSubview:self.buttonSelection];
    
    self.buttonSelectionDownArrow = [[UIButton alloc] init];
    [self.buttonSelectionDownArrow setFrame:CGRectMake(leftMarginInsideView + widthInsideView - 50, varPosY, 50, fontHeight * 2.0f)];
    [self.buttonSelectionDownArrow addTarget:self action:@selector(selectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonSelectionDownArrow.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.buttonSelectionDownArrow setImage:[[UIImage imageNamed:@"img_arrow_down_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.buttonSelectionDownArrow setTintColor:[Utility getUIColor:kUIColorFontLight]];
    [self.buttonSelectionDownArrow setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [view addSubview:self.buttonSelectionDownArrow];
    varPosY = gap + CGRectGetMaxY(self.buttonSelection.frame);
    
    
    viewHeight = gap + varPosY;
    [view setFrame:CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight)];
    
    [self.labelSelection setCenter:CGPointMake(self.labelSelection.center.x, view.center.y - self.labelSelection.frame.size.height/3)];
    [self.buttonSelection setCenter:CGPointMake(self.buttonSelection.center.x, view.center.y)];
    [self.buttonSelectionDownArrow setCenter:CGPointMake(self.buttonSelectionDownArrow.center.x, view.center.y)];
    [view setClipsToBounds:true];
}
- (void)selectionButtonClicked:(UIButton *)sender {
    [self.ddViewSelection removeFromSuperview];
    self.ddViewSelection = nil;
    if(self.ddViewSelection == nil)
    {
        NSArray* arrImage = nil;
        CGFloat height = [[MyDevice sharedManager] screenHeightInPortrait] * .30f;
        self.ddViewSelection = [[NIDropDown alloc] init:_buttonSelection viewheight:height strArr:self.dataStrings imgArr:arrImage direction:NIDropDownDirectionDown pView:self.parentView];
        self.ddViewSelection.delegate = self;
        self.ddViewSelection.fontColor = [Utility getUIColor:kUIColorFontLight];
    }
    else {
        [self.ddViewSelection toggle:_buttonSelection];
    }
}
- (void)reponseDropDownDelegate:(NIDropDown *)sender clickedItemId:(int)clickedItemId {
    if (self.dataObjects) {
        NSString* selectedObject = [self.dataObjects objectAtIndex:clickedItemId];
        NSString* selectedString = [self.ddViewSelection getStringAtIndex:clickedItemId];
        [self.buttonSelection setTitle:selectedString forState:UIControlStateNormal];
        [self.buttonSelection setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
        [self.buttonSelection.titleLabel setUIFont:kUIFontType16 isBold:false];
        [self.buttonSelectionDownArrow setTintColor:[Utility getUIColor:kUIColorFontLight]];
        
        [self.delegate reponseDDViewDelegate:self
                               clickedItemId:clickedItemId
                            clickedItemTitle:selectedString
                           clickedItemObject:selectedObject
                               ];
    }
}
- (UIView*)addBorder:(UIView*)view{
    UIView* viewBorder = [[UIView alloc] init];
    [viewBorder setFrame:CGRectMake(0, 0, view.frame.size.width, 1)];
    [viewBorder setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    return viewBorder;
}
- (void)openDropdownView {
    if (self.ddViewSelection == nil) {
        [self selectionButtonClicked:self.buttonSelection];
//        [self.ddViewSelection toggle:_buttonSelection];
    } else {
        [self.ddViewSelection toggle:_buttonSelection];
    }
}
- (NSString*)selectItemForString:(NSString*)str {
    if (self.ddViewSelection == nil) {
        [self selectionButtonClicked:self.buttonSelection];
        [self.ddViewSelection toggle:_buttonSelection];
    }
    return [self.ddViewSelection selectItemForString:str];
}
- (NSString*)selectItemAtIndex:(int)index {
    if (self.ddViewSelection == nil) {
        [self selectionButtonClicked:self.buttonSelection];
        [self.ddViewSelection toggle:_buttonSelection];
    }
    return [self.ddViewSelection selectItemAtIndex:index];
}
- (void)updateData:(NSString*)defaultValue
       dataObjects:(NSArray*)dataObjects
       dataStrings:(NSArray*)dataStrings  {
    self.default_value = defaultValue;
    self.dataObjects = dataObjects;
    self.dataStrings = dataStrings;
    CGFloat height = [[MyDevice sharedManager] screenHeightInPortrait] * .30f;
    [self.ddViewSelection updateData:self.buttonSelection height:height dataObjects:dataObjects dataStrings:dataStrings];
    [self.buttonSelection setTitle:self.default_value forState:UIControlStateNormal];
}
@end
