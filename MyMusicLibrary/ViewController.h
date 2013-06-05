//
//  ViewController.h
//  MyMusicLibrary
//
//  Created by Ohata Takashi on 2013/05/22.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "MyScrollView.h"

#define MAXWIDTH 1600
#define MAXHEIGHT 900
#define DEFAULTSIZE 100

@interface ViewController : UIViewController<UIScrollViewDelegate,NSCoding>{
    UITapGestureRecognizer *singleFingerDTap;
    MyScrollView *scroller;
    int imageTag;

}
@end
