//
//  HLHJFactStartFooterView.h
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/15.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLHJFactStartFooterView : UIView


/**
 type:1-图片资源 2-视频资源
 */
@property (nonatomic, copy) void(^uploadBlock)(id dataSource,NSInteger type ,id url);

@end
