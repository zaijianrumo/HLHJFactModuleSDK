//
//  HLHJCommenModel.h
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/18.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CommentModel,p_commentModel;
////更多评论详情
@interface HLHJCommenModel : NSObject

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *user_id;

@property (nonatomic, copy) NSString * member_name;

@property (nonatomic, copy) NSString * member_nickname;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *head_pic;

@property (nonatomic, strong) NSArray<CommentModel *> *comment ;

@property (nonatomic, copy) NSString *create_at;

@property (nonatomic, copy) NSString  *time_ago;


@property (nonatomic, strong) p_commentModel *p_comment;
@end

@interface CommentModel : NSObject

@property (nonatomic, copy) NSString *burst_id;

@property (nonatomic, copy) NSString *user_id;

@property (nonatomic, copy) NSString *create_at;

@property (nonatomic, copy) NSString *comment_id;

@property (nonatomic, copy) NSString * member_name;

@property (nonatomic, copy) NSString *member_nickname;

@property (nonatomic, copy) NSString *head_pic;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, strong) p_commentModel *p_comment;

@property (nonatomic, copy) NSString *time_ago;

@end
@interface p_commentModel : NSObject

@property (nonatomic, copy) NSString *user_nickname;

@property (nonatomic, copy) NSString  *content;
@property (nonatomic, copy) NSString  *user_id;
@end

