//
//  AppDelegate.m
//  MyMusicLibrary
//
//  Created by Ohata Takashi on 2013/05/22.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate
{
    int existViewControllerNumber;
    //現状、viewControllerにtag番号を割り振っている
    //tag番号を使ったファイルにシリアライズしている
    //tag番号が有限になるため、プロパティにtag以外の個体識別のための属性を追加する予定
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions//application開始時に行われる
{
    
    self.canvasViewControllerList = [[NSMutableArray alloc] initWithCapacity:1];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] init];
    
    self.window.rootViewController = self.viewController;
    
    self.viewController.view.tag = 1;
    existViewControllerNumber = 1;
    [self.viewController setCanvasViewControllerNumber:existViewControllerNumber-1];
    
    
    [self.viewController readSaveData];
    
    [self.canvasViewControllerList addObject:self.viewController];
    
    [self.window addSubview:self.viewController.view];
    
    // 初期状態としてViewController1を前面に表示する。
    [self.window bringSubviewToFront:self.viewController.view];
    
    [self.window makeKeyAndVisible];
    return YES;
    
}

-(void)addController{

    ViewController *cnt = [[ViewController alloc] init];
    existViewControllerNumber++;
    
    [self.viewController setCanvasViewControllerNumber:existViewControllerNumber-1];
    
    cnt.view.tag = existViewControllerNumber;

    [cnt readSaveData];
    
    [self.canvasViewControllerList addObject:cnt];
    self.window.rootViewController = cnt;
    [self.window addSubview:cnt.view];
    [self.window bringSubviewToFront:cnt.view];
    [self.window makeKeyAndVisible];
}

-(void)addController:(ViewController *)cnt{//アルバムのviewControllerに切り替えるときに使う    
    self.window.rootViewController = cnt;
    [self.window addSubview:cnt.view];
    [self.window bringSubviewToFront:cnt.view];
    [self.window makeKeyAndVisible];
    
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

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
