//
//  AppDelegate.h
//  MyMusicLibrary
//
//  Created by Ohata Takashi on 2013/05/22.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIScrollViewDelegate>
   


@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@property (nonatomic,retain) NSMutableArray *canvasViewControllerList;

-(void)addController;
-(void)addController:(ViewController *)cnt;

@end
