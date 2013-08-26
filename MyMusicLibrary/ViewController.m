//
//  ViewController.m
//  MyMusicLibrary
//
//  Created by Ohata Takashi on 2013/05/22.
//  Copyright (c) 2013年 Ohata Takashi. All rights reserved.
//

#import "ViewController.h"
#import "MusicImage.h"
#import "MusicSaveData.h"
#import "SuperView.h"
#import "EffectSoundBox.h"

@implementation ViewController
{
    UISwipeGestureRecognizer *rightSwipeGesture;
    UISwipeGestureRecognizer *leftSwipeGesture;
    UITapGestureRecognizer *singleFingerTap;
    UITapGestureRecognizer *doubleFingerTap;
    UITapGestureRecognizer *singleFingerDoubleTap;
    BOOL makeAlbum;
    
    AppDelegate *appDelegate;
    UITextField *textField;
    
    EffectSoundBox *effectSoundBox;
    SuperView *scrollerView;
    
    NSMutableArray *albumViewControllerList;//アルバムのviewcontrollerをリスト管理する　予定
    
    int canvasViewControllerNumber;//viewControllerの個体識別番号
    
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];

    self.imageTag = STARTMUSICTAGNUMBER;
    
    self.scroller = [[MyScrollView alloc] initWithFrame:CGRectMake(0,0,MAXWIDTH,MAXHEIGHT)];
    [self.view addSubview:self.scroller];
    
    //addGestures
    [self addSingleFingerDoubleTapGesture];
    [self addSingleFingerTapGesture];
    [self addDoubleFingerTaoGesture];
    [self addLeftSwipeGesture];
    [self addRightSwipeGesture];
    [self addRotationGesture];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    effectSoundBox = [[EffectSoundBox alloc] init];
    
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    if(self.albumMusicArray)
        [self addMusicImage:self.albumMusicArray];
    
    
///    [self.view addSubview:[_scroller getSubview]];
    _scroller.delegate = self;

    self.view = self.scroller;
}

-(void)setCanvasViewControllerNumber:(int)number{
    canvasViewControllerNumber = number;
}

- (SuperView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [_scroller getSubview];;
}

-(void)addSingleFingerTapGesture{
    singleFingerTap = [[UITapGestureRecognizer alloc]
                       initWithTarget:self  action:@selector(handleSingleTap:)];
    [self.scroller addGestureRecognizer:singleFingerTap];
    [singleFingerTap requireGestureRecognizerToFail:singleFingerDoubleTap];//ダブルタップが呼ばれないことを確認する
}

-(void)addSingleFingerDoubleTapGesture{
    singleFingerDoubleTap = [[UITapGestureRecognizer alloc]
                             initWithTarget:self  action:@selector(handleSingleDoubleTap:)];
    singleFingerDoubleTap.numberOfTapsRequired = 2;
    [self.scroller addGestureRecognizer:singleFingerDoubleTap];
}

-(void)addDoubleFingerTaoGesture{
    doubleFingerTap = [[UITapGestureRecognizer alloc]
                       initWithTarget:self  action:@selector(handleDoubleTap:)];
    doubleFingerTap.numberOfTouchesRequired = 2;
    
    [self.scroller addGestureRecognizer:doubleFingerTap];
}

-(void)addRightSwipeGesture{
    
    rightSwipeGesture = [[UISwipeGestureRecognizer alloc]
                         initWithTarget:self action:@selector(rightSwipeAction:)];
    rightSwipeGesture.numberOfTouchesRequired = 2;
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.scroller addGestureRecognizer:rightSwipeGesture];
    
}

-(void)addLeftSwipeGesture{
    leftSwipeGesture = [[UISwipeGestureRecognizer alloc]
                        initWithTarget:self action:@selector(leftSwipeAction:)];
    leftSwipeGesture.numberOfTouchesRequired = 2;
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;

    [self.scroller addGestureRecognizer:leftSwipeGesture];
}

-(void)addRotationGesture{
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:
                                                    self action:@selector(selRotationGesture:)];
    
    [rotationGesture requireGestureRecognizerToFail:rightSwipeGesture];
    [rotationGesture requireGestureRecognizerToFail:leftSwipeGesture];
    [self.scroller addGestureRecognizer:rotationGesture];
    
    
}

-(void)readSaveData{
    //保存していたデータを読み込む
    NSLog(@"read save data");
    [self readViewData];//壁紙情報を読み込む そのままスクローラに貼り付け
    [self readSerialData];//楽曲情報を読み込み　そのまま貼り付け
}


// ローテイトされた時に実行されるメソッド、selectorで指定します。
-(void) selRotationGesture:(UIRotationGestureRecognizer*) sender {
    UIRotationGestureRecognizer* selRotationGesture = (UIRotationGestureRecognizer*) sender;
    // 回転率 右回転の場合は +値 左回転の場合は -値
    NSLog(@"rotate:%f", selRotationGesture.rotation);
    //アフィン変換でスクローラを回転
    self.scroller.transform = CGAffineTransformMakeRotation(selRotationGesture.rotation);
    
}
-(void)handleSingleDoubleTap:(UIGestureRecognizer *)sender{    //アルバム作成　Musicライブラリにアクセスし、選択楽曲をスクローラに貼り付ける
    makeAlbum = YES;
    if(sender.state  == UIGestureRecognizerStateEnded){
        //imageTagの更新
        [self updateImageTag];
        //Dleterが出ていたら消す
        if([self checkDeleter]){
            for(int i = STARTMUSICTAGNUMBER; i < self.imageTag;i = i+DELETER+1){
                NSLog(@"remove deleter:%@",[[self.scroller getSubview] viewWithTag:i+DELETER]);
                [[[self.scroller getSubview] viewWithTag:i+DELETER] removeFromSuperview];
            }
        }else if([self deleteSelectFrame]){//SelectionFrame があったら消す
            self.scroller.delaysContentTouches = YES;
            return;
        }else{
            AudioServicesPlaySystemSound(OPENLIBRARYSOUNDNUM);//iphoneシステムサウンド
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


-(void)leftSwipeAction:(UIGestureRecognizer *)sender{//左にスワイプしたときの処理　ViewControllerを切り替え、別のスクローラを表示する
    NSLog(@"left swipe gesture called");
    if(self.prevController == nil){
        if(self.view.tag < [appDelegate.canvasViewControllerList count]){//ViewControllerを変更する
            ViewController *cnt= (ViewController *)[appDelegate.canvasViewControllerList objectAtIndex:self.view.tag];
            [appDelegate.window bringSubviewToFront:cnt.view];//別のコントローラの持つビューを全面へ持ってくる　つまり変更
//            NSLog(@"change view controller tag:%@",cnt.view);
            [self.view.window sendSubviewToBack:self.view];//自身を後ろへ
            appDelegate.window.rootViewController = cnt;//ビューコントローラの変更
        }else{
            //新しくcontrollerを作成
            [appDelegate addController];
            NSLog(@"change view controller tag:%@",[appDelegate.window viewWithTag:self.view.tag+1]);
        }
    }else{
        [appDelegate.window bringSubviewToFront:self.prevController.view];
        NSLog(@"change view controller tag:%@",self.prevController.view);
        [self.view.window sendSubviewToBack:self.prevController.view];
        appDelegate.window.rootViewController = self.prevController;
        [effectSoundBox playDeleteSound];
    }
}

-(void)rightSwipeAction:(UIGestureRecognizer *)sender{
    //フロントに持ってくるviewを指定　self.tag -1
    NSLog(@"right Swipe gesture called");
    if(self.view.tag>1){
        ViewController *cnt= (ViewController *)[appDelegate.canvasViewControllerList objectAtIndex:self.view.tag-2];
        [appDelegate.window bringSubviewToFront:cnt.view];
        NSLog(@"change view controller tag:%@",cnt.view);
        [self.view.window sendSubviewToBack:self.view];
        appDelegate.window.rootViewController = cnt;
    }else{
        NSLog(@"cant swipe right");
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleSingleTap:(UIGestureRecognizer *)sender{
    NSLog(@"singletap gesture called");
    makeAlbum = NO;
    if(sender.state  == UIGestureRecognizerStateEnded){
        //imageTagの更新
        [self updateImageTag];
            
        if([self checkDeleter]){
            for(int i = STARTMUSICTAGNUMBER; i < self.imageTag;i = i+DELETER+1){
                NSLog(@"remove deleter:%@",[[self.scroller getSubview] viewWithTag:i+DELETER]);
                [[[self.scroller getSubview] viewWithTag:i+DELETER] removeFromSuperview];
            }
        }else if([self deleteSelectFrame]){
            self.scroller.delaysContentTouches = YES;
            return;
        }else{
        AudioServicesPlaySystemSound(OPENLIBRARYSOUNDNUM);//iphoneシステムサウンド　
        // initWithMediaTypes の引数は下記を参照に利用したいメディアを設定
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

-(void)handleDoubleTap:(UIGestureRecognizer *)sender{//ダブルタップ時の処理　フォトアルバムへアクセス　壁紙を設定
    NSLog(@"double finger tap called");
    AudioServicesPlaySystemSound(OPENLIBRARYSOUNDNUM);//iphoneシステムサウンド　
    if(sender.state == UIGestureRecognizerStateEnded){
        [self startCameraPickerFromViewController:self usingDelegate:self sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        //sorcetype:フォトアルバム
    }
}
-(BOOL) startCameraPickerFromViewController:(UIViewController*)i_controller
                              usingDelegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)i_delegate
                                 sourceType:(UIImagePickerControllerSourceType)i_type
{
    if( ![UIImagePickerController isSourceTypeAvailable:i_type]
       || (i_delegate == nil)
       || (i_controller == nil ) ){
        return NO;
    }
    
    UIImagePickerController* a_picker = [[UIImagePickerController alloc] init];
    a_picker.sourceType = i_type;
    a_picker.delegate = i_delegate;
    a_picker.allowsEditing = NO;
    
    // ピッカーは非同期に表示される
    [i_controller presentViewController: a_picker animated:YES completion: ^{
    }];
    
    return YES;
}

/// 画像が選択されたときに呼ばれるデリゲート関数
- (void) imagePickerController:(UIImagePickerController*)i_picker
         didFinishPickingImage:(UIImage*)i_image
                   editingInfo:(NSDictionary*)i_editing_info
{
    
    [self useImage:i_image];
    [self dismissViewControllerAnimated:YES completion:NULL];
    AudioServicesPlaySystemSound(OPENLIBRARYSOUNDNUM);//iphoneシステムサウンド　
}

/// 画像の選択がキャンセルされたときに呼ばれるデリゲート関数
- (void) imagePickerControllerDidCancel:(UIImagePickerController*)i_picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"canceled");
        AudioServicesPlaySystemSound(CLOSELIBRARYSOUNDNUM);//iphoneシステムサウンド
    }];
    
}

- (void) navigationController:(UINavigationController*)i_navigation_controller
        didShowViewController:(UIViewController*)i_view_controller
                     animated:(BOOL)i_animated
{
}

- (void)useImage:(UIImage*)i_image
{
   /* MyImageView *view =[[MyImageView alloc] initWithImage:i_image];
    MyLabel *textView = [[MyLabel alloc] initWithFrame:CGRectMake(view.frame.origin.x,view.frame.origin.y,
                                                                  view.frame.size.width,view.frame.size.height/4)];
    textView.text = @"TEST";
    textView.tag = imageTag + TEXT;
    textView.backgroundColor = [UIColor clearColor];
    
    view.userInteractionEnabled = YES;
    view.tag = imageTag;
    NSLog(@"tag = %d",view.tag);
    imageTag+=4;
    [view addSubview:textView];
    [_scroller addSubview:view];
    
    view.delegate = self;*/
    
    NSLog(@"get image width:%f height:%f",i_image.size.width,i_image.size.height);
    
    SuperView *view = [_scroller getSubview];
    view.image = i_image;
    [self serializeViewData];
    
}

-(BOOL)checkDeleter{
    for(int i = STARTMUSICTAGNUMBER;i<self.imageTag;i=i+DELETER+1){
        if([[self.scroller getSubview] viewWithTag:i+DELETER] != nil)
            return YES;
    }
    return NO;
}
-(BOOL)deleteSelectFrame{
    BOOL deleted = NO;
    SuperView *view = [_scroller getSubview];
    if([view getHaveRedFrame]!=0){
        [[view  viewWithTag:[view getHaveRedFrame]] removeFromSuperview];
        [view updateHaveRedFrame:0];
        deleted = YES;
    }
    return deleted;
}

-(void)updateImageTag{
    if([[self.scroller getSubview] viewWithTag:STARTMUSICTAGNUMBER] == nil){
        self.imageTag = STARTMUSICTAGNUMBER;//初期化
        return;
    }
    for(int i = STARTMUSICTAGNUMBER;[[self.scroller getSubview] viewWithTag:i]!=nil;i=i+DELETER+1){
        self.imageTag = i;
    }
    self.imageTag = self.imageTag +DELETER+1;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventTypeMotion &&
        motion == UIEventSubtypeMotionShake ) {
        int i;
        for(i = STARTMUSICTAGNUMBER; [self.scroller viewWithTag:i] != nil;i += (DELETER + 1 )){
            if([self.scroller viewWithTag:i+PLAYINGFRAME]!= nil){
                break;
            }
        }//playingを特定
        //そのmusicimageの再生アイテムをシャッフルする関数を呼ぶ
        MusicImage *img = (MusicImage *)[self.scroller viewWithTag:i];
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
    AudioServicesPlaySystemSound(CLOSELIBRARYSOUNDNUM);//iphoneシステムサウンド
}

- (void)makeImage:(MPMediaPickerController *) mediaPicker
didPickMediaItems: (MPMediaItemCollection *) collection
{//アルバム、または楽曲イメージを作成する
    NSLog(@"Done pressed");
    CGRect imageFrame = CGRectMake(0,0,DEFAULTSIZE,DEFAULTSIZE);
    CGRect labelFrame = CGRectMake(0,0,DEFAULTSIZE,DEFAULTSIZE);
    
    if(makeAlbum){
        //アラートビュー表示
        //label作成
        
        [self displayAlertview];
        
        NSMutableArray *musicArray = [[NSMutableArray alloc] initWithCapacity:1];
        for (MPMediaItem *item in collection.items) {
            [musicArray addObject:item];   
        }
        
        MusicImage *musicImage = [[MusicImage alloc] initWithImage:[UIImage imageNamed:@"albumDefault.jpg"]];
        [musicImage addMusic:musicArray];
        musicImage.frame = imageFrame;
        
        [musicImage makeAlbumController];
        [self.scroller addMusicImage:musicImage];
    }else{
        for (MPMediaItem *item in collection.items) {
            
            int extent = [[item valueForProperty:MPMediaItemPropertyPlayCount] integerValue];
            imageFrame = CGRectMake(imageFrame.origin.x,imageFrame.origin.y,DEFAULTSIZE + +extent/10,DEFAULTSIZE + +extent/10);
            labelFrame = CGRectMake(0,0,DEFAULTSIZE + +extent/10,DEFAULTSIZE + +extent/10);
            
            //ラベルの作成
            UILabel *label = [self makeLabel:labelFrame withString:[item valueForProperty:MPMediaItemPropertyTitle]];
            
            //アートワークからImage作成
            MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
            
            NSMutableArray *musicArray = [[NSMutableArray alloc] initWithCapacity:1];
            [musicArray addObject:item];
            
            MusicImage *musicImage = [[MusicImage alloc] initWithImage:[artwork imageWithSize:CGSizeMake(DEFAULTSIZE,DEFAULTSIZE)]];
            musicImage.tag = self.imageTag;
            [self updateTag];
            
            //queryの追加
            [musicImage addMusic:musicArray];
            
            if(musicImage.image == nil)
                musicImage.image = [UIImage imageNamed:@"albumDefault.jpg"];
            
            musicImage.frame = imageFrame;
            
            [musicImage addSubview:label];
            [self.scroller addMusicImage:musicImage];
            
            imageFrame.origin.x+=5;
            imageFrame.origin.y+=5;//初期設置位置の更新
            if(imageFrame.origin.y>=MAXHEIGHT){
                imageFrame.origin.y = MAXHEIGHT;
                imageFrame.origin.x = MAXHEIGHT;
            }
        }
        
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
    [textField setDelegate:self];
    // アラートビューにテキストフィールドを埋め込む
    [alertView addSubview:textField];
    
    // アラート表示
    [alertView show];
    
    // テキストフィールドをファーストレスポンダに
    [textField becomeFirstResponder];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {//アルバム作成時のためのアラートビューの表示　作成中　　
    // OKが選択された場合
    if (buttonIndex == 1) {
        // テキストフィールドに一文字以上入力されていれば
        if ([textField.text length]){//アルバム作成時の処理
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(img.bounds.origin.x,img.bounds.origin.y,img.frame.size.width,img.frame.size.height/2)];
            
  //          label.text = textField.text;
    //        label.backgroundColor = [UIColor clearColor];
      //      label.numberOfLines = 2;
//            label.tag = self.tag + ALBUMLABEL;
            NSLog(@"albumlabel:%@",textField.text);
        }else{
            return;
        }
        textField.text = nil;//textFieldに値が入ったままになってしまうので、初期化
    }
}

-(void)updateTag{
    self.imageTag = self.imageTag + DELETER + 1;//tag の更新
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
    AudioServicesPlaySystemSound(CLOSELIBRARYSOUNDNUM);//iphoneシステムサウンド
}


-(UILabel *)makeLabel:(CGRect)labelFrame withString:(NSString *)text{
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.text = text;
    label.backgroundColor = [UIColor clearColor];
    label.tag = self.imageTag + SONGLABEL;
    label.numberOfLines = 2;
    label.contentMode = UIViewContentModeScaleToFill;
    
    return label;
}

//viewイメージをそのまま復元する　復元に時間がかかるため廃棄
/*-(void)readSerialData{
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/data.dat"];
    NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    NSLog(@"load object:%@",[array objectAtIndex:0]);

//    MusicImage *view = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    MusicImage *view = [array objectAtIndex:0];
    if (view) {
        NSMutableArray *saveData =[self.scroller getMusicSaveData];
        for(int i=0; i<[array count];i++){
            MusicImage *view = [array objectAtIndex:i];
            UILabel *label = [self makeLabel:view.bounds withString:@"test"];
            [view addSubview:label];
            
            view.tag = self.imageTag;
            [self updataTag];
            [self.scroller addMusicImage:view];
        }
//        [(MPMediaItem *)[view getMusicList] valueForProperty:MPMediaItemPropertyTitle]
        
        
    } else {
        NSLog(@"%@", @"データが存在しません。");
    }
}*/

-(void)serializeViewData{
    NSString *fileName = @"Documents/ViewData";
    NSString *extention = @".dat";
    NSString *fileNum = [NSString stringWithFormat:@"%d",self.view.tag];
    
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@",fileName,fileNum,extention]];
    NSLog(@"save file path:%@",filePath);
    BOOL successful;
    
    successful = [NSKeyedArchiver archiveRootObject:[_scroller getSubview].image  toFile:filePath];
    if(successful){
        NSLog(@"壁紙の保存に成功");
    }else{
        NSLog(@"壁紙の保存に失敗");        
    }
    
}
-(void)readViewData{
    NSString *fileName = @"Documents/ViewData";
    NSString *extention = @".dat";
    NSString *fileNum = [NSString stringWithFormat:@"%d",self.view.tag];

    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@",fileName,fileNum,extention]];
    NSLog(@"load file path:%@",filePath);
    UIImage *img = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    if(img){
        [_scroller getSubview].image = img;
        NSLog(@"壁紙の読み込みに成功");
    }else{
        NSLog(@"壁紙の読み込みに失敗");
    }
}

-(void)readSerialData{
    //serialData読み込み
    NSString *fileName = @"Documents/data";
    NSString *extention = @".dat";
    NSString *fileNum = [NSString stringWithFormat:@"%d",self.view.tag];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@",fileName,fileNum,extention]];
    NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

    //    MusicImage *view = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

    if (array) {
        for(int i=0; i<[array count];i++){
            MusicSaveData *loadData = [array objectAtIndex:i];
            MPMediaItem *item = (MPMediaItem *)[loadData.musicArray objectAtIndex:0];
            
            //ラベルの作成
            CGRect labelFrame = CGRectMake(0,loadData.bounds.size.height/2,loadData.bounds.size.width,loadData.bounds.size.height/2);
            UILabel *label = [self makeLabel:labelFrame withString:[item valueForProperty:MPMediaItemPropertyTitle]];

            //アルバムラベルの作成
            CGRect albumLabelFrame = CGRectMake(0,0,loadData.bounds.size.width,loadData.bounds.size.height/2);
            UILabel *albumLabel = [self makeLabel:albumLabelFrame withString:loadData.albumName];
            albumLabel.tag = self.imageTag + ALBUMLABEL;
            
            
            //アートワークからImage作成
            MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
            
            MusicImage *musicImage = [[MusicImage alloc] initWithImage:[artwork imageWithSize:CGSizeMake(DEFAULTSIZE,DEFAULTSIZE)]];
            if(musicImage.image == nil)
                musicImage.image = [UIImage imageNamed:@"albumDefault.jpg"];
            
            musicImage.tag = self.imageTag;
            //queryの追加
            [musicImage addMusic:loadData.musicArray];
            //frameの設定
            musicImage.frame = loadData.bounds;
            //ラベルの貼り付け
            [musicImage addSubview:label];
            [musicImage addSubview:albumLabel];
            musicImage.albumName = albumLabel.text;
            [musicImage serializer];
            [self.scroller addMusicImage:musicImage];
            self.imageTag +=DELETER+1;
        }
    } else {
        NSLog(@"%@", @"データが存在しません。");
    }
}

-(void)addMusicImage:(NSMutableArray *)array{
    NSLog(@"add music images to ViewController");
    NSLog(@"array:%@",array);
    CGRect imageFrame = CGRectMake(0,0,DEFAULTSIZE,DEFAULTSIZE);
    CGRect labelFrame = CGRectMake(0,0,DEFAULTSIZE,DEFAULTSIZE);
    
    for (int i = 0;i<[array count];i++) {
        MPMediaItem *item = (MPMediaItem *)[array objectAtIndex:i];
        int extent = [[item valueForProperty:MPMediaItemPropertyPlayCount] integerValue];
        imageFrame = CGRectMake(imageFrame.origin.x,imageFrame.origin.y,DEFAULTSIZE + +extent/10,DEFAULTSIZE + +extent/10);
        labelFrame = CGRectMake(0,0,DEFAULTSIZE + +extent/10,DEFAULTSIZE + +extent/10);
        
        //ラベルの作成
        UILabel *label = [self makeLabel:labelFrame withString:[item valueForProperty:MPMediaItemPropertyTitle]];
        
        //アートワークからImage作成
        MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
        
        NSMutableArray *musicArray = [[NSMutableArray alloc] initWithCapacity:1];
        [musicArray addObject:item];
        
        MusicImage *musicImage = [[MusicImage alloc] initWithImage:[artwork imageWithSize:CGSizeMake(DEFAULTSIZE,DEFAULTSIZE)]];
        musicImage.tag = self.imageTag;
        [self updateTag];
        
        //queryの追加
        [musicImage addMusic:musicArray];
        
        if(musicImage.image == nil)
            musicImage.image = [UIImage imageNamed:@"albumDefault.jpg"];
        
        musicImage.frame = imageFrame;
        
        [musicImage addSubview:label];
        
        [self.scroller addMusicImage:musicImage];
        
        imageFrame.origin.x+=5;
        imageFrame.origin.y+=5;//初期設置位置の更新
        if(imageFrame.origin.y>=MAXHEIGHT){
            imageFrame.origin.y = MAXHEIGHT;
            imageFrame.origin.x = MAXHEIGHT;
        }
    }
}

/**
 * デリゲートメソッドその1を実装
 */
- (void)changeViewController:(NSMutableArray *)cnt
{
    NSLog(@"cnt:%@",cnt);
    ViewController *test = (ViewController *)cnt;
    NSLog(@"test : %@",test);
    NSLog(@"test scroller:%@",test.scroller);
    ViewController *nextController = (ViewController *)cnt;
    nextController.prevController = self;
    [appDelegate addController:(ViewController *)nextController];
}
    
@end

