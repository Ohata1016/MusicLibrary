//
//  MusicSaveData.h
//  MyMusicLibrary
//
//  Created by Ohata Takashi on 2013/06/19.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MusicSaveData : NSObject<NSCoding>
@property (nonatomic)CGRect bounds;
@property (nonatomic, retain)NSMutableArray *musicArray;
@property (nonatomic,strong) NSString *albumName;

@end
