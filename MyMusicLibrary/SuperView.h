//
//  SuperView.h
//  MyMusicLibrary
//
//  Created by Ohata Takashi on 2013/06/21.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "EffectSoundBox.h"

@interface SuperView : UIImageView<NSCoding>

-(NSMutableArray *)getMusicSaveData;
-(int)getHaveRedFrame;
-(void)updateHaveRedFrame:(int)tag;
-(int)getHavePlayingFrame;
-(void)updateHavePlayingFrame:(int)tag;
-(void)allDelete;
-(void)playSelectSound;
-(void)playPanActionSound;
-(void)playDeleteSound;
@property MPMusicPlayerController *player;
@end
