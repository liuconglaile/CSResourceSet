//
//  CSNetworkCache.m
//  NewWorkersAbout
//
//  Created by mac on 16/11/16.
//  Copyright © 2016年 CS-Moming. All rights reserved.
//

#import "CSNetworkCache.h"
#import <CommonCrypto/CommonDigest.h>

#ifdef DEBUG
#define DebugLog(...) NSLog(__VA_ARGS__)
#else
#define DebugLog(...)
#endif

@implementation CSNetworkCache

+(BOOL)saveJsonResponseToCacheFile:(id)jsonResponse andURL:(NSString *)URL
{
    if(jsonResponse==nil) return NO;
    NSData * data= [self jsonToData:jsonResponse];
    return[[NSFileManager defaultManager] createFileAtPath:[self cacheFilePathWithURL:URL] contents:data attributes:nil];
}
+(void)save_asyncJsonResponseToCacheFile:(id)jsonResponse andURL:(NSString *)URL completed:(CSNetworkCacheCompletionBlock)completedBlock;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL result=[self saveJsonResponseToCacheFile:jsonResponse andURL:URL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
         
            if(completedBlock)
            {
                completedBlock(result);
            }
        });
    });
}
+(id )cacheJsonWithURL:(NSString *)URL
{
    NSString *path = [self cacheFilePathWithURL:URL];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:nil] == YES) {
        NSData *data = [fileManager contentsAtPath:path];
        return [self dataToJson:data];
    }
    return nil;
}
+ (NSString *)cacheFilePathWithURL:(NSString *)URL {
    
    NSString *path = [self cachePath];
    [self checkDirectory:path];//check路径
    //文件名
    NSString *cacheFileNameString = [NSString stringWithFormat:@"URL:%@ AppVersion:%@",URL,[self appVersionString]];
    NSString *cacheFileName = [self md5StringFromString:cacheFileNameString];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}
+(NSData *)jsonToData:(id)jsonResponse
{
    if(jsonResponse==nil) return nil;
    return [NSJSONSerialization dataWithJSONObject:jsonResponse options:NSJSONWritingPrettyPrinted error:nil];
}
+(id)dataToJson:(NSData *)data
{
    if(data==nil) return nil;
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}
+(NSString *)cachePath
{
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"CSNetworkCache"];
    return path;
}

+(void)checkDirectory:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}

+ (void)createBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        DebugLog(@"创建缓存目录失败, error = %@", error);
    } else {
        
        DebugLog(@"创建缓存目录成功 path = %@",path);
        [self addDoNotBackupAttribute:path];
    }
}
+ (void)addDoNotBackupAttribute:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error) {
        DebugLog(@"错误设置不备份属性, error = %@", error);
    }
}

+ (NSString *)md5StringFromString:(NSString *)string {
    
    if(string == nil || [string length] == 0)  return nil;
    
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}
+ (NSString *)appVersionString {
    
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+(BOOL)clearCache
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self cachePath];
    return [fileManager removeItemAtPath:path error:nil];
}
+ (float)cacheSize{
    NSString *directoryPath = [self cachePath];
    BOOL isDir = NO;
    unsigned long long total = 0;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir]) {
        if (isDir) {
            NSError *error = nil;
            NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
            
            if (error == nil) {
                for (NSString *subpath in array) {
                    NSString *path = [directoryPath stringByAppendingPathComponent:subpath];
                    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path
                                                                                          error:&error];
                    if (!error) {
                        total += [dict[NSFileSize] unsignedIntegerValue];
                    }
                }
            }
        }
    }
    return total/(1024.0*1024.0);
}

/** 缓存的有效期  单位是s */
#define kYBCache_Expire_Time (3600*24)

+ (BOOL)isExpire:(NSString *)fileName
{
    NSString *path = [self cachePath];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *attributesDict = [fm attributesOfItemAtPath:path error:nil];
    NSDate *fileModificationDate = attributesDict[NSFileModificationDate];
    NSTimeInterval fileModificationTimestamp = [fileModificationDate timeIntervalSince1970];
    //现在的时间戳
    NSTimeInterval nowTimestamp = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
    return ((nowTimestamp-fileModificationTimestamp)>kYBCache_Expire_Time);
}

+ (NSString *)md5:(NSString *)inPutText
{
    const char *cStr = [inPutText UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}


@end
