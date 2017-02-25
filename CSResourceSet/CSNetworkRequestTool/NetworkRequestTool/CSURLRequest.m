//
//  CSURLRequest.m
//  NetworkRequestTool
//
//  Created by mac on 17/2/13.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSURLRequest.h"

@interface CSURLRequest ()

/**
 离线下载栏目url容器
 */
@property (nonatomic,strong) NSMutableArray *channelUrlArray;

/**
 离线下载栏目名字容器
 */
@property (nonatomic,strong) NSMutableArray *channelKeyArray;

@end

@implementation CSURLRequest

+ (CSURLRequest *)sharedInstance {
    static CSURLRequest *request=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        request = [[CSURLRequest alloc] init];
    });
    return request;
}

/**
 *  添加请求头
 *
 *  @param value value
 *  @param field field
 */
- (void)setValue:(NSString *)value forHeaderField:(NSString *)field{
    if (value) {
        [self.mutableHTTPRequestHeaders setValue:value forKey:field];
    }
    else {
        [self removeHeaderForkey:field];
    }
}

/**
 *
 *  @param key request 对象
 *  @return request 对象
 */
- (NSString *)objectHeaderForKey:(NSString *)key{
    return  [self.mutableHTTPRequestHeaders objectForKey:key];
}
/**
 *  删除请求头的key
 *
 *  @param key key
 */
- (void)removeHeaderForkey:(NSString *)key{
    if(!key)return;
    [self.mutableHTTPRequestHeaders removeObjectForKey:key];
}
/**
 离线下载 将url 添加到请求列队
 
 @param urlString 请求地址
 */
- (void)addObjectWithUrl:(NSString *)urlString{
    [self addObjectWithForKey:urlString isUrl:YES];
}
/**
 离线下载 将url 从请求列队删除
 
 @param urlString 请求地址
 */
- (void)removeObjectWithUrl:(NSString *)urlString{
    [self removeObjectWithForkey:urlString isUrl:YES];
}


/**
 离线下载 将栏目其他参数  添加到容器
 
 @param key 栏目名字 或 其他 key
 */
- (void)addObjectWithKey:(NSString *)key{
    [self addObjectWithForKey:key isUrl:NO];
}


/**
 离线下载 将栏目其他参数 从容器删除
 
 @param key 请求地址 或 其他 key
 */
- (void)removeObjectWithKey:(NSString *)key{
    [self removeObjectWithForkey:key isUrl:NO];
}

/**
 离线下载 删除全部请求列队
 */
- (void)removeOfflineArray{
    
    [self.offlineUrlArray removeAllObjects];
    [self.offlineKeyArray removeAllObjects];
}

/**
 离线下载 判断栏目url 或 其他参数 是否已添加到请求容器
 
 @param key 请求地址 或 其他参数
 @param isUrl 是否是url
 @return 1:0
 */
- (BOOL)isAddForKey:(NSString *)key isUrl:(BOOL)isUrl{
    
    if (isUrl==YES) {
        @synchronized (self.channelUrlArray) {
            return  [self.channelUrlArray containsObject: key];
        }
    }else{
        @synchronized (self.channelKeyArray) {
            return  [self.channelKeyArray containsObject: key];
        }
    }
}

/**
 离线下载 将url 或 其他参数 添加到请求列队
 
 @param key   请求地址 或 其他参数
 @param isUrl 是否是url
 */
- (void)addObjectWithForKey:(NSString *)key isUrl:(BOOL)isUrl{
    if (isUrl==YES) {
        
        if ([self isAddForKey:key isUrl:isUrl]==1) {
            CSURLRequestLog(@"已经包含该栏目URL");
        }else{
            @synchronized (self.channelUrlArray) {
                [self.channelUrlArray addObject:key];
            }
        }
    }else{
        
        if ([self isAddForKey:key isUrl:isUrl]==1) {
            CSURLRequestLog(@"已经包含该栏目名字");
        }else{
            @synchronized (self.channelKeyArray ) {
                [self.channelKeyArray addObject:key];
            }
        }
    }
}

/**
 离线下载 将url 或 其他参数 从请求列队删除
 
 @param key   请求地址 或 其他参数
 @param isUrl 是否是url
 */
- (void)removeObjectWithForkey:(NSString *)key isUrl:(BOOL)isUrl{
    if (isUrl==YES) {
        if ([self isAddForKey:key isUrl:isUrl]==1) {
            @synchronized (self.channelUrlArray) {
                [self.channelUrlArray removeObject:key];
            }
        }else{
            CSURLRequestLog(@"已经删除该栏目URL");
        }
        
    }else{
        
        if ([self isAddForKey:key isUrl:isUrl]==1) {
            @synchronized (self.channelKeyArray) {
                [self.channelKeyArray removeObject:key];
            }
        }else{
            CSURLRequestLog(@"已经删除该栏目名字");
        }
    }
}

/**
 <#Description#>
 
 @param obj 对象
 @param key key
 */
- (void)setRequestObject:(id)obj forkey:(NSString *)key{
    
    if (obj) {
        @synchronized (self.requestDic){
            [self.requestDic setObject:obj forKey:key];
        }
    }
}
/**
 删除对应的key
 
 @param key key
 */
- (void)removeRequestForkey:(NSString *)key{
    
    if(!key)return;
    @synchronized (self.requestDic){
        [self.requestDic removeObjectForKey:key];
    }
}










/**
 *  @return urlArray 返回url数组
 */
- (NSMutableArray *)offlineUrlArray{
    return self.channelUrlArray;
}
/**
 *  @return urlArray 返回其他参数数组
 */
- (NSMutableArray *)offlineKeyArray{
    return self.channelKeyArray;
}
//MARK: lazy
- (NSMutableDictionary *)requestDic{
    
    if (!_requestDic) {
        _requestDic  = [[NSMutableDictionary alloc]init];
    }
    return _requestDic;
}

- (NSMutableArray *)channelUrlArray{
    
    if (!_channelUrlArray) {
        _channelUrlArray=[[NSMutableArray alloc]init];
    }
    return _channelUrlArray;
}

- (NSMutableArray *)channelKeyArray{
    
    if (!_channelKeyArray) {
        _channelKeyArray=[[NSMutableArray alloc]init];
    }
    return _channelKeyArray;
}

- (NSMutableDictionary *)mutableHTTPRequestHeaders{
    
    if (!_mutableHTTPRequestHeaders) {
        _mutableHTTPRequestHeaders  = [[NSMutableDictionary alloc] init];
    }
    return _mutableHTTPRequestHeaders;
}

@end
