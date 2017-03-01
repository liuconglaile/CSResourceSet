//
//  CSCacheTool.h
//  WorkersAbout
//
//  Created by mac on 17/2/7.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CSCacheType){
    CSCacheTypeReturnCacheDataThenLoad = 0,  ///< 有缓存就先返回缓存，同步请求数据
    CSCacheTypeReloadIgnoringLocalCacheData, ///< 忽略缓存，重新请求
    CSCacheTypeReturnCacheDataElseLoad,      ///< 有缓存就用缓存，没有缓存就重新请求(用于数据不变时)
    CSCacheTypeReturnCacheDataDontLoad,      ///< 有缓存就用缓存，没有缓存就不发请求，当做请求出错处理（用于离线模式）
    CSCacheTypeReturnCacheDataExpireThenLoad ///< 有缓存就用缓存，如果过期了就重新请求 没过期就不请求
};

@interface CSCacheTool : NSObject

/**
 *  缓存数据
 *
 *  @param fileName 缓存数据的文件名
 *
 *  @param data 需要缓存的二进制
 */
+ (void)cacheForData:(NSData *)data fileName:(NSString *)fileName;

/**
 *  取出缓存数据
 *
 *  @param fileName 缓存数据的文件名
 *
 *  @return 缓存的二进制数据
 */
+ (NSData *)getCacheFileName:(NSString *)fileName;

/**
 *  判断缓存文件是否过期
 */
+ (BOOL)isExpire:(NSString *)fileName;

/**
 *  获取缓存的大小
 *
 *  @return 缓存的大小  单位是B
 */
+ (NSUInteger)getSize;

/**
 *  清除缓存
 */
+ (void)clearCache;

@end


@interface CSCache : NSObject

@property (nonatomic, copy) NSString *fileName;//缓存文件名
@property (nonatomic, assign) BOOL result;//是否需要重新请求数据

@end
