//
//  NIDropDown.h
//  NIDropDown
//
//  Created by Bijesh N on 12/28/12.
//  Copyright (c) 2012 Nitor Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UITableViewCell_NIDropDown : UITableViewCell
@end

@class NIDropDown;
@protocol NIDropDownDelegate
- (void)reponseDropDownDelegate:(NIDropDown *)sender clickedItemId:(int)clickedItemId;
@end
enum NIDropDownDirection{
    NIDropDownDirectionUp,
    NIDropDownDirectionDown,
};

@interface NIDropDown : UIView <UITableViewDelegate, UITableViewDataSource>
{
    NSString *animationDirection;
    UIImageView *imgView;
    float viewheight;
    BOOL isViewVisible;
}
@property UITableView* tableView;
@property int fontSize;
@property NSString *fontName;
@property UIColor *fontColor;
@property UIView* pView;

@property (nonatomic, retain) id <NIDropDownDelegate> delegate;
@property (nonatomic, retain) NSString *animationDirection;

-(void)toggle:(UIButton *)button;
-(void)toggleWithMainFrame:(UIButton *)button;
-(void)toggleTextField:(UITextField *)textField;
- (id)init:(UIButton *)button viewheight:(CGFloat)height  strArr:(NSArray *)arr  imgArr:(NSArray *)imgArr direction:(int)direction pView:(UIView*)pView;
- (id)initTextField:(UITextField *)textField viewheight:(CGFloat)height  strArr:(NSArray *)arr  imgArr:(NSArray *)imgArr direction:(int)direction pView:(UIView*)pView;
- (void)selectItemManually:(int)itemId textStr:(NSString*)textStr;
- (BOOL)isDropDownViewVisible;
- (void)setDropDownViewVisible:(BOOL)value;
- (void)updateDataObjects:(UIButton *)button viewheight:(CGFloat)height strArr:(NSArray *)arr imgArr:(NSArray *)imgArr;
- (NSString*)getStringAtIndex:(int)index;
- (NSString*)selectItemAtIndex:(int)index;
- (NSString*)selectItemForString:(NSString*)string;
- (void)updateData:(UIButton*)button
            height:(float)height
       dataObjects:(NSArray*)dataObjects
       dataStrings:(NSArray*)dataStrings;
@end
