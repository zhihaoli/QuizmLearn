//
//  QuizTableViewController.m
//  QuizApp2
//
//  Created by Bruce Li on 2/5/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import <Parse/Parse.h>
#import "Question.h"
#import "QuizTableViewController.h"
#import "OtherQuizzesTableViewController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface QuizTableViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *otherQuizzesButton;
@property (strong, nonatomic) UIPopoverController *popoverController;

@property (strong,nonatomic) NSMutableArray *questionIDs;
@property (strong, nonatomic) NSMutableArray *quiz;

@end

@implementation QuizTableViewController

@synthesize popoverController, quiz, resultsArray;

NSUInteger displayQuestion;
NSMutableArray *attemptsArray;
NSUInteger questionsViewed;
NSIndexPath *indexPath2;
NSNumber *indexNum;
NSNumber *attemptsUsed;
NSMutableArray *colours;
NSInteger fastQuizLength;


- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


//When the 'more' button is tapped, bring up a popover table of other past quizzes that are avaliable to the student
- (IBAction)otherQuizzesClicked:(id)sender {
    
    
    OtherQuizzesTableViewController *otherQuizPopover = [[OtherQuizzesTableViewController alloc] init];
    
    otherQuizPopover.listPastQuizzes = self.listPastQuizzes;
   
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:otherQuizPopover];
    
    [self.popoverController setPopoverContentSize:CGSizeMake(310, 170)];
    
    [self.popoverController presentPopoverFromBarButtonItem:self.otherQuizzesButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
    
}

//upon returning from a past quiz selection, reset the views and content with that from the new quiz
- (IBAction)unwindFromOtherQuizzes:(UIStoryboardSegue *)segue {
    
    OtherQuizzesTableViewController *source = [segue sourceViewController];
    self.quizIdentifier = source.quizIdentifier;
    
    QuestionViewController *qvc = (QuestionViewController *)[self.splitViewController.viewControllers[1] topViewController];
    
    qvc.quizIdentifier = source.quizIdentifier;
    
    [self loadQuizData];
    [self displayFirstQuestion];
    

}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self.tableView reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating Quiz"];
    
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
}


-(void)refresh {

    [self checkForRelease];
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
    
}

- (void)stopRefresh{
    [self.refreshControl endRefreshing];
}


- (void)loadQuizData{
    
    self.navigationItem.title = self.quizIdentifier;
    
    self.questionIDs = [[NSMutableArray alloc] init];
    quiz = [[NSMutableArray alloc] init];
    
    
    //    still iffy about using a GCD queue here...
    //    dispatch_queue_t queue;
    //    queue = dispatch_queue_create("ca.QuizTable.Retrievequestions", NULL);
    //
    //    dispatch_async(queue, ^{
    PFQuery *query = [PFQuery queryWithClassName:[NSString stringWithFormat:@"%@",self.quizIdentifier]];
    
    [query selectKeys: @[@"questionNumber", @"questionContent", @"answerA", @"answerB", @"answerC", @"answerD", @"answerE", @"correctAnswer", @"questionType", @"questionRelease", @"numberOfAnswers", @"sortedQNumber"]];
    [query orderByAscending:@"questionNumber"];
    NSArray *questions = [[NSArray alloc]init];
    questions = [query findObjects ];
    
    
    NSLog(@"TabBar: Successfully retrieved %lu Questions.", (unsigned long)questions.count);
    
    [self initializeQuizArrayWithThisNumber:[questions count]];
    fastQuizLength = [questions count];
    
    
    //retrieving questions from Parse
    for (PFObject *question in questions) {
        
        Question *_question = [[Question alloc] init];
        
        _question.questionNumber = question[@"questionNumber"];
        _question.questionContent = question[@"questionContent"];
        _question.answerA = question[@"answerA"];
        _question.answerB = question[@"answerB"];
        _question.answerC = question[@"answerC"];
        _question.answerD = question[@"answerD"];
        _question.answerE = question[@"answerE"];
        _question.applicationReleased = [question[@"questionRelease"] boolValue];
        _question.qtype = question[@"questionType"];
        _question.numberOfAnswers = [question[@"numberOfAnswers"] intValue];
        _question.sortedQNumber = [question[@"sortedQNumber"] intValue];
        _question.correctAnswer = question[@"correctAnswer"];
        _question.questionRelease = question[@"questionRelease"];
        
    
        NSMutableArray *rowSecId = [[NSMutableArray alloc] initWithObjects: [NSString stringWithFormat:@"%d",_question.sortedQNumber] , _question.qtype, [question objectId], nil];
        
        [self.questionIDs addObject:rowSecId];
        
        [quiz replaceObjectAtIndex:[_question.questionNumber integerValue] withObject:_question];
        
        NSLog(@"TabBar: Successfully retrieved Question %@.", question[@"questionNumber"]);
    }
    
    
    PFQuery *checkResultsArray = [PFQuery queryWithClassName:[NSString stringWithFormat:@"%@_Results", self.quizIdentifier]];
    
    
    //get the results from this user
    //[checkResultsArray selectKeys:@[[NSString stringWithFormat:@"%@", [PFUser currentUser].username]]];
    NSArray *results = [[NSArray alloc]init];
    [checkResultsArray orderByAscending:@"createdAt"];
    [checkResultsArray setLimit:1000];
    results = [checkResultsArray findObjects];
    
    NSLog(@"%lu",[results count]);
    
    //RETRIEVE THE VERY FIRST SET OF RESULTS FROM THE USER
    
    PFObject *pfResult;
   
    for (PFObject *result in results) {
        
        if (result[[NSString stringWithFormat:@"%@", [PFUser currentUser].username]] != nil){
            pfResult = result;
            break;
        }
    }
    
    resultsArray = pfResult[[NSString stringWithFormat:@"%@", [PFUser currentUser].username]];
    
    NSLog(@"%lu",[resultsArray count]);
    
    if (![resultsArray count]){
        
        resultsArray = [[NSMutableArray alloc] init];
        for (int j = 0; j<[self.quiz count]; j++){
            [resultsArray addObject:@0];
        }
    }
    
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:1];
    
}

-(void) reloadData {
    [self.tableView reloadData];
}

- (void) checkForRelease{
    
    
    PFQuery *releaseQuery = [PFQuery queryWithClassName:[NSString stringWithFormat:@"%@", self.quizIdentifier]];
    
    [releaseQuery selectKeys:@[@"questionRelease", @"questionNumber"]];
    [releaseQuery findObjectsInBackgroundWithBlock:^(NSArray *questions, NSError *error) {
        
        for (PFObject *question in questions) {
            
            Question *q = [quiz objectAtIndex:[question[@"questionNumber"]integerValue]];
            
            if ([q.qtype isEqualToString:@"1"]){ //if an application question is not released
                q.questionRelease = question[@"questionRelease"];
                NSLog(@"got newly released question %@", question[@"questionNumber"]);
            }
        }
        
    }];
    
     [self performSelector:@selector(reloadData) withObject:nil afterDelay:1];
}


- (void)displayFirstQuestion{
    
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}


//This method returns the quiz length; this info needs to be in the right place at the right time
- (NSInteger)giveQuizLength{
  //  NSLog(@"qtvc gave quiz count %d", [quiz count]);
    return fastQuizLength;
}


- (void)initializeQuizArrayWithThisNumber:(NSUInteger)count{
    NSLog(@"The quiz array is being intialized with %lu spots", (unsigned long)count);
    for (int i = 0; i <= count; i++)
    {
        [quiz addObject:@0];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [quiz count] ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //detect which questions are RAP and which are Application, so they can be numbered appropriately
    // Return the number of rows in the section.
    int rapQs = 0;
    int appQs = 0;
    if ([quiz count]){
        for (int i = 1; i< [quiz count]; i++){
            Question *q = [quiz objectAtIndex:i];
            
            if ([q.qtype integerValue] ==  0){
                rapQs++;
            }
            else if ([q.qtype integerValue] ==  1){
                appQs++;
            }
        }
    }
    
    return ( section == 0 ? rapQs : appQs);
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    
    UILabel *v = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    [v setTextAlignment:NSTextAlignmentCenter];
    v.backgroundColor = UIColorFromRGB(0x70b4f3);
    v.alpha = 1;
    
    v.text = ( section == 0 ? ([quiz count] ? @"RAP Questions" : @"LOADING") : ([quiz count] ? @"Application Questions" : @"" ));
    v.tintColor = [UIColor whiteColor];
    return v;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //Use tags to access the different elements of the cell
    UILabel *questionNumberCellLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *questionContentCellLabel = (UILabel *)[cell viewWithTag:2];
    UIImageView *applicationResultCellImage = (UIImageView *)[cell viewWithTag:3];
    UIProgressView *progressView = (UIProgressView *)[cell viewWithTag:4];
    
    UILabel *attemptsUsedFraction = (UILabel *)[cell viewWithTag:5];
    
     progressView.tintColor = UIColorFromRGB(0x4CD964);
    
    if (indexPath.section == 0){
        
        Question *q = [quiz objectAtIndex:indexPath.row+1];
        
        
        if (![[resultsArray objectAtIndex:indexPath.row+1]  isEqual: @0]){
            questionContentCellLabel.text = @"Question complete";
             applicationResultCellImage.image =[UIImage imageNamed:@"1.png" ];
            questionNumberCellLabel.text = [NSString stringWithFormat:@"Question %@",q.questionNumber];
            applicationResultCellImage.alpha = 0.5;
            
            float percentageCorrect = (q.numberOfAnswers-[[resultsArray objectAtIndex:indexPath.row+1] floatValue]+1)/q.numberOfAnswers;
            
            progressView.progress = percentageCorrect;
             attemptsUsedFraction.text = [NSString stringWithFormat:@"%@/%d",[resultsArray objectAtIndex:indexPath.row+1], q.numberOfAnswers];
            
        }else{
        
        
        
        if (!q.qAttempts){

            progressView.progress = 0;
            
            applicationResultCellImage.image =[UIImage imageNamed:@"NormalQuestion2.png" ];
            
            applicationResultCellImage.alpha = 1;
            
            attemptsUsedFraction.text = [NSString stringWithFormat:@"0/%d", q.numberOfAnswers];
            
        }else{
            
            applicationResultCellImage.image =[UIImage imageNamed:@"1.png" ];

            float percentageCorrect = (q.numberOfAnswers-[q.qAttempts floatValue]+1)/q.numberOfAnswers;
            
            progressView.progress = percentageCorrect;
            
            applicationResultCellImage.alpha = 1;
            
            attemptsUsedFraction.text = [NSString stringWithFormat:@"%@/%d",q.qAttempts, q.numberOfAnswers];
        }
            
        
        if (q.sortedQNumber == indexPath.row+1 ) {
            
            if ([q.qtype integerValue] == 0){ // Rap question
                
                questionContentCellLabel.text = q.questionContent;
                questionNumberCellLabel.text = [NSString stringWithFormat:@"Question %@",q.questionNumber];

            }
        }
            
        }
        
        
    }else if (indexPath.section == 1){
        
        
        attemptsUsedFraction.text = @"";
        
        int count = 0;
        for (int i = 1; i< [quiz count]; i++) {
            
            Question *qCount = [quiz objectAtIndex:i];
            if ([qCount.qtype isEqualToString:@"0"]){
                count++; //number of RAP questions
            }
        }

        Question *q = [quiz objectAtIndex:count+indexPath.row+1];
        
        if (!q.qAttempts){
            
            applicationResultCellImage.image = [UIImage imageNamed:@"ReportQuestion3.png"];
            progressView.progress = 0;

        }else{
            
            applicationResultCellImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"1%@.png", q.reportButtonChoice]];
            progressView.progress = 1;

        }
        
        if (q.sortedQNumber == indexPath.row+1){
            
            if ([q.qtype integerValue] ==1 && [q.questionRelease intValue] == 0){
                
                questionNumberCellLabel.text = [NSString stringWithFormat:@"Application %lu ", indexPath.row+1];
                questionContentCellLabel.text = @"Question not released";
            
                applicationResultCellImage.alpha = 0.2;
                
            } else if (([q.qtype integerValue] ==1) && [q.questionRelease intValue]%2 == 1){

                questionNumberCellLabel.text = [NSString stringWithFormat:@"Application %lu ", indexPath.row+1];
                applicationResultCellImage.alpha = 1;
                questionContentCellLabel.text =[NSString stringWithFormat:@"%@", q.questionContent];

            } else if (([q.qtype integerValue] ==1) && [q.questionRelease intValue]%2 == 0){
                questionNumberCellLabel.text = [NSString stringWithFormat:@"Application %lu ", indexPath.row+1];
                questionContentCellLabel.text =@"Question has been closed";
                
                applicationResultCellImage.alpha = 0.5;

            }
        }
    }

    return cell;
}


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 78.0;
}

#pragma mark - Navigation


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


-(void)prepareQuestionViewController:(QuestionViewController *)qvc toDisplayQuestionAtRow:(NSInteger)row
{
    int numRowsInSec0 = (int)[self.tableView numberOfRowsInSection:0];
    BOOL isSec0 = ( row > numRowsInSec0 ? NO : YES);
    
    int rowToSelect = (int)row;

    if (!isSec0) {
        rowToSelect = (int)row-numRowsInSec0;
    }
    
    if ([self.tableView indexPathForSelectedRow].row != row){
        if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)){
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:rowToSelect-1 inSection:(isSec0 ? 0 : 1)] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
    
    Question *q = [quiz objectAtIndex:row];

    qvc.detailItem = q;
    qvc.navigationItem.title = ( [q.qtype isEqualToString:@"0"] ? [NSString stringWithFormat:@"Question %d", q.sortedQNumber] :[NSString stringWithFormat:@"Application %d", q.sortedQNumber ]);
  
    [qvc.navigationItem.rightBarButtonItem setTintColor:UIColorFromRGB(0x007AFE)];
    
    [qvc.scrollView setContentOffset:CGPointZero animated:NO];
    
    displayQuestion = [q.questionNumber integerValue];
    
    id detail = self.splitViewController.viewControllers[1];
    if ([detail isKindOfClass:[UINavigationController class]]){
        detail = [detail topViewController];
    }
    
    UIViewController *realDetail = detail;
    
        id mostRecentSubview = realDetail.view.subviews[[realDetail.view.subviews count]-1];
    
    if ([q.qtype isEqualToString:@"1"] && [q.questionRelease intValue] == 0){

    
        
    // If the last subview isnt a translucent view, make it one!
    
    if (![mostRecentSubview isKindOfClass:[ILTranslucentView class]]){
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        ILTranslucentView *translucentView = [[ILTranslucentView alloc] initWithFrame:screenRect];
        //that's it :)
        
        //optional:
        translucentView.translucentAlpha = 1;
        translucentView.translucentStyle = UIBarStyleDefault;
        translucentView.translucentTintColor = [UIColor clearColor];
        translucentView.backgroundColor = [UIColor clearColor];
        
       
        CGRect rect = CGRectMake(370, 200, 700, 100);
        
        //realDetail.navigationItem.title = @"Welcome";
        UILabel *textLabel = [[UILabel alloc]initWithFrame:rect];
        
        textLabel.center = realDetail.view.center;
        textLabel.text = @"This Question has not been released by the instructor yet";
        
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:24]];
        textLabel.numberOfLines = 3;
        [textLabel setTextAlignment:NSTextAlignmentCenter];
        textLabel.textColor = [UIColor blackColor];
        [translucentView addSubview:textLabel];
        [realDetail.view addSubview:translucentView];
        [UIView transitionWithView:realDetail.view duration:0.37 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            
        }completion:nil];
    }
        
    }else if (q.applicationReleased || [q.qtype isEqualToString:@"0"]){
        
        if ([mostRecentSubview isKindOfClass:[ILTranslucentView class]]){
            [[realDetail.view.subviews objectAtIndex:[realDetail.view.subviews count]-1]removeFromSuperview];
        }
    }
}

#pragma mark - UITableViewDelagate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailnav = self.splitViewController.viewControllers[1];
    
    id detail = [detailnav topViewController];
    
    if ([detail isKindOfClass:[QuestionViewController class]]){
        NSLog(@"about to prepare question %ld", (long)indexPath.row+1);
        
        int count = 0;
        
        if (indexPath.section == 1){
            
            count = (int)[self.tableView numberOfRowsInSection:0];
        
        }
        
        [self prepareQuestionViewController:detail toDisplayQuestionAtRow:count+indexPath.row+1];
        
        [detail switchQuestion];
    }
   
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"goToOtherQuizzes"]){
        OtherQuizzesTableViewController *destVC = (OtherQuizzesTableViewController *) [segue destinationViewController];
        destVC.listPastQuizzes = self.listPastQuizzes;
    }
}


@end
