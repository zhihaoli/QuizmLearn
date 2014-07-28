//
//  InitialViewController.m
//  Quizm Learn
//
//  Created by CIS1 on 2014-07-17.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import "InitialViewController.h"
#import <Parse/Parse.h>
#import "MyLoginViewController.h"
#import "PastQuizViewController.h"

@interface InitialViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation InitialViewController{
    BOOL loggedIn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"initial view did load");
    
    

    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    
    NSLog(@"this is happening");
    
    
    if (!loggedIn && [PFUser currentUser].username == nil && UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
        [self setUpLogin];
    }
    
    
    if (loggedIn || [PFUser currentUser].username != nil){
        //[self.navigationItem.leftBarButtonItem.target performSelector:self.navigationItem.leftBarButtonItem.action withObject:self.navigationItem afterDelay:0.1];
        [self makeDetailViewTranslucent];
        PastQuizViewController *master = (PastQuizViewController *)[self.splitViewController.viewControllers[0] topViewController];
        [master refreshTests];
        
    }
    
    //if you are not logged in, login; otherwise if device is in portrait, set up the appropriate splitview delegates
 
    //if (notLoggedIn && UIDeviceOrientationIsPortrait(UIInterfaceOrientation))
    
    
    //set up your delegates for split views
//    if (self.splitViewController.delegate == nil)
//    {
//        [self.splitViewController setDelegate:self];
//    }
}

//set the overlay text on top of the translucent view
- (UILabel *) setTextOfTranslucentView{
    
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 80, 700, 150)];
    textLabel.text = [NSString stringWithFormat:@"Welcome to SmarTEST Student %@!\n \n Get started by selecting a test from the left\n \nPlease remember to go log out when you are done!", [PFUser currentUser].username];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:24]];
    textLabel.numberOfLines = 5;
    [textLabel setTextAlignment:NSTextAlignmentCenter];
    textLabel.textColor = [UIColor blackColor];
    return textLabel;
    
}

//set the translucency on the detail view
- (void) makeDetailViewTranslucent{

    id mostRecentSubview = self.view.subviews.lastObject;
    
    // If the last subview isnt a translucent view, make it one!
    if (![mostRecentSubview isKindOfClass:[ILTranslucentView class]]){
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        ILTranslucentView *translucentView = [[ILTranslucentView alloc] initWithFrame:screenRect];
        
        //Make the logo on InitialView more visible by setting a lower alpha on it
        if ([[self.splitViewController.viewControllers[1] topViewController] isKindOfClass:[InitialViewController class]]){
            translucentView.translucentAlpha = 0.9;
        }else{
            translucentView.translucentAlpha = 1;
            
        }
        
        //Set the properties of the translucent view
        //NOTE: to be deprecated by iOS 8 UIVisualEffects
        translucentView.translucentStyle = UIBarStyleDefault;
        translucentView.translucentTintColor = [UIColor clearColor];
        translucentView.backgroundColor = [UIColor clearColor];
        
        self.navigationItem.title = @"Welcome";
        UILabel *textLabel = [self setTextOfTranslucentView];
        [translucentView addSubview:textLabel];
        [self.view addSubview:translucentView];
        [UIView transitionWithView:self.view duration:0.37 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            
        }completion:nil];
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    //self.splitViewController.delegate = nil;
}

//more split view delegate stuff during rotation
- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}

- (void)setUpLogin {
    MyLoginViewController *logInViewController = [[MyLoginViewController alloc] init];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    
    logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton;
    
    //bring up the login screen
    [self presentViewController:logInViewController animated:NO completion:NULL];
}

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    NSLog(@"User logged in");
    loggedIn = YES;
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoggedIn" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid login credentials!", nil) message:NSLocalizedString(@"Please check and re-enter your username and password", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Will do", nil) otherButtonTitles:nil] show];
    
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dismissed the logInViewController");
}



#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Avaliable Tests", @"Avaliable Tests");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
