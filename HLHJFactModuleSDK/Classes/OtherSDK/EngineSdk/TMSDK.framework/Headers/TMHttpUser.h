//
//  TMHttpUser.h
//  CordovaLib
//
//  Created by ZhouYou on 2018/1/9.
//

#import <Foundation/Foundation.h>
#import "TMHttpDefine.h"
#import "TMHttpUserInstance.h"

@interface TMHttpUser : NSObject

/*
 保存登录时的返回的token
 token用于其它接口Header中
 */
+ (void)saveToken:(NSString *)token;

/*
 获取saveToken保存的token
 */
+ (NSString *)token;

/*登录
 phoneNumber        string      必填      手机号
 state              Int         必填      登录验证方式(1:验证码, 2:密码)
 siteId             String      必填      站点id
 psd                String      必填      密码/验证码
 */
+ (void)loginWithNumber:(NSString *)phoneNumber
               password:(NSString *)psd
                  state:(int)state
                 siteId:(NSString *)siteId
                success:(TMHttpSuccess)success
                 failed:(TMHttpFailed)failed;

/*发送短信验证码
 phoneNumber        string    必填    手机号码
 state              Int       必填    类型: 1: 登录 2: 密码找回 3: 修改密码 4: 原手机号验证 5: 新手机号验证
 */
+ (void)sendSMSCheck:(NSString *)phoneNumber
               state:(int)state
             success:(TMHttpSuccess)success
              failed:(TMHttpFailed)failed;

/*修改用户信息
 userCode           String  必填  会员code
 nickName           string  选填  会员昵称
 birthday           string  选填  生日
 sex                Int     选填  性别 1 男 2 女
 password           string  选填  新密码
 mobile             string  选填  新手机号
 siteCode           string  必填  站点code
 */
+ (void)updateUser:(NSString *)userCode
          nickName:(NSString *)nickName
          birthday:(NSString *)birthday
               sex:(int)sex
          password:(NSString *)password
            mobile:(NSString *)mobile
          siteCode:(NSString *)siteCode
           success:(TMHttpSuccess)success
            failed:(TMHttpFailed)failed;

/*校验密码
 userCode       String  必填  会员code
 password       String  必填  会员密码
 */
+ (void)checkPassword:(NSString *)password
             userCode:(NSString *)userCode
              success:(TMHttpSuccess)success
               failed:(TMHttpFailed)failed;

/*修改用户头像
 picBase64      String  必填  头像图片数据,base64编码
 phoneNumber    String  必填  会员手机号
 */
+ (void)updateUserHeadPic:(NSString *)picBase64
                   mobile:(NSString *)phoneNumber
                  success:(TMHttpSuccess)success
                   failed:(TMHttpFailed)failed;

/*验证短信验证码
 phoneNumber        String  必填  会员手机号
 code               String  必填  输入的验证码
 */
+ (void)checkSMSCode:(NSString *)code
              mobile:(NSString *)phoneNumber
             success:(TMHttpSuccess)success
              failed:(TMHttpFailed)failed;

/*根据手机号修改密码
 mobile             String  必填  会员手机号
 password           String  必填  新密码
 siteCode           string  必填  站点code
 */
+ (void)updatePassword:(NSString *)password
                mobile:(NSString *)mobile
              siteCode:(NSString *)siteCode
               success:(TMHttpSuccess)success
                failed:(TMHttpFailed)failed;
@end
