//
//  CSCacheManager.h
//  NetworkRequestTool
//
//  Created by mac on 17/2/13.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Posted when a task name.
 */
FOUNDATION_EXPORT NSString * const PathDefault;

/**
 Posted when a task name.
 */
FOUNDATION_EXPORT NSString *const PathImager;

typedef void(^CompletionHandler)();

/**
 文件管理工具:管理文件的 &路径&创建&存储&编码&显示&删除 等功能
 */
@interface CSCacheManager : NSObject

+ (CSCacheManager *)sharedInstance;

- (void)createDirectoryAtPath:(NSString *)path;

//MARK:把内容,写入到文件
- (BOOL)setContent:(NSObject *)content writeToFile:(NSString *)path;

//MARK:当前路径是否存储数据
- (BOOL)isExistsAtPath:(NSString *)path;

//MARK:查找存储的文件 默认缓存路径/Library/Caches/ZBKit/AppCache
- (NSString *)pathWithFileName:(NSString *)name;

//MARK:拼接路径与编码后的文件
- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)CachePath;

//MARK:显示data文件缓存大小 默认缓存路径/Library/Caches/CSKit/AppCache
- (NSUInteger)getCacheSize;

//MARK:显示data文件缓存个数 默认缓存路径/Library/Caches/CSKit/AppCache
- (NSUInteger)getCacheCount;

//MARK:显示文件大小
- (NSUInteger)getFileSizeWithpath:(NSString *)path;

//MARK:显示文件个数
- (NSUInteger)getFileCountWithpath:(NSString *)path;

//MARK:显示文件的大小(单位)
- (NSString *)fileUnitWithSize:(float)size;

//MARK:磁盘总空间大小
- (NSUInteger)diskSystemSpace;

//MARK:磁盘空闲系统空间
- (NSUInteger)diskFreeSystemSpace;

//MARK:返回某个路径下的所有数据文件
- (NSArray *)getCacheFileWithPath:(NSString *)path;

//MARK:返回缓存文件的数据
-(NSDictionary* )getFileAttributes:(NSString *)key;

//MARK:自动清除过期缓存
- (void)automaticCleanCache;

//MARK:自动清除过期缓存
- (void)automaticCleanCacheWithPath:(NSString *)path CompletionHandler:(CompletionHandler)completionHandler;

//MARK:清除某一个缓存文件    默认路径/Library/Caches/CSKit/AppCache
- (void)clearCacheForkey:(NSString *)key;

//MARK:清除某一个缓存文件   默认路径/Library/Caches/CSKit/AppCache
- (void)clearCacheForkey:(NSString *)key CompletionHandler:(CompletionHandler)completionHandler;

//MARK:清除某一个缓存文件    自定义路径
- (void)clearCacheForkey:(NSString *)key path:(NSString *)path CompletionHandler:(CompletionHandler)completionHandler;

//MARK:清除全部缓存 /Library/Caches/CSKit/AppCache
- (void)clearCache;

//MARK:清除全部缓存 /Library/Caches/CSKit/AppCache
- (void)clearCacheOnCompletionHandler:(CompletionHandler)completionHandler;

//MARK:清除某一路径下的文件
- (void)clearDiskWithpath:(NSString *)path;

//MARK:清除某一路径下的文件
- (void)clearDiskWithpath:(NSString *)path CompletionHandler:(CompletionHandler)completionHandler;





//MARK:获取沙盒Home的文件目录
- (NSString *)homePath;

//MARK:获取沙盒Document的文件目录
- (NSString *)documentPath;

//MARK:获取沙盒Library的文件目录
- (NSString *)libraryPath;

//MARK:获取沙盒Library/Caches的文件目录
- (NSString *)cachesPath;

//MARK:获取沙盒tmp的文件目录
- (NSString *)tmpPath;

//MARK:获取沙盒自创建的CSKit文件目录
- (NSString *)CSKitPath;

//MARK:获取沙盒自创建的AppCache文件目录
- (NSString *)CSAppCachePath;


@end
