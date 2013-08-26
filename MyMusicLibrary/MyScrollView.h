//
//  MyScrollView.h
//  MyMusicLibrary
//
//  Created by Ohata Takashi on 2013/05/22.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MusicImage.h"
#import "SuperView.h"
@protocol MyScrollViewDelegate<NSObject>
-(void)changeViewController:(NSMutableArray *)cnt;
@end
@interface MyScrollView : UIScrollView<NSCoding>
@property (nonatomic, assign) id<MyScrollViewDelegate> delegate;
// デリゲートメソッドを呼ぶメソッド
- (void)callChangeViewController:(NSMutableArray *)cnt;
-(void)addMusicImage:(MusicImage*)image;
-(SuperView *)getSubview;
-(void)addAllDeleter;
@end
