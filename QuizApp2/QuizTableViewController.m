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


@interface QuizTableViewController ()

@end

@implementation QuizTableViewController
{
    NSUInteger displayQuestion;
}


NSMutableArray *quiz ; //ofQuestions
NSMutableArray *attemptsArray;
NSUInteger questionsViewed;
NSIndexPath *indexPath2;
NSNumber *indexNum;
NSNumber *attemptsUsed;
//NSIndexPath *currentSelection;


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
    
    NSLog(@"Quiz Table view loaded");

}

- (void)loadQuizData{
    
    if (!quiz){
        NSLog(@"The quiz identifier in master is %@", self.quizIdentifier);
        
        PFQuery *query = [PFQuery queryWithClassName:[NSString stringWithFormat:@"%@",self.quizIdentifier]];
        
        [query selectKeys: @[@"questionNumber", @"questionContent", @"answerA", @"answerB", @"answerC", @"answerD", @"correctAnswer"]];
        [query orderByAscending:@"questionNumber"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *questions, NSError *error) {
            if (!error) {
                
                NSLog(@"Successfully retrieved %lu Questions.", (unsigned long)questions.count);
                
                quiz = [[NSMutableArray alloc] init];
                
                [self initializeQuizArrayWithThisNumber:[questions count]];
                
                //retrieving questions from Parse
                for (PFObject *question in questions) {
                    
                    Question *_question = [[Question alloc] init];
                    
                    _question.questionNumber = question[@"questionNumber"];
                    _question.questionContent = question[@"questionContent"];
                    _question.answerA = question[@"answerA"];
                    _question.answerB = question[@"answerB"];
                    _question.answerC = question[@"answerC"];
                    _question.answerD = question[@"answerD"];
                    _question.correctAnswer = question[@"correctAnswer"];
                    
                    
                    
                    
                    
                    [quiz replaceObjectAtIndex:[_question.questionNumber integerValue] withObject:_question];
                    
                    //[quiz insertObject:_question atIndex:[_question.questionNumber integerValue]];
                    
                    //[quiz addObject:_question];
                    
                    Question *tempq = [quiz objectAtIndex:[_question.questionNumber integerValue] ];
                    
                    NSLog(@"Successfully retrieved Question %@ and placed it at index %ld", question[@"questionNumber"], (long)[tempq.questionNumber integerValue]);
                }
                
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];        
        
    }

}

- (NSUInteger *)giveQuizLength{
    return [quiz count];
}


- (void)initializeQuizArrayWithThisNumber:(NSUInteger)count{
    NSLog(@"The quiz array is being intialized with %d spots", count);
    for (int i = 0; i <= count; i++)
    {
        [quiz addObject:@0];
    }
    
    NSLog(@"The quiz array has %d spots", [quiz count]);
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [quiz count]-1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (quiz){
        Question *q = [quiz objectAtIndex:indexPath.row+1];
    
        cell.textLabel.text = [NSString stringWithFormat:@"Question %d ", indexPath.row+1];
        
        
        if (!q.qAttempts) {
            cell.imageView.image = [UIImage imageNamed:@"0.png"];
        }else{
            cell.imageView.image =[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", q.qAttempts]];
        }
    }
  

    return cell;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self.tableView reloadData];
    
//    if (displayQuestion){
//        Question *q = [quiz objectAtIndex:displayQuestion];
//        if (q.questionFinished){
//            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:displayQuestion-1 inSection:1];
//            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
//            [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
//        }
//        
//    }
    
}


//-(void)questionViewed:(NSNotification *)notification
//{
//    
//    //unichar attemptString = [[notification object] characterAtIndex:0];
//    
//    //[attemptsArray replaceObjectAtIndex:indexPath2.row withObject:[notification object]];
//    attemptsUsed = [notification object];
//    
//    NSLog(@"%@", attemptsArray);
//    //NSLog(@"QuizTableView received msgstr %hu from QuestionView", attemptString);
//    
//    
//    //[self.tableView reloadData];
//}
//
//-(void)questionViewed2:(NSNotification *)notification
//{
//    
//    unichar qNumberASCII = [[notification object] characterAtIndex:0];
//    
//    NSUInteger qNumber = [[notification object] integerValue];
//    
//    
//    NSLog(@"QuizTableView received msgstr %hu from QuestionView", qNumberASCII);
//    
//    [attemptsArray replaceObjectAtIndex:qNumber withObject:attemptsUsed];
//    
//  
//    
//    NSLog(@"%@", attemptsArray);
//    
//    
//    
//    [self.tableView reloadData];
//}



/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    NSLog(@"preparing to segue to the question!");
//    //this function is used to pass data using the navigation segue
//    if ([segue.identifier isEqual:@"goToQuestion"]) {
//        
//        NSLog(@"entered the quiz to question segue!");
//        
//        questionsViewed++;  //add one to the number of questions viewed
//        
//        NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
//        QuestionViewController *destViewC = segue.destinationViewController;
//        
//        indexPath2 = [indexPaths objectAtIndex:0];
//        
//        //        destViewC.questionNumber = [NSString stringWithFormat:@"%ld", (long)indexPath2.row+1];
//        
//        Question *q = [[Question alloc] init];
//        
//        for (q in quiz) {
//            for (int i = 1; i < ([quiz count]+1); i++) {
//                
//                if ([q.questionNumber isEqualToString:[NSString stringWithFormat:@"%ld",(long)indexPath2.row+1]]){
//                    destViewC.questionNumber = q.questionNumber;
//                    destViewC.questionContent = q.questionContent;
//                    destViewC.answerA = q.answerA;
//                    destViewC.answerB = q.answerB;
//                    destViewC.answerC = q.answerC;
//                    destViewC.answerD = q.answerD;
//                    destViewC.correctAnswer = q.correctAnswer;
//                    destViewC.navigationItem.title = [NSString stringWithFormat:@"Question %@", q.questionNumber];
//                    //NSLog([NSString stringWithFormat: @"Question %@ data has all been successfully transfered", q.questionNumber]);
//                    //destViewC.currentRow = self.currentSelection;
//                    destViewC.quizIdentifier = self.quizIdentifier;
//                    //destViewC.attemptsArray = attemptsArray;
//                }
//            }
//        }
//
//        
//        
//        // destViewC.questionContent = [quiz objectAtIndex:indexPath2.row];
//        
//        //this is where the action happens; send info to the question view
//        destViewC.attempts = [attemptsArray objectAtIndex:indexPath2.row+1];  //to decide if question should be available
//        //destViewC.correct = [theList objectAtIndex:indexPath2.row];         //to determine correct ans
//        
//           [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(questionViewed:) name:@"attempted" object:nil];
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(questionViewed2:) name:@"questionNumber" object:nil];
//    }
//}

-(void)prepareQuestionViewController:(QuestionViewController *)qvc toDisplayQuestion:(Question *)q
{
    qvc.detailItem = q;
    qvc.navigationItem.title = [NSString stringWithFormat:@"Question %@", q.questionNumber];
    displayQuestion = [q.questionNumber integerValue];
}

#pragma mark - UITableViewDelagate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailnav = self.splitViewController.viewControllers[1];
    
    id detail = [detailnav topViewController];
    
    if ([detail isKindOfClass:[QuestionViewController class]]){
        NSLog(@"about to prepare question %ld", (long)indexPath.row+1);
        [self prepareQuestionViewController:detail toDisplayQuestion:[quiz objectAtIndex:indexPath.row+1]];
        [detail switchQuestion];
    } else {
        NSLog(@"Didnt enter didselectrow");
    }
   
}

//The below code was unnecesarry bc quiz is being manipulated directly from question view controller

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
