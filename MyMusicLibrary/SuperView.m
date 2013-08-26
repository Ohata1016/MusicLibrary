//
//  SuperView.m
//  MyMusicLibrary
//
//  Created by Ohata Takashi on 2013/06/21.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import "SuperView.h"
#import "MusicImage.h"


@implementation SuperView
{
    EffectSoundBox *soundBox;
    int havePlayingFrame;
    int haveRedFrame;
    NSMutableArray *musicSaveData;
    NSNotificationCenter *notificationCenter;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        havePlayingFrame = 0;
        haveRedFrame = 0;
        self.userInteractionEnabled = YES;
        musicSaveData = [NSMutableArray array];
        notificationCenter= [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(changeImage) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:_player];//通知の対象に自分を追加
        soundBox = [[EffectSoundBox alloc] init];
        
        _player = [MPMusicPlayerController applicationMusicPlayer];
        _player.repeatMode = MPMusicRepeatModeOne;
        _player = [MPMusicPlayerController iPodMusicPlayer];
        
        [_player beginGeneratingPlaybackNotifications];
        
    }
    return self;
}
-(void)updateHaveRedFrame:(int)tag{
    haveRedFrame = tag;
}
-(int)getHaveRedFrame{
    return haveRedFrame;
}

-(void)changeImage{//曲が変わった通知を受けたら、musicImageの画像を変更する
    if(havePlayingFrame){
        NSLog(@"notification called");
    [(MusicImage *)[self viewWithTag:havePlayingFrame-PLAYINGFRAME] changeImage];
    }else{
        return;
    }
    
}
-(void)updateHavePlayingFrame:(int)tag{
    havePlayingFrame = tag;
}

-(int)getHavePlayingFrame{
    return havePlayingFrame;
}
-(NSMutableArray *)getMusicSaveData{
    return musicSaveData;
}

-(void)allDelete{
    NSLog(@"delete saveData");
    NSString *fileName = @"Documents/data";
    NSString *extention = @".dat";
    NSString *fileNum = [NSString stringWithFormat:@"%d",[self superview].tag];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@",fileName,fileNum,extention]];

    for(int i=STARTMUSICTAGNUMBER;[self viewWithTag:i]!=nil;i+=DELETER+1){
        [[self viewWithTag:i] removeFromSuperview];
    }
    [musicSaveData removeAllObjects];
    
    [NSKeyedArchiver archiveRootObject:musicSaveData toFile:filePath];
}

-(void)playSelectSound{
    [soundBox playSelectSound];
}
-(void)playPanActionSound{
    NSLog(@"play pan action sound call");
    [soundBox playPanActionSound];
}
-(void)playDeleteSound{
    NSLog(@"play delete action sound call");
    [soundBox playDeleteSound];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
