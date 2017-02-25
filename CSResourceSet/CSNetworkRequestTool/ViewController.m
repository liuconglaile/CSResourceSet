//
//  ViewController.m
//  CSNetworkRequestTool
//
//  Created by mac on 17/2/25.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import "CSURLSessionManager.h"

@interface ViewController ()<CSURLSessionDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* url = @"https://api.cs.juworker.com/home/index/get/";
    
    [[CSURLRequest sharedInstance] setValue:@"text/html" forHeaderField:@"Content-Type"];
    
    [[CSURLSessionManager sharedInstance] postRequestWithURL:url parameters:nil target:self];
    
}


/**
 数据请求成功调用的方法
 
 @param request CSURLRequest
 */
- (void)urlRequestFinished:(CSURLRequest *)request{
    
    CSURLRequestLog(@"请求头:%@",request.mutableHTTPRequestHeaders);
    
    CSURLRequestLog(@"sessiondelegate 请求类型:%zd",request.apiType);
   
    CSURLRequestLog(@"请求成功:%@",[self tryToParseData:request.responseObj]);
    
}

- (id)tryToParseData:(id)responseData {
    if ([responseData isKindOfClass:[NSData class]]) {
        // 尝试解析成JSON
        if (responseData == nil) {
            return responseData;
        } else {
            NSError *error = nil;
            
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingAllowFragments
                                                                       error:&error];
            
            if (error != nil) {
                return responseData;
            } else {
                return response;
            }
        }
    } else {
        return responseData;
    }
}


/**
 数据请求失败调用的方法
 
 @param request CSURLRequest
 */
- (void)urlRequestFailed:(CSURLRequest *)request{
    
    if (request.error.code == NSURLErrorCancelled)return;
    if (request.error.code == NSURLErrorTimedOut) {
        CSURLRequestLog(@"请求超时:%@",request.error.userInfo);
    }else{
        CSURLRequestLog(@"请求失败:%@",request.error.userInfo);
    }
    
}


@end
