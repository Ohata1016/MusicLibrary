//
//  MyScrollView.m
//  MyMusicLibrary
//
//  Created by Ohata Takashi on 2013/05/22.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import "MyScrollView.h"


@implementation MyScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"scrollview make");
       
        CGRect scrollFrame =CGRectMake(0,0,MAXWIDTH,MAXHEIGHT);
        initView = [[UIView alloc] initWithFrame:scrollFrame];
        
        [self setCanCancelContentTouches:NO];

        [self addSubview:initView];

        self.backgroundColor = [UIColor whiteColor];
        self.contentSize = CGSizeMake(scrollFrame.size.width,scrollFrame.size.height);
        self.delegate = self;
                
        self.maximumZoomScale = 2.5;//zoom maxsize
        self.minimumZoomScale = 0.1;//zoom minsize
        
        self.delaysContentTouches = YES;
        
        self.userInteractionEnabled = YES;
        
    }
    return self;
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    NSLog(@"zoom");
    return initView;
}
- (void)printSubviews:(UIView*)uiView addNSString:(NSString *)str
{
    //親ビューすべて表示
    NSLog(@"%@ %@", str, uiView);
    for (UIView* nextView in [uiView subviews])
    {
        [self printSubviews:nextView
                addNSString:[NSString stringWithFormat:@"%@==> ", str]];
    }
}

-(void)addMusicImage:(MusicImage*)image
{
    NSLog(@"add subview");
    [initView addSubview:image];
}

-(UIView *)getSubview
{
    return initView;
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
