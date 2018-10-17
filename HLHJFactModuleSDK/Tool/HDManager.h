//
//  HDManager.h
//  GuanZhou
//
//  Created by 孑孓 on 2017/8/18.
//  Copyright © 2017年 王志杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDManager : NSObject
//开始加载数据，让加载指示器显示到窗口上
+(void)startLoading;

//数据加载完毕，让加载指示器隐藏
+(void)stopLoading;

@end
