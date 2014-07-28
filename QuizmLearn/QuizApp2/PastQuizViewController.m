//
//  PastQuizViewController.m
//  QuizApp2
//
//  Created by Bruce Li on 2/6/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import "PastQuizViewController.h"
#import <Parse/Parse.h>
#import "Question.h"
#import "MyLoginViewController.h"
#import "InitialViewController.h"


@interface PastQuizViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *pastQuizCell;

@end

@implementation PastQuizViewController{
    BOOL loginProcess;
    BOOL loggedIn;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self setUpLogin];
    
    NSLog(@"view did load");
    
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc]initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonTapped)];

    
    
    self.navigationItem.leftBarButtonItem = logoutButton;

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing Tests"];
    
    [refresh addTarget:self action:@selector(refreshTests) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
    

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSLog(@"view will appear");
    
    
    
     //[self makeDetailViewTranslucent];
    
        if (!loggedIn && [PFUser currentUser].username == nil)
        {
            loginProcess = YES;
            NSLog(@"initial view will appear");
            [self setUpLogin];
        } 
    
        //after you log in, check to see if this user is using an instructor account
        if ((loggedIn && loginProcess) || [PFUser currentUser].username != nil) {
            [self makeDetailViewTranslucent];
            [self refreshTests];

            loginProcess = NO;
        }
}




-(void)refreshTests {
    
    PFQuery *queryUser = [PFUser query];
    [queryUser whereKey:@"username" equalTo:[PFUser currentUser].username];
    
    PFObject *user = [queryUser getFirstObject];
    
    NSString *courseName = user[@"StudentCourse"];
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"ImportedQuizzes"];
    [query selectKeys: @[@"QuizIdentifier", @"Course", @"QuizName", @"isLocked"]];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *pQuiz, NSError *error) {
        if (!error) {
            
            //retrieve the list of unlocked quizzes in the course this group is enrolled in
            self.listPastQuizzes = [[NSMutableArray alloc]init];
            
            for (PFObject *quiz in pQuiz) {
                
                if ([quiz[@"Course"] isEqualToString:courseName] && [quiz[@"isLocked"] isEqualToString:@"NO"]){
                    Quiz *_quiz = [[Quiz alloc]init];
                    _quiz.course = quiz[@"Course"];
                    _quiz.quizName = quiz[@"QuizName"];
                    _quiz.quizIdentifier = quiz[@"QuizIdentifier"];
                    [self.listPastQuizzes addObject:_quiz];
                }
                
            }
            [self.tableView reloadData];
        }
    }];
    
    
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.5];
    
}

- (void)stopRefresh{
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.listPastQuizzes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (self.listPastQuizzes == nil) {
        return cell;
    } else {
        
        Quiz *quiz = [self.listPastQuizzes objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", quiz.course, quiz.quizName];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //cell.backgroundColor = [UIColor lightGrayColor];
    return cell;
}

#pragma mark - Table View Delegate


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    NSIndexPath *index = [indexPaths objectAtIndex:0];
    if ([segue.identifier isEqualToString:@"goToQuestion"]){
        
        QuestionViewController *destVC = (QuestionViewController *)[segue destinationViewController];
        
        UIViewController *realDetail = destVC;
        
        id mostRecentSubview = realDetail.view.subviews.lastObject;
        
        // If the last subview isnt a translucent view, make it one!
        if (![mostRecentSubview isKindOfClass:[ILTranslucentView class]]){
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            ILTranslucentView *translucentView = [[ILTranslucentView alloc] initWithFrame:screenRect];
            
            translucentView.translucentAlpha = 1;
            
            //Set the properties of the translucent view
            //NOTE: to be deprecated by iOS 8 UIVisualEffects
            translucentView.translucentStyle = UIBarStyleDefault;
            translucentView.translucentTintColor = [UIColor clearColor];
            translucentView.backgroundColor = [UIColor clearColor];
            
            realDetail.navigationItem.title = @"Loading Test";
            UILabel *textLabel = [self setLoadingTextOfTranslucentView];
            [translucentView addSubview:textLabel];
            [realDetail.view addSubview:translucentView];
            [UIView transitionWithView:realDetail.view duration:0.37 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                
            }completion:nil];
        }

        
        
        
        
        Quiz *quiz = [self.listPastQuizzes objectAtIndex:index.row];
        self.quizIdentifier = quiz.quizIdentifier;
        

        destVC.listPastQuizzes = self.listPastQuizzes;
        destVC.quizIdentifier = self.quizIdentifier;
        
         NSLog(@"quiz id for question segue is: %@", self.quizIdentifier);

    }
    
    if ([segue.identifier isEqualToString:@"goToQuiz"]){
        NSIndexPath *index = [self.tableView indexPathForCell:sender];
        Quiz *quiz = [self.listPastQuizzes objectAtIndex:index.row];
        self.quizIdentifier = quiz.quizIdentifier;
        QuizTableViewController *destVC = (QuizTableViewController *)[segue destinationViewController];
        NSLog(@"quiz id for quiz segue is: %@", self.quizIdentifier);
        destVC.quizIdentifier = self.quizIdentifier;

        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"goToQuiz" sender:indexPath];
    [self performSegueWithIdentifier:@"goToQuestion" sender:indexPath];
}

#pragma mark - Login/Logout Methods

- (void)setUpLogin {
    
    UIViewController *realDetail = [self getDetailViewController];
    id mostRecentSubview = realDetail.view.subviews[[realDetail.view.subviews count]-1];
    
    if ([mostRecentSubview isKindOfClass:[ILTranslucentView class]]){
        [[realDetail.view.subviews objectAtIndex:[realDetail.view.subviews count]-1]removeFromSuperview];
    }
    
    MyLoginViewController *logInViewController = [[MyLoginViewController alloc] init];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    
    logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton;
    loginProcess = YES;
    
    //bring up the login screen
    [self presentViewController:logInViewController animated:NO completion:NULL];
}



-(void)logoutButtonTapped {

    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure?", nil) message:NSLocalizedString(@"Do you really want to sign out?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Yes", nil) otherButtonTitles:NSLocalizedString(@"Cancel",nil), nil] show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //If the user selects 'Yes' to signing out
    if (buttonIndex == 0){
        
        [PFUser logOut];
        [self setUpLogin];
        
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


#pragma mark - Detail View Methods

-(id) getDetailViewController{
    id detail = self.splitViewController.viewControllers[1];
    if ([detail isKindOfClass:[UINavigationController class]]){
        detail = [detail topViewController];
    }
    
    return detail;
}

//set the translucency on the detail view
- (void) makeDetailViewTranslucent{
    
    UIViewController *realDetail = [self getDetailViewController];
    
    id mostRecentSubview = realDetail.view.subviews.lastObject;
    
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
        
        realDetail.navigationItem.title = @"Welcome";
        UILabel *textLabel = [self setTextOfTranslucentView];
        [translucentView addSubview:textLabel];
        [realDetail.view addSubview:translucentView];
        [UIView transitionWithView:realDetail.view duration:0.37 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            
        }completion:nil];
    }
}

//set the overlay text on top of the translucent view
- (UILabel *) setTextOfTranslucentView{
    
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 80, 700, 150)];
    textLabel.text = [NSString stringWithFormat:@"Welcome to SmarTEST Student %@!\n \n Get started by selecting a test from the left\n \n Please remember to log out when you are done!", [PFUser currentUser].username];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:24]];
    textLabel.numberOfLines = 5;
    [textLabel setTextAlignment:NSTextAlignmentCenter];
    textLabel.textColor = [UIColor blackColor];
    return textLabel;
    
}

- (UILabel *) setLoadingTextOfTranslucentView{
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 80, 700, 100)];
    textLabel.text = [NSString stringWithFormat:@"Good things come to those who wait...loading your test!"];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:24]];
    textLabel.numberOfLines = 3;
    [textLabel setTextAlignment:NSTextAlignmentCenter];
    textLabel.textColor = [UIColor blackColor];
    return textLabel;
}



@end
