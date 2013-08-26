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
#import "MusicSaveData.h"
#import "CommonLibrary.h"
#import "SuperView.h"

#define STARTMUSICTAGNUMBER 6



@interface MusicImage : UIImageView<UIScrollViewDelegate,UITextViewDelegate,NSCoding>


typedef enum imageLabel:NSUInteger{
    IMAGE,
    FRAME,
    SONGLABEL,
    ALBUMLABEL,
    NOWPLAYINGITEM,
    PLAYINGFRAME,
    DELETER
}imageLabel;
@property     NSString *albumName;
-(void)addMusic:(NSMutableArray *)music;
-(void)deleteView;
-(void)shuffleMusic;
-(void)serializer;
-(void)changeImage;
-(void)makeAlbumController;
-(SuperView *)getSuperview;

@end
