//
//  CSURLSessionManager.m
//  NetworkRequestTool
//
//  Created by mac on 17/2/13.
//  Copyright © 2017年 mac. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CSURLSessionManager.h"

#import "CSCacheManager.h"
#import "NSFileManager+Time.h"

static const NSInteger timeOut = 60*60;
@implementation CSURLSessionManager



+ (CSURLSessionManager *)sharedInstance{
    static CSURLSessionManager *sessionInstance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionInstance = [[CSURLSessionManager alloc] init];
    });
    return sessionInstance;
}

- (id)init{
    self = [super init];
    if (self) {
        
        self.request.responseObj = [[NSMutableData alloc] init];
        
        self.request.timeoutInterval = 15;
        
    }
    return self;
}

+ (instancetype)manager {
    return [[[self class] alloc] init];
}

#pragma mark - 离线下载

- (void)offlineDownload:(NSMutableArray *)downloadArray apiType:(CSAPIType)type success:(RequestSuccess)success failed:(RequestFailed)failed{
    if (downloadArray.count==0)return;
    [downloadArray enumerateObjectsUsingBlock:^(NSString *urlString, NSUInteger idx, BOOL *stop) {
        [self getRequestWithURL:urlString apiType:type success:success failed:failed];
    }];
}
- (void)offlineDownload:(NSMutableArray *)downloadArray target:(id<CSURLSessionDelegate>)delegate apiType:(CSAPIType)type{
    if (downloadArray.count==0)return;
    [downloadArray enumerateObjectsUsingBlock:^(NSString *urlString, NSUInteger idx, BOOL *stop) {
        [self getRequestWithURL:urlString target:delegate apiType:type];
    }];
}

#pragma  mark -  请求

- (void)requestWithConfig:(RequestConfig)config success:(RequestSuccess)success failed:(RequestFailed)failed{
    
    config ? config(self.request) : nil;
    
    if (self.request.apiType == CSAPITypeOffline) {
        [self offlineDownload:self.request.urlArray apiType:self.request.apiType success:success failed:failed];
    }else{
        [self getRequestWithURL:self.request.urlString apiType:self.request.apiType success:success failed:failed];
    }
}

-(void)postRequestWithURL:(NSString *)urlString parameters:(NSDictionary*)parameters target:(id<CSURLSessionDelegate>)delegate{
    [CSURLSessionManager postRequestWithURL:urlString parameters:parameters target:delegate];
}

- (void)getRequestWithURL:(NSString *)urlString target:(id<CSURLSessionDelegate>)delegate{
    [CSURLSessionManager getRequestWithURL:urlString target:delegate];
}

- (void )getRequestWithURL:(NSString *)urlString target:(id<CSURLSessionDelegate>)delegate apiType:(CSAPIType)type{
    [CSURLSessionManager getRequestWithURL:urlString target:delegate apiType:type];
}

- (void )getRequestWithURL:(NSString *)urlString apiType:(CSAPIType)type success:(RequestSuccess)success failed:(RequestFailed)failed {
    [CSURLSessionManager getRequestWithURL:urlString target:nil apiType:type success:success failed:failed];
}

+(CSURLSessionManager *)postRequestWithURL:(NSString *)urlString parameters:(NSDictionary*)parameters target:(id<CSURLSessionDelegate>)delegate{
    CSURLSessionManager *session = [[CSURLSessionManager alloc] init];
    session.request.urlString = urlString;
    session.delegate = delegate;
    [session postStartRequestWithParameters:parameters];
    return  session;
}

+(CSURLSessionManager *)getRequestWithURL:(NSString *)urlString target:(id<CSURLSessionDelegate>)delegate{
    return [CSURLSessionManager getRequestWithURL:urlString target:delegate apiType:CSAPITypeDefault];
}

+(CSURLSessionManager *)getRequestWithURL:(NSString *)urlString target:(id<CSURLSessionDelegate>)delegate apiType:(CSAPIType)type{
    return [CSURLSessionManager getRequestWithURL:urlString target:delegate apiType:type success:nil failed:nil];
}

//MARK:get方法
+(CSURLSessionManager *)getRequestWithURL:(NSString *)urlString target:(id<CSURLSessionDelegate>)delegate apiType:(CSAPIType)type success:(RequestSuccess)success failed:(RequestFailed)failed {
    
    CSURLSessionManager *session = [[CSURLSessionManager alloc] init];
    session.request.urlString = urlString;
    session.request.apiType = type;
    session.delegate = delegate;
    session.requestSuccess = success;
    session.requestFailed = failed;
    NSString *path =[[CSCacheManager sharedInstance] pathWithFileName:urlString];
    
    if ([[CSCacheManager sharedInstance] isExistsAtPath:path] &&
        [NSFileManager isTimeOutWithPath:path timeOut:timeOut] == NO &&
        type != CSAPITypeRefresh &&
        type != CSAPITypeOffline)
    {
        
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        CSURLRequestLog(@"session cache");
        [session.request.responseObj appendData:data];
        
        success ? success(session.request.responseObj  ,type) : nil;
        
        if ([session.delegate respondsToSelector:@selector(urlRequestFinished:)]) {
            [session.delegate urlRequestFinished:session.request];
        }
        return session;
        
    }else{
        
        [session getStartRequest];
    }
    
    [session.request setRequestObject:session forkey:urlString];
    return session;
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error{
    /*
     会话接收的最后一条消息。 会话将仅因系统错误或已被显式无效而失效，在这种情况下，错误参数将为nil。
     */
}


- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session NS_AVAILABLE_IOS(7_0){
/*
 如果应用程序接收到（-application:handleEventsForBackgroundURLSession:completionHandler:）消息，
 则会话委托将接收该消息以指示先前为该会话排队的所有消息已经被递送。
 此时可以安全地调用先前存储的完成处理程序，或者开始任何内部更新，这将导致调用完成处理程序。
 */
    
}

/**
 *  1.接收到服务器响应的时候调用该方法
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    completionHandler(NSURLSessionResponseAllow);
}

/**
 *  接收到服务器返回数据的时候会调用该方法，如果数据较大那么该方法可能会调用多次
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.request.responseObj appendData:data];
}

/**
 *  请求完成(成功|失败)的时候会调用该方法，如果请求失败，则error有值
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if(error == nil){
        NSString *path =[[CSCacheManager sharedInstance] pathWithFileName:self.request.urlString];
        
        [[CSCacheManager sharedInstance] setContent:self.request.responseObj writeToFile:path];
        
        if (self.requestSuccess) {
            self.requestSuccess(self.request.responseObj,self.request.apiType);
        }
        
        if ([_delegate respondsToSelector:@selector(urlRequestFinished:)]) {
            [_delegate urlRequestFinished:self.request];
        }
        [self.request removeRequestForkey:self.request.urlString ];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }else{
        CSURLRequestLog(@"error:%@",[error localizedDescription]);
        self.request.error=nil;
        self.request.error=error;
        
        if (self.requestFailed) {
            self.requestFailed(self.request.error);
        }
        
        if ([_delegate respondsToSelector:@selector(urlRequestFailed:)]) {
            [_delegate urlRequestFailed:self.request];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

/**
 *  证书处理
 */
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    //挑战处理类型为 默认
    /*
     NSURLSessionAuthChallengePerformDefaultHandling：默认方式处理
     NSURLSessionAuthChallengeUseCredential：使用指定的证书
     NSURLSessionAuthChallengeCancelAuthenticationChallenge：取消挑战
     */
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    
    if (credential) {
        disposition = NSURLSessionAuthChallengeUseCredential;
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

#pragma mark - request Operation
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field{
    if (value) {
        [CSURLRequest sharedInstance].value = value;
        [[CSURLRequest sharedInstance] setValue:value forHeaderField:field ];
    }
    else {
        [[CSURLRequest sharedInstance] removeHeaderForkey:field];
    }
}

- (NSString *)valueForHTTPHeaderField:(NSString *)field {
    return [self.request objectHeaderForKey:field];
}

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(timeoutInterval))];
    self.request.timeoutInterval = timeoutInterval;
    [self didChangeValueForKey:NSStringFromSelector(@selector(timeoutInterval))];
}

- (NSURLSession *)urlSession{
    if (_urlSession == nil) {
        _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _urlSession;
}

- (CSURLRequest*)request{
    if (!_request) {
        _request=[[CSURLRequest alloc]init];
    }
    
    return _request;
}

- (void)requestToCancel:(BOOL)cancelPendingTasks{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (cancelPendingTasks) {
            [self.urlSession invalidateAndCancel];
        } else {
            [self.urlSession finishTasksAndInvalidate];
        }
    });
}

#pragma mark - get Request
- (void)getStartRequest{
    CSURLRequestLog(@"session get");
    if(!self.request.urlString)return;
    
    NSString* string = @"";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 9.0f ) {
        string = [self.request.urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        string = [self.request.urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
    }
    
    
    NSURL *url = [NSURL URLWithString:string];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.request.timeoutInterval];
    if ([CSURLRequest sharedInstance].value) {
        
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        
        [[[CSURLRequest sharedInstance] mutableHTTPRequestHeaders] enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            
            if (![mutableRequest valueForHTTPHeaderField:field]) {
                [mutableRequest addValue: value forHTTPHeaderField:field];
            }
            
        }];
        
        request = [mutableRequest copy];
        
        CSURLRequestLog(@"get_HeaderField%@", request.allHTTPHeaderFields);
    }
    
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:request];
    
    [dataTask resume];
    
}

#pragma mark - post Request
- (void)postStartRequestWithParameters:(NSDictionary *)parameters;{
    CSURLRequestLog(@"post");
    
    NSString* string = @"";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 9.0f ) {
        string = [self.request.urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        string = [self.request.urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
    }
    
    NSURL *url = [NSURL URLWithString:string];
    
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    
    [mutableRequest setHTTPMethod: @"POST"];
    
    if (self.request.value) {
        
        [[self.request mutableHTTPRequestHeaders] enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            
            if (![mutableRequest valueForHTTPHeaderField:field]) {
                [mutableRequest setValue:value forHTTPHeaderField:field];
            }
        }];
        
        CSURLRequestLog(@"POST_HeaderField%@", mutableRequest.allHTTPHeaderFields);
    }
    
    
    
    [mutableRequest setTimeoutInterval:self.request.timeoutInterval];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSString *key in parameters) {
        id obj = [parameters objectForKey:key];
        NSString *str = [NSString stringWithFormat:@"%@=%@",key,obj];
        [array addObject:str];
    }
    
    NSString *dataStr = [array componentsJoinedByString:@"&"];
    
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [mutableRequest setHTTPBody:data];
    
    
    
    
    //MARK:如果是 json 交互,需指明头信息
    NSArray* contentType = @[@"application/json",
                             @"text/html",
                             @"text/json",
                             @"text/plain",
                             @"text/javascript",
                             @"text/xml",
                             @"image/*"];
    
    for (NSString* valueStr in contentType) {
        [mutableRequest setValue:valueStr forHTTPHeaderField:@"content-type"];//请求头
    }
    
    
    
    
    
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:mutableRequest];
    
    [dataTask resume];
    
}




@end


