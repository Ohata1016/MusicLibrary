//
//  MusicImage.m
//  MyMusicLibrary
//
//  Created by Ohata Takashi on 2013/05/22.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import "MusicImage.h"
#import "RedFrame.h"
#import "Deleter.h"
#import "ImageScaller.h"
#import "MyScrollView.h"

@implementation MusicImage

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        // Initialization code
        //singletapジェスチャの追加
        singleFingerDTap = [[UITapGestureRecognizer alloc]
                            initWithTarget:self  action:@selector(handleSingleTap:)];

        [self addGestureRecognizer:singleFingerDTap];
        
        //        musicArrayの初期化
        musicArray = [[NSMutableArray alloc] initWithCapacity:1];
        
        //ロングタップジェスチャの追加
        longPressGesture =
        [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPres:)];
        // 長押しが認識される時間を設定
        longPressGesture.minimumPressDuration = 1.0;
        // ビューにジェスチャーを追加
        [self addGestureRecognizer:longPressGesture];
        
        //doubletouchジェスチャの追加
        doubleTapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        // ダブルタップ
        doubleTapGesture.numberOfTapsRequired = 2;
        // ビューにジェスチャーを追加
        [self addGestureRecognizer:doubleTapGesture];
        
        //ピンチジェスチャ-のインスタンス作成
        pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
        //ピンチジェスチャの追加
        [self addGestureRecognizer:pinchGesture];
        
        self.userInteractionEnabled = YES;
        
        //ビューにトリプルタップジェスチャの追加
        tripleTapGesture=
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTripleTap:)];
        // トリプルタップ
        tripleTapGesture.numberOfTapsRequired = 3; 
        [self addGestureRecognizer:tripleTapGesture];

        //右スワイプ
        rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeAction:)];
        rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
        rightSwipeGesture.delaysTouchesBegan=YES;
        //左スワイプ
        leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeAction:)];
        leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        leftSwipeGesture.delaysTouchesBegan=YES;
        
/*        //上スワイプ
        upSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upSwipeAction:)];
        upSwipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:upSwipeGesture];
        //下スワイプ
        downSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(downSwipeAction:)];
        downSwipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
        [self addGestureRecognizer:downSwipeGesture];*/
        
        //panGesture
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self addGestureRecognizer:panGesture];
        
        [self becomeFirstResponder];
        
        [singleFingerDTap requireGestureRecognizerToFail:doubleTapGesture];
        [singleFingerDTap requireGestureRecognizerToFail:tripleTapGesture];
        [doubleTapGesture requireGestureRecognizerToFail:tripleTapGesture];
        [panGesture requireGestureRecognizerToFail:rightSwipeGesture];
        [panGesture requireGestureRecognizerToFail:leftSwipeGesture];
        
        _player = [MPMusicPlayerController applicationMusicPlayer];
        _player.repeatMode = MPMusicRepeatModeOne;
        _player = [MPMusicPlayerController iPodMusicPlayer];
        playing = false;
        
        [_player beginGeneratingPlaybackNotifications];
    }
    return self;
}

-(void)changeImage{//曲が変わったら実行される　各MusicImageに対して送られるのはスマートじゃないかなぁ
    if([self.superview viewWithTag:self.tag + PLAYINGFRAME]!=nil && [musicArray count] >1){
            NSLog(@" not nil album artwork");
            self.image = [[_player.nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:CGSizeMake(self.frame.size.width,self.frame.size.height)];
        if(self.image == nil) {
            NSLog(@" nil album artwork");
            self.image = [UIImage imageNamed:@"albumDefault.jpg"];
        }
        [self deletePlayingItemLabel];
        [self addPlayingItemLabel];
    }
}

-(void)panAction:(UIPanGestureRecognizer *)sender{
    if(sender.state == UIGestureRecognizerStateBegan){
        [[self superview] bringSubviewToFront:self];
    }
    if(sender.state == UIGestureRecognizerStateChanged){
        // imageの位置を更新する
        //imageの位置更新
        CGPoint location = [sender translationInView:self];
        CGPoint movePoint = CGPointMake(self.center.x+location.x,self.center.y+location.y);
        //        NSLog(@"locationx:%f location:%f",location.x,location.y);
        movePoint = [self checkPoint:movePoint];
        
        self.center = movePoint;
        [sender setTranslation:CGPointZero inView:self];
    }
    if(sender.state == UIGestureRecognizerStateEnded){
        //imageが他のイメージと重なっていたら、アルバムを作成する
   //     NSLog(@"pan Ended");
        if([self checkContainsImage]){
            MusicImage *img = (MusicImage *)[self.superview viewWithTag:[self checkContainsImage]];
            if([[img getMusicArray] count] == 1){//重なってるイメージが単曲リストだった場合、アルバムを作成する
                //alertview表示
                //　｜テキスト入力｜
                //  |cancel| |OK|
                //if MusicImage then
                [self displayAlertview];
            }else{//対象がアルバムなので、アルバムに自身を追加する
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"アルバムに曲を追加します"
                                                                    message:@" "
                                                                   delegate:self
                                                          cancelButtonTitle:@"cancel"
                                                          otherButtonTitles:@"OK", nil];
                // アラート表示
                [alertView show];
            }
        }
    }
}

-(CGPoint)checkPoint:(CGPoint)movePoint{
    if(movePoint.x+self.frame.size.width/2>MAXWIDTH)
        movePoint.x = MAXWIDTH - self.frame.size.width/2;
    if(movePoint.x-self.frame.size.width/2<0)
        movePoint.x = self.frame.size.width/2;
    if(movePoint.y+self.frame.size.height/2>MAXHEIGHT)
        movePoint.y = MAXHEIGHT - self.frame.size.height/2;
    if(movePoint.y-self.frame.size.height/2<0)
        movePoint.y = self.frame.size.height/2;
    return movePoint;
}

-(void)rightSwipeAction:(UISwipeGestureRecognizer *)sender{
    if([self.superview viewWithTag:self.tag+PLAYINGFRAME] !=nil ){
        [_player skipToNextItem];
     //   self.image = [[_player.nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:CGSizeMake(self.frame.size.width,self.frame.size.height)];
    }
}
-(void)leftSwipeAction:(UISwipeGestureRecognizer *)sender{
    if([self.superview viewWithTag:self.tag+PLAYINGFRAME] !=nil){
        [_player skipToPreviousItem];
      //  self.image = [[_player.nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:CGSizeMake(self.frame.size.width,self.frame.size.height)];
    }
}

-(void)deletePlayingItemLabel{
    [[self.superview viewWithTag:self.tag+NOWPLAYINGITEM] removeFromSuperview];
}

-(void)addPlayingItemLabel{
    CGRect labelFrame = CGRectMake(self.bounds.origin.x,self.bounds.origin.y,self.frame.size.width,self.frame.size.height);
    UILabel *label =[[UILabel alloc] initWithFrame:labelFrame];
    label.text = [[_player nowPlayingItem] valueForProperty:MPMediaItemPropertyTitle];
    label.backgroundColor = [UIColor clearColor];
    label.tag= self.tag+NOWPLAYINGITEM;
    [self addSubview:label];
}

/*
-(void)upSwipeAction:(UISwipeGestureRecognizer *)sender{
    NSLog(@"up swipe gesture called");
}
-(void)downSwipeAction:(UISwipeGestureRecognizer
 
 *)sender{
    NSLog(@"down swipe gesture called");
}*/

-(void)pinchAction:(UIPinchGestureRecognizer *)sender{
    // ピンチジェスチャー発生時に、Imageの現在のアフィン変形の状態を保存する
    NSLog(@"image pinch gesture called");
    if (sender.state == UIGestureRecognizerStateBegan) {
        currentTrans = self.transform;
        // currentTransFormは、フィールド変数。imgViewは画像を表示するUIImageView型のフィールド変数。
    }
	
    // ピンチジェスチャー発生時から、どれだけ拡大率が変化したかを取得する
    // 2本の指の距離が離れた場合には、1以上の値、近づいた場合には、1以下の値が取得できる
    CGFloat scale = [sender scale];
    
    // ピンチジェスチャー開始時からの拡大率の変化を、imgViewのアフィン変形の状態に設定する事で、拡大する。
    self.transform = CGAffineTransformConcat(currentTrans, CGAffineTransformMakeScale(scale, scale));
}

-(void)handleSingleTap:(UIGestureRecognizer *)sender{
    if(sender.state  == UIGestureRecognizerStateEnded && [self viewWithTag:self.tag + FRAME] == nil){
        [self addRedFrame];
    }
}

- (void) handleLongPres:(UILongPressGestureRecognizer *)sender
{
    if([sender state] == UIGestureRecognizerStateBegan ){
        NSLog(@"imageView longtap called");
        [self addMusicImageDeleter];
        NSLog(@"superview%@",self.superview);
    }
}

-(void)addMusicImageDeleter{
    //addsubview
    for(int i = 1; [self.superview viewWithTag:i]!=nil ;i = i+DELETER+1){
        UIView *view = [self.superview viewWithTag:i];
        CGRect deleterFrame = CGRectMake(view.bounds.origin.x,view.bounds.origin.y,view.bounds.size.width/4,view.bounds.size.height/4);
        view = [self.superview viewWithTag:i];
        Deleter *deleter = [[Deleter alloc] initWithFrame:deleterFrame];

        deleter.tag = i+DELETER;
            NSLog(@"add deleter at %@",[self.superview viewWithTag:i]);
            [view addSubview:deleter];
    }
}

-(void)addRedFrame{
    //タップした際にイメージを赤く囲むレッドフレームを追加する
    for(int i = 1; [self.superview viewWithTag:i] != nil;i += (DELETER + 1 )){//他のredframeを削除
        [[self.superview viewWithTag:i+FRAME] removeFromSuperview];
    }
    RedFrame *redFrame = [[RedFrame alloc] initWithFrame:self.bounds];
    redFrame.tag = self.tag+FRAME;
    
    if([self.superview viewWithTag:self.tag+PLAYINGFRAME]==nil)//
        [self addSubview:redFrame];
}

-(void)addPlayingFrame{
    int i;
    for(i = 1; [self.superview viewWithTag:i] != nil;i += (DELETER + 1 )){
        if([self.superview viewWithTag:i+PLAYINGFRAME]!= nil){
            [[self.superview viewWithTag:i+PLAYINGFRAME] removeFromSuperview];
            break;
        }
    }//全てのビューからPlayingFrameを取り除く
    NSLog(@"tag:%d image gesture remove",i);
    NSLog(@"remove gesture from :%@",[self.superview viewWithTag:i]);
    MusicImage *img = (MusicImage *)[self.superview viewWithTag:i];
    
    [(MusicImage *)[self.superview viewWithTag:i] removeGestureRecognizer:[img getRightSwipeRecognizer]];
    [(MusicImage *)[self.superview viewWithTag:i] removeGestureRecognizer:[img getLeftSwipeRecognizer]];
    
    [self addGestureRecognizer:rightSwipeGesture];
    [self addGestureRecognizer:leftSwipeGesture];
    
    notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(changeImage) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:_player];//通知の対象に自分を追加
    
    RedFrame *redFrame = [[RedFrame alloc] initWithFrame:self.bounds];
    redFrame.tag = self.tag+PLAYINGFRAME;
    if([self.superview viewWithTag:self.tag+PLAYINGFRAME] == nil)
        [self addSubview:redFrame];
    
}

-(void)handleDoubleTap:(UIGestureRecognizer *)sender{
    NSLog(@"imageView doubletap gesture called");
    NSLog(@"array num:%d",[musicArray count]);
    
    if([musicArray count] == 1){
        _player.repeatMode = MPMusicRepeatModeOne;
    }else{
        _player.repeatMode = MPMusicRepeatModeAll;
    }
//        [_player nowPlayingItem];
    //自分の曲を再生中か
    //再生してない
    //player に自分の曲をセット
        //再生
    //再生してる
        //ポーズ
    
    if([self checkPlayingItem]){//プレイヤーの再生アイテムが自分の持ってるアイテムと一緒だった場合
        if([_player playbackState] ==  MPMusicPlaybackStatePlaying){//再生中なら
            [_player pause];//再生を一時停止する
        }else{
            [self addPlayingFrame];
            [_player play];
        }
    }else{//プレイヤの再生しているアイテムと、自分のアイテムが異なっていた場合
        [self addPlayingFrame];
        [_player setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:musicArray]];
        [_player play];
    }
    /*
    if(playing == YES){//playerが再生中の時
        [_player pause];
        playing = NO;//[_player playbackState] == MPMusicPlaybackStatePlaying
    }    else{//自分が再生していないとき
        NSLog(@"play music@");
        [self addPlayingFrame];
        [_player setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:musicArray]];
        NSLog(@"musicArray:%@",musicArray);
        [_player play];

        playing = YES;
    }*/
}

-(void)handleTripleTap:(UIGestureRecognizer *)sender{
    //for debug
    if(sender.state  == UIGestureRecognizerStateEnded){
        [_player skipToNextItem];
        [_player play];
    }
}

/*- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    //指が触れた時時1度呼ばれる
    NSLog(@"image touched");
//    [self addRedFrame];
    touchLocation = [[touches anyObject] locationInView:self];
    [[self superview] bringSubviewToFront:self];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event//タッチでmusicimageを動かしている間呼ばれる
{
    // imageの位置を更新する
    
    CGPoint pt = [[touches anyObject] locationInView:self];
    CGRect frame = [self frame];
    //imageの位置更新
    if(frame.origin.x+pt.x - touchLocation.x <MAXWIDTH-self.frame.size.width && frame.origin.x+pt.x - touchLocation.x>0)    frame.origin.x += pt.x - touchLocation.x;
    if(frame.origin.y+pt.y - touchLocation.y <MAXHEIGHT-self.frame.size.height && frame.origin.y+pt.y - touchLocation.y>0)     frame.origin.y += pt.y - touchLocation.y;

 //   [self checkPosition:frame var:var];
    [self setFrame:frame];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event//タッチが終了したら呼ばれる
{
    //imageが他のイメージと重なっていたら、アルバムを作成する
    NSLog(@"touches Ended");

    if([self checkContainsImage]){
        MusicImage *img = (MusicImage *)[self.superview viewWithTag:[self checkContainsImage]];
        if([[img getMusicArray] count] == 1){//重なってるイメージが単曲リストだった場合、アルバムを作成する
            //alertview表示
            //　｜テキスト入力｜
            //  |cancel| |OK|
            //if MusicImage then
            [self displayAlertview];
        }else{//対象がアルバムなので、アルバムに自身を追加する
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"アルバムに曲を追加します"
                                                                message:@" "
                                                               delegate:self
                                                      cancelButtonTitle:@"cancel"
                                                      otherButtonTitles:@"OK", nil];
            // アラート表示
            [alertView show];
        }
    }
}
*/
-(void)displayAlertview{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"アルバムを作成します"
                                                        message:@" "
                                                    delegate:self
                                              cancelButtonTitle:@"cancel"
                                              otherButtonTitles:@"OK", nil];
    // UITextFieldの生成
    textField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
   // textField.textAlignment = UITextAlignmentLeft;
    textField.font = [UIFont fontWithName:@"Arial-BoldMT" size:18];
    textField.textColor = [UIColor grayColor];
    textField.minimumFontSize = 8;
    textField.adjustsFontSizeToFitWidth = YES;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [textField setDelegate:self];
    // アラートビューにテキストフィールドを埋め込む
    [alertView addSubview:textField];

    // アラート表示
    [alertView show];
    
    // テキストフィールドをファーストレスポンダに
    [textField becomeFirstResponder];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // OKが選択された場合
    if (buttonIndex == 1) {
        // テキストフィールドに一文字以上入力されていれば
        if ([textField.text length]){
            //下のビューのラベルを書き換える
            MusicImage *img = (MusicImage *)[self.superview viewWithTag:[self checkContainsImage]];
            UILabel *label = (UILabel *)[img.superview viewWithTag:img.tag + TEXT];
            label.text = textField.text;
        }
        [self makeAlbum];
    }
}

-(void)changeLabel{

    [[self.superview viewWithTag:self.tag+TEXT] removeFromSuperview];//ラベル削除
    MusicImage *img = (MusicImage *)[self.superview viewWithTag:[self checkContainsImage]];//下のビューの取得
    CGRect frame = CGRectMake(img.bounds.origin.x,img.bounds.origin.y,img.frame.size.width/2,img.frame.size.height/2);
    UILabel *preLabel = (UILabel *)[img.superview viewWithTag:img.tag + TEXT];//下のビューのラベル獲得
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = preLabel.text;
    label.backgroundColor = [UIColor clearColor];
    
    label.tag = self.tag + TEXT;
    [self addSubview:label];
}

-(void)makeAlbum{
    //albumのlabel設定
    //曲をmusiclistに追加
    //曲を削除
    //タグとかの更新も
    //ラベルの作成
    
    MusicImage *img = (MusicImage*)[self.superview viewWithTag:[self checkContainsImage]];
    //copy album
    
    [self changeLabel];//ラベルの変更　下のイメージのラベルを自分のとこに持ってくる
    [self copyMusicImage:img];//imageの変更　下のイメージを自分のと入れ替える
    [self frameCopy];//フレームを自分に付け替える　下のイメージが
    //imageの削除
    [img deleteView];
    
}

-(void)frameCopy{
    MusicImage *img = (MusicImage*)[self.superview viewWithTag:[self checkContainsImage]];
    if([img.superview viewWithTag:img.tag+PLAYINGFRAME]!=nil|| [self.superview viewWithTag:self.tag+PLAYINGFRAME]!=nil){
        [self addPlayingFrame];
        [_player setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:musicArray]];//player 更新
    }
    if([img.superview viewWithTag:img.tag+FRAME]!=nil||[self.superview viewWithTag:self.tag+FRAME]!=nil){
        [self addRedFrame];
    }
}

-(void)copyMusicImage:(MusicImage *)img{
    //下のビューのイメージ、フレーム、musicArrayをコピーする
    MPMediaItem *item;
    self.frame =img.frame;
    self.image = img.image;
    self.bounds = img.bounds;
    for(int i =0; i != [musicArray count];i++){
        item = (MPMediaItem *)[musicArray objectAtIndex:i];
        [img.getMusicArray addObject:item];
    }
    musicArray = [img getMusicArray];
}

-(NSMutableArray *)getMusicArray{
    return musicArray;
}

-(int)checkContainsImage{//viewを移動し終えた時に重なっている一番最初のiamgeのTagを返す
    for(int i = 1;[self.superview viewWithTag:i] != nil;i = i + DELETER +1){
        if(CGRectContainsPoint([self.superview viewWithTag:i].frame,self.center) && i!=self.tag){
           return i;
        }
    }
    return 0;
}

-(BOOL)checkPlayingItem{//return value YES if self contain playing item if not , return NO;
    for(int i=0;i<[musicArray count];i++){
        if([_player nowPlayingItem] == [musicArray objectAtIndex:i])
            return YES;
    }
    return NO;
}

-(void)addMusic:(NSMutableArray *)music
{
    musicArray = music;
}

-(void)deleteView{
    [self updateImageTag];//tagの更新
    NSLog(@"delete view:%@",self);
    [notificationCenter removeObserver:self];
    [self removeFromSuperview];//imageの削除
}

-(void)updateImageTag
{
    NSLog(@"updateImage");
    for(int i = self.tag+DELETER+1;[self.superview viewWithTag:i] != nil;i= i+DELETER+1){
        NSLog(@"update ImageTag:%@",[self.superview viewWithTag:i]);
        [self.superview viewWithTag:i].tag -=(DELETER+1);
        [self.superview viewWithTag:i+FRAME].tag -=(DELETER+1);
        [self.superview viewWithTag:i+SCALLER].tag -=(DELETER+1);
        [self.superview viewWithTag:i+TEXT].tag -=(DELETER+1);
        [self.superview viewWithTag:i+PLAYINGFRAME].tag -=(DELETER+1);
        [self.superview viewWithTag:i+DELETER].tag -=(DELETER+1);
        NSLog(@"updated ImageTag:%@",[self.superview viewWithTag:i-DELETER-1]);
    }
}
-(void)shuffleMusic{
        int i = random()%([musicArray count]);
        _player.nowPlayingItem = [musicArray objectAtIndex:i];
        [_player play];
}


-(UISwipeGestureRecognizer *)getRightSwipeRecognizer{
    return rightSwipeGesture;
}
-(UISwipeGestureRecognizer *)getLeftSwipeRecognizer{
    return leftSwipeGesture;
}

@end
