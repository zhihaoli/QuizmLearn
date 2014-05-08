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
//@property (weak, nonatomic) IBOutlet UILabel *questionNumberCellLabel;
//@property (weak, nonatomic) IBOutlet UILabel *questionContentCellLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *applicationResultCellImage;



@property (strong,nonatomic) NSMutableArray *questionIDs;
@property (strong, nonatomic) NSMutableArray *quiz;
@end

@implementation QuizTableViewController

@synthesize popoverController, quiz;

    NSUInteger displayQuestion;



//NSMutableArray *quiz ; //ofQuestions
NSMutableArray *attemptsArray;
NSUInteger questionsViewed;
NSIndexPath *indexPath2;
NSNumber *indexNum;
NSNumber *attemptsUsed;
//NSIndexPath *currentSelection;
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

- (IBAction)otherQuizzesClicked:(id)sender {
    
    
    OtherQuizzesTableViewController *otherQuizPopover = [[OtherQuizzesTableViewController alloc] init];
    
    otherQuizPopover.listPastQuizzes = self.listPastQuizzes;
    NSLog(@"list past quizzes from quiz table: %@, list past quizzes from popover: %@", self.listPastQuizzes, otherQuizPopover.listPastQuizzes);
    
    
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:otherQuizPopover];
    
    [self.popoverController setPopoverContentSize:CGSizeMake(310, 170)];
    
    [self.popoverController presentPopoverFromBarButtonItem:self.otherQuizzesButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
    
    
}

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
    
     
    
    NSLog(@"Quiz Table view loaded");
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating Quiz"];
    
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
    
    //[self refresh];

    
    //[self.tableView setDelegate:self];

}

-(void)refresh {
    
    NSLog(@"does this happen on launch?");
    
    
    [self checkForRelease];
    //[self.tableView reloadData];
    //[self performSelector:@selector(retrieveQuestionsFromParse) withObject:nil];
    
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
    
}

- (void)stopRefresh{
    [self.refreshControl endRefreshing];
}


- (void)loadQuizData{
    
    //if (!quiz){
    
    self.navigationItem.title = self.quizIdentifier;
    
    self.questionIDs = [[NSMutableArray alloc] init];
    quiz = [[NSMutableArray alloc] init];
    
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
    
    
                    
                    
    NSMutableArray *rowSecId = [[NSMutableArray alloc] initWithObjects: [NSString stringWithFormat:@"%d",_question.sortedQNumber] , _question.qtype, [question objectId], nil];
                    
    [self.questionIDs addObject:rowSecId];
                    
                    [quiz replaceObjectAtIndex:[_question.questionNumber integerValue] withObject:_question];
    //[quiz addObject:_question];
                    NSLog(@"TabBar: Successfully retrieved Question %@.", question[@"questionNumber"]);
                }
                
    
        //}];


            [self performSelector:@selector(reloadData) withObject:nil afterDelay:1];
    //});
    
    
//        NSLog(@"The quiz identifier in master is %@", self.quizIdentifier);
//        
//        self.navigationItem.title = self.quizIdentifier;
//        
//        PFQuery *query = [PFQuery queryWithClassName:[NSString stringWithFormat:@"%@",self.quizIdentifier]];
//        
//        [query selectKeys: @[@"questionNumber", @"questionContent", @"answerA", @"answerB", @"answerC", @"answerD", @"correctAnswer", @"questionType", @"questionRelease"]];
//        [query orderByAscending:@"questionNumber"];
//        [query findObjectsInBackgroundWithBlock:^(NSArray *questions, NSError *error) {
//            if (!error) {
//                
//                NSLog(@"Successfully retrieved %lu Questions.", (unsigned long)questions.count);
//                
//                quiz = [[NSMutableArray alloc] init];
//                
//                [self initializeQuizArrayWithThisNumber:[questions count]];
//                
//                //retrieving questions from Parse
//                for (PFObject *question in questions) {
//                    
//                    //if ([question[@"questionRelease"] isEqualToString:@"1"]){
//                    
//                    Question *_question = [[Question alloc] init];
//                    
//                    _question.questionNumber = question[@"questionNumber"];
//                    _question.questionContent = question[@"questionContent"];
//                    _question.answerA = question[@"answerA"];
//                    _question.answerB = question[@"answerB"];
//                    _question.answerC = question[@"answerC"];
//                    _question.answerD = question[@"answerD"];
//                    _question.answerE = question[@"answerE"];
//                    _question.numberOfAnswers = question[@"numberOfAnswers"];
//                    _question.correctAnswer = question[@"correctAnswer"];
//                    _question.qtype = question[@"questionType"];
//                    _question.questionRelease = question[@"questionRelease"];
//                    
//                    
//                    
//                    
//                    [quiz replaceObjectAtIndex:[_question.questionNumber integerValue] withObject:_question];
//                    
//                    //[quiz insertObject:_question atIndex:[_question.questionNumber integerValue]];
//                    
//                    //[quiz addObject:_question];
//                    
//                   // Question *tempq = [quiz objectAtIndex:[_question.questionNumber integerValue] ];
//                    
//                    NSLog(@"Successfully retrieved Question %@ and placed it at index %ld", question[@"questionNumber"], (long)[_question.questionNumber integerValue]);
//                    //NSIndexPath *tempIndex = [NSIndexPath indexPathForRow:11 inSection:0];
//                    //NSLog(@"The object where question 12 should be is %@", [quiz objectAtIndex:tempIndex.row]);
//                        
//                   // }
//                
//                }
//            }else{
//                NSLog(@"Error: %@ %@", error, [error userInfo]);
//            }
            
      
        
    //}
    

    
    
    
   // NSIndexPath *tempIndex = [NSIndexPath indexPathForRow:11 inSection:0];
    //NSLog(@"The object where question 12 should be is %@", [quiz objectAtIndex:tempIndex.row]);

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
            
            if (q.applicationReleased == NO && [q.qtype isEqualToString:@"1"]){ //if an application question is not released
                q.applicationReleased = [question[@"questionRelease"] boolValue];
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


- (NSUInteger *)giveQuizLength{
  //  NSLog(@"qtvc gave quiz count %d", [quiz count]);
    return fastQuizLength;
    
}


- (void)initializeQuizArrayWithThisNumber:(NSUInteger)count{
    NSLog(@"The quiz array is being intialized with %lu spots", (unsigned long)count);
    for (int i = 0; i <= count; i++)
    {
        [quiz addObject:@0];
    }
    
    NSLog(@"The quiz array has %lu spots", (unsigned long)[quiz count]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return [quiz count] ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
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
    
    UILabel *questionNumberCellLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *questionContentCellLabel = (UILabel *)[cell viewWithTag:2];
    UIImageView *applicationResultCellImage = (UIImageView *)[cell viewWithTag:3];
    UIProgressView *progressView = (UIProgressView *)[cell viewWithTag:4];
    
    UILabel *attemptsUsedFraction = (UILabel *)[cell viewWithTag:5];
    
     progressView.tintColor = UIColorFromRGB(0x4CD964);
    
    if (indexPath.section == 0){
        
        Question *q = [quiz objectAtIndex:indexPath.row+1];
        
        if (!q.qAttempts){
       // cell.imageView.image = [UIImage imageNamed:@"NormalQuestion2.png" ];
            
            progressView.progress = 0;
            
            applicationResultCellImage.image =[UIImage imageNamed:@"NormalQuestion2.png" ];
            
            applicationResultCellImage.alpha = 1;
            
            attemptsUsedFraction.text = [NSString stringWithFormat:@"0/%d", q.numberOfAnswers];
            
        }else{
            
            applicationResultCellImage.image =[UIImage imageNamed:@"1.png" ];
            
            //progressView.tintColor = UIColorFromRGB(0x7CFC00);
            float percentageCorrect = (q.numberOfAnswers-[q.qAttempts floatValue]+1)/q.numberOfAnswers;
            
            progressView.progress = percentageCorrect;
            
            applicationResultCellImage.alpha = 1;
            
            attemptsUsedFraction.text = [NSString stringWithFormat:@"%@/%d",q.qAttempts, q.numberOfAnswers];
            
              //applicationResultCellImage.image =[UIImage imageNamed:@"NormalQuestion2.png" ];
            
            //applicationResultCellImage.image =[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", q.qAttempts]];
            //cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", q.qAttempts]];
        }
        
        if (q.sortedQNumber == indexPath.row+1 ) {
            //NSLog(@"Question %@", q.questionNumber);
            if ([q.qtype integerValue] == 0){ // Rap question
                
                
                questionContentCellLabel.text = q.questionContent;
                questionNumberCellLabel.text = [NSString stringWithFormat:@"Question %@",q.questionNumber];
                
                //cell.textLabel.text = [NSString stringWithFormat:@"Question %d ", indexPath.row+1];
                //cell.imageView.alpha = 1;
                NSLog(@"Question %@ is RAP", q.questionNumber);
                //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", q.questionContent];
                
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
            
            //cell.imageView.image = [UIImage imageNamed:@"ReportQuestion3.png" ];
        }else{
            
            applicationResultCellImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"1%@.png", q.reportButtonChoice]];
            
            progressView.progress = 1;
            
            //cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"1%@.png", q.reportButtonChoice]];
        }
        
        
        if (q.sortedQNumber == indexPath.row+1){
            
            if ([q.qtype integerValue] ==1 && !q.applicationReleased){
                
                questionNumberCellLabel.text = [NSString stringWithFormat:@"Application %d ", indexPath.row+1];
                
                
                //cell.textLabel.text = [NSString stringWithFormat:@"Application %d ", indexPath.row+1];

                NSLog(@"Question %@ is Application", q.questionNumber);
               
                questionContentCellLabel.text = @"Question not released";
                
                
                applicationResultCellImage.alpha = 0.2;
                
                //cell.detailTextLabel.text = @"Question not released";
                //cell.imageView.alpha = 0.2;

                //cell.releaseQButton.enabled = YES;
            } else if (([q.qtype integerValue] ==1) && q.applicationReleased){
                NSLog(@"Question %@ is Application and has been released", q.questionNumber);
                
                
                questionNumberCellLabel.text = [NSString stringWithFormat:@"Application %d ", indexPath.row+1];
                
                //cell.textLabel.text = [NSString stringWithFormat:@"Application %d ", indexPath.row+1];
                
                applicationResultCellImage.alpha = 1;
                
                //cell.imageView.alpha = 1;
                
                
                questionContentCellLabel.text =[NSString stringWithFormat:@"%@", q.questionContent];
                
                //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", q.questionContent];
            }
        }
    }
//
//        cell.textLabel.text = [NSString stringWithFormat:@"Question %ld ", indexPath.row+1];
//        
//        if ([q.questionRelease isEqualToString:@"0"]){
//            cell.detailTextLabel.text = @"Question Not Released";
//            cell.imageView.alpha = 0.2;
//        }
//        else if ([q.questionRelease isEqualToString:@"1"]){
//            cell.detailTextLabel.text = q.questionContent;
//            cell.imageView.alpha = 1;
//        }
        
        //[self updateTableImage:indexPath.row+1 withAttempts:q.qAttempts];
//        if([q.qtype isEqualToString:@"0"]){
//            if (!q.qAttempts) {
//                    cell.imageView.image = [UIImage imageNamed:@"NormalQuestion2.png"];
//            }else{
//                cell.imageView.image =[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", q.qAttempts]];
//            }
//        } else if ([q.qtype isEqualToString:@"1"]){
//            if (!q.qAttempts) {
//                cell.imageView.image = [UIImage imageNamed:@"ReportQuestion3"];
//            }else{
//                cell.imageView.image =[UIImage imageNamed:[NSString stringWithFormat:@"1%@.png", q.reportButtonChoice]];
//            }
//        }
//    }
    return cell;
}

//- (void)updateTableImage:(NSInteger *)row withAttempts:(NSString)attempts{
//    
//    if (!q.qAttempts) {
//        cell.imageView.image = [UIImage imageNamed:@"0.png"];
//    }else{
//        cell.imageView.image =[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", q.qAttempts]];
//    }
//
//}



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
    int numRowsInSec0 = [self.tableView numberOfRowsInSection:0];
    BOOL isSec0 = ( row > numRowsInSec0 ? NO : YES);
    
    int rowToSelect = row;

    if (!isSec0) {
        rowToSelect = row-numRowsInSec0;
    }
    
    if ([self.tableView indexPathForSelectedRow].row != row){
        if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)){
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:rowToSelect-1 inSection:(isSec0 ? 0 : 1)] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
    
    
    NSLog(@"Number of Rows in Section 0: %d, isSec0: %hhd, rowToSelect: %d, row: %d", numRowsInSec0, isSec0, rowToSelect, row);

    Question *q = [quiz objectAtIndex:row];

    qvc.detailItem = q;
    //qvc.navigationItem.title = [NSString stringWithFormat:@"Question %@", q.questionNumber];
    
     qvc.navigationItem.title = ( [q.qtype isEqualToString:@"0"] ? [NSString stringWithFormat:@"Question %d", q.sortedQNumber] :[NSString stringWithFormat:@"Application %d", q.sortedQNumber ]);
    
      // qvc.navigationItem.rightBarButtonItem.tintColor = UIColorFromRGB(0x007AFF);
    
    [qvc.navigationItem.rightBarButtonItem setTintColor:UIColorFromRGB(0x007AFE)];
    
    //[qvc.navigationItem.rightBarButtonItem setTintColor:[UIColor blueColor]];
  
    
    [qvc.scrollView setContentOffset:CGPointZero animated:NO];
    
    displayQuestion = [q.questionNumber integerValue];
    
    id detail = self.splitViewController.viewControllers[1];
    if ([detail isKindOfClass:[UINavigationController class]]){
        detail = [detail topViewController];
    }
    
    UIViewController *realDetail = detail;
    
        id mostRecentSubview = realDetail.view.subviews[[realDetail.view.subviews count]-1];
    
    if ([q.qtype isEqualToString:@"1"] && !q.applicationReleased){

    
        
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
            
            count = [self.tableView numberOfRowsInSection:0];
        
//        for (int i = 1; i< [quiz count]; i++) {
//            
//            Question *qCount = [quiz objectAtIndex:i];
//            if ([qCount.qtype isEqualToString:@"0"]){
//                count++; //number of RAP questions
//            }
//        }
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

//The below code was unnecesarry bc questions in quiz are being manipulated directly from question view controller

//- (void)updateImage:(QuestionViewController *)qvc forCell:(NSIndexPath *)indexPath{
//    
//    int numAttemptsForPic = qvc.detailItem.qAttempts;
//    
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png", numAttemptsForPic]];
//}

//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[self.tableView reloadData];
//    id detailnav = self.splitViewController.viewControllers[1];
//    
//    id detail = [detailnav topViewController];
//    
//    if ([detail isKindOfClass:[QuestionViewController class]]){
//        [self updateImage:detail forCell:indexPath];
//    }
//}

@end
