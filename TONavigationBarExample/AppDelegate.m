//
//  AppDelegate.m
//  TONavigationBarExample
//
//  Created by Tim Oliver on 1/31/18.
//  Copyright © 2018 Tim Oliver. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "TONavigationBar.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    ViewController *viewController = [[ViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithNavigationBarClass:[TONavigationBar class] toolbarClass:nil];
    [navController pushViewController:viewController animated:NO];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
