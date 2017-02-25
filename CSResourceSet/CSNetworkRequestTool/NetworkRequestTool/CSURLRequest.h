//
//  CSURLRequest.h
//  NetworkRequestTool
//
//  Created by mac on 17/2/13.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEBUG_ISOPEN True //True || False

#ifdef DEBUG
#define CSURLRequestLog(format, ...) printf("class: <%p %s:(%d) > method: %s \n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] )
#else
#define CSURLRequestLog(format, ...)
#endif


@interface CSURLRequest : NSObject


/**
 用于标识不同类型的请求
 
 - CSAPITypeDefault:  默认类型
 - CSAPITypeRefresh:  重新请求 （有缓存，不读取，重新请求
 - CSAPITypeLoadMore: 加载更多
 - CSAPITypeDetail:   详情
 - CSAPITypeOffline:  离线    （有缓存，不读取，重新请求）
 - CSAPITypeCustom:   自定义
 */
typedef NS_ENUM(NSInteger,CSAPIType) {
    CSAPITypeDefault,
    CSAPITypeRefresh,
    CSAPITypeLoadMore,
    CSAPITypeDetail,
    CSAPITypeOffline,
    CSAPITypeCustom
};


/**
 请求类型枚举&这里只做了两种
 
 - CSMethodTypeGET:  GET请求
 - CSMethodTypePOST: POST请求
 */
typedef NS_ENUM(NSInteger,CSMethodType) {
    CSMethodTypeGET,
    CSMethodTypePOST
};


/** 用于标识不同类型的request */
@property (nonatomic,assign) CSAPIType apiType;
/** 用于标识不同类型的request */
@property (nonatomic,assign) CSMethodType methodType;
/** 接口(请求地址) */
@property (nonatomic,copy) NSString *urlString;

/** 请求url列队容器 */
@property (nonatomic,strong) NSMutableArray *urlArray;

/** 提供给外部配置参数使用 */
@property (nonatomic,strong) id parameters;

/** 数据,提供给外部使用 */
@property (nonatomic,strong) NSMutableData *responseObj;

/** 已创建请求的超时间隔（以秒为单位）。 默认超时时间间隔为15秒. */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/** 请求错误 */
@property (nonatomic,strong)NSError *error;

/** 用于维护多个request对象 */
@property ( nonatomic, strong) NSMutableDictionary *requestDic;

/** 用于维护 请求头的request对象 */
@property ( nonatomic, strong) NSMutableDictionary *mutableHTTPRequestHeaders;

/** 用于判断是否有请求头 */
@property (nonatomic,copy) NSString *value;

+ (CSURLRequest *)sharedInstance;

//MARK:添加请求头
- (void)setValue:(NSString *)value forHeaderField:(NSString *)field;

//MARK:获取请求头的key
- (NSString *)objectHeaderForKey:(NSString *)key;

//MARK:删除请求头的key
- (void)removeHeaderForkey:(NSString *)key;

//MARK:返回url数组
- (NSMutableArray *)offlineUrlArray;

//MARK:返回其他参数数组
- (NSMutableArray *)offlineKeyArray;

//MARK:离线下载 将url 添加到请求列队
- (void)addObjectWithUrl:(NSString *)urlString;

//MARK:离线下载 将url 从请求列队删除
- (void)removeObjectWithUrl:(NSString *)urlString;

//MARK:离线下载 将栏目其他参数  添加到容器
- (void)addObjectWithKey:(NSString *)key;

//MARK:离线下载 将栏目其他参数 从容器删除
- (void)removeObjectWithKey:(NSString *)key;

//MARK:离线下载 删除全部请求列队
- (void)removeOfflineArray;

//MARK:离线下载 判断栏目url 或 其他参数 是否已添加到请求容器
- (BOOL)isAddForKey:(NSString *)key isUrl:(BOOL)isUrl;

//MARK:离线下载 将url 或 其他参数 添加到请求列队
- (void)addObjectWithForKey:(NSString *)key isUrl:(BOOL)isUrl;

//MARK:离线下载 将url 或 其他参数 从请求列队删除
- (void)removeObjectWithForkey:(NSString *)key isUrl:(BOOL)isUrl;

//MARK:
- (void)setRequestObject:(id)obj forkey:(NSString *)key;

//MARK:删除对应的ke
- (void)removeRequestForkey:(NSString *)key;




@end
