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
    //if you are not logged in, login; otherwise if device is in portrait, set up the appropriate splitview delegates
    if (!loggedIn)
    {
        NSLog(@"initial view will appear");
        [self login];
    } else if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
    {
        [self.navigationItem.leftBarButtonItem.target performSelector:self.navigationItem.leftBarButtonItem.action withObject:self.navigationItem afterDelay:0.1];
    }
    
    //after you log in, check to see if this user is using an instructor account
    if (loggedIn) {
        PastQuizViewController *master = (PastQuizViewController *)[self.splitViewController.viewControllers[0] topViewController];
        [master refreshTests];
  
        
    }
    
    //set up your delegates for split views
    if (self.splitViewController.delegate == nil)
    {
        [self.splitViewController setDelegate:self];
    }
}



- (void)viewWillDisappear:(BOOL)animated
{
    self.splitViewController.delegate = nil;
}

//more split view delegate stuff during rotation
- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if (toInterfaceOrientation == UIDeviceOrientationPortrait) {
        if ([self.splitViewController.viewControllers[0] conformsToProtocol:@protocol(UISplitViewControllerDelegate)]) {
            self.splitViewController.delegate = self.splitViewController.viewControllers[0];
        }
        else {
            self.splitViewController.delegate = nil;
        }
    }
}


- (void)login{
    // Create the log in view controller
    NSLog(@"initial presents login");
    MyLoginViewController *logInViewController = [[MyLoginViewController alloc] init];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    
    logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton;

    
    [self presentViewController:logInViewController animated:NO completion:NULL];
}


- (void) logout {
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure?", nil) message:NSLocalizedString(@"Do you really want to sign out?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Yes", nil) otherButtonTitles:NSLocalizedString(@"Cancel",nil), nil] show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //if user presses 'Yes' to log out
    if (buttonIndex == 0){
        [PFUser logOut];
        
        loggedIn = NO;
        
        [self login];
    }
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoggedIn" object:nil];
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

#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || !field.length) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    
    PFQuery *queryInstructor = [PFUser query];
    [queryInstructor whereKey:@"username" equalTo:[PFUser currentUser].username];
    PFObject *instructor = [queryInstructor getFirstObject];
    instructor[@"isInstructor"] = @"YES";
    [instructor save];
    loggedIn = YES;
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoggedIn" object:nil];
        //launch the tutorial
        [self performSegueWithIdentifier:@"firstTimeTutorial" sender:self];
    }];
    
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
    
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Avaliable Tests", @"Avaliable Tests");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    //self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    //self.masterPopoverController = nil;
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
