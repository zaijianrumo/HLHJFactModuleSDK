//
//  HLHJFFactInputToolbar.h
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/11.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HLHJFFactInputToolbar;

@protocol HLHJFFactInputToolbarDelegate <NSObject>
@optional
- (void)inputToolbar:(HLHJFFactInputToolbar *)inputToolbar sendContent:(NSString *)sendContent;
@end

@interface HLHJFFactInputToolbar : UIView
/**
 *  初始化chat bar
 */
- (instancetype)initWithFrame:(CGRect)frame;
/**
 *  文本输入框
 */
@property (nonatomic,strong)UITextView *textInput;
/**
 *  设置输入框最大行数
 */
@property (nonatomic,assign)NSInteger textViewMaxLine;
/**
 *  textView占位符
 */
@property (nonatomic,strong)UILabel *placeholderLabel;

@property (nonatomic,weak) id<HLHJFFactInputToolbarDelegate>delegate;

@property (nonatomic, copy) void (^keyIsVisiableBlock)(BOOL keyboardIsVisiable);

// 发送成功
-(void)sendSuccessEndEditing;

@end
