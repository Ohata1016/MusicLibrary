//
//  MusicSaveData.m
//  MyMusicLibrary
//
//  Created by Ohata Takashi on 2013/06/19.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import "MusicSaveData.h"

@implementation MusicSaveData


-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self){
        _musicArray = [aDecoder decodeObjectForKey:@"musicArray"];
        _bounds  = [aDecoder decodeCGRectForKey:@"bounds"];
        _albumName = [aDecoder decodeObjectForKey:@"albumName"];
    }
    return self;
}
-(id)init{
    self = [super init];
    _musicArray =[[NSMutableArray alloc] initWithCapacity:1];//array初期化
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_musicArray forKey:@"musicArray"];
    [aCoder encodeObject:_albumName forKey:@"albumName"];
    [aCoder encodeCGRect:_bounds forKey:@"bounds"];
}



@end
