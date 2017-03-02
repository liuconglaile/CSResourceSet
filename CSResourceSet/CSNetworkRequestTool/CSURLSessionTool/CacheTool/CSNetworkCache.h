//
//  CSNetworkCache.h
//  NewWorkersAbout
//
//  Created by mac on 16/11/16.
//  Copyright © 2016年 CS-Moming. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CSCacheType){
    CSCacheTypeReturnCacheDataThenLoad = 0,  ///< 有缓存就先返回缓存，同步请求数据
    CSCacheTypeReloadIgnoringLocalCacheData, ///< 忽略缓存，重新请求
    CSCacheTypeReturnCacheDataElseLoad,      ///< 有缓存就用缓存，没有缓存就重新请求(用于数据不变时)
    CSCacheTypeReturnCacheDataDontLoad,      ///< 有缓存就用缓存，没有缓存就不发请求，当做请求出错处理（用于离线模式）
    CSCacheTypeReturnCacheDataExpireThenLoad ///< 有缓存就用缓存，如果过期了就重新请求 没过期就不请求
};

typedef void(^CSNetworkCacheCompletionBlock)(BOOL result);
/**
 *  一键缓存数据
 */
@interface CSNetworkCache : NSObject

/**
 *  写入/更新缓存(同步) [按APP版本号缓存,不同版本APP,同一接口缓存数据互不干扰]
 *
 *  @param jsonResponse 要写入的数据(JSON)
 *  @param URL    数据请求URL
 *
 *  @return 是否写入成功
 */
+(BOOL)saveJsonResponseToCacheFile:(id)jsonResponse andURL:(NSString *)URL;

/**
 *  写入/更新缓存(异步) [按APP版本号缓存,不同版本APP,同一接口缓存数据互不干扰]
 *
 *  @param jsonResponse    要写入的数据(JSON)
 *  @param URL             数据请求URL
 *  @param completedBlock  异步完成回调(主线程回调)
 */
+(void)save_asyncJsonResponseToCacheFile:(id)jsonResponse andURL:(NSString *)URL completed:(CSNetworkCacheCompletionBlock)completedBlock;

/**
 *  获取缓存的对象(同步)
 *
 *  @param URL 数据请求URL
 *
 *  @return 缓存对象
 */
+(id )cacheJsonWithURL:(NSString *)URL;


/**
 *  清除所有缓存
 */
+(BOOL)clearCache;

/**
 *  获取缓存总大小(单位:M)
 *
 *  @return 缓存大小
 */
+ (float)cacheSize;

+ (BOOL)isExpire:(NSString *)fileName;


@end
