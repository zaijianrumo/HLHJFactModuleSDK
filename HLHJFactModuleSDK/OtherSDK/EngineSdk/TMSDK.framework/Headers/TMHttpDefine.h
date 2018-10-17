//
//  TMHttpDefine.h
//  CordovaLib
//
//  Created by ZhouYou on 2018/1/10.
//

#ifndef TMHttpDefine_h
#define TMHttpDefine_h

typedef void(^TMHttpSuccess)(id data);
typedef void(^TMHttpFailed)(NSString *error, id data);

//#define TmHttpUrl_Base              @"http://39.107.76.66"
//******************User*********************
#define TmHttpUrl_user_login        @"/member/login/memberLogin"

#define TmHttpUrl_user_sendSMS      @"/member/member/sendMsg"

#define TmHttpUrl_user_update       @"/member/member/updateMember"

#define TmHttpUrl_user_checkPsd     @"/member/member/checkPass"

#define TmHttpUrl_user_headPic      @"/member/member/changeHeadPic"

#define TmHttpUrl_user_checkCode    @"/member/member/checkCode"

#define TmHttpUrl_user_updatePsd    @"/member/member/updatePass"

//******************User*********************

#define TmHttpUrl_config_config     @"/api/Appconf/getConfig"
//******************Config*********************


#endif /* TMHttpDefine_h */
