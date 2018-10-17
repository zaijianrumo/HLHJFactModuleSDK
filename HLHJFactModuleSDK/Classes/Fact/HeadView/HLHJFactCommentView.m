//
//  HLHJFactCommentView.m
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/14.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "HLHJFactCommentView.h"
#import "UIView+SDAutoLayout.h"
#import "HLHJFactCellModel.h"
#import "MLLinkLabel.h"



@interface HLHJFactCommentView () <MLLinkLabelDelegate>

@property (nonatomic, strong) NSArray *commentItemsArray;
@property (nonatomic, strong) MLLinkLabel *likeLabel;
@property (nonatomic, strong) NSMutableArray *commentLabelsArray;

@end

@implementation HLHJFactCommentView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        [self setupViews];
        
    }
    return self;
}
- (void)setupViews {
    
    _likeLabel = [MLLinkLabel new];
    _likeLabel.font = [UIFont systemFontOfSize:14];
    _likeLabel.linkTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:108/255 green:184/255 blue:255/255 alpha:1]};
    _likeLabel.isAttributedContent = YES;
    [self addSubview:_likeLabel];
    
}


- (void)setCommentItemsArray:(NSArray *)commentItemsArray
{
    _commentItemsArray = commentItemsArray;
    
    long originalLabelsCount = self.commentLabelsArray.count;
    long needsToAddCount = commentItemsArray.count > originalLabelsCount ? (commentItemsArray.count - originalLabelsCount) : 0;
    for (int i = 0; i < needsToAddCount; i++) {
        MLLinkLabel *label = [MLLinkLabel new];
        UIColor *highLightColor = [UIColor colorWithRed:108/255 green:184.1/255 blue:255/255 alpha:1];
        label.linkTextAttributes = @{NSForegroundColorAttributeName : highLightColor};
        label.font = [UIFont systemFontOfSize:14];
        label.delegate = self;
        [self addSubview:label];
        [self.commentLabelsArray addObject:label];
    }
    
    for (int i = 0; i < _commentItemsArray.count; i++) {
        HLHJFactCellCommentItemModel *model = _commentItemsArray[i];
        MLLinkLabel *label = self.commentLabelsArray[i];
        if (!model.attributedContent) {
            model.attributedContent = [self generateAttributedStringWithCommentItemModel:model];
        }
        label.attributedText = model.attributedContent;
    }
}


- (void)setupWithCommentItemsArray:(NSArray *)commentItemsArray {
    
    self.commentItemsArray = commentItemsArray;
    
 
    if (self.commentLabelsArray.count) {
        [self.commentLabelsArray enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
            [label sd_clearAutoLayoutSettings];
            label.hidden = YES; //重用时先隐藏所以评论label，然后根据评论个数显示label
        }];
    }
    if (!commentItemsArray.count) {
        self.fixedWidth = @(0); // 如果没有评论或者点赞，设置commentview的固定宽度为0（设置了fixedWith的控件将不再在自动布局过程中调整宽度）
        self.fixedHeight = @(0); // 如果没有评论或者点赞，设置commentview的固定高度为0（设置了fixedHeight的控件将不再在自动布局过程中调整高度）
        return;
    } else {
        self.fixedHeight = nil; // 取消固定宽度约束
        self.fixedWidth = nil; // 取消固定高度约束
    }
    
    UIView *lastTopView = nil;
    
    for (int i = 0; i < self.commentItemsArray.count; i++) {
        UILabel *label = (UILabel *)self.commentLabelsArray[i];
        label.hidden = NO;
        CGFloat topMargin = 5;
        label.sd_layout
        .leftSpaceToView(self, 0)
        .rightSpaceToView(self, 0)
        .topSpaceToView(lastTopView, topMargin)
        .autoHeightRatio(0);
        
        label.isAttributedContent = YES;
        lastTopView = label;
    }
    [self setupAutoHeightWithBottomView:lastTopView?lastTopView:self bottomMargin:commentItemsArray.count > 0 ? 5:1];
    
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

#pragma mark - private actions

- (NSMutableAttributedString *)generateAttributedStringWithCommentItemModel:(HLHJFactCellCommentItemModel *)model
{
//    NSString *text = model.one_member_nickname.length > 0 ? model.one_member_nickname : model.one_member_name;
//    NSString *firstUserName = model.one_member_nickname.length > 0 ? model.one_member_nickname : model.one_member_name;
//
//     NSString *textTwo = model.member_nickname.length > 0 ? model.member_nickname:model.member_name;
//    NSString *secondUserName = model.member_nickname.length > 0 ? model.member_nickname:model.member_name;
//
//
//
//    if (model.member_name.length == 0) {
//        if (model.member_name.length) {
//
//            text = [text stringByAppendingString:[NSString stringWithFormat:@"回复%@",secondUserName]];
//        }
//
//        text = [text stringByAppendingString:[NSString stringWithFormat:@": %@", model.one_content.length > 0 ? model.one_content:@""]];
//
//        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text];
//
//        [attString setAttributes:@{NSLinkAttributeName : model.ID? model.ID:@""} range:[text rangeOfString:firstUserName]];
//
//        if (secondUserName) {
//
//            [attString setAttributes:@{NSLinkAttributeName : model.ID? model.ID:@""} range:[text rangeOfString:secondUserName]];
//
//        }
//        return attString;
//    }else {
//
//        if (model.member_name.length) {
//
//            textTwo = [textTwo stringByAppendingString:[NSString stringWithFormat:@"回复%@",firstUserName]];
//        }
//
//        textTwo = [textTwo stringByAppendingString:[NSString stringWithFormat:@": %@", model.content.length > 0 ? model.content:@""]];
//
//         NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:textTwo];
//
//         [attString setAttributes:@{NSLinkAttributeName : model.ID? model.ID:@""} range:[textTwo rangeOfString:firstUserName]];
//
//        if (secondUserName) {
//
//            [attString setAttributes:@{NSLinkAttributeName : model.ID? model.ID:@""} range:[textTwo rangeOfString:secondUserName]];
//
//        }
//        return attString;
//
//
//    }
//
    
    
    
    NSString *text = model.one_member_nickname.length > 0 ? model.one_member_nickname : model.one_member_name;
    NSString *firstUserName = model.one_member_nickname.length > 0 ? model.one_member_nickname : model.one_member_name;
    
    NSString *textTwo = model.member_nickname.length > 0 ? model.member_nickname:model.member_name;
    NSString *secondUserName = model.member_nickname.length > 0 ? model.member_nickname:model.member_name;
    
    
    
    if (model.member_name.length == 0) {
        if (model.member_name.length) {
            
            text = [text stringByAppendingString:[NSString stringWithFormat:@"回复%@",secondUserName]];
        }
        
        text = [text stringByAppendingString:[NSString stringWithFormat:@": %@", model.content.length > 0 ? model.content:@""]];
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text];
        
        [attString setAttributes:@{NSLinkAttributeName : model.ID? model.ID:@""} range:[text rangeOfString:firstUserName]];
        
        if (secondUserName) {
            
            [attString setAttributes:@{NSLinkAttributeName : model.ID? model.ID:@""} range:[text rangeOfString:secondUserName]];
            
        }
        return attString;
    }else {
        
        if (model.member_name.length) {
            
            textTwo = [textTwo stringByAppendingString:[NSString stringWithFormat:@"回复%@",firstUserName]];
        }
        
        textTwo = [textTwo stringByAppendingString:[NSString stringWithFormat:@": %@", model.content.length > 0 ? model.content:@""]];
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:textTwo];
        
        [attString setAttributes:@{NSLinkAttributeName : model.ID? model.ID:@""} range:[textTwo rangeOfString:firstUserName]];
        
        if (secondUserName) {
            
            [attString setAttributes:@{NSLinkAttributeName : model.ID? model.ID:@""} range:[textTwo rangeOfString:secondUserName]];
            
        }
        return attString;
        
        
    }
    
    
    

}

#pragma mark - MLLinkLabelDelegate

- (void)didClickLink:(MLLink *)link linkText:(NSString *)linkText linkLabel:(MLLinkLabel *)linkLabel
{

    if (_didClickCommentLabelBlock) {
        self.didClickCommentLabelBlock(link.linkValue);
    }
}


- (NSMutableArray *)commentLabelsArray
{
    if (!_commentLabelsArray) {
        _commentLabelsArray = [NSMutableArray new];
    }
    return _commentLabelsArray;
}

@end
