//
//  BYConstant.h
//  IBY
//
//  Created by panShiyu on 14/12/1.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#ifndef IBY_BYConstant_h
#define IBY_BYConstant_h

#define BYAPPID 935095138

#define BYEditorImageWidth 800
#define BYEditorImageHeight 600

#define BYMSG_POOR_NETWORK @"网络异常，请检查网络情况"

#define BYURL_SERVICE_PROTOCOL @"http://m.biyao.com/Static/statichtml/registxy.html"
#define BYURL_ABOUTBIYAO @"http://m.biyao.com/Static/statichtml/aboutus.html"

#define BYURL_SERVICE_SMSCODEHELPER @"http://m.biyao.com/Static/statichtml/regvcerror.html"

#define BYURL_M_DetailDesign @"http://m.biyao.com/product/show?it=biyao&designid="
#define BYAPP_SCHEMA @"biyao"

#define BYDES_EncryptionKey @"meydarin"
#define BYDES_EncryptionIV @"y3ee2h1a"

//#define BYURL_SERVICE_PROTOCOL @"http://m.biyao.com/account/registxy?f=ios&it=biyao"

#define BYURL_HOME  @"http://m.biyao.com/appindex?f=ios&it=biyao"
//#define BYURL_HOME  @"http://m.biyao.com/supplier/mini?url_param=ceshiphoto"
//#define BYURL_HOME @"http://192.168.97.69:8080/m.biyao.com/wxtest"
#define BYURL_CARTLIST @"http://m.biyao.com/shopcar/list"
#define BYURL_BOOKLIST @"http://m.biyao.com/booklist"
#define BYURL_MINE @"http://m.biyao.com/account/mine"
#define BYURL_TEST_MINE @"http://192.168.97.69:8080/m.biyao.com/account/mine"


#pragma mark - 顺手赚钱
// 网页部分
#define BYURL_BASE      @"http://m.biyao.com"
#define SSZQURL_BASE    @"http://sf.m.biyao.com"
#define SSZQURL_ERROR   @"/error.html"
#define SSZQURL_HOME    @"/share/income.html"
#define SSZQURL_WALLET  @"/share/money.html"
#define SSZQURL_RANK    @"/share/ranklist.html"
#define SSZQURL_SERVICE @"/service.html"
#define SSZQURL_SERVICE_PROTOCOL        @"/Static/statichtml/registxy.html"
#define SSZQURL_SERVICE_SMSCODEHELPER   @"/Static/statichtml/registxy.html"
#define SSZQURL_USER_SHARESFZ           @"/share/sharesfz.html"
#define SSZQURL_MINE    @"/account/mine.html"

//    NSString *urlStr = [NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_SERVICE_SMSCODEHELPER];


// 后台数据接口
#define SSZQAPI_BASE                @"http://sf-api.biyao.com"      // 必要@"http://appapi.biyao.com/"
#define SSZQAPI_BASE_LGOIN          @"http://192.168.99.60:8085"    // 99 ? 98
#define SSZQAPI_USER_CUSTOMERREGISTERSERVLET    @"/user/customer/CustomerRegisterServlet"   // @"user/customer/CustomerRegisterServlet"
#define SSZQAPI_USER_UPDATEPASSWORD @"/user/customer/UpdatePassword" // @"user/customer/UpdatePassword"

#define SSZQAPI_USER_LGOIN          @"/user/customer/login"     // @"/user/customer/login"
#define SSZQAPI_PUSH_REFRESHTOKEN   @"/user/customer/refreshtoken"  //-

// 验证
#define SSZQAPI_SMS_VERYCODE        @"user/customer/CustomerAcquireCode4App" //-
#define SSZQAPI_SMS_CHECKUSER       @"user/customer/MobilePreRegist"
#define SSZQAPI_VCODE_GETVCODE      @"vcode/getvcode"
#define SSZQAPI_VCODE_VALIDATEVCODE @"vcode/validatevcode"

// 以下未做替换
#define SSZQURL_M_DetailDesign @""
#define SSZQAPP_SCHEMA @"sszq"  // 无用






#endif
