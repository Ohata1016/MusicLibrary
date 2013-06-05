//
//  redFrame.m
//  MyMusicLibrary
//
//  Created by Ohata Takashi on 2013/05/23.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import "RedFrame.h"

@implementation RedFrame

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage *frameImage = [UIImage imageNamed:@"redFrame.png"];

        self.image = frameImage;
    }
    return self;
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
