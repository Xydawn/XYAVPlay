//
//  VedioView.h
//  MyPlayer
//
//  Created by qianfeng on 15-6-23.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VedioView : UIView

//AVPlayer是实际播放的内容的，内容的展示是使用
//AVPlayerLayer，所以需要把二者结合起来
-(void)setPlayer:(AVPlayer*)player;

@end
