//
//  BigButtonViewController.h
//  QuizApp2-7
//
//  Created by cisdev2 on 2/22/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BigButtonViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *bigButtonImage;
@property NSString *currentButton;
@property (strong, nonatomic) NSMutableArray *colours;

@end
