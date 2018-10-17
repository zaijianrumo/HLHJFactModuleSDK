
//
//  HLHJMoreViewController.h
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/18.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TMSDK/TMSDK.h>
#import "HLHJFactCellModel.h"
@interface HLHJMoreViewController : TMViewController

@property (nonatomic, strong) HLHJListModel  *model;

@property (nonatomic, copy) NSString  *burst_id;

@end
