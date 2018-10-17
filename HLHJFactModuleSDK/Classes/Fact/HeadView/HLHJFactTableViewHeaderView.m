//
//  HLHJFactTableViewHeaderView.m
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/14.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "HLHJFactTableViewHeaderView.h"

#import "UIView+SDAutoLayout.h"

@implementation HLHJFactTableViewHeaderView {
    UIButton  *_factButton;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}
- (void)setup
{
    _sdCycleScrollView = [[SDCycleScrollView alloc]init];
    _sdCycleScrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _sdCycleScrollView.pageDotColor = [UIColor whiteColor];
    _sdCycleScrollView.bannerImageViewContentMode  = UIViewContentModeScaleAspectFill;
    _sdCycleScrollView.currentPageDotColor = [TMEngineConfig instance].themeColor;
    
    _factButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _factButton.titleLabel.font = [UIFont systemFontOfSize:14];
    _factButton.titleLabel.lineBreakMode = 0;//这句话很重要
    _factButton.layer.cornerRadius = 5;
    _factButton.clipsToBounds = YES;
    [_factButton setBackgroundColor:[TMEngineConfig instance].themeColor];
    [_factButton setTitle:@"我要\n爆料" forState:UIControlStateNormal];
    [_factButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_factButton addTarget:self action:@selector(wantReportAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addSubview:_sdCycleScrollView];
    [self addSubview:_factButton];
    
    _sdCycleScrollView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 40, 0));
    
    _factButton.sd_layout
    .widthIs(50)
    .heightIs(50)
    .rightSpaceToView(self, 15)
    .bottomSpaceToView(self, 20);
    
}

- (void)wantReportAction:(UIButton *)sender {
    if (self.WantReportBlock) {
        self.WantReportBlock();
    }
}

@end
