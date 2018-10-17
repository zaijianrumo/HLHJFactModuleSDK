//
//  HLHJFactAlertTool.m
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/18.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "HLHJFactAlertTool.h"

@implementation HLHJFactAlertTool
+(UIAlertController *)createAlertWithTitle:(NSString *)title message:(NSString *)message preferred:(UIAlertControllerStyle)preferred confirmHandler:(void (^)(UIAlertAction *))confirmHandler   cancleHandler:(void (^)(UIAlertAction *))cancleHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferred];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"登陆" style:UIAlertActionStyleDefault handler:confirmHandler];
    [alertController addAction:confirmAction];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:cancleHandler];
    [alertController addAction:cancleAction];
    return alertController;
}
@end
