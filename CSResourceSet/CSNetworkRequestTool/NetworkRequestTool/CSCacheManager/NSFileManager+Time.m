//
//  NSFileManager+Time.m
//  NetworkRequestTool
//
//  Created by mac on 17/2/13.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSFileManager+Time.h"

@implementation NSFileManager (Time)

+(BOOL)isTimeOutWithPath:(NSString *)path timeOut:(NSTimeInterval)time{
    
    NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    
    NSDate *current = [info objectForKey:NSFileModificationDate];
    
    NSDate *date = [NSDate date];
    
    NSTimeInterval currentTime = [date timeIntervalSinceDate:current];
    
    if (currentTime>time) {
        return YES;
    }else{
        return NO;
    }
}

@end
