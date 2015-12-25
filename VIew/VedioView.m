//
//  VedioView.m
//  MyPlayer
//
//  Created by qianfeng on 15-6-23.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "VedioView.h"


@implementation VedioView

//要使用AVPlayer进行视频的播放，需要一个view展示内容，该view对应的layer一定是AVPlayerLayer

//重写layerClass，指定该view使用的layer
+(Class)layerClass
{
    return [AVPlayerLayer class];
}


-(void)setPlayer:(AVPlayer*)player
{
    AVPlayerLayer *layer = (AVPlayerLayer*)self.layer;
    //给layer设置AVPlayer，这样player提供内容，layer负责渲染展示
    [layer setPlayer:player];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
