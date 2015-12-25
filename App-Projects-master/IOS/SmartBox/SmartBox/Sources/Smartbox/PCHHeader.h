//
//  PCHHeader.h
//  Smartbox
//
//  Created by Mesada on 15/3/1.
//  Copyright (c) 2015年 mesada. All rights reserved.
//
//bobo 代替原来的pch文件，由于原来的pch文件在新版本xcode中冲突，会使到。h文件没法跳转

#ifndef Smartbox_PCHHeader_h
#define Smartbox_PCHHeader_h

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
//用于控制测试代码
#define debugbobo 1
//测试环境控制
#define test 1

#define VERSION_NO		@"V1.0.0"
#define VERSION_CHECKNO @"1.0.0"//@"3.5.2"
#define VERSION_UINT	65536//132096//196608  //格式如:1.0.0 (16进制10000的十进制值为:65536)

#define HttpNetworkTimeout		20.0
#define TcpNetworkTimeout		20.0
#define TcpLoginTimeout			12.0
#define TcpShortTimeOut			12.0


#define DefaultDeviceToken           @"04cf34c6dd72b3d43c63d976c5c1f6373ae47005cae87bb7cc3d2057d7a85378"

//#define DefaultDeviceToken           @"ba896b2636ad8ec5560b91a4a244a2a6"
//-------------------------------test服务器
#ifdef test
#define BusiServerIp				@"218.17.152.243"
#define FileServPrefix				@"http://testfileservice.365car.com.cn:88/"
///////////////////////http
#define AppBaseURLString @"http://testtsi.365car.com.cn:60080/"//@"http://port.365car.com.cn/";
#define AppBasePortURLString  @"http://192.168.7.101:81/"

#else
//-------------------------------商用环境
#define BusiServerIp				@"conn.365car.com.cn"
#define FileServPrefix				@"http://fileservice.365car.com.cn:88/"
///////////////////////http
#define AppBaseURLString @"http://tsi.365car.com.cn/"
#define AppBasePortURLString @"http://port.365car.com.cn/"
#endif





///////////////////////http
#define   OBDTokenKey @"3dd985b5a9af6e86c7d412aaad987a0585a2589ee9fbd3cd877e4de120f910c1f364067c4091ffb28b343f6274a4306e"
#define   thirdserTokenKey @"dasdfsdfsadfsadfsadfsdfaaaaaaaafjljalksdjfjsadfjl8kasdjfajsdlkfjw2rj3j45rjsdlfjlasdjfsdaf325234234234234dasdfsdfsadfsadfsadfssfsfsdfadfjl"

//WEB接口会话密钥  签名算法方式一
#define   kTokenKey @"2010web4SonlineASDFSFWEFASDFAs"
//签名算法方式二
#define   CTokenKey @"2013tsicheyoubangandroidprojecta"
//smartbox
#define   UTILSAPI @"tsi/api/httpUtilsApi/commonPost"
//查询爱车
#define   kQueryCarURL   @"tsi/api/queryCarLastTrackInfo"
#define FileMiddleUri @"fileService/web4s/photo/userPhoto/normal/"


//#define BusiServerIp @"conn.365car.com.cn"


/*通知名称*/
#define  LoginSuccessed_Notification                 @"LoginSuccessed"



#define screenHeight [[UIScreen mainScreen] bounds].size.height //屏幕高度
#define screenWidth [[UIScreen mainScreen] bounds].size.width  //屏幕宽度

#endif


#endif
