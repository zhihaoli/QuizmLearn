//
//  ImportViewController.m
//  QuizApp2
//
//  Created by Bruce Li on 1/30/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import "ImportViewController.h"
#import "Question.h"
#import "QuizTableViewController.h"
#import "PastQuizViewController.h"

@interface ImportViewController ()
@property (weak, nonatomic) IBOutlet UITextField *quizName;
@property (weak, nonatomic) IBOutlet UITextField *instructor;
@property (weak, nonatomic) IBOutlet UITextField *course;
@property (weak, nonatomic) IBOutlet UITextField *section;
@property (weak, nonatomic) IBOutlet UITextField *date;
@property (weak, nonatomic) IBOutlet UITextField *timer;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;


@end

@implementation ImportViewController
{
   // BOOL loggedIn;
}

NSArray * questions;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    
    //if (!loggedIn) {
        [super viewWillAppear:animated];
        NSLog(@"Not logged in");
        //self.welcomeLabel.text = NSLocalizedString(@"Not logged in", nil);
    //}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - ()

- (IBAction)logOutButtonTapAction:(id)sender {
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"See Quiz", @"See Quiz");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}
@end
