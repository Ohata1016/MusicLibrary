//
//  skipSongBottun.m
//  MyMusicLibrary
//
//  Created by Ohata Takashi on 2013/05/27.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import "skipSongBottun.h"

@implementation skipSongBottun

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage *frameImage = [UIImage imageNamed:@"scaller.gif"];
        self.userInteractionEnabled = YES;
        self.image = frameImage;
        
        UIGestureRecognizer *singleFingerDTap = [[UITapGestureRecognizer alloc]
                                                        initWithTarget:self  action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleFingerDTap];
        
        [self.superview addSubview:self];
        
    }
    return self;
}

-(void)handleSingleTap:(UIGestureRecognizer *)sender{
    
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
