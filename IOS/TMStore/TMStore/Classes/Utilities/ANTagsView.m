//
//  ANTagsView.m
//  ANTagsView
//
//  Created by Adnan Nasir on 27/08/2015.
//  Copyright (c) 2015 Adnan Nasir. All rights reserved.
//

#import "ANTagsView.h"
#import "Variables.h"
#define TAG_SPACE_HORIZONTAL 10 //10todo
#define TAG_SPACE_VERTICAL 10 // 5
#define DEFAULT_VIEW_HEIGHT 60//40
#define MAX_TAG_SIZE 150
#define MIN_TAG_SIZE 10  //40
#define DEFAULT_VIEW_WIDTH MAX_TAG_SIZE+20
#define DEFAULT_TAG_CORNER_RADIUS 12
#define DEFAULT_LEFT_WIDTH 10
#define MAX_TAG_COUNT -1
@implementation ANTagsView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
-(instancetype) initWithTags:(NSArray *)tagsArray
{
    self = [super init];
    if(self)
    {
        viewWidth = DEFAULT_VIEW_WIDTH;
        tagsToDisplay = tagsArray;
        maxTagSize = DEFAULT_VIEW_WIDTH - TAG_SPACE_HORIZONTAL;
        tagRadius = DEFAULT_TAG_CORNER_RADIUS;
        tagTextColor = [UIColor blueColor];
        tagBGColor = [UIColor grayColor];
    }
    return self;
    
}
- (instancetype) initWithTags:(NSArray *)tagsArray frame:(CGRect)frame
{
    return [self initWithTags:tagsArray frame:frame delegate:nil];
}
- (instancetype) initWithTags:(NSArray *)tagsArray frame:(CGRect)frame delegate:(id)delegate {
    self = [super initWithFrame:frame];
    if(self)
    {
        self.responseDelegate = delegate;
        viewWidth = frame.size.width;
        
        NSMutableArray* array = [[NSMutableArray alloc] init];
        int i = 0;
        for (NSString* str in tagsArray) {
            if (MAX_TAG_COUNT == -1 || i < MAX_TAG_COUNT) {
                [array addObject:str];
            }
            i++;
        }
        tagsToDisplay = [NSArray arrayWithArray:array];
        
        maxTagSize = DEFAULT_VIEW_WIDTH - TAG_SPACE_HORIZONTAL;
        tagRadius = DEFAULT_TAG_CORNER_RADIUS;
        tagTextColor = [UIColor blueColor];
        tagBGColor = [UIColor grayColor];
        [self renderTagsOnView:tagsToDisplay];
        
    }
    return self;
}

-(void) renderTagsOnView:(NSArray*)tags
{
    [self removeAllTags];
    tagsToDisplay = [[NSArray alloc] initWithArray:tags];
    tagXPos = TAG_SPACE_HORIZONTAL;
    tagYPos = TAG_SPACE_VERTICAL;
    viewHeight = DEFAULT_VIEW_HEIGHT;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, viewWidth, viewHeight);
    for (NSString *tag in tagsToDisplay)
    {
        BOOL addMore = [self addTagInView:tag];
        if (addMore == false) {
            break;
        }
        
    }
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, viewWidth, viewHeight);
}
-(void) setTagBackgroundColor:(UIColor *)color
{
    tagBGColor = color;
    for (UIView *view in self.subviews)
    {
        if([view isKindOfClass:[UILabel class]])
        {
            UILabel *tag = (UILabel *)view;
            tag.backgroundColor = tagBGColor;
        }
    }
}

-(void) removeAllTags
{
    for (UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
}
-(void) setFrameWidth:(int)width;
{
  // viewWidth = width+viewWidth;
    viewWidth = viewWidth-TAG_SPACE_HORIZONTAL;
    maxTagSize = viewWidth - TAG_SPACE_HORIZONTAL;
    [self renderTagsOnView:tagsToDisplay];
}

-(void) setTagTextColor:(UIColor *)color
{
    tagTextColor = color;
    for (UIView *view in self.subviews)
    {
        if([view isKindOfClass:[UILabel class]])
        {
            UILabel *tag = (UILabel *)view;
            tag.textColor = tagTextColor;
        }
    }
}

-(void) setTagCornerRadius:(int)radius
{
    tagRadius = radius;
    for (UIView *view in self.subviews)
    {
        if([view isKindOfClass:[UILabel class]])
        {
            UILabel *tag = (UILabel *)view;
            tag.layer.masksToBounds = YES;
            tag.layer.cornerRadius = tagRadius;
        }
    }
}
-(BOOL) addTagInView:(NSString *)tag
{
    
    
    UILabel *tagLabel = [[UILabel alloc]init];
    UIFont *tagFont = [UIFont fontWithName:@"Helvetica Neue" size:18];
    CGSize maximumLabelSize = CGSizeMake( maxTagSize, CGRectGetWidth(self.bounds) );
    
    CGSize expectedLabelSize = [tag sizeWithFont:tagFont
                               constrainedToSize:maximumLabelSize
                                   lineBreakMode:[tagLabel lineBreakMode]];
    expectedLabelSize.width += 16;//RISHABH
    expectedLabelSize.height += 5;
    if(expectedLabelSize.width < MIN_TAG_SIZE)
        expectedLabelSize.width = MIN_TAG_SIZE;
//    PLOG(@"   tagslabel%f",expectedLabelSize.width);
    
    
    if (enableMaxHeightConstraint && viewHeight > maxHeight) {
        viewHeight -= (expectedLabelSize.height + TAG_SPACE_HORIZONTAL);
        if (lastTag) {
            [lastTag removeFromSuperview];
            lastTag = nil;
        }
        return false;
    }
    
    if((tagXPos + expectedLabelSize.width) > self.frame.size.width)
    {
        tagXPos = TAG_SPACE_HORIZONTAL;
        tagYPos += expectedLabelSize.height + TAG_SPACE_VERTICAL;
        viewHeight += expectedLabelSize.height + TAG_SPACE_HORIZONTAL;
    }
    
    
    
    tagLabel.frame = CGRectMake(tagXPos, tagYPos, expectedLabelSize.width, expectedLabelSize.height);
    tagLabel.text = tag;
    tagLabel.numberOfLines = 3;
    tagLabel.textAlignment = NSTextAlignmentCenter;
    tagLabel.backgroundColor = tagBGColor;
    tagLabel.textColor = tagTextColor;
    tagLabel.layer.masksToBounds = YES;
    tagLabel.layer.cornerRadius = tagRadius;
    [self addSubview:tagLabel];
    lastTag = tagLabel;
    [self setClipsToBounds:true];
    tagXPos += tagLabel.frame.size.width + TAG_SPACE_HORIZONTAL;
//    UITapGestureRecognizer *gesRecognizer = [[UITapGestureRecognizer alloc]
//                                            initWithTarget:self
//                                            action:@selector(handleTap:)];
//    gesRecognizer.delegate = self;
//    // Add Gesture to your view.
//    [self addGestureRecognizer:gesRecognizer];
  
    
    UITapGestureRecognizer *gesRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(handleTap:)];
    gesRecognizer.delegate = self;
    [tagLabel addGestureRecognizer:gesRecognizer];
    [tagLabel setUserInteractionEnabled:true];
    
    

    return true;
}
- (void)handleTap:(UITapGestureRecognizer*)sender {
    UILabel* label = (UILabel*)sender.view;
    PLOG(@"%@", label.text);
    [self.responseDelegate clickedOnLabel:label.text];
}
- (void)setMaxHeightConstraint:(float)height {
    enableMaxHeightConstraint = true;
    maxHeight = height;
    [self renderTagsOnView:tagsToDisplay];
}
@end
