//
//  CSURLSessionToolDelegate.h
//  NSURLSession封装
//
//  Created by mac on 17/2/6.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HTTP_REQUEST_METHOD) {
    HTTP_REQUEST_METHOD_GET = 0,
    HTTP_REQUEST_METHOD_HEAD,
    HTTP_REQUEST_METHOD_POST,
    HTTP_REQUEST_METHOD_PUT,
    HTTP_REQUEST_METHOD_PATCH,
    HTTP_REQUEST_METHOD_DELETE,
};

typedef void(^completionHandler)(id data,NSError *error);

@protocol CSURLSessionToolDelegate <NSObject>

@end
