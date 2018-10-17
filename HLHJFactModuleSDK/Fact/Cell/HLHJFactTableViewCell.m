//
//  HLHJFactTableViewCell.m
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/14.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "HLHJFactTableViewCell.h"

#import "HLHJFactCellModel.h"

#import "UIView+SDAutoLayout.h"
#import "HLHJFactCommentView.h"


#import "UIImageView+WebCache.h"


const CGFloat contentLabelFontSize = 14;
CGFloat maxContentLabelHeight = 0; // 根据具体font而定

@implementation HLHJFactTableViewCell
{
    UIImageView *_iconView;///头像
    UILabel *_timeLabel;///时间
    UILabel *_nameLable;///昵称
    UILabel *_contentLabel;///内容
    UIButton *_moreButton;///更多
    UIButton *_giveLikeButton;///点赞
    UIButton *_seeMoreOperaBtn;///查看更多评论
    UIButton *_operationButton;///评论按钮
    UIButton *_shareButton;///分享按钮
    HLHJFactCommentView *_commentView;///评论视图
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setup];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
- (void)setup
{
    
    _iconView = [[UIImageView alloc]init];
    
    _nameLable = [UILabel new];
    _nameLable.font = [UIFont systemFontOfSize:15];
    _nameLable.textColor = [UIColor colorWithRed:51/255 green:51/255 blue:51/255 alpha:1];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:11];
    _timeLabel.textColor = [UIColor colorWithRed:102/255 green:102/255 blue:102/255 alpha:1];
    
    
    _contentLabel = [UILabel new];
    _contentLabel.font = [UIFont systemFontOfSize:contentLabelFontSize];
    _contentLabel.textColor = [UIColor colorWithRed:51/255 green:51/255 blue:51/255 alpha:1];
    _contentLabel.numberOfLines = 0;
    if (maxContentLabelHeight == 0) {
        maxContentLabelHeight = _contentLabel.font.lineHeight * 3;
    }
    
    _picContainerView = [HLHJFactPhotoContainerView new];
    
    
    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreButton setTitle:@"全文" forState:UIControlStateNormal];
    [_moreButton setTitleColor: [UIColor colorWithRed:108/255 green:184.1/255 blue:255/255 alpha:1] forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(moreButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _moreButton.titleLabel.font = [UIFont systemFontOfSize:14];
    
    _operationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_operationButton setImage:[UIImage imageNamed:@"imgBundle.bundle/ic_bl_pinglun"] forState:UIControlStateNormal];
    [_operationButton addTarget:self action:@selector(operationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareButton setImage:[UIImage imageNamed:@"imgBundle.bundle/ic_bl_fengxiang"] forState:UIControlStateNormal];
    [_shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _giveLikeButton = [UIButton new];
    [_giveLikeButton setImage:[UIImage imageNamed:@"imgBundle.bundle/ic_bl_dianzan"] forState:UIControlStateNormal];
    [_giveLikeButton setImage:[UIImage imageNamed:@"imgBundle.bundle/ic_bl_dianzan1"] forState:UIControlStateSelected];
    [_giveLikeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_giveLikeButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    _giveLikeButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_giveLikeButton addTarget:self action:@selector(giveLikeButtonButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _giveLikeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    
    _seeMoreOperaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _seeMoreOperaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_seeMoreOperaBtn setTitle:@"查看全部评论" forState:UIControlStateNormal];
    [_seeMoreOperaBtn setTitleColor: [UIColor colorWithRed:108/255 green:184.1/255 blue:255/255 alpha:1] forState:UIControlStateNormal];
    [_seeMoreOperaBtn addTarget:self action:@selector(seemMoreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _seeMoreOperaBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    _seeMoreOperaBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    _commentView = [HLHJFactCommentView new];
    
    
    NSArray *views = @[_iconView, _nameLable,_timeLabel, _contentLabel, _moreButton, _picContainerView,_giveLikeButton, _seeMoreOperaBtn,_operationButton,_shareButton, _commentView];
    
    [self.contentView sd_addSubviews:views];
    
    UIView *contentView = self.contentView;
    CGFloat margin = 5;
    
    _iconView.sd_layout
    .leftSpaceToView(contentView, margin)
    .topSpaceToView(contentView, margin + 5)
    .widthIs(40)
    .heightIs(40);
    _iconView.layer.cornerRadius = 20;
    _iconView.clipsToBounds = YES;
    
    _nameLable.sd_layout
    .leftSpaceToView(_iconView, margin)
    .topEqualToView(_iconView)
    .heightIs(18);
    [_nameLable setSingleLineAutoResizeWithMaxWidth:200];
    
    
    _timeLabel.sd_layout
    .leftEqualToView(_nameLable)
    .topSpaceToView(_nameLable, margin)
    .heightIs(15)
    .widthIs(200);
    
    _contentLabel.sd_layout
    .leftEqualToView(_nameLable)
    .topSpaceToView(_timeLabel, margin)
    .rightSpaceToView(contentView, margin)
    .autoHeightRatio(0);
    
    // morebutton的高度在setmodel里面设置
    _moreButton.sd_layout
    .leftEqualToView(_contentLabel)
    .topSpaceToView(_contentLabel, margin)
    .widthIs(30);
    
    _picContainerView.sd_layout
    .leftEqualToView(_contentLabel);
    // 已经在内部实现宽度和高度自适应所以不需要再设置宽度高度，top值是具体有无图片在setModel方法中设置
    
    
    
    _giveLikeButton.sd_layout
    .leftEqualToView(_contentLabel)
    .topSpaceToView(_picContainerView, margin)
    .heightIs(25);
    
    _operationButton.sd_layout
    .rightSpaceToView(contentView, margin)
    .centerYEqualToView(_giveLikeButton)
    .heightIs(25)
    .widthIs(25);
    
    _shareButton.sd_layout
    .rightSpaceToView(_operationButton, margin)
    .centerYEqualToView(_giveLikeButton)
    .heightIs(25)
    .widthIs(25);
    
    _seeMoreOperaBtn.sd_layout
    .topSpaceToView(_giveLikeButton, margin)
    .leftEqualToView(_contentLabel)
    .widthIs(100);
    //    .heightIs(20);
    
    _commentView.sd_layout
    .leftEqualToView(_contentLabel)
    .rightSpaceToView(self.contentView, margin)
    .topSpaceToView(_seeMoreOperaBtn, 0); // 已经在内部实现高度自适应所以不需要再设置高度
}

- (void)setModel:(HLHJListModel *)model
{
    _model = model;

    ///页面上只展示3条
    if (model.comment.count > 3) {
        NSArray *smallArray = [model.comment subarrayWithRange:NSMakeRange(0, 3)];
        [_commentView setupWithCommentItemsArray:smallArray];
    }else {
        [_commentView setupWithCommentItemsArray:model.comment];
    }
    ///如果评论大于3条显示查看更多按钮
    if (model.comment.count > 3) {
        _seeMoreOperaBtn.sd_layout.heightIs(20);
        _seeMoreOperaBtn.hidden = NO;
    }else {
        _seeMoreOperaBtn.sd_layout.heightIs(0);
        _seeMoreOperaBtn.hidden = YES;
    }
    
    //头像
    if (model.head_pic.length > 0) {
        NSString *url = model.head_pic;
        if (![url containsString:@"://"]) {
            url = [NSString stringWithFormat:@"%@%@",BASE_URL,url];
        }
         url = [url stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
        [_iconView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"imgBundle.bundle/ic_bl_touxiang"]];
        
    }else {
        _iconView.image = [UIImage imageNamed:@"imgBundle.bundle/ic_bl_touxiang"];
    }
    //点赞数量
   [_giveLikeButton setTitle:[NSString stringWithFormat:@" %ld",(long)model.laud_num] forState:UIControlStateNormal];
    ///是否点赞
    _giveLikeButton.selected = model.is_laud ==  0  ? NO: YES;
    //昵称
    _nameLable.text = model.member_nickname.length > 0 ? model.member_nickname:model.member_name;
    //发布的内容
    _contentLabel.text = model.content;
    //发布的时间
    _timeLabel.text =[self compareCurrentTime:[self cStringFromTimestamp:model.create_at ]];
    
    // 如果文字高度超过60
    if (model.shouldShowMoreButton) {
        _moreButton.sd_layout.heightIs(20);
        _moreButton.hidden = NO;
        if (model.isOpening) { // 如果需要展开
            _contentLabel.sd_layout.maxHeightIs(MAXFLOAT);
            [_moreButton setTitle:@"收起" forState:UIControlStateNormal];
        } else {
            _contentLabel.sd_layout.maxHeightIs(maxContentLabelHeight);
            [_moreButton setTitle:@"全文" forState:UIControlStateNormal];
        }
    } else {
        _moreButton.sd_layout.heightIs(0);
        _moreButton.hidden = YES;
    }
    
    
    CGFloat picContainerTopMargin = 0;
    if (model.source.count) {
        picContainerTopMargin = 5;
    }
    __weak typeof(self) weakSelf = self;
    [_picContainerView picPathStringsArray:model.source type:model.source_type andVidoImage:model.video_thumb];
     _picContainerView.clickPlayActionBlock = ^(BOOL isPlay ,CGRect rect) {
         if ([weakSelf.delegate respondsToSelector:@selector(zf_playTheVideoAtIndexPath:)]) {
             [weakSelf.delegate zf_playTheVideoAtIndexPath:weakSelf.indexPath];
         }
    };
    _picContainerView.sd_layout.topSpaceToView(_moreButton, picContainerTopMargin);
    
    _commentView.didClickCommentLabelBlock = ^(NSString *commentId) {
        if(weakSelf.delegate && [_delegate respondsToSelector:@selector(didClickcCommentLabelInCell:commentId:)]){
            [weakSelf.delegate didClickcCommentLabelInCell:weakSelf.indexPath commentId:commentId];
        }
    };
    
   UIView *bottomView;
    if (model.comment.count == 0) {
        bottomView = _giveLikeButton;
    }else {
        bottomView  = _commentView;
    }
    [self setupAutoHeightWithBottomView:bottomView bottomMargin:5];
}

#pragma mark - private actions

- (void)moreButtonClicked
{
    if (self.moreButtonClickedBlock) {
        self.moreButtonClickedBlock(self.indexPath);
    }
}
- (void)seemMoreButtonClicked:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSeeMoreButtoInCell:)]) {
        [self.delegate didClickSeeMoreButtoInCell:_indexPath];
    }
}
- (void)operationButtonClicked:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickcCommentButtonInCell:)]) {
        [self.delegate didClickcCommentButtonInCell:_indexPath];
    }
}
- (void)shareButtonClicked:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickShareButtoInCell:)]) {
        [self.delegate didClickShareButtoInCell:_indexPath];
    }
}
- (void)giveLikeButtonButtonClicked:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickLikeButtonInCell:)]) {
        [self.delegate didClickLikeButtonInCell:_indexPath];
    }
}
- (void)setDelegate:(id<HLHJFactTableViewCellDelegate>)delegate withIndexPath:(NSIndexPath *)indexPath {
    self.delegate = delegate;
    self.indexPath = indexPath;
}
//、时间戳——字符串时间
- (NSString *)cStringFromTimestamp:(NSString *)timestamp{
    //时间戳转时间的方法
    NSDate *timeData = [NSDate dateWithTimeIntervalSince1970:[timestamp intValue]];
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strTime = [dateFormatter stringFromDate:timeData];
    return strTime;
}

//// yyyy-MM-dd HH:mm:ss.SSS
- (NSString *) compareCurrentTime:(NSString *)str
{
    //把字符串转为NSdate
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *timeDate = [dateFormatter dateFromString:str];
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:timeDate];
    long temp = 0;
    NSString *result;
    if (timeInterval/60 < 1)
    {
        result = [NSString stringWithFormat:@"刚刚"];
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%ld分钟前",temp];
    }
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%ld小时前",temp];
    }
    else if((temp = temp/24) <30){
        result = [NSString stringWithFormat:@"%ld天前",temp];
    }
    else if((temp = temp/30) <12){
        result = [NSString stringWithFormat:@"%ld月前",temp];
    }
    else{
        temp = temp/12;
        result = [NSString stringWithFormat:@"%ld年前",temp];
    }
    return  result;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
