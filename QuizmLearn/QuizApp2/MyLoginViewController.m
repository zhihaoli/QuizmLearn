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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
    isLandscape = UIDeviceOrientationIsLandscape(self.interfaceOrientation);
    isValid = UIDeviceOrientationIsValidInterfaceOrientation(self.interfaceOrientation);
    
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"QuizmLearnLoginBG.png"]]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"QuizmLearnLoginLogo2.png"]]];
    
    [self.logInView.passwordField setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
    [self.logInView.usernameField setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
    
    [self.logInView.passwordField setTextColor:[UIColor blackColor]];
    [self.logInView.usernameField setTextColor:[UIColor blackColor]];
    
    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"QuizmLearnLoginBG"] forState:UIControlStateNormal];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIDeviceOrientationPortrait || toInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        [self.logInView.logo setFrame:CGRectMake(225.0f, 110.0f, 300.0f, 400.0f)];
        isPortrait = YES;
        isLandscape = NO;
        
    }else{
        [self.logInView.logo setFrame:CGRectMake(355.0f,-20.0f, 300.0f, 400.0f)];
        isPortrait = NO;
        isLandscape = YES;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Set frame for elements
    //[self.logInView.dismissButton setFrame:CGRectMake(10.0f, 10.0f, 87.5f, 45.5f)];
    
    if(isPortrait) {
        [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"QuizmLearnLoginLogo2.png"]]];
        [self.logInView.logo setFrame:CGRectMake(225.0f, 110.0f, 300.0f, 400.0f)];
    }else if (isLandscape){
        [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"QuizmLearnLoginLogo.png"]]];
        [self.logInView.logo setFrame:CGRectMake(355.0f,-20.0f, 300.0f, 400.0f)];
    }
    
    //[self.logInView.logo setFrame:CGRectMake(225.0f, 110.0f, 300.0f, 400.0f)];
//    [self.logInView.facebookButton setFrame:CGRectMake(35.0f, 287.0f, 120.0f, 40.0f)];
//    [self.logInView.twitterButton setFrame:CGRectMake(35.0f+130.0f, 287.0f, 120.0f, 40.0f)];
//    [self.logInView.signUpButton setFrame:CGRectMake(35.0f, 385.0f, 250.0f, 40.0f)];
//    [self.logInView.usernameField setFrame:CGRectMake(35.0f, 145.0f, 250.0f, 50.0f)];
//    [self.logInView.passwordField setFrame:CGRectMake(35.0f, 195.0f, 250.0f, 50.0f)];
//    [self.fieldsBackground setFrame:CGRectMake(35.0f, 145.0f, 250.0f, 100.0f)];
}

@end
