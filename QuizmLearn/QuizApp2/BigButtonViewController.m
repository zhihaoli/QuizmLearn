//
//  BigButtonViewController.m
//  QuizApp2-7
//
//  Created by cisdev2 on 2/22/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import "BigButtonViewController.h"

@interface BigButtonViewController ()

@end

@implementation BigButtonViewController

BOOL isPortrait;
BOOL isLandscape;
BOOL isValid;

NSString *fontColour;
NSString *backgroundColour;
UIColor *cfontColour;
UIColor *cbackgroundColour;

UITapGestureRecognizer *tapToDismiss;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    tapToDismiss = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapToDismiss:)];
    [self.view addGestureRecognizer:tapToDismiss];
    
    isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
    isLandscape = UIDeviceOrientationIsLandscape(self.interfaceOrientation);
    isValid = UIDeviceOrientationIsValidInterfaceOrientation(self.interfaceOrientation);
}

- (void)viewWillAppear:(BOOL)animated
{
    //Set the correct background and fontColors for each button based on the colors array in Parse
    
    if ([self.currentButton isEqualToString:@"A"]){
        backgroundColour = [self.colours objectAtIndex:0];
        fontColour = [self.colours objectAtIndex:1];
    }
    
    if ([self.currentButton isEqualToString:@"B"]){
        backgroundColour = [self.colours objectAtIndex:2];
        fontColour = [self.colours objectAtIndex:3];
        
    }
    
    if ([self.currentButton isEqualToString:@"C"]){
        backgroundColour = [self.colours objectAtIndex:4];
        fontColour = [self.colours objectAtIndex:5];
        
    }
    
    if ([self.currentButton isEqualToString:@"D"]){
        backgroundColour = [self.colours objectAtIndex:6];
        fontColour = [self.colours objectAtIndex:7];
        
    }
    
    if ([self.currentButton isEqualToString:@"E"]){
        backgroundColour = [self.colours objectAtIndex:8];
        fontColour = [self.colours objectAtIndex:9];
        
    }
    
    
    cbackgroundColour = [self colorFromHexString:backgroundColour];
    cfontColour = [self colorFromHexString:fontColour];
    
    self.bigButtonImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"report%@.png", self.currentButton]];
    self.bigButtonImage.image = [self colorImageWithColor:cfontColour withImage:[UIImage imageNamed:[NSString stringWithFormat:@"report%@.png", self.currentButton]]];

    
    self.view.backgroundColor = cbackgroundColour;

}


- (void) handleTapToDismiss: (UITapGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:0];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


//Change the background and font color of the image
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}


- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIDeviceOrientationPortrait || toInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        isPortrait = YES;
        isLandscape = NO;
    }else{
        isPortrait = NO;
        isLandscape = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
