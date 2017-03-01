//
//  NSDictionary+URL.h
//  NSURLSession封装
//
//  Created by mac on 17/2/6.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (URL)

+ (NSDictionary *)dictionaryWithURLQuery:(NSString *)query;
- (NSString *)URLQueryString;

@end
