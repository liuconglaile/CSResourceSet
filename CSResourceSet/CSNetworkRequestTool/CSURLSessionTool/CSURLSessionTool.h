//
//  CSURLSessionTool.h
//  NSURLSession封装
//
//  Created by mac on 17/2/6.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSURLSessionToolDelegate.h"
#import "CSCacheTool.h"

@interface CSURLSessionTool : NSObject

+ (NSURLSessionDataTask *)getRequestWithURL:(NSString*)url Parameters:(NSDictionary*)parameters completionHandler:(completionHandler)completionHandler;

+ (NSURLSessionDataTask *)postRequestWithURL:(NSString*)url Parameters:(NSDictionary*)parameters completionHandler:(completionHandler)completionHandlers;

+ (NSURLSessionDataTask *)postRequestWithURL:(NSString*)url Parameters:(NSDictionary*)parameters CacheType:(CSCacheType)cacheType completionHandler:(completionHandler)completionHandlers;

@end
