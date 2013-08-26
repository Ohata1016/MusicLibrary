//
//  MyScrollView.m
//  MyMusicLibrary
//
//  Created by Ohata Takashi on 2013/05/22.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import "MyScrollView.h"
#import "AllDeleter.h"


@implementation MyScrollView
{
    SuperView *initView;//大本のview
}

//@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        CGRect scrollFrame =CGRectMake(0,0,MAXWIDTH,MAXHEIGHT);
        
        initView = [[SuperView alloc] initWithFrame:scrollFrame];
        [self addSubview:initView];
        [self setCanCancelContentTouches:NO];
        
        self.backgroundColor = [UIColor whiteColor];
        self.contentSize = CGSizeMake(scrollFrame.size.width,scrollFrame.size.height);
        
        self.maximumZoomScale = 2.5;//zoom maxsize
        self.minimumZoomScale = 0.1;//zoom minsize
                
        self.delaysContentTouches = YES;
        
        self.userInteractionEnabled = YES;
        
        self.CanCancelContentTouches = NO;
        [self addAllDeleter];
        
    }
    return self;
}


-(void)addAllDeleter{
    NSLog(@"add allDeleter");
    CGRect frame = CGRectMake(MAXWIDTH-ALLDELETERSIZE,0,ALLDELETERSIZE,ALLDELETERSIZE);//test 50
    
    AllDeleter *allDeleter = [[AllDeleter alloc] initWithFrame:frame];
    [initView addSubview:allDeleter];
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
    [image serializer];
}

-(SuperView *)getSubview
{
    return initView;
}

-(void)callChangeViewController:(NSMutableArray *)cnt{
    // デリゲート先がちゃんと「sampleMethod1」というメソッドを持っているか?
    if ([self.delegate respondsToSelector:@selector(changeViewController:)]) {
        // sampleMethod1を呼び出す
        [self.delegate changeViewController:cnt];
    }else{
        NSLog(@"error!");
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
