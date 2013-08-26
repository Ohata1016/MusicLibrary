//
//  ImageScaller.m
//  MyMusicLibrary
//
//  Created by Ohata Takashi on 2013/05/25.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import "ImageScaller.h"

@implementation ImageScaller
{
    CGPoint touchLocation;
    CGRect superInitRect;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIImage *frameImage = [UIImage imageNamed:@"scaller.gif"];
        self.userInteractionEnabled = YES;
        self.image = frameImage;
    }
    return self;
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    superInitRect = self.frame;
    
}

-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event
{
    //    NSLog(@"image moved");
    CGPoint pt = [[touches anyObject] locationInView:self];
    CGRect frame = [self frame];
    
    CGRect newImageFrame;
    CGRect newLabelFrame;
    CGRect newDeleterFrame;
    if(frame.origin.x+pt.x - touchLocation.x <MAXWIDTH && frame.origin.x+pt.x - touchLocation.x>0)    frame.origin.x += pt.x - touchLocation.x;
    if(frame.origin.y+pt.y - touchLocation.y <MAXHEIGHT && frame.origin.y+pt.y - touchLocation.y>0)     frame.origin.y += pt.y - touchLocation.y;
    
    newImageFrame =  CGRectMake(self.superview.frame.origin.x,self.superview.frame.origin.y,frame.origin.x+frame.size.width ,frame.origin.y +frame.size.height);
    newLabelFrame = CGRectMake(self.superview.bounds.origin.x,self.superview.bounds.origin.y,frame.origin.x+frame.size.width ,frame.origin.y +frame.size.height);
    newDeleterFrame =  CGRectMake(self.superview.bounds.origin.x,self.superview.bounds.origin.y,(frame.origin.x+frame.size.width)/4 ,(frame.origin.y +frame.size.height)/4);
    
    self.superview.frame = newImageFrame;
    [self.superview viewWithTag:self.superview.tag+FRAME].frame = newLabelFrame;
    [self.superview viewWithTag:self.superview.tag+SONGLABEL].frame = newLabelFrame;
    [self.superview viewWithTag:self.superview.tag+PLAYINGFRAME].frame = newLabelFrame;

    [self.superview viewWithTag:self.superview.tag+DELETER].frame = newDeleterFrame;
        
    //   [self checkPosition:frame var:var];
    [self setFrame:frame];
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
