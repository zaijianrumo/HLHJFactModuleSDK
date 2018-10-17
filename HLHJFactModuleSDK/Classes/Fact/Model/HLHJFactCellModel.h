//
//  HLHJFactCellModel.h
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/14.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HLHJFactCellCommentItemModel,HLHJBannerModel,HLHJListModel;

@interface HLHJFactCellModel : NSObject

@property (nonatomic, strong) NSArray<HLHJBannerModel *> *banner;

@property (nonatomic, strong) NSArray<HLHJListModel *> *list;

@end

///列表数据

@interface HLHJListModel : NSObject

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *member_name;

@property (nonatomic, copy) NSString *member_nickname;

@property (nonatomic, copy) NSString *head_pic;

@property (nonatomic, assign) NSInteger source_type;

@property (nonatomic, copy) NSString *create_at;

@property (nonatomic, assign) NSInteger laud_num;

@property (nonatomic, assign) NSInteger is_laud;

@property (nonatomic, assign, getter = isLiked) BOOL liked;

@property (nonatomic, strong) NSMutableArray<HLHJFactCellCommentItemModel *> *comment;

@property (nonatomic, strong) NSArray *source;

@property (nonatomic, assign) BOOL isOpening;
@property (nonatomic, copy) NSString *video_thumb;

@property (nonatomic, assign, readonly) BOOL shouldShowMoreButton;
@end

///评论
@interface HLHJFactCellCommentItemModel : NSObject


@property (nonatomic, copy) NSString *create_at;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *member_name;
@property (nonatomic, copy) NSString *member_nickname;


@property (nonatomic, copy) NSString  *ID;
@property (nonatomic, copy) NSString  *one_content;
@property (nonatomic, copy) NSString *one_member_name;
@property (nonatomic, copy) NSString *one_member_nickname;


@property (nonatomic, copy) NSAttributedString *attributedContent;


@end

/////轮播图
@interface HLHJBannerModel : NSObject

@property (nonatomic, copy) NSString *banner_img;

@end
