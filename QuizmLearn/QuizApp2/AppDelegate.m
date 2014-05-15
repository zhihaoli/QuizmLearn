//
//  AppDelegate.m
//  QuizApp2
//
//  Created by Bruce Li on 1/27/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //Parse backend ID and key
    [Parse setApplicationId:@"1LlY1hjS7ZV2aEjGcH2eIFhXbaL3tfnhdDaghIuz"
                  clientKey:@"bLPC47d78N8aGJIQXSKoJBaoG7rhtdLwX6oVRVXm"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    self.viewController = [[ImportViewController alloc]init];

    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    splitViewController.delegate = (id)navigationController.topViewController;
    
    
    //[application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    
    //all the url stuff is inherited from the code in Quizm Teach; it does not play a role in this app
//    NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
//    if(url != nil && [url isFileURL]) {
//        [self.viewController handleOpenURL:url];
//    }
    
  
    
    return YES;
}

-(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    if (url != nil && [url isFileURL]) {
//        [self.viewController handleOpenURL:url];
//    }
    return YES;
}


- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    if (url != nil && [url isFileURL]) {
//        [self.viewController handleOpenURL:url];
//    }
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
//    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//    [currentInstallation setDeviceTokenFromData:deviceToken];
//    [currentInstallation saveInBackground];
//}
//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
//    NSLog(@"received a notifcation");
//    [PFPush handlePush:userInfo];
//}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
