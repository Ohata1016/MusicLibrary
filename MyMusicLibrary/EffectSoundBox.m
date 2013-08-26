//
//  EffectSoundBox.m
//  MyMusicLibrary
//
//  Created by 大畑 貴史 on 2013/08/03.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import "EffectSoundBox.h"
//重要
//参考:http://blog.nicolet.jp/article/62788265.html
//効果音を出す方法は２種類
//SystemSoundIDを使う方法
//AVAudioPlayerを使う方法
//iphone5ではSystemSoundIDを使う方法だと音量調節ができない
//一方、AVAudioを使う場合は、現在再生している音楽を止めて音を出してしまう
//現状SystemSoundIDを使う方法で実装する

@implementation EffectSoundBox
{
    SystemSoundID selectSound;
    SystemSoundID acsessLibrarySound;
    SystemSoundID panActionSound;
    SystemSoundID deleteSound;
    
}

-(id)init{
    self = [super init];
    [self setSelectSound];
    [self setPanActionSound];
    [self setDeleteSound];
    return self;
}

-(void)setSelectSound{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"se_click_2" ofType:@"mp3"];
    NSURL *url = [NSURL URLWithString:path];
    
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url),&selectSound);
    
}

-(void)setAcsessLibrarySound{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"se_click_2" ofType:@"mp3"];
    NSURL *url = [NSURL URLWithString:path];
    
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url),&acsessLibrarySound);
}

-(void)setDeleteSound{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"se_pyuun" ofType:@"mp3"];
    NSURL *url = [NSURL URLWithString:path];
    
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url),&deleteSound);
}

-(void)setPanActionSound{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"se_kachi_1" ofType:@"mp3"];
    NSURL *url = [NSURL URLWithString:path];
    
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url),&panActionSound);
    
}

-(void)playSelectSound{
    AudioServicesPlaySystemSound(selectSound);
}

-(void)playPanActionSound{
    AudioServicesPlaySystemSound(panActionSound);
}

-(void)playDeleteSound{
    AudioServicesPlaySystemSound(deleteSound);
}
@end
