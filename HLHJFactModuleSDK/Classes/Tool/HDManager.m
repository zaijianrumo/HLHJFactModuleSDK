//
//  HDManager.m
//  GuanZhou
//
//  Created by 孑孓 on 2017/8/18.
//  Copyright © 2017年 王志杰. All rights reserved.
//

#import "HDManager.h"
#import "MBProgressHUD.h"

@implementation HDManager


//获取加载指示器的方法
+(MBProgressHUD *)shareHDView
{
    static MBProgressHUD *hdView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!hdView) {
            //获取程序的主窗口
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            hdView = [[MBProgressHUD alloc]initWithWindow:window];
//            hdView.mode = MBProgressHUDModeAnnularDeterminate;
            hdView.animationType = MBProgressHUDAnimationZoom;
            hdView.labelFont = [UIFont systemFontOfSize:12];
            hdView.labelText = @"正在上传...";
        }
    });
    return hdView;
}
//开始加载
+(void)startLoading
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hd =[self shareHDView];
    [window addSubview:hd];
    [hd show:YES];
}

//结束加载
+(void)stopLoading
{
    MBProgressHUD *hd =[self shareHDView];
    [hd hide:YES];
}


@end
