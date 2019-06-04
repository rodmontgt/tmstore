//
//  ANTagsView.h
//  ANTagsView
//
//  Created by Adnan Nasir on 27/08/2015.

// This code is distributed under the terms and conditions of the MIT license.

// Copyright (c) 2015-2020 Adnan Nasir. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>
@class ANTagsView;

@protocol ANTagsViewDelegate<NSObject>
- (void)clickedOnLabel:(NSString*)string;
@end

@interface ANTagsView : UIView <UIGestureRecognizerDelegate>
{
    int tagXPos;
    int tagYPos;
    int viewHeight;
    int viewWidth;
    int tagRadius;
    int maxTagSize;
    NSArray *tagsToDisplay;
    UIColor *tagBGColor;
    UIColor *tagTextColor;
    BOOL enableMaxHeightConstraint;
    float maxHeight;
    UILabel* lastTag;
    
}
@property (nonatomic, weak) id<ANTagsViewDelegate> responseDelegate;
-(instancetype) initWithTags:(NSArray *)tagsArray;
-(instancetype) initWithTags:(NSArray *)tagsArray frame:(CGRect)frame;
-(instancetype) initWithTags:(NSArray *)tagsArray frame:(CGRect)frame delegate:(id)delegate;
-(void) setTagCornerRadius:(int)radius;
-(void) setTagBackgroundColor:(UIColor *)color;
-(void) setTagTextColor:(UIColor *)color;
-(void) setFrameWidth:(int)width;
-(BOOL) addTagInView:(NSString *)tag;
-(void) renderTagsOnView:(NSArray*)tags;
- (void)handleTap:(UITapGestureRecognizer*)sender;
- (void)setMaxHeightConstraint:(float)height;
@end
