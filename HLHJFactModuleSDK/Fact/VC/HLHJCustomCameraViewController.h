//
//  HLHJCustomCameraViewController.h
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/15.
//  Copyright © 2018年 mac. All rights reserved.
//



///录制视频及拍照分辨率
typedef NS_ENUM(NSUInteger, HLHJCaptureSessionPreset) {
    HLHJCaptureSessionPreset325x288,
    HLHJCaptureSessionPreset640x480,
    HLHJCaptureSessionPreset1280x720,
    HLHJCaptureSessionPreset1920x1080,
    HLHJCaptureSessionPreset3840x2160,
};
///导出视频类型
typedef NS_ENUM(NSUInteger, HLHJExportVideoType) {
    //default
    HLHJExportVideoTypeMov,
    HLHJExportVideoTypeMp4,
};
#import <UIKit/UIKit.h>

@interface HLHJCustomCameraViewController : UIViewController


@property (nonatomic, assign) CFTimeInterval maxRecordTime;

///是否允许拍照
@property (nonatomic, assign) BOOL allowTakePhoto;
///是否允许录制视频
@property (nonatomic, assign) BOOL allowRecordVideo;

///最大录制时长
@property (nonatomic, assign) NSInteger maxRecordDuration;

@property (nonatomic, assign) HLHJCaptureSessionPreset sessionPreset;

@property (nonatomic, assign) HLHJExportVideoType videoType;

///录制视频时候进度条颜色
@property (nonatomic, strong) UIColor *circleProgressColor;

/**
 确定回调，如果拍照则videoUrl为nil，如果视频则image为nil
 */
@property (nonatomic, copy) void (^doneBlock)(UIImage *image, NSURL *videoUrl);
@end
