//
//  NIDropDown.m
//  NIDropDown
//
//  Created by Bijesh N on 12/28/12.
//  Copyright (c) 2012 Nitor Infotech. All rights reserved.
//

#import "NIDropDown.h"
#import "QuartzCore/QuartzCore.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Utility.h"
#define BTN_SIZE_HEIGHT 50
@interface UITableViewCell_NIDropDown ()

@end
@implementation UITableViewCell_NIDropDown

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect cellTextLabelRect = self.textLabel.frame;
    cellTextLabelRect.origin.x = 0;
    cellTextLabelRect.size.width = self.superview.frame.size.width;
    self.textLabel.frame = cellTextLabelRect;
}

@end


@interface NIDropDown ()
@property(nonatomic, strong) UITableView *table;
@property(nonatomic, strong) UIButton *btnSender;
@property(nonatomic, strong) UITextField *textFieldSender;
@property(nonatomic, retain) NSArray *list;
@property(nonatomic, retain) NSArray *listFake;
@property(nonatomic, retain) NSArray *imageList;
@end

NSString* _up = @"UP";
NSString* _down = @"DOWN";

@implementation NIDropDown
@synthesize table;
@synthesize btnSender;
@synthesize textFieldSender;
@synthesize list;
@synthesize listFake;
@synthesize imageList;
@synthesize delegate;
@synthesize animationDirection;
#pragma mark - init

- (id)init:(UIButton *)button viewheight:(CGFloat)height  strArr:(NSArray *)arr  imgArr:(NSArray *)imgArr direction:(int)direction pView:(UIView*)pView {
    btnSender = button;
    _pView = pView;
    if (direction == NIDropDownDirectionUp) {
        animationDirection = _up;
    } else {
        animationDirection = _down;
    }
    self.table = (UITableView *)[super init];
    _tableView = self.table;
    if (self) {
        // Initialization code
        CGRect btn = button.frame;
        self.list = [NSArray arrayWithArray:arr];
        self.listFake = [NSArray arrayWithArray:arr];
        self.imageList = [NSArray arrayWithArray:imgArr];
        float maxHeight = list.count * BTN_SIZE_HEIGHT;
        float minHeight = height;
        if (minHeight > maxHeight) {
            height = maxHeight;
        }
        CGPoint btnUniversalPos = [button.superview convertPoint:button.frame.origin toView:_pView];
        if ([animationDirection isEqualToString:_up]) {
            self.frame = CGRectMake(btnUniversalPos.x, btnUniversalPos.y, btn.size.width, 0);
            self.layer.shadowOffset = CGSizeMake(-5, -5);
        }else if ([animationDirection isEqualToString:_down]) {
            self.frame = CGRectMake(btnUniversalPos.x, btnUniversalPos.y + BTN_SIZE_HEIGHT, btn.size.width, 0);
            self.layer.shadowOffset = CGSizeMake(-5, 5);
        }
        
        self.layer.masksToBounds = NO;
        //        self.layer.cornerRadius = 8;
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, btn.size.width, 0)];
        
        table.delegate = self;
        table.dataSource = self;
        //        table.layer.cornerRadius = 5;
        table.backgroundColor = [Utility getUIColor:kUIColorBuyButtonFont];
        table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        table.separatorColor = [Utility getUIColor:kUIColorThemeButtonBorderNormal];
        [table setBounces:false];
        viewheight = height;
        [_pView addSubview:self];
        
        //        [button.superview addSubview:self];
        [self addSubview:table];
        isViewVisible = false;
        RLOG(@"isViewVisible = %d", isViewVisible);
        [self toggle:button];
    }
    return self;
}
#pragma mark - show/hide view
-(void)toggleWithMainFrame:(UIButton *)button{
    CGRect btn = button.frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25f];
    
    CGPoint btnUniversalPos = [button.superview convertPoint:button.frame.origin toView:_pView];
    if(isViewVisible){
        if ([animationDirection isEqualToString:_up]) {
            self.frame = CGRectMake(btnUniversalPos.x, btnUniversalPos.y, btn.size.width, 0);
        }else if ([animationDirection isEqualToString:_down]) {
            self.frame = CGRectMake(btnUniversalPos.x, btnUniversalPos.y + BTN_SIZE_HEIGHT, btn.size.width, 0);
        }
        isViewVisible = false;
        RLOG(@"isViewVisible = %d", isViewVisible);
        table.frame = CGRectMake(0, 0, btn.size.width, 0);
    }else{
        if ([animationDirection isEqualToString:_up]) {
            self.frame = CGRectMake(btnUniversalPos.x, btnUniversalPos.y - viewheight, btn.size.width, viewheight);
        } else if([animationDirection isEqualToString:_down]) {
            self.frame = CGRectMake(btnUniversalPos.x, btnUniversalPos.y - viewheight / 2, btn.size.width, viewheight);
        }
        isViewVisible = true;
        RLOG(@"isViewVisible = %d", isViewVisible);
        table.frame = CGRectMake(0, 0, btn.size.width, viewheight);
    }
    [UIView commitAnimations];
}

-(void)toggle:(UIButton *)button{
    CGRect btn = button.frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25f];
    CGPoint btnUniversalPos = [button.superview convertPoint:button.frame.origin toView:_pView];
    if(isViewVisible){
        if ([animationDirection isEqualToString:_up]) {
            self.frame = CGRectMake(btnUniversalPos.x, btnUniversalPos.y, btn.size.width, 0);
        }else if ([animationDirection isEqualToString:_down]) {
            self.frame = CGRectMake(btnUniversalPos.x, btnUniversalPos.y + BTN_SIZE_HEIGHT, btn.size.width, 0);
        }
        isViewVisible = false;
        RLOG(@"isViewVisible = %d", isViewVisible);
        table.frame = CGRectMake(0, 0, btn.size.width, 0);
    }else{
        if ([animationDirection isEqualToString:_up]) {
            self.frame = CGRectMake(btnUniversalPos.x, btnUniversalPos.y - viewheight, btn.size.width, viewheight);
        } else if([animationDirection isEqualToString:_down]) {
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            CGPoint p = [btnSender convertPoint:btnSender.center toView:window];
            RLOG(@"btnUniversalPos.y = %f", p.y);
            if (p.y >= (btnUniversalPos.y - BTN_SIZE_HEIGHT - viewheight)) {
                float posy = btnUniversalPos.y + BTN_SIZE_HEIGHT - viewheight;
                if (posy < 0) {
                    posy = 0;
                }
                self.frame = CGRectMake(btnUniversalPos.x, posy, btn.size.width, viewheight);
            } else {
                self.frame = CGRectMake(btnUniversalPos.x, btnUniversalPos.y + BTN_SIZE_HEIGHT, btn.size.width, viewheight);
            }
        }
        isViewVisible = true;
        RLOG(@"isViewVisible = %d", isViewVisible);
        table.frame = CGRectMake(0, 0, btn.size.width, viewheight);
    }
    [UIView commitAnimations];
}

- (id)initTextField:(UITextField *)textField viewheight:(CGFloat)height  strArr:(NSArray *)arr  imgArr:(NSArray *)imgArr direction:(int)direction pView:(UIView*)pView {
    textFieldSender = textField;
    _pView = pView;
    if (direction == NIDropDownDirectionUp) {
        animationDirection = _up;
    } else {
        animationDirection = _down;
    }
    self.table = (UITableView *)[super init];
    if (self) {
        // Initialization code
        CGRect btn = textField.frame;
        self.list = [NSArray arrayWithArray:arr];
        self.listFake = [NSArray arrayWithArray:arr];
        self.imageList = [NSArray arrayWithArray:imgArr];
        float maxHeight = list.count * BTN_SIZE_HEIGHT;
        float minHeight = height;
        if (minHeight > maxHeight) {
            height = maxHeight;
        }
        CGPoint btnUniversalPos = [textField.superview convertPoint:textField.frame.origin toView:_pView];
        if ([animationDirection isEqualToString:_up]) {
            self.frame = CGRectMake(btnUniversalPos.x, btnUniversalPos.y, btn.size.width, 0);
            self.layer.shadowOffset = CGSizeMake(-5, -5);
        }else if ([animationDirection isEqualToString:_down]) {
            self.frame = CGRectMake(btnUniversalPos.x, btnUniversalPos.y + BTN_SIZE_HEIGHT, btn.size.width, 0);
            self.layer.shadowOffset = CGSizeMake(-5, 5);
        }
        
        self.layer.masksToBounds = NO;
        //        self.layer.cornerRadius = 8;
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, btn.size.width, 0)];
        
        table.delegate = self;
        table.dataSource = self;
        //        table.layer.cornerRadius = 5;
        table.backgroundColor = [Utility getUIColor:kUIColorBuyButtonFont];
        table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        table.separatorColor = [Utility getUIColor:kUIColorThemeButtonBorderNormal];
        [table setBounces:false];
        viewheight = height;
        [_pView addSubview:self];
        
        //        [button.superview addSubview:self];
        [self addSubview:table];
        isViewVisible = false;
        RLOG(@"isViewVisible = %d", isViewVisible);
        //        [self toggleTextField:textField];
    }
    return self;
}
#pragma mark - show/hide view
- (BOOL)isDropDownViewVisible{
    return isViewVisible;
}
- (void)setDropDownViewVisible:(BOOL)value{
    isViewVisible = value;
}
-(void)toggleTextField:(UITextField *)textField{
    CGRect btn = textField.frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25f];
    CGPoint btnUniversalPos = [textField.superview convertPoint:textField.frame.origin toView:_pView];
    if(isViewVisible){
        if ([animationDirection isEqualToString:_up]) {
            self.frame = CGRectMake(btnUniversalPos.x, btnUniversalPos.y, btn.size.width, 0);
        }else if ([animationDirection isEqualToString:_down]) {
            self.frame = CGRectMake(btnUniversalPos.x, btnUniversalPos.y + BTN_SIZE_HEIGHT, btn.size.width, 0);
        }
        isViewVisible = false;
        RLOG(@"isViewVisible = %d", isViewVisible);
        table.frame = CGRectMake(0, 0, btn.size.width, 0);
    }else{
        if ([animationDirection isEqualToString:_up]) {
            self.frame = CGRectMake(btnUniversalPos.x, btnUniversalPos.y - viewheight, btn.size.width, viewheight);
        } else if([animationDirection isEqualToString:_down]) {
            self.frame = CGRectMake(btnUniversalPos.x, btnUniversalPos.y + BTN_SIZE_HEIGHT, btn.size.width, viewheight);
        }
        isViewVisible = true;
        RLOG(@"isViewVisible = %d", isViewVisible);
        table.frame = CGRectMake(0, 0, btn.size.width, viewheight);
    }
    [UIView commitAnimations];
    
}

#pragma mark - tableview methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (btnSender) {
        return 50;
        return btnSender.frame.size.height;
    }
    if (textFieldSender) {
        return textFieldSender.frame.size.height;
    }
    return 200;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.list) {
        return [self.list count];
    }
    return 0;
}
- (UITableViewCell_NIDropDown *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell_NIDropDown *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        cell = [[UITableViewCell_NIDropDown alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell.textLabel setUIFont:kUIFontType18 isBold:false];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    }
    
    if ([self.imageList count] == [self.list count]) {
        cell.textLabel.text = [Utility getNormalStringFromAttributed:[list objectAtIndex:indexPath.row]];
        cell.imageView.image = [imageList objectAtIndex:indexPath.row];
    }
    else if ([self.imageList count] > [self.list count]) {
        cell.textLabel.text = [Utility getNormalStringFromAttributed:[list objectAtIndex:indexPath.row]];
        if (indexPath.row < [imageList count]) {
            cell.imageView.image = [imageList objectAtIndex:indexPath.row];
        }
    }
    else if ([self.imageList count] < [self.list count]) {
        cell.textLabel.text = [Utility getNormalStringFromAttributed:[list objectAtIndex:indexPath.row]];
        if (indexPath.row < [imageList count]) {
            cell.imageView.image = [imageList objectAtIndex:indexPath.row];
        }
    }
    if (cell.selectedBackgroundView == nil) {
        UIView * v = [[UIView alloc] init];
        [cell setSelectedBackgroundView:v];
    }
    if (cell.isSelected) {
        cell.textLabel.textColor = [Utility getUIColor:kUIColorBuyButtonFont];
        cell.selectedBackgroundView.backgroundColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
    } else {
        cell.textLabel.textColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
        cell.selectedBackgroundView.backgroundColor = [Utility getUIColor:kUIColorBuyButtonFont];
    }
   

    
    
    
    
    //    float newWidth = MAX(tableView.frame.size.width, LABEL_SIZE(cell.textLabel).width);
    //    CGRect cellTextRect = cell.frame;
    //    cellTextRect.origin.x = 0;
    //    cellTextRect.size.width = newWidth;
    //    cell.frame = cellTextRect;
    //
    //    [cell layoutSubviews];
    //    [cell.textLabel layoutSubviews];
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell.textLabel respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell.textLabel setLayoutMargins:UIEdgeInsetsZero];
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
    if (cell.selectedBackgroundView != nil) {
        [cell.selectedBackgroundView removeFromSuperview];
    }
    UIView * v = [[UIView alloc] init];
    [cell setSelectedBackgroundView:v];
    cell.selectedBackgroundView.backgroundColor = [Utility getUIColor:kUIColorBuyButtonFont];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self toggle:btnSender];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    int clickedItemId = (int)indexPath.row;
    
    [btnSender setTitle:[Utility getNormalStringFromAttributed:cell.textLabel.text] forState:UIControlStateNormal];
    
    for (UIView *subview in btnSender.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            [subview removeFromSuperview];
        }
    }
    imgView.image = cell.imageView.image;
    imgView = [[UIImageView alloc] initWithImage:cell.imageView.image];
    imgView.frame = CGRectMake(5, 5, 25, 25);
    [btnSender addSubview:imgView];
    
    [self myDelegate:clickedItemId];
    cell.textLabel.textColor = [Utility getUIColor:kUIColorBuyButtonFont];
    if (cell.selectedBackgroundView != nil) {
        [cell.selectedBackgroundView removeFromSuperview];
    }
    UIView * v = [[UIView alloc] init];
    [cell setSelectedBackgroundView:v];
    cell.selectedBackgroundView.backgroundColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
}
- (void)myDelegate:(int)clickedItemID {
    [self.delegate reponseDropDownDelegate:self clickedItemId:clickedItemID];
}

-(void)dealloc {
}
- (void)selectItemManually:(int)itemId textStr:(NSString*)textStr{
    [self toggle:btnSender];
    [btnSender setTitle:[self.list objectAtIndex:itemId] forState:UIControlStateNormal];
    for (UIView *subview in btnSender.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            [subview removeFromSuperview];
        }
    }
    [self myDelegate:itemId];
}
- (void)updateDataObjects:(UIButton *)button viewheight:(CGFloat)height strArr:(NSArray *)arr imgArr:(NSArray *)imgArr {
    btnSender = button;
    CGRect btn = button.frame;
    self.list = [NSArray arrayWithArray:arr];
    self.listFake = [NSArray arrayWithArray:arr];
    self.imageList = [NSArray arrayWithArray:imgArr];
    float maxHeight = list.count * BTN_SIZE_HEIGHT;
    float minHeight = height;
    if (minHeight > maxHeight) {
        height = maxHeight;
    }
    CGPoint btnUniversalPos = [button.superview convertPoint:button.frame.origin toView:_pView];
    if ([animationDirection isEqualToString:_up]) {
        self.frame = CGRectMake(btnUniversalPos.x, btnUniversalPos.y, btn.size.width, 0);
        self.layer.shadowOffset = CGSizeMake(-5, -5);
    }else if ([animationDirection isEqualToString:_down]) {
        self.frame = CGRectMake(btnUniversalPos.x, btnUniversalPos.y + BTN_SIZE_HEIGHT, btn.size.width, 0);
        self.layer.shadowOffset = CGSizeMake(-5, 5);
    }
    viewheight = height;
    if (table) {
        [table reloadData];
    }
}
- (NSString*)getStringAtIndex:(int)index {
    if (self.list && [self.list count] > index) {
        return [self.list objectAtIndex:index];
    }
    return @"";
}

- (NSString*)selectItemAtIndex:(int)index {
    NSString* stringSelected = @"";
    if (index < [self.list count]) {
        [self toggle:btnSender];
        stringSelected = [self.list objectAtIndex:index];
        [btnSender setTitle:stringSelected forState:UIControlStateNormal];
        for (UIView *subview in btnSender.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                [subview removeFromSuperview];
            }
        }
        [self myDelegate:index];
    }
    return stringSelected;
}
- (NSString*)selectItemForString:(NSString*)string {
    if ([self.list containsObject:string]) {
        [self toggle:btnSender];
        int index = (int)[self.list indexOfObject:string];
        return [self selectItemAtIndex:index];
    } else if([self.list count] > 0) {
        [self toggle:btnSender];
        int index = 0;
        return [self selectItemAtIndex:index];
    }
    return @"";
}
- (void)updateData:(UIButton*)button
            height:(float)height
       dataObjects:(NSArray*)dataObjects
       dataStrings:(NSArray*)dataStrings {
    [self updateDataObjects:button viewheight:height strArr:dataObjects imgArr:nil];
}
@end
