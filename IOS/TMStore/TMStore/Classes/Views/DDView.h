//
//  DDView.h
//  TMStore
//
//  Created by Rishabh Jain on 25/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIDropDown.h"
@class DDView;
@protocol DDViewDelegate
- (void)reponseDDViewDelegate:(DDView *)sender
                clickedItemId:(int)clickedItemId
             clickedItemTitle:(NSString*)clickedItemTitle
            clickedItemObject:(id)clickedItemObject;
@end


@interface DDView : UIView <NIDropDownDelegate>
@property UILabel* labelSelection;
@property UIButton* buttonSelection;
@property UIButton* buttonSelectionDownArrow;
@property NIDropDown* ddViewSelection;

@property NSArray* dataObjects;
@property NSArray* dataStrings;
@property UIView* parentView;
//@property id delegate;
@property (nonatomic, retain) id <DDViewDelegate> delegate;
@property NSString* default_value;
- (id)initWithDelegate:(id)delegate
            parentView:(UIView*)parentView
          defaultValue:(NSString*)defaultValue
           dataObjects:(NSArray*)dataObjects
           dataStrings:(NSArray*)dataStrings;
- (NSString*)selectItemForString:(NSString*)str;
- (NSString*)selectItemAtIndex:(int)index;
- (void)updateData:(NSString*)defaultValue
       dataObjects:(NSArray*)dataObjects
       dataStrings:(NSArray*)dataStrings;
- (void)openDropdownView;
@end


