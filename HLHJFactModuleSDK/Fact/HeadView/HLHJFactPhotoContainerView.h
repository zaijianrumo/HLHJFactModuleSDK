//
//  HLHJFactPhotoContainerView.h
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/14.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLHJFactPhotoContainerView : UIView

@property (nonatomic, strong) NSArray *picPathStringsArray;

- (void)picPathStringsArray:(NSArray *)arr type:(NSInteger)type  andVidoImage:(NSString *)img;

@property (nonatomic, copy) void(^clickPlayActionBlock)(BOOL isPlay,CGRect rect);

@end

//@interface HLHJFactPhotoContainerView : UIView
//
//@property (nonatomic, strong) NSArray *picPathStringsArray;
//
//@end
