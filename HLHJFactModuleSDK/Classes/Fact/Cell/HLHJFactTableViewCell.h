//
//  HLHJFactTableViewCell.h
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/14.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLHJFactPhotoContainerView.h"
@protocol HLHJFactTableViewCellDelegate <NSObject>

///点赞
- (void)didClickLikeButtonInCell:(NSIndexPath *)indexPath;
////评论
- (void)didClickcCommentButtonInCell:(NSIndexPath *)indexPath;
///回复某条评论
-(void)didClickcCommentLabelInCell:(NSIndexPath *)indexPath commentId:(NSString *)commentId;
///分享
-(void)didClickShareButtoInCell:(NSIndexPath *)indexPath;
///查看更多评论
-(void)didClickSeeMoreButtoInCell:(NSIndexPath *)indexPath;
/**
 @brief 视频
 */
- (void)zf_playTheVideoAtIndexPath:(NSIndexPath *)indexPath;
@end

@class HLHJFactCellModel,HLHJListModel;

@interface HLHJFactTableViewCell : UITableViewCell

@property (nonatomic, weak) id<HLHJFactTableViewCellDelegate> delegate;

@property (nonatomic, strong) HLHJFactPhotoContainerView *picContainerView;///图片

@property (nonatomic, strong) HLHJListModel *model;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) void (^moreButtonClickedBlock)(NSIndexPath *indexPath);

- (void)setDelegate:(id<HLHJFactTableViewCellDelegate>)delegate withIndexPath:(NSIndexPath *)indexPath;

@end
