//
//  NSFileManager+Time.h
//  NetworkRequestTool
//
//  Created by mac on 17/2/13.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Time)

/**
 *   判断指定路径下的文件，是否超出规定时间的方法
 *
 *  @param path 文件路径
 *  @param time NSTimeInterval 毫秒
 *
 *  @return 是否超时
 */
+(BOOL)isTimeOutWithPath:(NSString *)path timeOut:(NSTimeInterval)time;

@end
