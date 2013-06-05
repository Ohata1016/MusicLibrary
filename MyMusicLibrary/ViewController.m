//
//  ViewController.m
//  MyMusicLibrary
//
//  Created by Ohata Takashi on 2013/05/22.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import "ViewController.h"
#import "MusicImage.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    imageTag = 1;
    CGRect frame = CGRectMake(0,0,MAXWIDTH,MAXHEIGHT);
    scroller = [[MyScrollView alloc] initWithFrame:frame];
    
    singleFingerDTap = [[UITapGestureRecognizer alloc]
                        initWithTarget:self  action:@selector(handleSingleTap:)];
    [scroller addGestureRecognizer:singleFingerDTap];

    self.view = scroller;
    
	// Do any additional setup after loading the view, typically from a nib.
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleSingleTap:(UIGestureRecognizer *)sender{
    NSLog(@"singletap gesture called");
    if(sender.state  == UIGestureRecognizerStateEnded){
        //imageTagの更新
        [self updateImageTag];
            
        if([self checkDeleter]){
            for(int i = 1; i < imageTag;i = i+DELETER+1){
                NSLog(@"remove deleter:%@",[[scroller getSubview] viewWithTag:i+DELETER]);
                [[[scroller getSubview] viewWithTag:i+DELETER] removeFromSuperview];
            }
        }else if([self deleteSelectFrame]){
            scroller.delaysContentTouches = YES;
            return;
        }else{
        // initWithMediaTypes の引数は下記を参照に利用したいメディアを設定しましょう。
        MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
        // デリゲートを自分クラスに設定
        picker.delegate = self;
        // 複数のメディアを選択可能に設定
        [picker setAllowsPickingMultipleItems: YES];
        
        // プロンプトに表示する文言を設定
        picker.prompt = NSLocalizedString (@"Add songs to play","Prompt in media item picker");
        
        // ViewController へピッカーを設定
        [self presentViewController:picker animated:YES completion:^{
        }];
        }
    }
}

-(BOOL)checkDeleter{
    for(int i=1;i<imageTag;i=i+DELETER+1){
        if([[scroller getSubview] viewWithTag:i+DELETER] != nil)
            return YES;
    }
    return NO;
}
-(BOOL)deleteSelectFrame{
    BOOL deleted = NO;
    for(int i = 1; i < imageTag;i = i+DELETER+1){
        if([[scroller getSubview] viewWithTag:i+FRAME] != nil){
            [[[scroller getSubview] viewWithTag:i+FRAME] removeFromSuperview];
         //   [[[scroller getSubview] viewWithTag:i+SCALLER] removeFromSuperview];
            deleted = YES;
        }
    }
    return deleted;
}

-(void)updateImageTag{
    if([[scroller getSubview] viewWithTag:1] == nil){
        imageTag = 1;//初期化
        return;
    }
    for(int i = 1;[[scroller getSubview] viewWithTag:i]!=nil;i=i+DELETER+1){
        imageTag = i;
            NSLog(@"%dがつぎのTagかな？",i);
    }
    imageTag = imageTag +DELETER+1;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventTypeMotion &&
        motion == UIEventSubtypeMotionShake ) {
        int i;
        for(i = 1; [scroller viewWithTag:i] != nil;i += (DELETER + 1 )){
            if([scroller viewWithTag:i+PLAYINGFRAME]!= nil){
                break;
            }
        }//playingを特定
        //そのmusicimageの再生アイテムをシャッフルする関数を呼ぶ
        MusicImage *img = (MusicImage *)[scroller viewWithTag:i];
        [img shuffleMusic];
        }
    
}



// デリゲートの設定 Done 押下時に呼ばれます。
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker
   didPickMediaItems: (MPMediaItemCollection *) collection
{
    // 選択されたメディアは 配列で格納されている。
    [self makeImage:mediaPicker didPickMediaItems:collection];
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)makeImage:(MPMediaPickerController *) mediaPicker
didPickMediaItems: (MPMediaItemCollection *) collection
{
    NSLog(@"Done pressed");
    CGRect imageFrame = CGRectMake(0,0,DEFAULTSIZE,DEFAULTSIZE);
    CGRect labelFrame = CGRectMake(0,0,DEFAULTSIZE,DEFAULTSIZE);
    for (MPMediaItem *item in collection.items) {
        // 選択されたメディアの属性を取得してログへ表示する。
/*        NSLog(@"Title is %@", [item valueForProperty:MPMediaItemPropertyTitle]);
        NSLog(@"Artist is %@", [item valueForProperty:MPMediaItemPropertyArtist]);
        NSLog(@"alubum title is %@", [item valueForProperty:MPMediaItemPropertyAlbumTitle]);*/
        int extent = [[item valueForProperty:MPMediaItemPropertyPlayCount] integerValue];
        imageFrame = CGRectMake(imageFrame.origin.x,imageFrame.origin.y,DEFAULTSIZE + +extent/10,DEFAULTSIZE + +extent/10);
        labelFrame = CGRectMake(0,0,DEFAULTSIZE + +extent/10,DEFAULTSIZE + +extent/10);
        
        //ラベルの作成
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        label.text =[item valueForProperty:MPMediaItemPropertyTitle];
        label.backgroundColor = [UIColor clearColor];
        label.tag = imageTag + TEXT;
        label.numberOfLines = 2;
        
        //アートワークからImage作成
        MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];

        NSMutableArray *musicArray = [[NSMutableArray alloc] initWithCapacity:1];
        [musicArray addObject:item];
        
        MusicImage *musicImage = [[MusicImage alloc] initWithImage:[artwork imageWithSize:CGSizeMake(DEFAULTSIZE,DEFAULTSIZE)]];
        musicImage.tag = imageTag;
        //queryの追加
        [musicImage addMusic:musicArray];
        
        if(musicImage.image == nil)
            musicImage.image = [UIImage imageNamed:@"albumDefault.jpg"];

        musicImage.frame = imageFrame;
        
        [musicImage addSubview:label];
        [scroller addMusicImage:musicImage];

        imageTag = imageTag + DELETER + 1;//tag の更新
        
        NSLog(@"add image%@",musicImage);
        imageFrame.origin.x+=5;
        imageFrame.origin.y+=5;//初期設置位置の更新
        if(imageFrame.origin.y>=MAXHEIGHT){
            imageFrame.origin.y = MAXHEIGHT;
            imageFrame.origin.x = MAXHEIGHT;
        }

        
    }
}

- (void)printSubviews:(UIView*)uiView addNSString:(NSString *)str
{
    NSLog(@"%@ %@", str, uiView);
    
    for (UIView* nextView in [uiView subviews])
    {
        [self printSubviews:nextView
                addNSString:[NSString stringWithFormat:@"%@==> ", str]];
    }
}




- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
