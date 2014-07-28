//
//  QuestionViewController.m
//  QuizApp2
//
//  Created by Bruce Li on 1/28/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//
// This, along with the QuizTableVC, is the main classes of Quizm Learn and controls most of the functions of the app

#import "QuestionViewController.h"
#import <Parse/Parse.h>
#import "ImportViewController.h"
#import "PastQuizViewController.h"
#import "Question.h"
#import "MyLoginViewController.h"
#import "BigButtonViewController.h"
#import "Reachability.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface QuestionViewController ()

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRightGesture;
@property (weak, nonatomic) IBOutlet UITextView *qContentLabel;

@property (weak, nonatomic) IBOutlet UIImageView *progressBarBorder;

@property (weak, nonatomic) IBOutlet UITextView *answerALabel;
@property (weak, nonatomic) IBOutlet UITextView *answerBLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerCLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerDLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerELabel;

@property (weak, nonatomic) IBOutlet UIView *viewInScrollView;

@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet UIButton *reportCardButton;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSArray * questions;

@property (strong, nonatomic) QuizTableViewController *master;

@property (weak, nonatomic) IBOutlet UIImageView *scrollIndicator;
@property (weak, nonatomic) IBOutlet UILabel *Ebackground;
@property (weak, nonatomic) IBOutlet UILabel *Dbackground;
@property (weak, nonatomic) IBOutlet UILabel *Cbackground;
@property (weak, nonatomic) IBOutlet UILabel *Abackground;
@property (weak, nonatomic) IBOutlet UILabel *bBackground;
@property (weak, nonatomic) IBOutlet UILabel *questionClosedLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property BOOL *questionFinished;

@end

@implementation QuestionViewController
{
    Reachability *internetReachableFoo;
    UIAlertView *alert;
    CGPoint resultImageStartPoint;
    BOOL loggedIn;
    BOOL quizImported;
    BOOL logOutFlag;
    
    BOOL firstQuestionDisplayed;
    BOOL alertVisible;
    BOOL finishedQuestion;
    BOOL loggingOutAlert;
    BOOL submittingAppQ;
    NSString *messagestring;
    NSString *groupName;
    NSInteger quizLength;
    NSArray *buttonArray;
    NSArray *imageArray;
    NSArray *startpointsArray;
    NSString *resultsArrayID;
    NSTimer *buttonTimer;
    NSString *currentButton;
    NSMutableArray *colours;
    NSArray *tapGestureArray;
    UITapGestureRecognizer *tapGestureRecognizerA;
    UITapGestureRecognizer *tapGestureRecognizerB;
    UITapGestureRecognizer *tapGestureRecognizerC;
    UITapGestureRecognizer *tapGestureRecognizerD;
    UITapGestureRecognizer *tapGestureRecognizerE;
    
}

@synthesize nextButton;
@synthesize swipeRightGesture;
@synthesize buttonA;
@synthesize buttonB;
@synthesize buttonC;
@synthesize buttonD;
@synthesize buttonE;
@synthesize reportButton;
@synthesize reportCardButton;
@synthesize popoverController;
@synthesize resultImage;
@synthesize colours;
@synthesize middleOfQuestion;
@synthesize startedQuiz;
@synthesize master;

# pragma mark - View Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    groupName = [PFUser currentUser].username;
    
    [self.navigationItem setHidesBackButton:YES];
    
    
    [self testInternetConnection];
    [self.scrollView setScrollEnabled:YES];
    [self initializeTapGestures];
    [self initializeButtonAndImages];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
   
}




- (void)goToWelcomeMethod{
    [self performSegueWithIdentifier: @"goToWelcome" sender: self];
}

// This method conrols the Login, launching the welcome view (import view), and launching the first question.
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    master = (QuizTableViewController *)[self.splitViewController.viewControllers[0] topViewController];
     if (!firstQuestionDisplayed){
         [self setUpTest];
        self.progressView.tintColor = UIColorFromRGB(0x007AFF);
        [self performSelector:@selector(viewDidLoadDelayedLoading) withObject:self afterDelay:0.4];
    }
}

// Called from view did load to display first question
- (void)viewDidLoadDelayedLoading{
    firstQuestionDisplayed = YES;
    
    [master displayFirstQuestion];
    [master.navigationItem.rightBarButtonItem setTintColor:UIColorFromRGB(0x007AFE)];
    
    master.listPastQuizzes = self.listPastQuizzes;
    [self assignQuizLengthFromMaster:master];
    
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)){
        [master.tableView reloadData];
    } else { // It's in portriat
        [self.navigationItem.leftBarButtonItem.target performSelector:self.navigationItem.leftBarButtonItem.action withObject:self.navigationItem afterDelay:0.5];
    }
    
    [self getColoursFromParse];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Set Up
- (void)initializeTapGestures {
    //Initialize the gesture recognizers over the answer labels
    tapGestureRecognizerA = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFromA:)];
    tapGestureRecognizerB = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFromB:)];
    tapGestureRecognizerC = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFromC:)];
    tapGestureRecognizerD = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFromD:)];
    tapGestureRecognizerE = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFromE:)];
    
    [self.answerALabel addGestureRecognizer:tapGestureRecognizerA];
    [self.answerBLabel addGestureRecognizer:tapGestureRecognizerB];
    [self.answerCLabel addGestureRecognizer:tapGestureRecognizerC];
    [self.answerDLabel addGestureRecognizer:tapGestureRecognizerD];
    [self.answerELabel addGestureRecognizer:tapGestureRecognizerE];
    
    
    tapGestureArray = [[NSArray alloc]initWithObjects:tapGestureRecognizerA, tapGestureRecognizerB, tapGestureRecognizerC, tapGestureRecognizerD, tapGestureRecognizerE, nil];
    
    tapGestureRecognizerA.delegate = self;
    tapGestureRecognizerB.delegate = self;
    tapGestureRecognizerC.delegate = self;
    tapGestureRecognizerD.delegate = self;
    tapGestureRecognizerE.delegate = self;
}

- (void)initializeButtonAndImages {
    //set the title
    self.navigationItem.title = ( [self.detailItem.qtype isEqualToString:@"0"] ? [NSString stringWithFormat:@"Question %d", self.detailItem.sortedQNumber] :[NSString stringWithFormat:@"Application %d", self.detailItem.sortedQNumber ]);
    
    buttonArray = [[NSArray alloc] initWithObjects:buttonA, buttonB, buttonC, buttonD, buttonE, nil];
    
    for (UIButton* button in buttonArray) {
        [button setTitleColor:UIColorFromRGB(0x007AFF) forState:UIControlStateNormal];
    }
    
    imageArray = [[NSArray alloc] initWithObjects:_aImage,_bImage,_cImage,_dImage, _eImage, nil];
    
    reportButton.titleLabel.text = @"Report Choice";
    
    //Dont enable the nextButton until they've selected a correct answer
    nextButton.enabled = NO;
    [nextButton setBackgroundImage:[UIImage imageNamed:@"buttonbackground"] forState:UIControlStateNormal];
    nextButton.titleLabel.tintColor = [UIColor whiteColor];
    [nextButton setAlpha:0.8];
    
    
    [self.qContentLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)testInternetConnection
{
    internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (alertVisible){ // can probably just check the alert.visible property instead
                
                UIImageView *checkMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ios7-checkmark"]];
                
                
                [alert dismissWithClickedButtonIndex:0 animated:NO];
                UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection found!", nil) message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
                
                
                [successAlert setValue:checkMark forKey:@"accessoryView"];
                [successAlert show];
                [self performSelector:@selector(hideAlert:) withObject:successAlert afterDelay:2.0];
            }
            
            NSLog(@"Yayyy, we have the interwebs!");
        });
    };
    
    // Internet is not reachable
    internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            spinner.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
            [spinner startAnimating];
            
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Lost Internet!", nil) message:NSLocalizedString(@"Waiting for connection...", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil, nil];
            
            [alert setValue:spinner forKey:@"accessoryView"];
            [alert show];
            alertVisible = YES;
            
            NSLog(@"Someone broke the internet :(");
        });
    };
    
    [internetReachableFoo startNotifier];
}

- (void)hideAlert:(UIAlertView *)successAlert{
    [successAlert dismissWithClickedButtonIndex:0 animated:YES];
}

// Use this method to import all of the data from import view controller and then perform the same replace master segue to QuizTableController that import view controller used to do
// After you get that working, try to make "didSelectRowAtIndexPath" to do everything the replace segue did, and disable the replace segue

// called from unwind segue when the quiz identifier is recieved from past quiz view controller
- (void)sendQuizIDto:(QuizTableViewController *)qtvc withidentifier:(NSString *)identifier {
    qtvc.quizIdentifier = identifier;
    [qtvc loadQuizData];
}


#pragma mark - Login and Logout

- (void)presentLogin {
    // Create the log in view controller
    MyLoginViewController *logInViewController = [[MyLoginViewController alloc] init];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    
    logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsLogInButton;
    
    [self presentViewController:logInViewController animated:NO completion:NULL];
}

- (void)makeTranslucent {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    ILTranslucentView *translucentView = [[ILTranslucentView alloc] initWithFrame:screenRect];
    
    translucentView.translucentAlpha = 1;
    translucentView.translucentStyle = UIBarStyleDefault;
    translucentView.translucentTintColor = [UIColor clearColor];
    translucentView.backgroundColor = [UIColor clearColor];
    
    self.navigationItem.title = @"";
    self.navigationItem.rightBarButtonItem.title = @"";
    
    [self.view addSubview:translucentView];
}


//This action is only called if the user tries to logout before entering a quiz
//It exists as an exit if the user has no quizzes to select from
//It should not be used very often, and acts as an "emergency exit"
- (IBAction)unwindFromLogout:(UIStoryboardSegue *)segue {
    
    [master makeTranslucent];
    [self makeTranslucent];
    
    loggingOutAlert = YES;
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please logout now", nil) message:NSLocalizedString(@"Make sure you select a test next time. If there are no tests, ask your instructor.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Logout", nil) otherButtonTitles:nil, nil] show];
    
    loggedIn = NO;
    quizImported = NO;
    firstQuestionDisplayed = NO;
    
}

- (IBAction)logOutButtonTapAction:(id)sender {
    
    loggingOutAlert = YES;
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure?", nil) message:NSLocalizedString(@"Logging out will finish your test", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"I'm Sure", nil) otherButtonTitles:NSLocalizedString(@"Go Back",nil), nil] show];
    
}

- (void)logout {
    [PFUser logOut];
    
    [self.attempts removeAllObjects];
    
    loggingOutAlert = NO;
    loggedIn = NO;
    quizImported = NO;
    firstQuestionDisplayed = NO;
    
    
    MyLoginViewController *logInViewController = [[MyLoginViewController alloc] init];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    
    logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsLogInButton;
    
    [self presentViewController:logInViewController animated:NO completion:NULL];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //Logout
    if (buttonIndex == 0 && loggingOutAlert){
        [self logout];
        
        //Submit Answer for Application Questions
    }else if (buttonIndex == 0 && [alertView.title isEqualToString:@"Is this your final answer?"]){
        
        submittingAppQ = YES;
        
        [self sendAttemptsToParse];
        
        self.questionClosedLabel.text = @"Question is complete";
        
        [self EnableButtonsAccordingToButtonsPressed];
        
        self.detailItem.appQSubmitted = YES;
        
        [self SetImagesAccordingToButtonsPressed];
        
        submittingAppQ = NO;
    }
}


#pragma mark - Data Storage and Retrieval

-(void) getColoursFromParse{
    PFQuery *queryStudent = [PFUser query];
    [queryStudent whereKey:@"username" equalTo:[PFUser currentUser].username];
    PFObject *student = [queryStudent getFirstObject];
    
    NSString *course = student[@"StudentCourse"];
    
    PFQuery *queryColours = [PFQuery queryWithClassName:[NSString stringWithFormat:@"%@_Info", course]];
    [queryColours getFirstObjectInBackgroundWithBlock:^(PFObject *classInfo, NSError *error) {
        colours = [[NSMutableArray alloc] init];
        colours = classInfo[@"ColourArray"];
    }];
}

// Called when a correct answer is pressed or anytime a report answer is chosen
- (void)sendAttemptsToParse{
    if ([self.attempts count] == 0 || !self.attempts){  //if the attempts array hasnt been made
        NSLog(@"quiz id is: %@", self.quizIdentifier);
        [self assignQuizLengthFromMaster:master];
        
        //create the attempts array
        self.attempts = [[NSMutableArray alloc] init];
        for (int i = 0; i < (int)quizLength+1; i++ ){
            [self.attempts insertObject:@0 atIndex:i];
        }
        
        // This is needed so the instructor doesnt try and pull stuff from you when you havent started the quiz
        if (!startedQuiz){
            startedQuiz = YES;
            
            // This put your results array on parse!
            PFObject *resultArray = [PFObject objectWithClassName:[NSString stringWithFormat:@"%@_Results",self.quizIdentifier]];
            
            NSLog(@"self.attempts is: %@", self.attempts);
            
            resultArray [[NSString stringWithFormat:@"%@", groupName]] = self.attempts;
            
            [resultArray save];
            
            //This is to keep track of the original results array, so each update updates the same array rather than creating a new one
            resultsArrayID = [resultArray objectId];
            
        }
    }
    
    // Assign number or letter as 'messagestring' depending on the question
    if ([self qIsTypeNormal]){
        messagestring = self.detailItem.qAttempts;
    } else {
        messagestring = currentButton;
    }
    
    
    [self.attempts replaceObjectAtIndex:[self.detailItem.questionNumber integerValue] withObject:messagestring];
    
    
    
    //Add a counter so the instructor knows how many students completed the question
    PFQuery *counterQuery = [PFQuery queryWithClassName:self.quizIdentifier];
    [counterQuery whereKey:@"questionNumber" equalTo:self.detailItem.questionNumber];
    PFObject *counterObj = [counterQuery getFirstObject];
    
    if (counterObj[@"completionCounter"] != nil){
        int currentNum = [counterObj[@"completionCounter"] intValue];
        currentNum++;
        counterObj[@"completionCounter"] = [NSNumber numberWithInt:currentNum];
    }else{
        counterObj[@"completionCounter"] = @1;
        
    }
    
    [counterObj save];
    
    PFQuery *query = [PFQuery queryWithClassName:[NSString stringWithFormat:@"%@_Results",self.quizIdentifier]];
    
    NSLog(@"results array id: %@", resultsArrayID);
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:[NSString stringWithFormat:@"%@",resultsArrayID] block:^(PFObject *resultArrayUpdate, NSError *error) {
        
        NSMutableArray *oldResults = [[NSMutableArray alloc]init];
        
        if (resultArrayUpdate[[NSString stringWithFormat:@"%@", groupName]] == nil){
            for (int i = 0; i < (int)quizLength+1; i++ ){
                [oldResults insertObject:@0 atIndex:i];
            }
        }else{
            oldResults = resultArrayUpdate[[NSString stringWithFormat:@"%@", groupName]];
        }
        
        for (int i=0; i<[oldResults count]; i++){
            if ([[oldResults objectAtIndex:i] isEqual: @0]){
                [oldResults replaceObjectAtIndex:i withObject:[self.attempts objectAtIndex:i]];
            }
        }
        
        resultArrayUpdate [[NSString stringWithFormat:@"%@", groupName]] = oldResults;
        
        [resultArrayUpdate saveInBackground];
    }];
}


# pragma mark - Button Actions

// This method is called often, whenever a button has to be enabled or disabled. It has the benefit that it does different things for regular buttons and the report button.
+(void) shouldDisableButton:(UIButton *)sender should:(BOOL)state {
    
    NSSet *normalbuttonStrings = [NSSet setWithObjects:@"A", @"B", @"C",@"D", @"E", nil];
    
    sender.enabled = !state;
    
    // If it's a report button set the appropriate label text and background image
    
    if ([sender.titleLabel.text isEqualToString:@"Next Question"]){
        [sender setBackgroundImage:[UIImage imageNamed:@"buttonbackground"] forState:UIControlStateNormal];
        sender.titleLabel.tintColor = [UIColor whiteColor];
        [sender setAlpha:0.8];
    }else if (![normalbuttonStrings containsObject:sender.titleLabel.text] ){
        [sender setTitle:@"" forState:UIControlStateDisabled];
        [sender setBackgroundImage:[UIImage imageWithCGImage:(__bridge CGImageRef)([UIColor colorWithWhite:1.0 alpha:1])] forState:UIControlStateDisabled];
        [sender setBackgroundImage:[UIImage imageNamed:@"buttonbackground"] forState:UIControlStateNormal];
        [sender setAlpha:0.8];
    }
}

// Handles all the logistics for enabling buttons, for both kinds of questions
- (void)EnableButtonsAccordingToButtonsPressed{
    
    // Prevents enabled next button on the last question
    if ([self.detailItem.questionNumber integerValue] != (int)quizLength-1 ){
        [QuestionViewController shouldDisableButton:nextButton should:NO];
    }
    
    // If a RAP question is complete
    if([self.detailItem.qtype intValue] == 0 && self.detailItem.questionFinished ){
        
        for(int index = 0; index < 5; index++)
        {
            [QuestionViewController shouldDisableButton:[buttonArray objectAtIndex:index] should:YES];
            UITapGestureRecognizer  *tapGesture = [tapGestureArray objectAtIndex:index];
            tapGesture.enabled = NO;
        }
        
        //if a report question is finished but not closed, keep the buttons enabled
    } else if ([self.detailItem.qtype intValue] == 1 && self.detailItem.questionFinished && [self.detailItem.questionRelease intValue]%2 == 1){
        
        // if it is a report question, AND the question is finished, you need to enable the report choice button and make sure that the current reportChoicebutton is correct.
        [QuestionViewController shouldDisableButton:reportButton should:NO];
        [QuestionViewController shouldDisableButton:reportCardButton should:NO];
        currentButton = self.detailItem.reportButtonChoice;
        
    }else if ([self.detailItem.qtype intValue] == 1 && [self.detailItem.questionRelease intValue]%2 == 0){ // if the report question has closed
        
        for(int index = 0; index < 5; index++)
        {
            [QuestionViewController shouldDisableButton:[buttonArray objectAtIndex:index] should:YES];
            UITapGestureRecognizer  *tapGesture = [tapGestureArray objectAtIndex:index];
            tapGesture.enabled = NO;
        }
        
    }else {
        // Question isnt finished, disable buttons if theyve been pressed, dont if they havent been
        [QuestionViewController shouldDisableButton:reportButton should:YES];
        for(int index = 0; index < 5; index++)
        {
            if ([[self.detailItem.ButtonsPressed objectAtIndex:index] isEqualToValue:@0]){
                [QuestionViewController shouldDisableButton:[buttonArray objectAtIndex:index] should:NO];
                UITapGestureRecognizer  *tapGesture = [tapGestureArray objectAtIndex:index];
                tapGesture.enabled = YES;
            } else {
                [QuestionViewController shouldDisableButton:[buttonArray objectAtIndex:index] should:YES];
                UITapGestureRecognizer  *tapGesture = [tapGestureArray objectAtIndex:index];
                tapGesture.enabled = NO;
            }
        }
        
        //if question has been previously completed
        if (![[master.resultsArray objectAtIndex:[self.detailItem.questionNumber intValue]] isEqual:@0]){
            for(int index = 0; index < 5; index++)
            {
                [QuestionViewController shouldDisableButton:[buttonArray objectAtIndex:index] should:YES];
                UITapGestureRecognizer  *tapGesture = [tapGestureArray objectAtIndex:index];
                tapGesture.enabled = NO;
            }
            
        }
    }
    
    
    if (submittingAppQ || self.detailItem.appQSubmitted) {
        for(int index = 0; index < 5; index++)
        {
            [QuestionViewController shouldDisableButton:[buttonArray objectAtIndex:index] should:YES];
            UITapGestureRecognizer  *tapGesture = [tapGestureArray objectAtIndex:index];
            tapGesture.enabled = NO;
            
        }
        self.questionClosedLabel.text = @"Question has been complete";
    }
    
}

// Handles all the logistics for setting the images (checkmarks and x's, progress bars, and background of button)
- (void)SetImagesAccordingToButtonsPressed{
    
    // This is needed to tell if a button has been pressed at all. If the table tries to update before a button is pressed, it will crash
    bool flag = false;
    
    if ([self qIsTypeNormal]){
        
        // Set the lower progress bar image for the first time
        if (!self.detailItem.qAttempts)
        {
            resultImage.center = CGPointMake(resultImageStartPoint.x, resultImage.center.y);
        }
        
        //question is finished, display qattempts-1 as progress bar
        else if (self.detailItem.questionFinished)
        {
            [self.progressView setProgress:1 animated:YES];
        }
        else // question is not finished, move bar to the left 200 pixels
        {
            
            if (!self.detailItem.justEntered){
                
                
                float movePercentage = 0.0;
                
                switch (self.detailItem.numberOfAnswers){
                    case 2:
                        movePercentage = 1;
                    case 3:
                        movePercentage = 0.5;
                    case 4:
                        movePercentage = 0.33;
                    case 5:
                        movePercentage = 0.25;
                }
                
                [self.progressView setProgress:self.progressView.progress-movePercentage animated:YES];
                
            }else{
                self.detailItem.justEntered = NO;
            }
        }
        
        
        // Set the check mark and x images
        // 1, 2, 3 are special codes assigned to each question to track its state
        for(int index = 0; index < 5; index++)
        {
            if ([[self.detailItem.ButtonsPressed objectAtIndex:index] isEqualToValue:@1]){
                
                flag = true;
                UIImageView *tempimage = [imageArray objectAtIndex:index];
                tempimage.image = [UIImage imageNamed:@"redX7.png"];
                
            } else if ([[self.detailItem.ButtonsPressed objectAtIndex:index] isEqualToValue:@2]){
                flag = true;
                UIImageView *tempimage = [imageArray objectAtIndex:index];
                
                tempimage.image = [UIImage imageNamed:@"ok-512.png"];
                
            } else if ([[self.detailItem.ButtonsPressed objectAtIndex:index] isEqualToValue:@0]){
                UIImageView *tempimage = [imageArray objectAtIndex:index];
                tempimage.image = nil;
                
            }
            
        }
        
    } else { // it's a report question, need to set the background image to show its been selected, and make sure all other images are nil
        
        _aImage.image = nil;
        _bImage.image = nil;
        _cImage.image = nil;
        _dImage.image = nil;
        _eImage.image = nil;
        
        resultImage.center = resultImageStartPoint;
        
        // The @3 in the index of buttonspressed means it was chosen as a report question answer
        for(int index = 0; index < 5; index++)
        {
            if ([[self.detailItem.ButtonsPressed objectAtIndex:index] isEqualToValue:@3]){
                UIImageView *tempimage = [imageArray objectAtIndex:index];
                tempimage.image = [UIImage imageNamed:@"1-ext.png"];
            }
        }
    }
    
    // stuff below here applies to both types of questions
    if (( UIDeviceOrientationIsLandscape(self.interfaceOrientation) && flag ) || (( UIDeviceOrientationIsLandscape(self.interfaceOrientation)) &&![self qIsTypeNormal])){
        // Device is in landscape, so we need to update the table image as soon as the button is pressed. Only do this if a button has been pressed (flag will be yes)
        // If it is a report question, only update it the first time.
        
        NSArray *indexPaths;
        if ([self.detailItem.qtype isEqualToString:@"0"]){
            
            indexPaths = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:self.detailItem.sortedQNumber-1 inSection:0], nil];
        }else if ([self.detailItem.qtype isEqualToString:@"1"]){
            indexPaths = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:self.detailItem.sortedQNumber-1 inSection:1], nil];
        }
        
        [master.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    
}


- (IBAction)clicked:(UIButton *)sender {
    
    currentButton = sender.titleLabel.text; // This is to send to BigButtonController and to use in the message string to parse
    
    if (!self.detailItem.qAttempts) // if its null
    {
        self.detailItem.qAttempts = [NSString stringWithFormat:@"%d", 1];
    } else {
        self.detailItem.qAttempts = [NSString stringWithFormat:@"%ld", [self.detailItem.qAttempts integerValue] +1];
    }
    
    if ([self qIsTypeNormal]){
        
        [QuestionViewController shouldDisableButton:sender should:YES];
        
        // Buttons pressed is an array where index 0 - 3 corresponds to buttons A - D. The array is initialized to all 0's. When a button is pressed, a 1 will be entered in the corresponing index for that button if it is wrong, and a 2 if it is right. This array is the key to being able to display the proper images and enable the proper buttons when re-entering a question.
        // I am now also going to add a 3 in the array if it is a report question, so we know which button to add the "selected" background image to.
        
        if ([sender.titleLabel.text isEqualToString:self.detailItem.correctAnswer]) {
            self.detailItem.questionFinished = YES;
            self.attemptsLabel.text = [NSString stringWithFormat:@"No more Attempts!"];
            [self performSelectorInBackground:@selector(sendAttemptsToParse) withObject:nil];
            [self.detailItem insertObjectInButtonsPressed:@2 AtLetterSpot:sender.titleLabel.text];
            self.detailItem.middleOfQuestion = NO;
            [master.navigationItem setHidesBackButton:NO];
            
        } else {
            [self.detailItem insertObjectInButtonsPressed:@1 AtLetterSpot:sender.titleLabel.text];
            self.attemptsLabel.text = [NSString stringWithFormat:@"Attempts Left: %ld", self.detailItem.numberOfAnswers - [self.detailItem.qAttempts integerValue]];
            self.detailItem.middleOfQuestion = YES;
            [master.navigationItem setHidesBackButton:YES];
        }
        
    } else { // It is a report question
        self.detailItem.questionFinished = YES; // This will turn off all the buttons when calling EnableButtonsAccordingToButtonsPressed
        //[self sendAttemptsToParse]; // This will send the button selected to parse
        
        //clear the previous selection
        for (int i = 0; i< [self.detailItem.ButtonsPressed count]; i++){
            [self.detailItem.ButtonsPressed replaceObjectAtIndex:i withObject:@0];
            UIButton *b = [buttonArray objectAtIndex:i];
            b.enabled = YES;
            
            UITapGestureRecognizer  *tapGesture = [tapGestureArray objectAtIndex:i];
            tapGesture.enabled = YES;
        }
        
        
        
        
        [self.detailItem insertObjectInButtonsPressed:@3 AtLetterSpot:sender.titleLabel.text];
        
        self.detailItem.reportButtonChoice = currentButton;
        self.attemptsLabel.text = @"";
    }
    [self EnableButtonsAccordingToButtonsPressed]; // Both types of questions use EnableButtons and SetImages  Method
    
    NSLog(@"before set images, bar x: %f, bary: %f", resultImage.center.x, resultImage.center.y);
    
    [self SetImagesAccordingToButtonsPressed];
    
    NSLog(@"clicked: bar x: %f, bary: %f", resultImage.center.x, resultImage.center.y);
}

- (IBAction)reportButtonSelected:(UIButton *)sender {
    
    if (!self.detailItem.appQSubmitted){
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Is this your final answer?", nil) message:NSLocalizedString(@"This will complete the question and you may not change your answer afterwards", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Yes", nil) otherButtonTitles:NSLocalizedString(@"Cancel",nil), nil] show];
    }
}


#pragma mark - Helper Methods

// Public method so that the master knows if it should update the tableview cell image
- (BOOL)shouldUpdatePhoto {
    return (self.detailItem.questionFinished);
}

// There is many times it is needed to check what kind of question it is.
-(BOOL)qIsTypeNormal{
    if ([self.detailItem.qtype isEqualToString:@"0"]){
        return YES;
    } else {
        return NO;
    }
}

// Called from sendAttempts to parse, needed to create the attempts array
- (void)assignQuizLengthFromMaster:(QuizTableViewController *)qtvc{
    quizLength = [qtvc giveQuizLength];
}

//Change the color of an image (in this case, the Big Button Letters and Background)
- (UIImage *)colorImageWithColor:(UIColor *)color withImage:(UIImage *)image
{
    // Make a rectangle the size of your image
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    // Create a new bitmap context based on the current image's size and scale, that has opacity
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    // Get a reference to the current context (which you just created)
    CGContextRef c = UIGraphicsGetCurrentContext();
    // Draw your image into the context we created
    [image drawInRect:rect];
    // Set the fill color of the context
    CGContextSetFillColorWithColor(c, [color CGColor]);
    // This sets the blend mode, which is not super helpful. Basically it uses the your fill color with the alpha of the image and vice versa. I'll include a link with more info.
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    // Now you apply the color and blend mode onto your context.
    CGContextFillRect(c, rect);
    // You grab the result of all this drawing from the context.
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    // And you return it.
    return result;
}


# pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString: @"goToBigButton"]){
        // Send the BigButton view the button that was assigned to the report question in buttonpressed
        BigButtonViewController *destViewC = [segue destinationViewController];
        
        destViewC.currentButton = self.detailItem.reportButtonChoice;
        destViewC.colours = colours;
        
    }
}

// Called from the master when a new question is pushed, also called for nextbutton. It manages updating all the labels, and calls the neccesarry methods to update the images and buttons
- (void)switchQuestion{
    
    //Hide or unhide the scroll indicators (depending on number of answers)
    if (self.detailItem.numberOfAnswers>3) {
        
        [self unhideTheTabBarWithAnimation:YES];
    }else{
        [self hideTheTabBarWithAnimation:YES];
    }
    
    //Cool flip animation when you change questions
    [UIView transitionWithView:self.view duration:0.6 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        
        //Question is closed
        if ([self.detailItem.qtype intValue] == 1 && [self.detailItem.questionRelease intValue]%2 == 0){
            self.questionClosedLabel.text = @"Question is closed";
            [QuestionViewController shouldDisableButton:reportButton should:YES];
            
            //Question has previously been completed
        }else if (![[master.resultsArray objectAtIndex:[self.detailItem.questionNumber intValue]] isEqual:@0]){
            self.questionClosedLabel.text = @"Question has previously been completed";
            self.detailItem.appQSubmitted = YES;
            self.detailItem.questionFinished = YES;
            self.attemptsLabel.text = [NSString stringWithFormat:@"Attempts Used: %@",[master.resultsArray objectAtIndex:[self.detailItem.questionNumber intValue]]];
            [QuestionViewController shouldDisableButton:reportCardButton should:NO];
            self.detailItem.reportButtonChoice = [master.resultsArray objectAtIndex:[self.detailItem.questionNumber intValue]];
            
            //Regular Application Question
        }else if ([self.detailItem.qtype intValue] == 1) {
            self.progressView.progress = 0;
            self.questionClosedLabel.text = @"Please select an answer and press the Submit Choice button when you are ready";
        }else{
            self.questionClosedLabel.text = @"";
        }
        
        [self setUpQuestionAnswerLabels];
        
    }completion:nil];
    
    if ([self qIsTypeNormal]){
        
        //Disable the report button if it is not an Application Question
        [QuestionViewController shouldDisableButton:reportButton should:YES];
        [QuestionViewController shouldDisableButton:reportCardButton should:YES];
        
        if (!self.detailItem.questionStarted){
            self.progressView.progress = 1;
            self.detailItem.questionStarted = YES;
        }else{
            
            self.detailItem.justEntered = YES;
            
        }
        if (!self.detailItem.qAttempts) { //If buttons pressed is still Null, create it.
            self.detailItem.ButtonsPressed = [[NSMutableArray alloc] initWithObjects:@0,@0, @0, @0, @0, nil];
            if (self.detailItem.questionFinished) {
                
            }else{
                
                self.attemptsLabel.text = [NSString stringWithFormat:@"Attempts Left: %d", self.detailItem.numberOfAnswers];
            }
        } else { //Question has been attempted
            self.attemptsLabel.text = [NSString stringWithFormat:@"Attempts Left: %lu", self.detailItem.numberOfAnswers - [self.detailItem.qAttempts integerValue]];
        }
        nextButton.enabled = NO;
        
        
    } else { // else, it is an Application question!
        
        if (!self.detailItem.qAttempts) { //If buttons pressed is still Null
            self.detailItem.ButtonsPressed = [[NSMutableArray alloc] initWithObjects:@0,@0, @0, @0, @0, nil];
        }
        
        self.attemptsLabel.text = @"";
    }
    // These handle all the logistics for enabling buttons and setting images.
    [self EnableButtonsAccordingToButtonsPressed];
    [self SetImagesAccordingToButtonsPressed];
    
}

// Next questions redirects to GoToNextQuestions because the swipeleft gesture also needs the same code
- (IBAction)nextQuestion:(id)sender {
    
    if ([self.detailItem.qtype isEqualToString:@"1"] && !self.detailItem.appQSubmitted && self.detailItem.questionFinished){
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"You haven't submitted your answer yet", nil) message:NSLocalizedString(@"Please go back and press the report choice button if you are ready to submit your answer", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Okay", nil) otherButtonTitles:nil, nil] show];
    }
    
    
    
    if ([self.detailItem.questionNumber integerValue] != (int)quizLength){
        NSLog(@"The question number is %ld", (long)[self.detailItem.questionNumber integerValue]);
        [self goToNextQuestion];
    }
    
}

- (IBAction)swipedRight:(id)sender {
    
    if ([self.detailItem.qtype isEqualToString:@"1"] && !self.detailItem.appQSubmitted && self.detailItem.questionFinished){
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"You haven't submitted your answer yet", nil) message:NSLocalizedString(@"Please go back and press the report choice button if you are ready to submit your answer", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Okay", nil) otherButtonTitles:nil, nil] show];
    }
    
    // Make sure you cant swipe on the last question
    if ([self.detailItem.questionNumber integerValue] != (int)quizLength){
        NSLog(@"The question number is %ld", (long)[self.detailItem.questionNumber integerValue]);
        [self goToNextQuestion];
    }
}


- (void)goToNextQuestion{
    
    id detailnav = self.splitViewController.viewControllers[1];
    id detail = [detailnav topViewController];
    
    if ([master isKindOfClass:[QuizTableViewController class]]){
        NSInteger currentrow = [self.detailItem.questionNumber integerValue];
        [master prepareQuestionViewController:detail toDisplayQuestionAtRow:currentrow+1];
        [self switchQuestion];
    }
}

// Unwinds from pastquiz view controller when the user taps a quiz
- (void) setUpTest {

    startedQuiz = NO;
    
    id mostRecentSubview = master.view.subviews.lastObject;
    
    if ([master isKindOfClass:[QuizTableViewController class]]){
        [self sendQuizIDto:master withidentifier:self.quizIdentifier];
        
        if ([mostRecentSubview isKindOfClass:[ILTranslucentView class]]){
            [[master.view.subviews objectAtIndex:[master.view.subviews count]-1]removeFromSuperview];
            self.navigationItem.rightBarButtonItem.title = @"Logout";
            master.navigationItem.rightBarButtonItem.title = @"More";
        }
    }
}


- (IBAction)reportCardButtonPressed:(id)sender {
    
    if (self.detailItem.reportButtonChoice == nil){
        
    }else{
        
        [self performSegueWithIdentifier: @"goToBigButton" sender: self];
    }
}




#pragma mark - Formatting

//This method is the center the text in the textField boxes for each answer/question content
-(void)observeValueForKeyPath:(NSString *)keyPath   ofObject:(id)object   change:(NSDictionary *)change   context:(void *)context {
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])  / 2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}


- (void) handleTapFromA: (UITapGestureRecognizer *)recognizer
{
    [self clicked:self.buttonA];
    recognizer.enabled = NO;
}

- (void) handleTapFromB: (UITapGestureRecognizer *)recognizer
{
    [self clicked:self.buttonB];
    recognizer.enabled = NO;
}

- (void) handleTapFromC: (UITapGestureRecognizer *)recognizer
{
    [self clicked:self.buttonC];
    recognizer.enabled = NO;
}

- (void) handleTapFromD: (UITapGestureRecognizer *)recognizer
{
    [self clicked:self.buttonD];
    recognizer.enabled = NO;
}

- (void) handleTapFromE: (UITapGestureRecognizer *)recognizer
{
    [self clicked:self.buttonE];
    recognizer.enabled = NO;
}

- (void)formatLabel: (UITextView *)label{
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    [label addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
    label.textAlignment = NSTextAlignmentCenter;
   
    
}

- (void)setUpQuestionAnswerLabels {
    //Set the Question Content and each answer
    self.qContentLabel.text = [NSString stringWithFormat:@"%@. %@", self.detailItem.questionNumber, self.detailItem.questionContent];
    [self formatLabel:self.qContentLabel];
    
    self.answerALabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerA];
    self.answerBLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerB];
    self.answerCLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerC];
    self.answerDLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerD];
    self.answerELabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerE];
    
    [self formatLabel:self.answerALabel];
    [self formatLabel:self.answerBLabel];
    [self formatLabel:self.answerCLabel];
    [self formatLabel:self.answerDLabel];
    [self formatLabel:self.answerELabel];
    
    //Depending on the number of answers, turn on and off different labels and format each one appropriately
    
    if (self.detailItem.numberOfAnswers == 2) {
        
        //NO C, D, E
        self.answerCLabel.hidden = YES;
        self.buttonC.alpha = 0;
        
        self.answerDLabel.hidden = YES;
        self.buttonD.alpha = 0;
        
        self.answerELabel.hidden = YES;
        self.buttonE.alpha = 0;
        
        self.Cbackground.backgroundColor = [UIColor clearColor];
        self.Dbackground.backgroundColor = [UIColor clearColor];
        self.Ebackground.backgroundColor = [UIColor clearColor];
    }
    
    if (self.detailItem.numberOfAnswers == 3){
        
        self.answerCLabel.hidden = NO;
        self.buttonC.alpha = 1;
        
        
        self.Cbackground.backgroundColor = UIColorFromRGB(0x007AFF);
        self.Cbackground.alpha = 0.3;
        self.Dbackground.backgroundColor = [UIColor clearColor];
        self.Ebackground.backgroundColor = [UIColor clearColor];
        
        //NO D and E
        self.answerDLabel.hidden = YES;
        self.buttonD.alpha = 0;
        
        self.answerELabel.hidden = YES;
        self.buttonE.alpha = 0;
        
    }
    
    
    if (self.detailItem.numberOfAnswers == 4){
        
        self.answerCLabel.hidden = NO;
        self.buttonC.alpha = 1;
        
        self.answerDLabel.hidden = NO;
        self.buttonD.alpha = 1;
        
        //NO E
        self.answerELabel.hidden = YES;
        self.buttonE.alpha = 0;
        
        self.Cbackground.backgroundColor = UIColorFromRGB(0x007AFF);
        self.Cbackground.alpha = 0.3;
        self.Dbackground.backgroundColor = UIColorFromRGB(0x007AFF);
        self.Dbackground.alpha = 0.3;
        
        self.Ebackground.backgroundColor = [UIColor clearColor];
    }
    
    if (self.detailItem.numberOfAnswers == 5){
        
        self.answerCLabel.hidden = NO;
        self.buttonC.alpha = 1;
        
        self.answerDLabel.hidden = NO;
        self.buttonD.alpha = 1;
        
        self.answerELabel.hidden = NO;
        self.buttonE.alpha = 1;
        
        self.Cbackground.backgroundColor = UIColorFromRGB(0x007AFF);
        self.Cbackground.alpha = 0.3;
        self.Dbackground.backgroundColor = UIColorFromRGB(0x007AFF);
        self.Dbackground.alpha = 0.3;
        self.Ebackground.backgroundColor = UIColorFromRGB(0x007AFF);
        self.Ebackground.alpha = 0.3;
    }
}


#pragma mark - Scroll view delegates


- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (sender.contentOffset.x != 0) {
        CGPoint offset = sender.contentOffset;
        offset.x = 0;
        sender.contentOffset = offset;
    }
    
    //Scroll only if there is more than 3 answers
    if (self.detailItem.numberOfAnswers>3){
        
        
        //Hide the scroll indicator after the last answer has appeared on the screen (reached bottom of view)
        if (self.detailItem.numberOfAnswers == 4){
            if (CGRectEqualToRect(CGRectIntersection(self.scrollView.bounds, self.answerDLabel.frame),
                                  self.answerDLabel.frame)){
                [self hideTheTabBarWithAnimation:YES];
            }
            
        }else if (self.detailItem.numberOfAnswers == 5){
            if (CGRectEqualToRect(CGRectIntersection(self.scrollView.bounds, self.answerELabel.frame),
                                  self.answerELabel.frame)){
                [self hideTheTabBarWithAnimation:YES];
            }
            
        }else{
            [self unhideTheTabBarWithAnimation:YES];
        }
        
    }
}



-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.detailItem.numberOfAnswers>3){
        
        if (self.detailItem.numberOfAnswers == 4){
            if (CGRectEqualToRect(CGRectIntersection(self.scrollView.bounds, self.answerDLabel.frame),
                                  self.answerDLabel.frame)){
                [self hideTheTabBarWithAnimation:YES];
            }else{
                [self unhideTheTabBarWithAnimation:YES];
            }
        }
        
        
        if (self.detailItem.numberOfAnswers == 5){
            if (CGRectEqualToRect(CGRectIntersection(self.scrollView.bounds, self.answerELabel.frame),
                                  self.answerELabel.frame)){
                [self hideTheTabBarWithAnimation:YES];
            }else{
                [self unhideTheTabBarWithAnimation:YES];
            }
        }
    }
}


-(void) scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    [self unhideTheTabBarWithAnimation:YES];
}


- (void) hideTheTabBarWithAnimation:(BOOL) withAnimation {
    if (NO == withAnimation) {
        self.scrollIndicator.image = nil;
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:nil];
        [UIView setAnimationDuration:0.75];
        
        self.scrollIndicator.alpha = 0;
        
        [UIView commitAnimations];
    }
}


- (void) unhideTheTabBarWithAnimation:(BOOL) withAnimation {
    if (NO == withAnimation) {
        self.scrollIndicator.image = [UIImage imageNamed:@" "];
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:nil];
        [UIView setAnimationDuration:0.75];
        
        self.scrollIndicator.alpha = 1;
        
        [UIView commitAnimations];
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"See Test", @"See Test");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    //self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    //self.masterPopoverController = nil;
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
    
    groupName = user.username;
    loggedIn = YES;
    [self dismissViewControllerAnimated:NO completion:nil];
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

@end
