//
//  CSURLSessionDelegate.h
//  NetworkRequestTool
//
//  Created by mac on 17/2/13.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSURLRequest.h"


typedef void (^RequestConfig)(CSURLRequest *request);

typedef void (^RequestSuccess)(id responseObj,CSAPIType type);

typedef void (^RequestFailed)(NSError *error);

typedef void (^RrogressBlock)(NSProgress * progress);


@protocol CSURLSessionDelegate <NSObject>

@required

/**
 数据请求成功调用的方法

 @param request CSURLRequest
 */
- (void)urlRequestFinished:(CSURLRequest *)request;
@optional


/**
 数据请求失败调用的方法

 @param request CSURLRequest
 */
- (void)urlRequestFailed:(CSURLRequest *)request;

@end
