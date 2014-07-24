//
//  ImportViewController.h
//  QuizApp2
//
//  Created by Bruce Li on 1/30/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+ParsingExtensions.h"
#import <Parse/Parse.h>

@interface ImportViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *importedRows;
@property (strong, nonatomic) NSArray * questions;

@property (strong, nonatomic) NSString *quizIdentifier;

@property NSString *groupName;

@end
