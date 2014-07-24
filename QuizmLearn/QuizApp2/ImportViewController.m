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

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (weak, nonatomic) IBOutlet UILabel *groupNameWelcome;
@property (strong, nonatomic) NSMutableArray *listPastQuizzes;

@property (weak, nonatomic) IBOutlet UITableView *pastQuizTable;


@end

@implementation ImportViewController

BOOL isPortrait;
BOOL isLandscape;
BOOL isValid;
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
    
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing Tests"];
    
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];

    
    [self refresh];
    
    self.groupNameWelcome.text = [NSString stringWithFormat:@"Welcome to SmarTEST Student\n %@", _groupName];
    
}

-(void)refresh {
    
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
            [self.pastQuizTable reloadData];
        }
    }];
    
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.5];
    
}

- (void)stopRefresh{
    
    
    //[self.refreshControl endRefreshing];
}



- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
    isLandscape = UIDeviceOrientationIsLandscape(self.interfaceOrientation);

    if (isPortrait){
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"QuizmLearnLoginBG.png"]]];
           }else if (isLandscape){
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"QuizmLearnLoginBGLandscape.png"]]];
       
    }

   }

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View Data Source

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

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self performSegueWithIdentifier:@"goToQuiz" sender:self];
//}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goToQuiz"]){
        
        NSIndexPath *index = [self.pastQuizTable indexPathForCell:sender];
        
        Quiz *quiz = [self.listPastQuizzes objectAtIndex:index.row];
        self.quizIdentifier = quiz.quizIdentifier;
        
        QuestionViewController *destVC = (QuestionViewController *)[segue destinationViewController];
        destVC.listPastQuizzes = self.listPastQuizzes;
        
    }
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
