#import "RCustomViewSegue.h"
//#import "RCustomViewController.h"
#import "ViewControllerMain.h"
@implementation RCustomViewSegue
- (void) perform {
//    RCustomViewController *customViewController = (RCustomViewController *)self.sourceViewController;
    ViewControllerMain *customViewController = (ViewControllerMain *)self.sourceViewController;
    
    UIViewController *destinationViewController = (UIViewController *) customViewController.destinationViewController;

    //remove old viewController
    if (customViewController.oldViewController) {
        [customViewController.oldViewController willMoveToParentViewController:nil];
        [customViewController.oldViewController.view removeFromSuperview];
        [customViewController.oldViewController removeFromParentViewController];
    }
    
    destinationViewController.view.frame = customViewController.containerCenter.bounds;
    [customViewController addChildViewController:destinationViewController];
    [customViewController.containerCenter addSubview:destinationViewController.view];
    [destinationViewController didMoveToParentViewController:customViewController];
}

@end
