//
//  HLHJFactTableViewHeaderView.h
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/14.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SDCycleScrollView.h"
@interface HLHJFactTableViewHeaderView : UIView

@property (nonatomic, copy) void(^WantReportBlock)(void);

@property (nonatomic, strong)SDCycleScrollView *sdCycleScrollView;


@end
