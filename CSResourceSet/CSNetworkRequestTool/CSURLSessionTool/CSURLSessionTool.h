//
//  CSURLSessionTool.h
//  NSURLSession封装
//
//  Created by mac on 17/2/6.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSURLSessionToolDelegate.h"
#import "CSNetworkCache.h"

#ifdef DEBUG
#define NSLog(format, ...) printf("类名: <%p %s:(%d) > 方法: %s \n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] )
#else
#define NSLog(format, ...)
#endif

@interface CSURLSessionTool : NSObject

+ (NSURLSessionDataTask *)getRequestWithURL:(NSString*)url Parameters:(NSDictionary*)parameters completionHandler:(completionHandler)completionHandler;

+ (NSURLSessionDataTask *)postRequestWithURL:(NSString*)url Parameters:(NSDictionary*)parameters completionHandler:(completionHandler)completionHandlers;

+ (NSURLSessionDataTask *)postRequestWithURL:(NSString*)url Parameters:(NSDictionary*)parameters CacheType:(CSCacheType)cacheType completionHandler:(completionHandler)completionHandlers;

@end
