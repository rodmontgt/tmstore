#import "RCustomViewController.h"
#import "RCustomViewSegue.h"
#import "Variables.h"
@interface RCustomViewController ()

@property (nonatomic, strong) NSMutableDictionary *viewControllersByIdentifier;
@property (strong, nonatomic) NSString *destinationIdentifier;
@property (nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@end

@implementation RCustomViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    
    self.viewControllersByIdentifier = [NSMutableDictionary dictionary];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    
    if (self.childViewControllers.count < 1) {
        [self performSegueWithIdentifier:@"viewController1" sender:[self.buttons objectAtIndex:0]];
    }

}
- (void)didReceiveMemoryWarning {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    
    [[self.viewControllersByIdentifier allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if (![self.destinationIdentifier isEqualToString:key]) {
            [self.viewControllersByIdentifier removeObjectForKey:key];
        }
    }];
    
    [super didReceiveMemoryWarning];
}
//- (NSUInteger)supportedInterfaceOrientations
//{
//    //Forced Portrait mode
//    return UIInterfaceOrientationMaskPortrait;
//}

//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    self.destinationViewController.view.frame = self.container.bounds;
//}
//
#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if (![segue isKindOfClass:[RCustomViewSegue class]]) {
        [super prepareForSegue:segue sender:sender];
        return;
    }
    
    self.oldViewController = self.destinationViewController;
    
    //if view controller isn't already contained in the viewControllers-Dictionary
    RLOG(@"####segue.identifier=%@", segue.identifier);
    
    
    if (![self.viewControllersByIdentifier objectForKey:segue.identifier]) {
        [self.viewControllersByIdentifier setObject:segue.destinationViewController forKey:segue.identifier];
    }
    
    [self.buttons setValue:@NO forKeyPath:@"selected"];
    [sender setSelected:YES];
    self.destinationIdentifier = segue.identifier;
    self.destinationViewController = [self.viewControllersByIdentifier objectForKey:self.destinationIdentifier];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([self.destinationIdentifier isEqual:identifier]) {
        //Dont perform segue, if visible ViewController is already the destination ViewController
        return NO;
    }
    
    return YES;
}

#pragma mark - Methods


- (IBAction)btnClicked:(id)sender
{
    NSString* nss = [sender restorationIdentifier];
    if ([nss isEqualToString:@"vc1"]){
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UIViewController *toViewController = [sb instantiateViewControllerWithIdentifier:@"FirstViewController"];
        RCustomViewSegue *segue = [[RCustomViewSegue alloc] initWithIdentifier:@"viewController1" source:self destination:toViewController];
        [self prepareForSegue:segue sender:sender];
        [segue perform];
    }else if ([nss isEqualToString:@"vc2"]){
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UIViewController *toViewController = [sb instantiateViewControllerWithIdentifier:@"SecondViewController"];
        RCustomViewSegue *segue = [[RCustomViewSegue alloc] initWithIdentifier:@"viewController2" source:self destination:toViewController];
        [self prepareForSegue:segue sender:sender];
        [segue perform];
    }else if ([nss isEqualToString:@"vc3"]){
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UIViewController *toViewController = [sb instantiateViewControllerWithIdentifier:@"ThirdViewController"];
        RCustomViewSegue *segue = [[RCustomViewSegue alloc] initWithIdentifier:@"viewController3" source:self destination:toViewController];
        [self prepareForSegue:segue sender:sender];
        [segue perform];
    }
    //Write a code you want to execute on buttons click event
}
@end
