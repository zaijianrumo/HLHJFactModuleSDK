//
//  HLHJFactStartViewController.m
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/15.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "HLHJFactStartViewController.h"

#import "HLHJFactStartHeaderView.h"
#import "UIView+SDAutoLayout.h"
#import "HLHJFactStartFooterView.h"

#import "HLHJFactNetworkTool.h"
#import <TMSDK/TMHttpUser.h>
#import <TMSDK/TMHttpUserInstance.h>
#import "HDManager.h"

@interface HLHJFactStartViewController ()


@property (nonatomic, strong) UITableView  *hlhjTableView;

@property (nonatomic, strong) NSMutableArray  *dataArr;

@property (nonatomic, strong) HLHJFactStartHeaderView *headerView;
@end

@implementation HLHJFactStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.edgesForExtendedLayout = UIRectEdgeNone;;
    self.navigationItem.title = @"我要爆料";
    _dataArr = [NSMutableArray array];
    [self.view addSubview:self.hlhjTableView];
    self.hlhjTableView.tableFooterView = [UIView new];
    
    
    self.hlhjTableView.sd_layout
    .rightEqualToView(self.view)
    .topEqualToView(self.view)
    .bottomEqualToView(self.view)
    .leftEqualToView(self.view);
    
    _headerView = [[HLHJFactStartHeaderView alloc]initWithFrame:CGRectZero];
    self.hlhjTableView.tableHeaderView = _headerView;
    _headerView.sd_layout
    .topEqualToView(self.hlhjTableView)
    .leftEqualToView(self.hlhjTableView)
    .rightEqualToView(self.hlhjTableView)
    .heightIs(260);
    
    
    HLHJFactStartFooterView  *footerView = [[HLHJFactStartFooterView alloc]initWithFrame:CGRectZero];
    self.hlhjTableView.tableFooterView = footerView;
    footerView.sd_layout
    .topEqualToView(self.hlhjTableView)
    .leftEqualToView(self.hlhjTableView)
    .rightEqualToView(self.hlhjTableView)
    .heightIs(400);
    
     footerView.uploadBlock = ^(id dataSource,NSInteger type ,id url) {
        if (_headerView.contentView.text.length == 0) {
            [self.view makeToast:@"请输入爆料内容"];
            return ;
        }
        NSInteger source_type = [(NSArray *)dataSource count] > 0 ? type : 0;
          ///1.没有资源  不用上传图片
        if (source_type == 0) {
            
            NSDictionary *prama  = @{@"token":[TMHttpUser token].length > 0 ? [TMHttpUser token]:@"",
                                     @"content":_headerView.contentView.text,
                                     @"source_type":@(source_type),
                                     };
            [HLHJFactNetworkTool hlhjRequestWithType:GET requestUrl:@"/hlhjburst/api/report" parameter:prama successComplete:^(id  _Nullable responseObject) {
                
                ///判断是否登陆
                BOOL success = [self responseObject:responseObject];
                
                if (!success) {
                    return ;
                }
                
                [self.view makeToast:responseObject[@"msg"]];
                if ([responseObject[@"code"]integerValue] == 1) {
                    _headerView.contentView.text = @"";
                    [self.view makeToast:@"爆料成功"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                }else {
                    [self.view makeToast:@"爆料失败"];
                }
            } failureComplete:^(NSError * _Nonnull error) {
                [self.view makeToast:@"爆料失败"];
            }];
            
        ///2.图片资源.上传图片
        }else if(source_type == 1){
            
            [self uploadImg:dataSource source_type:source_type video_thumb:@""];
            
        ///3.视频资源.上传视频
     }else if(source_type == 2){
         
         [_dataArr removeAllObjects];
         [_dataArr addObject:url];
         ///NOTE1.获取七牛token
          [HDManager startLoading];
         [HLHJFactNetworkTool hlhjRequestWithType:GET requestUrl:@"/hlhjburst/api/qiniu" parameter:@{@"token":[TMHttpUser token].length > 0 ? [TMHttpUser token]:@""} successComplete:^(id  _Nullable responseObject) {
             
     
             BOOL success = [self responseObject:responseObject];
             if (!success) {
                 return ;
             }
            NSString *cdn = responseObject[@"data"][@"cdn"];
               ///NOTE2.
             [HLHJFactNetworkTool uploadVideoWithPath:responseObject[@"data"][@"url"] videos:_dataArr params:@{@"token":responseObject[@"data"][@"token"]} successComplete:^(id  _Nonnull responseObject) {
                 
              
                 NSString *key = responseObject[@"key"];
                 NSString *source = [NSString stringWithFormat:@"%@/%@",cdn,key];
                 
                 [_dataArr removeAllObjects];
                 for (UIImage *image in dataSource) {
                     NSData *imageData = UIImagePNGRepresentation(image);
                     [_dataArr addObject:imageData];
                 }
                 ///NOTE3.上传视频封面
                 [HLHJFactNetworkTool uploadImageWithPath:@"/hlhjburst/api/upload" photos:_dataArr params:nil successComplete:^(id  _Nonnull responseObject) {
                     
                     BOOL success = [self responseObject:responseObject];
                     if (!success) {
                         return ;
                     }
                     NSMutableArray *sourceArr = [NSMutableArray array];
                     NSArray *arr = responseObject[@"data"];
                     for (NSDictionary *dict in arr) {
                         [sourceArr addObject:dict[@"save_path"]];
                     }
                     NSString *string = [sourceArr componentsJoinedByString:@","];
                     NSDictionary * prama  = @{       @"token":[TMHttpUser token].length > 0 ? [TMHttpUser token]:@"",
                                                      @"content":_headerView.contentView.text,
                                                      @"source_type":@(source_type),
                                                      @"source":source,
                                                      @"video_thumb":string
                                                      };
                     ////NOTE4.提交
                     [HLHJFactNetworkTool hlhjRequestWithType:GET requestUrl:@"/hlhjburst/api/report" parameter:prama successComplete:^(id  _Nullable responseObject) {
                         NSLog(@"--4-%@",responseObject);
                           [HDManager stopLoading];
                         BOOL success = [self responseObject:responseObject];
                         if (!success) {
                             return ;
                         }
                         if ([responseObject[@"code"]integerValue] == 1) {
                             _headerView.contentView.text = @"";
                              [self.view makeToast:@"上传成功"];
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                 [self.navigationController popViewControllerAnimated:YES];
                             });
                         }else {
                              [self.view makeToast:@"上传失败"];
                         }
                     } failureComplete:^(NSError * _Nonnull error) {
                         
                          [HDManager stopLoading];
                         [self.view makeToast:@"上传失败,请稍后再试"];
                     }];
                 } failureComplete:^(NSError * _Nonnull error) {
                     
                      [HDManager stopLoading];
                    [self.view makeToast:@"上传失败,请稍后再试"];
                 }];
             } failureComplete:^(NSError * _Nonnull error) {
                 
                  [HDManager stopLoading];
                  [self.view makeToast:@"上传失败,请稍后再试"];
             }];
         } failureComplete:^(NSError * _Nonnull error) {
             
              [HDManager stopLoading];
              [self.view makeToast:@"上传失败,请稍后再试"];
         }];
     }
    };

}
///上传图片
- (void)uploadImg:(id)dataSource source_type:(NSInteger)source_type video_thumb:(NSString *)video_thumb {
    [_dataArr removeAllObjects];
    for (UIImage *image in dataSource) {
        UIImage *fixImage = [self fixOrientation:image];
        NSData *imageData = UIImagePNGRepresentation(fixImage);
        [_dataArr addObject:imageData];
    }
    [HDManager startLoading];
    [HLHJFactNetworkTool uploadImageWithPath:@"/hlhjburst/api/upload" photos:_dataArr params:nil successComplete:^(id  _Nonnull responseObject) {
        
        BOOL success = [self responseObject:responseObject];
        if (!success) {
            return ;
        }
        NSMutableArray *sourceArr = [NSMutableArray array];
        NSArray *arr = responseObject[@"data"];
        for (NSDictionary *dict in arr) {
            [sourceArr addObject:dict[@"save_path"]];
        }
        NSString *string = [sourceArr componentsJoinedByString:@","];
        NSDictionary * prama  = @{       @"token":[TMHttpUser token].length > 0 ? [TMHttpUser token]:@"",
                                          @"content":_headerView.contentView.text,
                                          @"source_type":@(source_type),
                                          @"source": source_type == 1 ? string:video_thumb,
                                          @"video_thumb":source_type == 1 ? video_thumb:string
                                          };
        [HLHJFactNetworkTool hlhjRequestWithType:GET requestUrl:@"/hlhjburst/api/report" parameter:prama successComplete:^(id  _Nullable responseObject) {
             [HDManager stopLoading];
            BOOL success = [self responseObject:responseObject];
            if (!success) {
                return ;
            }
            [self.view makeToast:responseObject[@"msg"]];
            if ([responseObject[@"code"]integerValue] == 1) {
                _headerView.contentView.text = @"";
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        } failureComplete:^(NSError * _Nonnull error) {
             [HDManager stopLoading];
        }];
    } failureComplete:^(NSError * _Nonnull error) {
         [HDManager stopLoading];
    }];
    
}
- (BOOL)responseObject:(NSDictionary *)dict {
   
    if ([dict[@"code"] integerValue] == 500 || [dict[@"code"] integerValue] == 100) {
         [HDManager stopLoading];
        UIAlertController *alert = [HLHJFactAlertTool createAlertWithTitle:@"提示" message:@"请先登陆" preferred:UIAlertControllerStyleAlert confirmHandler:^(UIAlertAction *confirmAction) {
            SetI001LoginViewController *ctr = [SetI001LoginViewController new];
            ctr.edgesForExtendedLayout  = UIRectEdgeNone;
            [self.navigationController pushViewController:ctr animated:YES];
        } cancleHandler:^(UIAlertAction *cancleAction) {
            
        }];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    return YES;
    
}

- (UITableView *)hlhjTableView {
    if (!_hlhjTableView) {
        _hlhjTableView =[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _hlhjTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _hlhjTableView;
    
    
}

- (UIImage *)fixOrientation:(UIImage *)srcImg {
    
    if (srcImg.imageOrientation == UIImageOrientationUp) return srcImg;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (srcImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
                                             CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                             CGImageGetColorSpace(srcImg.CGImage),
                                             CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
