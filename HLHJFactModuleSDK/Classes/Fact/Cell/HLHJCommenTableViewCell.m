//
//  HLHJCommenTableViewCell.m
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/18.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "HLHJCommenTableViewCell.h"
#import "UIImageView+WebCache.h"
@implementation HLHJCommenTableViewCell
{
    UIImageView *_iconView;///头像
    UILabel *_nameLable;///昵称
    UILabel *_timeLabel;///时间
    UILabel *_contentLabel;///内容
    UILabel *_commentLabel;///回复内容
    
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setup];
         self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
- (void)setup {
    
    _iconView = [[UIImageView alloc]init];
    _nameLable = [UILabel new];
    _nameLable.font = [UIFont systemFontOfSize:15];
    _nameLable.textColor = [UIColor colorWithRed:51/255 green:51/255 blue:51/255 alpha:1];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:11];
    _timeLabel.textColor = [UIColor colorWithRed:102/255 green:102/255 blue:102/255 alpha:1];
    
    _contentLabel = [UILabel new];
    _contentLabel.font = [UIFont systemFontOfSize:14];
    _contentLabel.textColor = [UIColor colorWithRed:51/255 green:51/255 blue:51/255 alpha:1];
    _contentLabel.numberOfLines = 0;
    
    _commentLabel = [UILabel new];
    _commentLabel.font = [UIFont systemFontOfSize:14];
    _commentLabel.textColor = [UIColor darkTextColor];
    _commentLabel.numberOfLines = 0;
    _commentLabel.backgroundColor = [UIColor whiteColor];
    _commentLabel.layer.masksToBounds = YES;
    _commentLabel.layer.cornerRadius = 5;
    _commentLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];

    
    NSArray *views = @[_iconView, _nameLable,_timeLabel, _contentLabel,_commentLabel];
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
    
    _commentLabel.sd_layout
    .leftEqualToView(_nameLable)
    .topSpaceToView(_contentLabel, margin)
    .rightSpaceToView(contentView, margin)
    .autoHeightRatio(0);
    
    
}
- (void)setModel:(CommentModel *)model {
    
    _model = model;
    if (_model.head_pic.length > 0) {
        NSString *url = @"";
        if ([_model.head_pic containsString:@"://"]) {
            url = _model.head_pic;
        }else {
            url = [NSString stringWithFormat:@"%@%@",BASE_URL,_model.head_pic];
        }
        url = [url stringByReplacingOccurrencesOfString:@"\\" withString:@"//"];
        [_iconView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"imgBundle.bundle/ic_bl_touxiang"]];
    }else {
        _iconView.image = [UIImage imageNamed:@"imgBundle.bundle/ic_bl_touxiang"];
    }
        
    
     _nameLable.text = model.member_nickname.length > 0 ? model.member_nickname:model.member_name;
    
     _contentLabel.text = model.content;
    

     _timeLabel.text =[self compareCurrentTime:[self cStringFromTimestamp:model.create_at]];
 
    
      p_commentModel *pmodel = model.p_comment;
    
    NSString *secName = pmodel.user_nickname;
    
    if (secName.length == 0 && pmodel.content.length == 0) {
        _commentLabel.text = @"";
    }else {
        NSString *content = [NSString stringWithFormat:@"   @%@:%@",secName.length == 0 ? @"":secName,pmodel.content];
        
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:content];
        
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:108/255 green:184.1/255 blue:255/255 alpha:1] range:NSMakeRange(0, secName.length + 4)];
        
         _commentLabel.attributedText = attString;
    }
    [self setupAutoHeightWithBottomView:_commentLabel bottomMargin:10];
  
}

- (void)setCommenModel:(HLHJListModel *)commenModel {
    
       _commenModel = commenModel;
        if (_commenModel.head_pic.length > 0) {
               NSString *url = @"";
            if ([_commenModel.head_pic containsString:@"://"]) {
                url = _commenModel.head_pic;
            }else {
                url = [NSString stringWithFormat:@"%@%@",BASE_URL,_commenModel.head_pic];
            }
            url = [url stringByReplacingOccurrencesOfString:@"\\" withString:@"//"];
            [_iconView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"imgBundle.bundle/ic_bl_touxiang"]];
        }else {
            _iconView.image = [UIImage imageNamed:@"imgBundle.bundle/ic_bl_touxiang"];
        }
        _nameLable.text = _commenModel.member_nickname.length > 0 ? _commenModel.member_nickname:_commenModel.member_name;
    
        _contentLabel.text = _commenModel.content;
  
        _timeLabel.text =[self compareCurrentTime:[self cStringFromTimestamp:_commenModel.create_at]];
    
        _commentLabel.text = @"";
    
        [self setupAutoHeightWithBottomView:_commentLabel bottomMargin:0];
}

//- (void)setCommenModel:(HLHJCommenModel *)commenModel {
//
//    _commenModel = commenModel;
//    if (_commenModel.head_pic.length > 0) {
//           NSString *url = @"";
//        if ([_commenModel.head_pic containsString:@"://"]) {
//            url = _commenModel.head_pic;
//        }else {
//            url = [NSString stringWithFormat:@"%@%@",BASE_URL,_commenModel.head_pic];
//        }
//        url = [url stringByReplacingOccurrencesOfString:@"\\" withString:@"//"];
//        [_iconView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"imgBundle.bundle/ic_bl_touxiang"]];
//    }else {
//        _iconView.image = [UIImage imageNamed:@"imgBundle.bundle/ic_bl_touxiang"];
//    }
//    _nameLable.text = _commenModel.member_nickname.length > 0 ? _commenModel.member_nickname:_commenModel.member_name;
//
//    _contentLabel.text = _commenModel.content;
//
//    NSLog(@"---%@",_model.create_at);
//    _timeLabel.text =[self compareCurrentTime:[self cStringFromTimestamp:_commenModel.create_at]];
//
//    _commentLabel.text = @"";
//
//    [self setupAutoHeightWithBottomView:_commentLabel bottomMargin:0];
//}
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
}

@end
