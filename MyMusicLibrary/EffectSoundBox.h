//
//  EffectSoundBox.h
//  MyMusicLibrary
//
//  Created by 大畑 貴史 on 2013/08/03.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
@interface EffectSoundBox : NSObject
-(id)init;
-(void)playSelectSound;
-(void)playPanActionSound;
-(void)playDeleteSound;
@end
