//
//  Deleter.m
//  MyMusicLibrary
//
//  Created by Ohata Takashi on 2013/05/23.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import "Deleter.h"

@implementation Deleter
{
        UITapGestureRecognizer *singleFingerDTap;
}
- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"addDeleter");
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        UIImage *img = [UIImage imageNamed:@"deleter.png"];
        self.image = img;
        singleFingerDTap = [[UITapGestureRecognizer alloc]
                            initWithTarget:self  action:@selector(handleSingleTap:)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:singleFingerDTap];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        singleFingerDTap = [[UITapGestureRecognizer alloc]
                            initWithTarget:self  action:@selector(handleSingleTap:)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:singleFingerDTap];
        // Initialization code
    }
    return self;
}

-(void)handleSingleTap:(UIGestureRecognizer *)sender{
    NSLog(@"Deleter gesture called");
    //大本のviewをとっとく
    MusicImage *img = (MusicImage*)self.superview;
    NSLog(@"img getsuperview:%@",[img getSuperview]);
    [[img getSuperview] playDeleteSound];

    if(sender.state == UIGestureRecognizerStateEnded){
        [img deleteView];
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
