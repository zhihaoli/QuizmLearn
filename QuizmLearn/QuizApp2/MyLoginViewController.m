//
//  MyLoginViewController.m
//  QuizApp2-7
//
//  Created by cisdev2 on 2/20/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import "MyLoginViewController.h"

@interface MyLoginViewController ()

@end

@implementation MyLoginViewController

BOOL isPortrait;
BOOL isLandscape;
BOOL isValid;
UILabel *textLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
    isLandscape = UIDeviceOrientationIsLandscape(self.interfaceOrientation);
    isValid = UIDeviceOrientationIsValidInterfaceOrientation(self.interfaceOrientation);
    
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"QuizmLearnLoginBG.png"]]];
    //[self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SmartTest_Student_trans.png"]]];
    [self.logInView setLogo:nil];

    textLabel = [[UILabel alloc]init];
    


    textLabel.text = @"Welcome to SmarTEST Student!";
    
    [textLabel setBackgroundColor:[UIColor clearColor]];
    
    [textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:44]];
    textLabel.textColor = [UIColor whiteColor];

    
    
    [self.logInView.passwordField setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
    [self.logInView.usernameField setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
    
    [self.logInView.passwordField setTextColor:[UIColor blackColor]];
    [self.logInView.usernameField setTextColor:[UIColor blackColor]];
    
        
    if (isPortrait){
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"QuizmLearnLoginBG.png"]]];
            [textLabel setFrame:CGRectMake(100, 80, 700, 100)];
        [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"QuizmLearnLoginBG.png"] forState:UIControlStateNormal];
        

    }else if (isLandscape){
       [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"QuizmLearnLoginBGLandscape.png"]]];
            [textLabel setFrame:CGRectMake(210, 80, 700, 100)];
        [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateNormal];

    }
    
        [self.logInView addSubview:textLabel];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIDeviceOrientationPortrait || toInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown) {
          //[self.logInView.logo setFrame:CGRectMake(290.0f, 165.0f, 200.0, 250.0)];
         [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"QuizmLearnLoginBG.png"] forState:UIControlStateNormal];
        

        isPortrait = YES;
        isLandscape = NO;
        
    }else{
        //[self.logInView.logo setFrame:CGRectMake(355.0f,-20.0f, 300.0f, 400.0f)];
          //[self.logInView.logo setFrame:CGRectMake(290.0f, 165.0f, 200.0, 250.0)];
        [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateNormal];
        isPortrait = NO;
        isLandscape = YES;
    }
}



- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Set frame for elements
    //[self.logInView.dismissButton setFrame:CGRectMake(10.0f, 10.0f, 87.5f, 45.5f)];
    
    if(isPortrait) {
        [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SmartTest_Student_trans.png"]]];
        //[self.logInView setLogo:nil];
        [self.logInView.logo setFrame:CGRectMake(290.0f, 165.0f, 200.0, 250.0)];
        

            }else if (isLandscape){
       [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SmartTest_Student_trans.png"]]];
         //       [self.logInView setLogo:nil];
          //[self.logInView.logo setFrame:CGRectMake(290.0f, 165.0f, 200.0, 250.0)];
                
                [self.logInView.usernameField setFrame:CGRectMake(485.0f, 215.0f, 250.0f, 50.0f)];
                [self.logInView.passwordField setFrame:CGRectMake(485.0f, 265.0f, 250.0f, 50.0f)];
                [self.logInView.logInButton setFrame:CGRectMake(750.0f, 240.0f, self.logInView.logInButton.frame.size.width, self.logInView.logInButton.frame.size.height)];
                 [self.logInView.logo setFrame:CGRectMake(240, 160, 160, 200)];

        
    }
    
    if (isPortrait){
        [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"QuizmLearnLoginBG.png"]]];
        [textLabel setFrame:CGRectMake(100, 80, 700, 100)];

        
    }else if (isLandscape){
        [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"QuizmLearnLoginBGLandscape.png"]]];
        
        
      [textLabel setFrame:CGRectMake(210, 60, 700, 100)];

    }
    

    
//    [self.logInView.logo setFrame:CGRectMake(225.0f, 110.0f, 300.0f, 400.0f)];
//    [self.logInView.facebookButton setFrame:CGRectMake(35.0f, 287.0f, 120.0f, 40.0f)];
//    [self.logInView.twitterButton setFrame:CGRectMake(35.0f+130.0f, 287.0f, 120.0f, 40.0f)];
//    [self.logInView.signUpButton setFrame:CGRectMake(35.0f, 385.0f, 250.0f, 40.0f)];
//    [self.logInView.usernameField setFrame:CGRectMake(35.0f, 145.0f, 250.0f, 50.0f)];
//    [self.logInView.passwordField setFrame:CGRectMake(35.0f, 195.0f, 250.0f, 50.0f)];
//    [self.fieldsBackground setFrame:CGRectMake(35.0f, 145.0f, 250.0f, 100.0f)];
}

@end
