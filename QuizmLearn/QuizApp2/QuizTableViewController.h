//
//  QuizTableViewController.h
//  QuizApp2
//
//  Created by Bruce Li on 2/5/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImportViewController.h"
#import "QuestionViewController.h"
#import "QuestionSelectionDelegate.h"
#import "ILTranslucentView.h"


@interface QuizTableViewController : UITableViewController

@property (strong, nonatomic) NSIndexPath *currentSelection;
@property (strong, nonatomic) NSString *currentButtonSelected;

@property (strong, nonatomic) NSString * quizIdentifier;
@property (strong, nonatomic) QuestionViewController *questionViewController;

@property (strong, nonatomic) NSMutableArray *listPastQuizzes;
@property (strong, nonatomic) NSMutableArray *listOfQuestions;

@property (strong, nonatomic) NSMutableArray *resultsArray;

- (NSInteger)giveQuizLength;

-(void)prepareQuestionViewController:(QuestionViewController *)qvc toDisplayQuestionAtRow:(NSInteger)row;

- (void)loadQuizData;

- (void)displayFirstQuestion;

- (void)makeTranslucent;

@end
