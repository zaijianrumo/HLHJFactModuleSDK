//
//  HLHJFactNetworkTool.m
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/11.
//  Copyright © 2018年 mac. All rights reserved.
//
//
#import "HLHJFactNetworkTool.h"
#import "UIView+Toast.h"
static AFHTTPSessionManager *_manager;

@implementation HLHJFactNetworkTool

+ (AFHTTPSessionManager *)shareInstance {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [AFHTTPSessionManager manager];
    });
    return _manager;
}
+ (AFHTTPSessionManager *)sharedManager {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        _manager = [AFHTTPSessionManager manager];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript" , @"text/plain" ,@"text/html",@"application/xml",@"image/jpeg",nil];
        [_manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        _manager.requestSerializer.timeoutInterval = 10.0f;
        [_manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];

        //***************** HTTPS 设置 *****************************//
        // 设置非校验证书模式
        _manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        // 客户端是否信任非法证书
        _manager.securityPolicy.allowInvalidCertificates = YES;
        // 是否在证书域字段中验证域名
        _manager.securityPolicy.validatesDomainName = NO;
        
    });
    return _manager;
}

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
            failureComplete:(void(^_Nonnull)(NSError * _Nonnull error))failure {


      url = [NSString stringWithFormat:@"%@%@",BASE_URL,url];
//      NSLog(@"请求链接:%@ \n 请求参数:%@",url ,parameter);
    
      _manager = [self sharedManager];
        if (type == 1) { // GET 请求
            [_manager GET:url parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){

               NSInteger code = [responseObject[@"code"] integerValue];
                if (code == 1 || code == 100  || code == 500) {
                    !success ? : success(responseObject);
                }else {
                   
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){

                if (error.code == NSURLErrorCancelled)  return ;
                 NSLog(@"%@",error);
                !failure ? : failure(error);
            }];
        }else if (type == 2){ // POST 请求

            [_manager POST:url parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
                
                NSInteger code = [responseObject[@"code"] integerValue];
                if (code == 1 || code == 100  || code == 500) {
                    !success ? : success(responseObject);
                }else {
                    
                }
                NSLog(@"-----%@",responseObject);


            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){

                if (error.code == NSURLErrorCancelled)  return ;
                NSLog(@"%@",error);
                !failure ? : failure(error);
            }];
        }else {
            NSLog(@"未选择请求类型");
            return;
        }

}
/**
 *  上传图片(多张)
 *
 *  @param path    路径
 *  @param photos  图片数组(data)
 *  @param params  参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
+ (void)uploadImageWithPath:(NSString *_Nullable)path photos:(NSArray *_Nullable)photos params:(NSDictionary *_Nullable)params  successComplete:(void(^_Nonnull)(id _Nonnull responseObject))success failureComplete:(void(^_Nonnull)(NSError * _Nonnull error))failure {
 
     path = [NSString stringWithFormat:@"%@%@",BASE_URL,path];
    
    [_manager POST:path parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (int i = 0; i < photos.count; i ++) {
            
            NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
            
            formatter.dateFormat=@"yyyyMMddHHmmss";
            
            NSString *str=[formatter stringFromDate:[NSDate date]];
            
            NSString *fileName=[NSString stringWithFormat:@"%@.jpeg",str];
            
            [formData appendPartWithFileData:photos[i] name:[NSString stringWithFormat:@"upload%d",i+1] fileName:fileName mimeType:@"file"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
       
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1 || code == 100  || code == 500) {
            
            !success ? : success(responseObject);
        }else {
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (error.code == NSURLErrorCancelled)  return ;
        NSLog(@"%@",error);
        !failure ? : failure(error);
        
    }];
    
}

/**
 上传视频
 
 @param path 路径
 @param videos 视频数组((data))
 @param params 参数
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)uploadVideoWithPath:(NSString *_Nullable)path videos:(NSArray *_Nullable)videos params:(NSDictionary *_Nullable)params successComplete:(void(^_Nonnull)(id _Nonnull responseObject))success failureComplete:(void(^_Nonnull)(NSError * _Nonnull error))failure {

    [_manager POST:path parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {        
            NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
            formatter.dateFormat=@"yyyyMMddHHmmss";
            NSString *str=[formatter stringFromDate:[NSDate date]];
            NSString *fileName=[NSString stringWithFormat:@"%@.mp4",str];
            [formData appendPartWithFileData:videos[0] name:@"file" fileName:fileName mimeType:@"video/mp4"];

    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        !success ? : success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (error.code == NSURLErrorCancelled)  return ;
        NSLog(@"%@",error);
        !failure ? : failure(error);
        
    }];
    
}
@end

