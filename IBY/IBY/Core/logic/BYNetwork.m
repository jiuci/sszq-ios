//
//  BYNetwork.m
//  IBY
//
//  Created by coco on 14-9-10.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "BYNetwork.h"
#import "AFNetworking.h"
#import "BYError.h"
#import "BYAppCenter.h"
#import "BYUser.h"


@interface BYNetwork ()
@property (nonatomic, strong) NSMutableDictionary* managerDict;

@end

NSString* makeFingerprint(NSString* baseUrl, NSString* suffixUrl, NSDictionary* params)
{
    NSString* fprint = [NSString stringWithFormat:@"%@%@%@", baseUrl, suffixUrl, params];
    return [fprint generateMD5];
}

AFHTTPRequestOperationManager* makeNetManager(NSString* baseUrl)
{
    AFHTTPRequestOperationManager* netmanager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    [netmanager setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey]];
    if (!netmanager.requestSerializer) {
        netmanager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    [netmanager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    return netmanager;
}

NSString* baseUrlByMode(BYNetMode mode)
{
    NSArray* urls = @[
//        @"http://192.168.99.60:8085/",
        SSZQAPI_BASE_LGOIN,
        @"http://192.168.99.231:8085/",
        @"http://118.144.72.200:8085/",
//        @"http://appapi.biyao.com/"
        SSZQAPI_BASE
    ];
    return urls[mode];
}

@implementation BYNetwork

+ (instancetype)sharedNetwork
{
    static BYNetwork* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _currentMode = BYNetModeOnline;
//        _currentMode = BYNetModePreview;
//        _currentMode = BYNetModeDev;
    }
    return self;
}

- (AFHTTPRequestOperationManager*)currentNetManager
{
    NSString* baseUrl = baseUrlByMode(_currentMode);

    AFHTTPRequestOperationManager* manager = self.managerDict[baseUrl];
    if (!manager) {
        manager = makeNetManager(baseUrl);
        self.managerDict[baseUrl] = manager;
    }
    return manager;
}

+ (void)switchToMode:(BYNetMode)mode
{
    [BYNetwork sharedNetwork].currentMode = mode;
}

- (NSMutableDictionary*)managerDict
{
    if (!_managerDict) {
        _managerDict = [[NSMutableDictionary alloc] init];
    }
    return _managerDict;
}

- (void)setCurrentMode:(BYNetMode)currentMode
{
    _currentMode = currentMode;

    NSString* baseUrl = baseUrlByMode(currentMode);

    if (!baseUrl) {
        return;
    }

    if (!self.managerDict[baseUrl]) {
        self.managerDict[baseUrl] = makeNetManager(baseUrl);
    }
}

- (NSString*)currentBaseUrl
{
    return baseUrlByMode(_currentMode);
}

+ (void)get:(NSString*)url params:(NSDictionary*)params finish:(void (^)(NSDictionary* data, BYError* error))finish
{
    [BYNetwork get:url params:params isCacheValid:NO finish:finish];
}

+ (void)post:(NSString*)url params:(NSDictionary*)params finish:(void (^)(NSDictionary* data, BYError* error))finish
{
    [BYNetwork post:url params:params isCacheValid:NO finish:finish];
}

+ (void)get:(NSString*)url
          params:(NSDictionary*)params
    isCacheValid:(BOOL)isCacheValid
          finish:(void (^)(NSDictionary* data, BYError* error))finish
{
    NSCAssert(finish, @"finish block 不能为空");

    NSString* fprint = nil;
    if (isCacheValid) {
        fprint = makeFingerprint([BYNetwork sharedNetwork].currentBaseUrl, url, params);
        NSDictionary* data = [[TMCache TemporaryCache] objectForKey:fprint];
        NSDictionary* result = data[@"data"];
        if (data && result.count > 0) {
            finish(result, nil);
            return;
        }
    }
    
    AFHTTPRequestOperationManager* curManager = [[BYNetwork sharedNetwork] currentNetManager];
    [[BYNetwork sharedNetwork] refreshHeader:curManager];

    [curManager GET:url parameters:params success:^(AFHTTPRequestOperation* operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"] && [responseObject[@"success"] intValue] == 1 ) {
            
            NSDictionary *result = responseObject[@"data"];
            if (isCacheValid && result.count > 0) {
                runOnBackgroundQueue(^{
                    [[TMCache TemporaryCache] setObject:responseObject forKey:fprint];
                });
            }
            
            finish(result,nil);
        }else {
            BYError *netErr = nil;
            if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"error"]) {
                netErr = makeTransferNetError(responseObject[@"error"]);
            }
            BYError *error = makeNetDecodeError(netErr);
            finish(nil,error);
        }
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
        finish(nil,makeNetError(error));
    }];
}

+ (void)postComplete:(NSString*)url
     params:(NSDictionary*)params
    header:(NSDictionary*)header
     finish:(void (^)(NSDictionary* data, BYError* error))finish
{
 
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    
    NSCAssert(finish, @"finish block 不能为空");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //申明返回的结果是json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //申明请求的数据是json类型
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    //如果报接受类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    //传入的参数
    //你的接口地址
    //发送请求
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BYLog(@"JSON: %@", responseObject);
       finish(responseObject,nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        BYLog(@"Error: %@", error);
         finish(nil,makeNetError(error));
    }];
    return;
    AFHTTPRequestOperationManager* curManager = makeNetManager(url);
    curManager.securityPolicy = securityPolicy;
    [[BYNetwork sharedNetwork] refreshCustomHeader:header manager:curManager];
    [curManager POST:url parameters:params success:^(AFHTTPRequestOperation* operation, id responseObject) {
      
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
        NSString * str = [[NSString alloc]initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
        BYLog(@"res -- %@",str);
       
    }];
}


+ (void)post:(NSString*)url
          params:(NSDictionary*)params
    isCacheValid:(BOOL)isCacheValid
          finish:(void (^)(NSDictionary* data, BYError* error))finish
{
    NSCAssert(finish, @"finish block 不能为空");

    NSString* fprint = nil;
    if (isCacheValid) {
        fprint = makeFingerprint([BYNetwork sharedNetwork].currentBaseUrl, url, params);
        NSDictionary* data = [[TMCache TemporaryCache] objectForKey:fprint];
        if (data && data.count > 0) {
            BYLog(@"-----------use cache");
            finish(data[@"data"], nil);
            return;
        }
    }

    AFHTTPRequestOperationManager* curManager = [[BYNetwork sharedNetwork] currentNetManager];
    [[BYNetwork sharedNetwork] refreshHeader:curManager];
    curManager.requestSerializer.timeoutInterval = 8;
    [curManager POST:url parameters:params success:^(AFHTTPRequestOperation* operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"] && [responseObject[@"success"] intValue] == 1 ) {
            
            NSDictionary *result = responseObject[@"data"];
            if (isCacheValid && result.count > 0) {
                runOnBackgroundQueue(^{
                    [[TMCache TemporaryCache] setObject:responseObject forKey:fprint];
                });
            }
            finish(result,nil);
        }else {
            BYError *netErr = nil;
            if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"error"]) {
                netErr = makeTransferNetError(responseObject[@"error"]);
            }
            BYError *error = makeNetDecodeError(netErr);
            finish(nil,error);
        }
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
        finish(nil,makeNetError(error));
    }];
}

+ (void)postByBaseUrl:(NSString*)baseUrl
               suffix:(NSString*)suffix
               params:(NSDictionary*)params
               finish:(void (^)(NSDictionary* data, NSError* error))finish
{
    AFHTTPRequestOperationManager* manager = makeNetManager(baseUrl);
    [[BYNetwork sharedNetwork] refreshHeader:manager];

    [manager POST:suffix parameters:params success:^(AFHTTPRequestOperation* operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"] && [responseObject[@"success"] intValue] == 1 ) {
            finish(responseObject[@"data"],nil);
        }else {
            BYError *netErr = nil;
            if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"error"]) {
                netErr = makeTransferNetError(responseObject[@"error"]);
            }
            BYError *error = makeNetDecodeError(netErr);
            finish(nil,error);
        }
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
        finish(nil,makeNetError(error));
    }];
}

+ (void)getComplete:(NSString*)url
             params:(NSDictionary*)params
             header:(NSDictionary*)header
             finish:(void (^)(NSDictionary* data, BYError* error))finish
{
    NSCAssert(finish, @"finish block 不能为空");
    
    
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    
    NSCAssert(finish, @"finish block 不能为空");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //申明返回的结果是json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //申明请求的数据是json类型
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    //如果报接受类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [[BYNetwork sharedNetwork] refreshCustomHeader:header manager:manager];
    //传入的参数
    //你的接口地址
    //发送请求
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        finish(responseObject,nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        BYLog(@"Error: %@", error);
        finish(nil,makeNetError(error));
    }];
    return;

    [manager GET:url parameters:params success:^(AFHTTPRequestOperation* operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"] && [responseObject[@"success"] intValue] == 1 ) {
            
            NSDictionary *result = responseObject[@"data"];
            
            finish(result,nil);
        }else {
            BYError *netErr = nil;
            if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"error"]) {
                netErr = makeTransferNetError(responseObject[@"error"]);
            }
            BYError *error = makeNetDecodeError(netErr);
            finish(nil,error);
        }
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
        finish(nil,makeNetError(error));
    }];
}

- (void)refreshHeader:(AFHTTPRequestOperationManager*)netmanager
{
    if (!netmanager.requestSerializer) {
        netmanager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    [[BYAppCenter sharedAppCenter].paramsMapForHeader bk_each:^(id key, NSString* value) {
        if ([value isKindOfClass:[NSString class]] && value.length > 0) {
            [netmanager.requestSerializer setValue:value forHTTPHeaderField:key];
            
        }
    }];
}

- (void)refreshCustomHeader:(NSDictionary*)header manager:(AFHTTPRequestOperationManager*)netmanager
{
    if (!netmanager.requestSerializer) {
        netmanager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    [header bk_each:^(id key, NSString* value) {
        if ([value isKindOfClass:[NSString class]] && value.length > 0) {
            [netmanager.requestSerializer setValue:value forHTTPHeaderField:key];
            
        }
    }];
}

#pragma mark - 顺手赚钱身份证上传

+ (void)postDataCompleteUrl:(NSString *)url
                     params:(NSDictionary*)params
                     finish:(void (^)(NSDictionary* data, BYError* error))finish
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [[BYNetwork sharedNetwork] refreshHeader:manager];
    AFHTTPRequestOperation *operation = nil;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"multipart/form-data"];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"----WebKitFormBoundarySSZQIdcardImageUpload"];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    operation = [manager POST:url
                   parameters:params
    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (NSString *key in params) {
            id value = params[key];
            if ([value isKindOfClass:[NSData class]]) {
                [formData appendPartWithFileData:value
                                            name:key
                                        fileName:@"idcard.jpg"
                                        mimeType:@"image/jpg"];
//                                        mimeType:@"image/jpeg/jpg/png"];
            }
        }
    }
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          if ([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"state"] isEqualToString:@"SUCCESS"] ) {
                              finish(responseObject ,nil);
                              BYLog(@"BYNetWork:上传成功————————");
                          }else {
                              BYError *netErr = nil;
                              if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"error"]) {
//                                  netErr = makeTransferNetError(responseObject[@"error"]);
                              }
                              BYError *error = makeNetDecodeError(netErr);
                              finish(nil,error);
                          }
                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          BYLog(@"AF-POST-(文件)请求失败, error is %@", error);
                          finish(nil,makeNetError(error));
                      }];
  
    // 设置返回的数据解析方式
    operation.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
}

+ (void)postAppendParamsCompleteUrl:(NSString *)url
                            params:(NSDictionary *)params
                             finish:(void (^)(NSDictionary *, BYError *))finish
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [[BYNetwork sharedNetwork] refreshHeader:manager];
    AFHTTPRequestOperation *operation = nil;

    [manager POST:url
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              BYLog(@"responseObject-》：%@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            BYLog(@"responseObject-》：%@", error);
        }];
    
}

@end
