//
//  MusicImage.h
//  MyMusicLibrary
//
//  Created by Ohata Takashi on 2013/05/22.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>


#define MAXWIDTH 1600
#define MAXHEIGHT 900

@interface MusicImage : UIImageView<UIScrollViewDelegate,UITextViewDelegate>{
    UITapGestureRecognizer *singleFingerDTap;
    UILongPressGestureRecognizer *longPressGesture;
    UIPinchGestureRecognizer *pinchGesture;
    UITapGestureRecognizer *doubleTapGesture;
    UITapGestureRecognizer *tripleTapGesture;
    UISwipeGestureRecognizer *rightSwipeGesture;
    UISwipeGestureRecognizer *leftSwipeGesture;
    UISwipeGestureRecognizer *upSwipeGesture;
    UISwipeGestureRecognizer *downSwipeGesture;
    UIPanGestureRecognizer *panGesture;
    NSNotificationCenter *notificationCenter;
    
    
    CGAffineTransform currentTrans;
    
    CGPoint touchLocation;
    MPMediaQuery *myMusic;
    NSMutableArray *musicArray;
    NSMutableArray *nowPlayingItem;
    
    UITextField *textField;
    BOOL playing;
}
typedef enum imageLabel:NSUInteger{
    IMAGE,
    FRAME,
    SCALLER,
    TEXT,
    NOWPLAYINGITEM,
    PLAYINGFRAME,
    DELETER
}imageLabel;

-(void)addMusic:(NSMutableArray *)music;
-(void)deleteView;
-(void)shuffleMusic;
@property MPMusicPlayerController *player;
@end
