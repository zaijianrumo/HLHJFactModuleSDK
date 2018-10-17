//
//  HLHJCommenTableViewCell.h
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/18.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HLHJFactCellModel.h"
#import "HLHJCommenModel.h"
@interface HLHJCommenTableViewCell : UITableViewCell

@property (nonatomic, strong) CommentModel  *model;

//@property (nonatomic, strong) HLHJCommenModel *commenModel;

@property (nonatomic, strong) HLHJListModel  * commenModel;

@end
