//
//  HLHJCommenModel.m
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/18.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "HLHJCommenModel.h"

@implementation HLHJCommenModel
/// YYModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"comment":[CommentModel class]};
}
@end

@implementation CommentModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"p_comment" : [p_commentModel class]};
}
@end

@implementation p_commentModel

@end


