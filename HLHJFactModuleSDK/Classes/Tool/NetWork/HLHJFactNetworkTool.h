//
//  HLHJFactNetworkTool.h
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/11.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"

@interface HLHJFactNetworkTool : NSObject

typedef NS_ENUM(NSInteger, requestType) {
    GET = 1,
    POST = 2,
};

+ (AFHTTPSessionManager *_Nonnull)shareInstance;

/**
 普通请求

 @param type 请求类型
 @param url 请求链接
 @param parameter 请求参数
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)hlhjRequestWithType:(requestType )type
                 requestUrl:(NSString *_Nonnull)url
                  parameter:(NSDictionary *_Nullable)parameter
            successComplete:(void(^_Nullable)(id _Nullable responseObject))success
            failureComplete:(void(^_Nonnull)(NSError * _Nonnull error))failure;

/**
 *  上传图片(多张)
 *
 *  @param path    路径
 *  @param photos  图片数组(data)
 *  @param params  参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
+ (void)uploadImageWithPath:(NSString *_Nullable)path photos:(NSArray *_Nullable)photos params:(NSDictionary *_Nullable)params  successComplete:(void(^_Nonnull)(id _Nonnull responseObject))success failureComplete:(void(^_Nonnull)(NSError * _Nonnull error))failure;

/**
 上传视频
 
 @param path 路径
 @param photos 视频数组((data))
 @param params 参数
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)uploadVideoWithPath:(NSString *_Nullable)path videos:(NSArray *_Nullable)videos params:(NSDictionary *_Nullable)params successComplete:(void(^_Nonnull)(id _Nonnull responseObject))success failureComplete:(void(^_Nonnull)(NSError * _Nonnull error))failure;

@end

