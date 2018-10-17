//
//  HLHJFactCellModel.m
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/14.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "HLHJFactCellModel.h"
#import <UIKit/UIKit.h>
#import "YYModel.h"


@implementation HLHJFactCellModel

/// YYModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"list":[HLHJListModel class],@"banner":[HLHJBannerModel class]};
}

@end



extern const CGFloat contentLabelFontSize;
extern CGFloat maxContentLabelHeight;
@implementation HLHJListModel
{
    CGFloat _lastContentWidth;
}

@synthesize content = _content;

- (void)setContent:(NSString *)content {
    _content  = content;
}
- (NSString *)content
{
    CGFloat contentW = [UIScreen mainScreen].bounds.size.width - 70;
    if (contentW != _lastContentWidth) {
        _lastContentWidth = contentW;
        CGRect textRect = [_content boundingRectWithSize:CGSizeMake(contentW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:contentLabelFontSize]} context:nil];
        if (textRect.size.height > maxContentLabelHeight) {
            _shouldShowMoreButton = YES;
        } else {
            _shouldShowMoreButton = NO;
        }
    }

    return _content;
}

- (void)setIsOpening:(BOOL)isOpening
{
    if (!_shouldShowMoreButton) {
        _isOpening = NO;
    } else {
        _isOpening = isOpening;
    }
}
/// YYModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"comment" : [HLHJFactCellCommentItemModel class]};
}
+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{@"ID" :@"id"};
}

@end

@implementation HLHJFactCellCommentItemModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"ID" :@"id"};
}
@end

@implementation HLHJBannerModel

@end


