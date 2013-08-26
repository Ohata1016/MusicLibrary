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
#import "ViewController.h"
#import "AppDelegate.h"

@implementation MusicImage
{
    UITapGestureRecognizer *singleFingerTap;
    UITapGestureRecognizer *doubleFingerTap;
    UILongPressGestureRecognizer *longPressGesture;
    UIPinchGestureRecognizer *pinchGesture;
    UITapGestureRecognizer *singleFingerDoubleTap;
    UITapGestureRecognizer *tripleTapGesture;
    UISwipeGestureRecognizer *rightSwipeGesture;
    UISwipeGestureRecognizer *leftSwipeGesture;
    UISwipeGestureRecognizer *upSwipeGesture;
    UISwipeGestureRecognizer *downSwipeGesture;
    UIPanGestureRecognizer *panGesture;
    
    CGAffineTransform currentTrans;
    CGRect beforeFrame;
    CGRect beforeBounds;
    CGRect afterFrame;
    CGRect afterBounds;
    
    NSMutableArray *musicArray;
    NSMutableArray *nowPlayingItem;
    
    UITextField *textField;
    MusicSaveData *saveData;
    
    ViewController *albumController;
    
}

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        //        musicArrayの初期化
        musicArray = [[NSMutableArray alloc] initWithCapacity:1];
        
        [self becomeFirstResponder];
        
        [self addSingleFingerDoubleTapGesture];
        [self addSingleFingerTapGesture];
        [self addLeftSwipeGesture];
        [self addRightSwipeGesture];
        [self addPanGesture];
        [self addPinchGesture];
        [self addLongTapGesture];
        
/*        //上スワイプ
        upSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upSwipeAction:)];
        upSwipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:upSwipeGesture];
        //下スワイプ
        downSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(downSwipeAction:)];
        downSwipeGesture.diognizer:downSwipeGesture];*/
        //panGesture
        
        //saveata
        saveData = [[MusicSaveData alloc] init];
        
        [self serializer];
    }
    return self;
}



-(void)addSingleFingerTapGesture{
    singleFingerTap = [[UITapGestureRecognizer alloc]
                       initWithTarget:self  action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:singleFingerTap];
    [singleFingerTap requireGestureRecognizerToFail:singleFingerDoubleTap];//ダブルタップが呼ばれないことを確認する
}

-(void)addSingleFingerDoubleTapGesture{
    singleFingerDoubleTap = [[UITapGestureRecognizer alloc]
                             initWithTarget:self  action:@selector(handleSingleDoubleTap:)];
    singleFingerDoubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:singleFingerDoubleTap];
}


-(void)addRightSwipeGesture{
    rightSwipeGesture = [[UISwipeGestureRecognizer alloc]
                         initWithTarget:self action:@selector(rightSwipeAction:)];
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwipeGesture.delaysTouchesBegan=YES;
    [self addGestureRecognizer:rightSwipeGesture];
}

-(void)addLeftSwipeGesture{
    leftSwipeGesture = [[UISwipeGestureRecognizer alloc]
                        initWithTarget:self action:@selector(leftSwipeAction:)];
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipeGesture.delaysTouchesBegan=YES;
    [self addGestureRecognizer:leftSwipeGesture];
    
}

-(void)addLongTapGesture{
    //ロングタップジェスチャの追加
    longPressGesture =
    [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPres:)];
    // 長押しが認識される時間を設定
    longPressGesture.minimumPressDuration = 1.0;
    // ビューにジェスチャーを追加
    [self addGestureRecognizer:longPressGesture];
}

-(void)addPinchGesture{
    //ピンチジェスチャ-のインスタンス作成
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    //ピンチジェスチャの追加
    [self addGestureRecognizer:pinchGesture];
}

-(void)addPanGesture{
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:panGesture];
    [panGesture requireGestureRecognizerToFail:rightSwipeGesture];
    [panGesture requireGestureRecognizerToFail:leftSwipeGesture];
}

-(void)updataSaveData{
    saveData.musicArray = musicArray;
    saveData.bounds = CGRectMake(self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
    saveData.albumName = _albumName;
    
    NSLog(@"updata savedata:%@",saveData);
    NSLog(@"updata labeldata:%@",saveData.albumName);
   // NSLog(@"save bounds:%f:%f;%f:%f",saveData.bounds.origin.x,saveData.bounds.origin.y,saveData.bounds.size.width,saveData.bounds.size.height);
  //  NSLog(@"saved musicArray:%@",saveData.musicArray);
   // NSLog(@"self musicArray:%@",musicArray);
}

-(void)changeImage{//曲が変わったら実行される 親から呼び出される
    if([self.superview viewWithTag:self.tag + PLAYINGFRAME]!=nil && [musicArray count] >1){
            NSLog(@" not nil album artwork");
            self.image = [[[self getSuperview].player.nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:CGSizeMake(self.frame.size.width,self.frame.size.height)];
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
        [self dropShadow];
        [[self getSuperview] playPanActionSound];
    }
    if(sender.state == UIGestureRecognizerStateChanged){
        // imageの位置を更新する
        //imageの位置更新
        CGPoint location = [sender translationInView:self];
        CGPoint movePoint = CGPointMake(self.center.x+location.x,self.center.y+location.y);
        
        NSLog(@"locationx:%f location:%f",location.x,location.y);
        movePoint = [self checkPoint:movePoint];
        
        self.center = movePoint;
        [sender setTranslation:CGPointZero inView:self];
    }
    if(sender.state == UIGestureRecognizerStateEnded){//pangestureが終了した時
        //imageが他のイメージと重なっていたら、アルバムを作成する
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
        [[self getSuperview] playPanActionSound];
        [self serializer];
        self.layer.shadowOpacity = 0.0f;
    }
}

-(void)dropShadow{
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.7f;
    self.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.layer.shadowRadius = 5.0f;
    self.layer.masksToBounds = NO;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    self.layer.shadowPath = path.CGPath;
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
        [[self getSuperview].player skipToNextItem];
     //   self.image = [[[self getSuperview].player.nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:CGSizeMake(self.frame.size.width,self.frame.size.height)];
                [self serializer];
    }
}
-(void)leftSwipeAction:(UISwipeGestureRecognizer *)sender{
    if([self.superview viewWithTag:self.tag+PLAYINGFRAME] !=nil){
        [[self getSuperview].player skipToPreviousItem];
      //  self.image = [[[self getSuperview].player.nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:CGSizeMake(self.frame.size.width,self.frame.size.height)];
                [self serializer];
    }
}

-(void)deletePlayingItemLabel{
    [[self.superview viewWithTag:self.tag+SONGLABEL] removeFromSuperview];
}

-(void)addPlayingItemLabel{
    CGRect labelFrame = CGRectMake(self.bounds.origin.x,self.bounds.origin.y+self.frame.size.height/2,self.frame.size.width,self.frame.size.height/2);
    UILabel *label =[[UILabel alloc] initWithFrame:labelFrame];
    label.text = [[[self getSuperview].player nowPlayingItem] valueForProperty:MPMediaItemPropertyTitle];
    label.backgroundColor = [UIColor clearColor];
    label.tag= self.tag+SONGLABEL;
    label.numberOfLines = 2;
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

- (void)printSubviews:(UIView*)uiView addNSString:(NSString *)str//デバッグ用　親ビューをすべて表示
{
    //親ビューすべて表示
    NSLog(@"%@ %@", str, uiView);
    for (UIView* nextView in [uiView subviews])
    {
        [self printSubviews:nextView
                addNSString:[NSString stringWithFormat:@"%@==> ", str]];
    }
}

-(void)pinchAction:(UIPinchGestureRecognizer *)sender{
    // ピンチジェスチャー発生時に、Imageの現在のアフィン変形の状態を保存する
    NSLog(@"image pinch gesture called");
    if (sender.state == UIGestureRecognizerStateBegan) {
        beforeFrame = self.frame;
        beforeBounds = self.bounds;
        // currentTransFormは、フィールド変数。imgViewは画像を表示するUIImageView型のフィールド変数。
    }
    if(sender.state == UIGestureRecognizerStateChanged){
    // ピンチジェスチャー発生時から、どれだけ拡大率が変化したかを取得する
    // 2本の指の距離が離れた場合には、1以上の値、近づいた場合には、1以下の値が取得できる
        CGFloat scale = [sender scale];
    
    // ピンチジェスチャー開始時からの拡大率の変化を、imgViewのアフィン変形の状態に設定する事で、拡大する。
  //      self.transform = CGAffineTransformConcat(currentTrans, CGAffineTransformMakeScale(scale, scale));
        self.frame = CGRectMake(beforeFrame.origin.x,beforeFrame.origin.y,beforeFrame.size.width*scale,beforeFrame.size.height*scale);
        
        [[self superview] viewWithTag:self.tag+SONGLABEL].frame = CGRectMake(0,0,beforeFrame.size.width*scale + 20,beforeFrame.size.height*scale);
        [[self superview] viewWithTag:self.tag+PLAYINGFRAME].frame = self.bounds;
        [[self superview] viewWithTag:self.tag+FRAME].frame = self.bounds;
        [[self superview] viewWithTag:self.tag+ALBUMLABEL].frame = CGRectMake(0,20 - self.frame.size.height/2,beforeFrame.size.width*scale,beforeFrame.size.height*scale);
    }
    if(sender.state == UIGestureRecognizerStateEnded){
        [self printFrame];
//    self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,self.frame.size.width*scale,self.frame.size.height*scale);
    [self serializer];
    }
}

-(void)handleSingleTap:(UIGestureRecognizer *)sender{
    
    [[self getSuperview] playSelectSound];;
    if(sender.state  == UIGestureRecognizerStateEnded && [self viewWithTag:self.tag + FRAME] == nil){
        if([musicArray count] == 1)
            [self addRedFrame];
        else{

            [[self getMyScrollView] callChangeViewController:(NSMutableArray *)albumController];
        }
    
    }
    NSLog(@"tapped musicImage:%@",self);
}
//error
-(void)makeAlbumController{
    albumController = [[ViewController alloc] init];//controllerの作成
    albumController.albumMusicArray = musicArray;
    //albumController.scroller = [[MyScrollView alloc] initWithFrame:CGRectMake(0,0,MAXWIDTH,MAXHEIGHT)];
    //albumController.view  = albumController.scroller;

    NSLog(@"album view Controller scroller: %@",albumController.scroller);
    
}

- (void)handleLongPres:(UILongPressGestureRecognizer *)sender
{
    if([sender state] == UIGestureRecognizerStateBegan ){
        NSLog(@"imageView longtap called");
        [self addMusicImageDeleter];
        NSLog(@"superview%@",self.superview);
    }
}

-(void)addMusicImageDeleter{
    //addsubview
    for(int i = STARTMUSICTAGNUMBER;[self.superview viewWithTag:i]!=nil;i = i+DELETER+1){
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
    SuperView *view = [self getSuperview];
    
    if ([view getHaveRedFrame]!=0) {
    [[self.superview viewWithTag:[view getHaveRedFrame]] removeFromSuperview];
    }
    
    RedFrame *redFrame = [[RedFrame alloc] initWithFrame:self.bounds];
    redFrame.tag = self.tag+FRAME;
    
    if([self.superview viewWithTag:self.tag+PLAYINGFRAME]==nil){
        [self addSubview:redFrame];
        [view updateHaveRedFrame:self.tag+FRAME];
    }//
}


-(void)addPlayingFrame{
        SuperView *view = [self getSuperview];
        if([view getHavePlayingFrame]!=0){
            [[view viewWithTag:[view getHavePlayingFrame]] removeFromSuperview];
        }
        
        MusicImage *img = (MusicImage *)[self.superview viewWithTag:[view getHavePlayingFrame]-PLAYINGFRAME];
        
        [(MusicImage *)[self.superview viewWithTag:[view getHavePlayingFrame]-PLAYINGFRAME] removeGestureRecognizer:[img getRightSwipeRecognizer]];
        [(MusicImage *)[self.superview viewWithTag:[view getHavePlayingFrame]-PLAYINGFRAME] removeGestureRecognizer:[img getLeftSwipeRecognizer]];
        
        [self addGestureRecognizer:rightSwipeGesture];
        [self addGestureRecognizer:leftSwipeGesture];

        [self pringBounds];
        RedFrame *redFrame = [[RedFrame alloc] initWithFrame:self.bounds];
        redFrame.tag = self.tag+PLAYINGFRAME;
        [view updateHavePlayingFrame:redFrame.tag];
        [self addSubview:redFrame];
}

-(void)addPlayingFrame:(CGRect)preFrame{
        SuperView *view = [self getSuperview];
        if([view getHavePlayingFrame]!=0){
            [[view viewWithTag:[view getHavePlayingFrame]] removeFromSuperview];
        }
        
        MusicImage *img = (MusicImage *)[self.superview viewWithTag:[view getHavePlayingFrame]-PLAYINGFRAME];
        
        [(MusicImage *)[self.superview viewWithTag:[view getHavePlayingFrame]-PLAYINGFRAME] removeGestureRecognizer:[img getRightSwipeRecognizer]];
        [(MusicImage *)[self.superview viewWithTag:[view getHavePlayingFrame]-PLAYINGFRAME] removeGestureRecognizer:[img getLeftSwipeRecognizer]];
        
        [self addGestureRecognizer:rightSwipeGesture];
        [self addGestureRecognizer:leftSwipeGesture];
        
        RedFrame *redFrame = [[RedFrame alloc] initWithFrame:preFrame];
        redFrame.tag = self.tag+PLAYINGFRAME;
        [view updateHavePlayingFrame:redFrame.tag];
        [self addSubview:redFrame];
}

-(void)handleSingleDoubleTap:(UIGestureRecognizer *)sender{
    NSLog(@"imageView doubletap gesture called");
    NSLog(@"array num:%d",[musicArray count]);
    
    if([musicArray count] == 1){//単曲のイメージの場合は連続再生
        [self getSuperview].player.repeatMode = MPMusicRepeatModeOne;
    }else{//アルバムの場合はアルバムリストのすべての曲を無限再生
        [self getSuperview].player.repeatMode = MPMusicRepeatModeAll;
    }
    
    if([self checkPlayingItem]){//プレイヤーの再生アイテムが自分の持ってるアイテムと一緒だった場合
        if([[self getSuperview].player playbackState] ==  MPMusicPlaybackStatePlaying){//再生中なら
        [[self getSuperview].player pause];//再生を一時停止する
        }else{
            [self addPlayingFrame];
            [[self getSuperview].player play];
        }
    }else{//プレイヤの再生しているアイテムと、自分のアイテムが異なっていた場合
        [self addPlayingFrame];
        [[self getSuperview].player setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:musicArray]];
        [[self getSuperview].player play];
    }
}

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
            MusicImage *img = (MusicImage *)[self.superview viewWithTag:[self checkContainsImage]];
        if ([textField.text length]){//アルバム作成時の処理
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x,self.bounds.origin.y,self.frame.size.width,self.frame.size.height/2)];
            
            label.text = textField.text;
            label.backgroundColor = [UIColor clearColor];
            label.numberOfLines = 2;
            label.tag = self.tag + ALBUMLABEL;
            label.contentMode = UIViewContentModeScaleToFill;
            
            _albumName = label.text;
            NSLog(@"albumlabel:%@",label);
            [self addSubview:label];
        }else{//アルバムに
            //albumLabelの張替え　下のビューのアルバムラベルと張替え
            UILabel *label = (UILabel *)[img.superview viewWithTag:img.tag + ALBUMLABEL];
            UILabel *albumLabel = (UILabel *)[[self superview] viewWithTag:self.tag+ALBUMLABEL];
            NSLog(@"albumlabel:%@",label);
            NSLog(@"self albumlabel:%@",(UILabel *)[[self superview] viewWithTag:self.tag+ALBUMLABEL]);
            if(albumLabel == nil){
                label.tag = self.tag +ALBUMLABEL;
                [self addSubview:label];
                _albumName = label.text;
            }else{
                albumLabel.text = label.text;
                _albumName = albumLabel.text;
            }
        }
        textField.text = nil;//textFieldに値が入ったままになってしまうので、初期化
        [self makeAlbum];
        [self serializer];
    }
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
    [self frameCopy:img];//フレームを自分に付け替える　下のイメージが
    [self makeAlbumController];
    //imageの削除
    [img deleteView];
    
}


-(void)changeLabel{
    [[self.superview viewWithTag:self.tag+SONGLABEL] removeFromSuperview];//ラベル削除
    MusicImage *img = (MusicImage *)[self.superview viewWithTag:[self checkContainsImage]];//下のビューの取得
    CGRect frame = CGRectMake(img.bounds.origin.x,img.bounds.origin.y+img.frame.size.height/2,img.frame.size.width,img.frame.size.height/2);
    UILabel *preLabel = (UILabel *)[img.superview viewWithTag:img.tag + SONGLABEL];//下のビューのラベル獲得
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = preLabel.text;
    label.backgroundColor = [UIColor clearColor];
    label.tag = self.tag + SONGLABEL;
    label.numberOfLines = 2;
    label.contentMode = UIViewContentModeScaleToFill;
    
    [self addSubview:label];
}


-(void)frameCopy:(MusicImage *)img{
    if([img.superview viewWithTag:img.tag+PLAYINGFRAME]!=nil|| [self.superview viewWithTag:self.tag+PLAYINGFRAME]!=nil){
        [self printFrame];
        NSLog(@"pre Frame:%f,%f,%f,%f",img.bounds.origin.x,img.bounds.origin.y,img.bounds.size.height,img.bounds.size.width);
        [self addPlayingFrame];
        [[self getSuperview].player setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:musicArray]];//player 更新
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
    for(int i = STARTMUSICTAGNUMBER;[self.superview viewWithTag:i] != nil;i = i + DELETER +1){
        if(CGRectContainsPoint([self.superview viewWithTag:i].frame,self.center) && i!=self.tag){
           return i;
        }
    }
    return 0;
}

-(BOOL)checkPlayingItem{//return value YES if self contain playing item if not , return NO;
    for(int i=0;i<[musicArray count];i++){
        if([[self getSuperview].player nowPlayingItem] == [musicArray objectAtIndex:i])
            return YES;
    }
    return NO;
}

-(void)addMusic:(NSMutableArray *)music
{
    musicArray = music;
    [self updataSaveData];
}

-(void)deleteView{
    [self updateImageTag];//tagの更新
    [self removeSaveData];
    [self removeFromSuperview];//imageの削除
    //updata savedata
}

-(void)updateImageTag//すべてのimage tagを更新する
{
    NSLog(@"updateImage");
    if(self.tag + PLAYINGFRAME <[(SuperView *)[self superview] getHavePlayingFrame])
        [(SuperView *)[self superview] updateHavePlayingFrame:[(SuperView *)[self superview] getHavePlayingFrame]-(DELETER+1)];
    if(self.tag + FRAME <[(SuperView *)[self superview] getHaveRedFrame])
        [(SuperView *)[self superview] updateHaveRedFrame:[(SuperView *)[self superview] getHaveRedFrame]-(DELETER + 1)];
    
    for(int i = self.tag+DELETER+1;[self.superview viewWithTag:i] != nil;i= i+DELETER+1){
        NSLog(@"update ImageTag:%@",[self.superview viewWithTag:i]);
        [self.superview viewWithTag:i].tag -=(DELETER+1);
        [self.superview viewWithTag:i+FRAME].tag -=(DELETER+1);
        [self.superview viewWithTag:i+SONGLABEL].tag -=(DELETER+1);
        [self.superview viewWithTag:i+ALBUMLABEL].tag -=(DELETER+1);
        [self.superview viewWithTag:i+PLAYINGFRAME].tag -=(DELETER+1);
        [self.superview viewWithTag:i+DELETER].tag -=(DELETER+1);
    }
}

-(void)shuffleMusic{
        int i = random()%([musicArray count]);
        [self getSuperview].player.nowPlayingItem = [musicArray objectAtIndex:i];
        [[self getSuperview].player play];
}

-(UISwipeGestureRecognizer *)getRightSwipeRecognizer{
    return rightSwipeGesture;
}
-(UISwipeGestureRecognizer *)getLeftSwipeRecognizer{
    return leftSwipeGesture;
}

-(void)removeSaveData{//セーブ用の配列を更新してセーブする。
    NSLog(@"delete saveData");
    NSString *fileName = @"Documents/data";
    NSString *extention = @".dat";
    NSString *fileNum = [NSString stringWithFormat:@"%d",[[self superview] superview].tag];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@",fileName,fileNum,extention]];

    NSMutableArray *array = [[self getSuperview] getMusicSaveData];
    [array removeObjectAtIndex:((self.tag-1)/(DELETER+1) )];

    [NSKeyedArchiver archiveRootObject:[[self getSuperview] getMusicSaveData] toFile:filePath];
    
}

/*-(void)serializer{
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/data.dat"];
    BOOL successful = NO;
    NSMutableArray *array = [[self getMyScrollView] getMusicSaveData];
    
    NSLog(@"save object:%@",self);
    //search
    NSLog(@"array count:%d",[array count]);
    NSLog(@"selftag count:%d",((self.tag-1)/(DELETER+1) +1));
    if([array count] >= ((self.tag-1)/(DELETER+1) +1)){//すでにImageが存在するので、オブジェクトを更新する
        NSLog(@"途中に代入します");
            NSLog(@"selftag count:%d",((self.tag-1)/(DELETER+1) +1));
        [array insertObject:self atIndex:((self.tag-1)/(DELETER+1) +1)];
        [array removeObjectAtIndex:((self.tag-1)/(DELETER+1) +1)];
    }
    else{//オブジェクトが存在しないので、最後尾に追加する
        NSLog(@"最後尾に代入します");
        [array addObject:self];
    }
    
    successful = [NSKeyedArchiver archiveRootObject:[[self getMyScrollView] getMusicSaveData] toFile:filePath];
    if (successful) {
        NSLog(@"データの保存に成功しました。");
            NSLog(@"save object:%@",array);
    }else{
        NSLog(@"しませんでした");
    }
}*/
-(void)serializer{
    //データ保存ファイル名、パスの指定
    NSString *fileName = @"Documents/data";
    NSString *extention = @".dat";
    NSString *fileNum = [NSString stringWithFormat:@"%d",[[self superview] superview].tag];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@",fileName,fileNum,extention]];

    BOOL successful = NO;
    NSMutableArray *array = [[self getSuperview] getMusicSaveData];//savedataの配列
    [self updataSaveData];
    //search
//    NSLog(@"array count:%d",[array count]);
  //  NSLog(@"selftag count:%d",((self.tag-1)/(DELETER+1) +1));
    if([array count] >= ((self.tag-1)/(DELETER+1) +1)){//すでにImageが存在するので、オブジェクトを更新する
     //   NSLog(@"途中に代入します");
       // NSLog(@"selftag count:%d",((self.tag-1)/(DELETER+1) +1));
        [array insertObject:saveData atIndex:((self.tag-1)/(DELETER+1) +1)];
        [array removeObjectAtIndex:((self.tag-1)/(DELETER+1) +1)];
    }
    else{//オブジェクトが存在しないので、最後尾に追加する
        NSLog(@"最後尾に代入します");
        [array addObject:saveData];
    }
    
    successful = [NSKeyedArchiver archiveRootObject:[[self getSuperview] getMusicSaveData] toFile:filePath];
    if (successful) {
        NSLog(@"データの保存に成功しました。");
     //   NSLog(@"save object:%@",array);
    }else{
        NSLog(@"しませんでした");
    }
}
/*//viewエンコード　以下の3つをエンコードするけど、時間が掛かるからやめ
- (void)encodeWithCoder:(NSCoder*)aCoder
{
 //   [aCoder encode]
    [aCoder encodeObject:musicArray forKey:@"musicArray"];
    [aCoder encodeObject:self.image forKey:@"image"];
    [aCoder encodeCGRect:self.frame forKey:@"frame"];
}*/
-(void)printFrame{
    NSLog(@"self Frame:%f,%f,%f,%f",self.frame.origin.x,self.frame.origin.y,self.frame.size.height,self.frame.size.width);
}
-(void)pringBounds{
            NSLog(@"self bounds:%f,%f,%f,%f",self.bounds.origin.x,self.bounds.origin.y,self.bounds.size.height,self.bounds.size.width);
}

-(SuperView *)getSuperview{
    return (SuperView *)self.superview;
}
-(MyScrollView *)getMyScrollView{
    return (MyScrollView *)self.superview.superview;
}


@end
