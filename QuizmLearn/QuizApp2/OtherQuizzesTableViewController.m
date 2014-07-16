//
//  OtherQuizzesTableViewController.m
//  QuizApp2
//
//  Created by Bruce Li on 2/6/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//
// This class is accessed when the user presses the 'more' button, revealing a list of other unlocked quizzes they are enrolled in
// This class is very similar to PastQuizVC and probably should have been subclassed

#import <Parse/Parse.h>
#import "Question.h"
#import "Quiz.h"
#import "OtherQuizzesTableViewController.h"
#import "QuestionViewController.h"


@interface OtherQuizzesTableViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *pastQuizCell;

@end

@implementation OtherQuizzesTableViewController

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

}

-(void)setUpRefresh{
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing Tests"];
    
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
}

-(void)refresh {
    
    
    if (!self.middleOfQuestion){
    
    PFQuery *queryUser = [PFUser query];
    [queryUser whereKey:@"username" equalTo:[PFUser currentUser].username];
    
    PFObject *user = [queryUser getFirstObject];
    
    NSString *courseName = user[@"StudentCourse"];
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"ImportedQuizzes"];
    [query selectKeys: @[@"QuizIdentifier", @"Course", @"QuizName", @"isLocked"]];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *pQuiz, NSError *error) {
        if (!error) {
            
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
    
    }
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
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Quiz *quiz = [self.listPastQuizzes objectAtIndex:indexPath.row];
    self.quizIdentifier = quiz.quizIdentifier;

    NSLog(@"The quiz Identifier for for past quiz view is %@", self.quizIdentifier);

    QuestionViewController *qvc = [[QuestionViewController alloc ] init];
    
    qvc.quizIdentifier = self.quizIdentifier;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

        NSIndexPath *index = [self.tableView indexPathForCell:sender];
   
        Quiz *quiz = [self.listPastQuizzes objectAtIndex:index.row];

        self.quizIdentifier = quiz.quizIdentifier;

}


@end
