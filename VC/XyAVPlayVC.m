//
//  XyAVPlayVC.m
//  ChatDemo-UI2.0
//
//  Created by apple on 15/12/5.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "XyAVPlayVC.h"
#import <AVFoundation/AVFoundation.h>
#import "VedioView.h"
#import <MediaPlayer/MediaPlayer.h>
@interface XyAVPlayVC ()
@property (nonatomic,strong) VedioView *avplay;
@property(nonatomic)AVPlayer *player;
@property (nonatomic) AVPlayerItem *item;
@property (nonatomic,strong)UISlider *slider;
@property BOOL played;
@property (nonatomic, strong) MPMoviePlayerViewController *play;
@property (nonatomic) CGFloat playTime;
@end

@implementation XyAVPlayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initUI];
    [self setNAV];
}
#pragma mark - InitUI
-(void)initUI{
    
    self.slider  = [[UISlider alloc]init];
    
    self.slider.maximumValue = 1.0;
    self.slider.minimumValue = 0.0;
    self.slider.value        = 0.0;
    [self.slider  addTarget:self action:@selector(changeTime:) forControlEvents:(UIControlEventValueChanged )];
    [self.slider xy_autoLayoutSetSize:CGSizeMake(k_width*0.8, 40) withSuperView:self.view];
    [self.slider xy_autoConstantToSuperWith:0.1*k_width withAttribute:(NSLayoutAttributeLeft)];
    [self.slider xy_autoConstantToSuperWith:100 withAttribute:(NSLayoutAttributeTop)] ;
    
    
    UIButton *button = [[UIButton alloc]init];
    [button xy_autoLayoutSetSize:CGSizeMake(40, 40) withSuperView:self.view];
    [button addTarget:self action:@selector(quanping:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"全屏" forState:0];
    [button xy_autoConstantToSuperWith:20 withAttribute:(NSLayoutAttributeLeft) withSuperView:self.view];
    [button xy_autoConstantToSuperWith:500 withAttribute:(NSLayoutAttributeTop) withSuperView:self.view];
    [button setBackgroundColor:[UIColor blueColor] ];
    
    
    NSString *videoPath = [[NSBundle mainBundle]pathForResource:@"1" ofType:@"mp4"];
    NSURL *localURL = [NSURL fileURLWithPath:videoPath];
    AVURLAsset *localAssert = [[AVURLAsset alloc]initWithURL:localURL options:nil];
    
    self.avplay = [[VedioView alloc]initWithFrame:CGRectMake(0, 80,k_width ,k_height-80)];
    [self.view addSubview:self.avplay];

    AVPlayerLayer *layer = (AVPlayerLayer*)self.avplay.layer;
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    //AVPlayerItem 他是对assert对应资源的一种整体描述，包括能够播放，以及影片长度等内容
    _item = [[AVPlayerItem alloc]initWithAsset:localAssert];

    //使用item生成player，这里会对影片进行预加载分析，然后更新item的状态
    self.player = [AVPlayer playerWithPlayerItem:_item];
    
    //把AVPlayer和AVPlayerLayer进行关联
    [self.avplay setPlayer:self.player];
    [self.player play];
    self.played = YES;
    //监听AVPlayerItem的status状态，当status状态为readyToPlayer时，我们认为影片时可以播放的
    [_item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self.view bringSubviewToFront:self.slider];
    [self.view bringSubviewToFront:button];
}

-(void)changeTime:(UISlider *)sender{
    float progressValue = self.slider.value;
    CMTime totalTime = self.player.currentItem.duration;
    
    //seekToTime 实现影片的定位
    //CMTimeMultiplyByFloat64 让一个CMTime乘以float值，返回对应的CMTime
    [self.player seekToTime:CMTimeMultiplyByFloat64(totalTime, progressValue)];
}

-(void)quanping:(id)sender{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp4"];
    NSURL *url = nil;
    if ([path rangeOfString:@"http:"].location != NSNotFound || [path rangeOfString:@"https:"].location != NSNotFound) { // 网络的视频
        url = [NSURL URLWithString:path];
    } else {
        // 本地视频
        url = [NSURL fileURLWithPath:path];
    }
    
    [self.player pause];
    self.played =!self.played;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"开始" style:(UIBarButtonItemStyleDone) target:self action:@selector(playOrPurse)];
    
    if (self.play==nil) {
        self.play = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playReady) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
    }
  

    
    [self presentViewController:self.play animated:YES completion:^{

    }];
    
    
    // 视频资源分为普通的文件资源,还有流媒体格式(.m3u8)的视频资源
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    // 点击done按钮->视频播放器会自动通过通知中心发送MPMoviePlayerPlaybackDidFinishNotification这条广播
    // [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    // 每个应用程序有且只有一个通知中心的对象(单例),可以理解为广播站，任何对象都可以通过通知中心发送广播
    // 任何对象都可以通过通知中心注册成为某条广播的观察者(具有接收/收听某条广播能力的对象)
    // 在通知中心注册self为MPMoviePlayerPlaybackDidFinishNotification广播的观察者，一旦有其他对象发送这条广播，self就能接收到并触发playBack方法
    // addObserver 添加观察者, selector 触发的方法,name:广播的名称

}

-(void)playReady{
    self.play.moviePlayer.currentPlaybackTime = self.playTime;
    CHQLog(@"%f",self.play.moviePlayer.currentPlaybackTime)
}

-(void)playEnd:(NSNotification*)notification
{
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *item = (AVPlayerItem*)object;
        if (item.status == AVPlayerItemStatusReadyToPlay) {
            //            if ([item canPlayReverse]) {
            //                self.player.rate = -1;
            //            }
            //这里影片可以播放
            [self.player play];
            
            
            //AVPlayer提供了一个周期性调用block的方法，这里可以进行进度更新
            //CMTime 指定一个时间，value/timeScale可以得到秒数
            //CMTimeMake(1, 1) 间隔为1s
            __weak typeof(self)weakSelf = self;
            [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                //time是指当前影片播放的时间
                
                //得到影片的总时间
                CMTime totalTime = weakSelf.player.currentItem.duration;
                
                //CMTimeGetSeconds 把CMTime转换为秒数
                CGFloat currentTimeSeconds = CMTimeGetSeconds(time);
                
                
                
                CGFloat totalSeconds = CMTimeGetSeconds(totalTime);
                //更新进度
                weakSelf.slider.value = currentTimeSeconds*1.0/totalSeconds;
                
                weakSelf.playTime = currentTimeSeconds;
                
            }];
        }else{
            NSLog(@"影片不能播放");
        }
    }
}
#pragma mark - setNAV
-(void)setNAV{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:(UIBarButtonItemStyleDone) target:self action:@selector(dissmiss)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"暂停" style:(UIBarButtonItemStyleDone) target:self action:@selector(playOrPurse)];
}

-(void)playOrPurse{
    self.played =!self.played;
    if (self.played) {
        [self.player play];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"暂停" style:(UIBarButtonItemStyleDone) target:self action:@selector(playOrPurse)];
    }else{
        [self.player pause];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"开始" style:(UIBarButtonItemStyleDone) target:self action:@selector(playOrPurse)];
    }
}

-(void)dissmiss{
    [self.player pause];
 
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)playEnd {
    [self.play dismissViewControllerAnimated:YES completion:^{
    
    }];
    NSLog(@"播放结束");
}

-(void)dealloc{
    [_item removeObserver:self forKeyPath:@"status"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
