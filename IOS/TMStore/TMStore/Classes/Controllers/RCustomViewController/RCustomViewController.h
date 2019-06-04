#import <UIKit/UIKit.h>
@interface RCustomViewController : UIViewController

@property (weak, nonatomic) UIViewController *destinationViewController;
@property (strong, nonatomic) UIViewController *oldViewController;
@property (weak, nonatomic) IBOutlet UIView *container;

@property (weak, nonatomic) UIViewController *yourViewController;

@property (weak, nonatomic) IBOutlet UIButton *tabBtn1;
@property (weak, nonatomic) IBOutlet UIButton *tabBtn2;
@property (weak, nonatomic) IBOutlet UIButton *tabBtn3;

- (IBAction)btnClicked:(id)sender;

@end
