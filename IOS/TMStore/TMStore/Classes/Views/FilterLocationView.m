//
//  FilterLocationView.m
//  TMStore
//
//  Created by Twist Mobile on 03/11/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "FilterLocationView.h"
#import "LocationCell.h"
#import "TMLanguage.h"
#import "Utility.h"

@interface FilterLocationView ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet FilterLocationView *contentView;

@end

@implementation FilterLocationView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {                                                                                                                                                                                                                                                                                                                                                                                                            
        [self setup];
    }
    return self;
}

- (void)setup {
    
    _lblRangeUnit.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _lblRangeUnit.layer.shadowOffset = CGSizeMake(0, 2);
    _lblRangeUnit.layer.shadowOpacity = 0.8;
    _lblRangeUnit.layer.shadowRadius = 3;
    _lblRangeUnit.layer.masksToBounds = NO;
    _lblRangeUnit.layer.borderWidth = 1;
    _lblRangeUnit.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    [[NSBundle mainBundle] loadNibNamed:@"FilterLocationView" owner:self options:nil];
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
    [self.tfRange setKeyboardType:UIKeyboardTypeNumberPad];
//    _tfRange.keyboardType = UIKeyboardTypeNumberPad;
//    _arrMeter= @[Localize(@"kilometer"), Localize(@"mile")];
    _arrMeter= @[Localize(@"kilometer")];

    _tableRangeUnit.hidden = true;
    _lblRangeUnit.text = Localize(@"kilometer");
    _tableRangeUnit.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _tableRangeUnit.layer.shadowOffset = CGSizeMake(0, 2);
    _tableRangeUnit.layer.shadowOpacity = 0.8;
    _tableRangeUnit.layer.shadowRadius = 3;
    _tableRangeUnit.layer.masksToBounds = NO;
    _locationSearch.layer.borderWidth = 1;
    _locationSearch.layer.borderColor = [[UIColor whiteColor] CGColor];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{
                                                                                                 NSForegroundColorAttributeName : [UIColor blackColor],
                                                                                                 NSFontAttributeName : [UIFont systemFontOfSize:15]
                                                                                                 }];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundColor:[UIColor colorWithRed:230/255.0 green:230/255.0 blue:232/255.0 alpha:1]];
    [self.locationSearch setSearchBarStyle:UISearchBarStyleMinimal];
    [self.locationSearch setTranslucent:YES];
//    [self.locationSearch setTintColor:[UIColor whiteColor]];
    self.locationSearch.barTintColor = [UIColor whiteColor];

    [_btnCurrentLocation setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [_btnCurrentLocation setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
   

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
   self.tableRangeUnit.hidden = true;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_arrMeter count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 38;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        NSLog(@"%f",_tableRangeUnit.contentSize.height);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * idnt = @"identifier";
    
    LocationCell * cell = [tableView dequeueReusableCellWithIdentifier:idnt];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"LocationCell" bundle:nil] forCellReuseIdentifier:idnt];
        cell = [tableView dequeueReusableCellWithIdentifier:idnt];
    }
    cell.lbltitle.text = [_arrMeter objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableRangeUnit.hidden = true;
    _lblRangeUnit.text = _arrMeter[indexPath.row];
}

- (IBAction)actionRangeUnit:(id)sender {
    self.tableRangeUnit.hidden = false;

}

@end
