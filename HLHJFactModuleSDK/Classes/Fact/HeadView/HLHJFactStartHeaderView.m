//
//  HLHJFactStartHeaderView.m
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/15.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "HLHJFactStartHeaderView.h"

#import "UIView+SDAutoLayout.h"

#import "IQKeyboardManager.h"
@interface HLHJFactStartHeaderView()<UITextViewDelegate>

@property(nonatomic, weak)UILabel *placeHolder;

@property(nonatomic, weak)UILabel *countlabel;

@end

@implementation HLHJFactStartHeaderView

- (instancetype)initWithFrame:(CGRect)frame  {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setup];
        
        ///键盘弹出时，点击背景，键盘收回
        [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
        ///隐藏键盘上面的toolBar,
        [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    }
    return self;
}
- (void)setup {
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"填写详细信息";
    label.font =[UIFont systemFontOfSize:14];
    label.textColor = [UIColor blackColor];
    [self addSubview:label];
    
    UILabel *deslabel = [[UILabel alloc] init];
    deslabel.text = @"请详细描述您的爆料。";
    deslabel.font = [UIFont systemFontOfSize:14];
    deslabel.textColor = [UIColor darkGrayColor];
    [self addSubview:deslabel];
    
    UITextView *textView = [UITextView new];
    textView.layer.cornerRadius = 5;
    textView.layer.borderWidth = 1;
    textView.font = [UIFont systemFontOfSize:15];
    textView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    textView.layer.masksToBounds = YES;
    textView.delegate = self;
    [self addSubview:textView];
    self.contentView = textView;
    
    
    UILabel *placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 200, 20)];
    placeHolderLabel.text = @"请输入您的爆料内容，300字内";
    placeHolderLabel.numberOfLines = 1;
    placeHolderLabel.textColor = [UIColor lightGrayColor];
    [placeHolderLabel sizeToFit];
    placeHolderLabel.font = [UIFont systemFontOfSize:15.f];
    [textView addSubview:placeHolderLabel];
    self.placeHolder = placeHolderLabel;

    UILabel *countlabel = [[UILabel alloc] init];
    countlabel.text = @"0/300";
    countlabel.font = [UIFont systemFontOfSize:12];
    countlabel.textAlignment = NSTextAlignmentRight;
    countlabel.textColor = [UIColor lightGrayColor];
    [self addSubview:countlabel];
    self.countlabel = countlabel;
    
     label.sd_layout
    .leftSpaceToView(self, 10)
    .topSpaceToView(self, 10)
    .heightIs(14)
    .widthIs(200);
    
     deslabel.sd_layout
    .leftEqualToView(label)
    .topSpaceToView(label, 5)
    .widthIs(200)
    .heightIs(14);
    
    
     textView.sd_layout
    .leftEqualToView(label)
    .topSpaceToView(deslabel, 5)
    .rightSpaceToView(self, 10)
    .heightIs(175);
    
     countlabel.sd_layout
    .rightEqualToView(textView)
    .topSpaceToView(textView, 8)
    .leftEqualToView(label)
    .heightIs(14);
    

}
#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    if (!textView.text.length) {
        self.placeHolder.alpha = 1;
    } else {
        self.placeHolder.alpha = 0;
    }
    ///1.实时显示字数
    self.countlabel.text = [NSString stringWithFormat:@"%lu/300", (unsigned long)textView.text.length];
    ///2.字数限制操作
    if (textView.text.length >= 300) {
        textView.text = [textView.text substringToIndex:300];
        self.countlabel.text = @"300/300";
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}
@end
