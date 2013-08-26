//
//  AllDeleter.m
//  MyMusicLibrary
//
//  Created by 大畑 貴史 on 2013/08/02.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import "AllDeleter.h"

@implementation AllDeleter



-(void)handleSingleTap:(UIGestureRecognizer *)sender{
    NSLog(@"AllDeleter gesture called");
    
    SuperView *scr = (SuperView *)[self superview];
    if(sender.state == UIGestureRecognizerStateEnded){
        [scr allDelete];
    }
    
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
