//
//  CSURLSessionManager.h
//  NetworkRequestTool
//
//  Created by mac on 17/2/13.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSURLSessionDelegate.h"

@interface CSURLSessionManager : NSObject<NSURLSessionDelegate>

@property (nonatomic,copy) NSURLSession *urlSession;

@property (nonatomic,strong) CSURLRequest *request;

@property (nonatomic, strong) RequestSuccess requestSuccess;

@property (nonatomic, strong) RequestFailed requestFailed;

@property (nonatomic,weak) id<CSURLSessionDelegate>delegate;





/**
 *  创建并返回一个“ZBURLSessionManager”对象
 *  Creates and returns an `ZBURLSessionManager` object
 */
+ (instancetype)manager;

/**
 返回单例对象
 
 @return  “ZBURLSessionManager”对象
 */
+ (CSURLSessionManager *)sharedInstance;


/**
 设置由HTTP客户端在请求对象中设置的HTTP头的值。 如果`nil`，删除该头的现有值
 
 @param value 设置指定头的默认值
 @param field 设置默认值的HTTP头
 */
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;


/**
 返回请求操作中设置的HTTP标头的值
 
 @param field 要检索其默认值的HTTP头
 @return 设置为默认指定头的值
 */
- (NSString *)valueForHTTPHeaderField:(NSString *)field;


/**
 请求会话管理，可选择取消尚未完成的任务
 
 @param cancelPendingTasks 是否取消任务
 */
- (void)requestToCancel:(BOOL)cancelPendingTasks;

/**
 *  离线下载 请求方法
 *
 *  @param downloadArray 请求列队
 *  @param delegate      代理  传实现协议的对象
 *  @param type          用于直接区分不同的request对象 离线下载 为 ZBRequestTypeOffline
 */
- (void)offlineDownload:(NSMutableArray *)downloadArray target:(id<CSURLSessionDelegate>)delegate apiType:(CSAPIType)type;

/**
 *  get请求 不能post
 *
 *  @param config          请求配置  Block
 *  @param success         请求成功的 Block
 *  @param failed          请求失败的 Block
 */
- (void)requestWithConfig:(RequestConfig)config  success:(RequestSuccess)success failed:(RequestFailed)failed;
/**
 *  get请求
 *
 *  @param urlString    请求的协议地址
 *  @param delegate     代理  传实现协议的对象
 *
 */
- (void)getRequestWithURL:(NSString *)urlString target:(id<CSURLSessionDelegate>)delegate;

/**
 *  get请求
 *
 *  @param urlString    请求的协议地址
 *  @param delegate     代理 传实现协议的对象
 *  @param type         用于直接区分不同的request对象 默认类型为 ZBRequestTypeDefault
 *
 */
- (void )getRequestWithURL:(NSString *)urlString target:(id<CSURLSessionDelegate>)delegate apiType:(CSAPIType)type;

/**
 *  get请求
 *
 *  @param urlString        请求的协议地址
 *  @param type             用于直接区分不同的request对象 默认类型为 ZBRequestTypeDefault
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
- (void )getRequestWithURL:(NSString *)urlString apiType:(CSAPIType)type success:(RequestSuccess)success failed:(RequestFailed)failed;

/**
 *  post 请求
 *
 *  @param urlString    请求的协议地址
 *  @param parameters    请求所用的字典
 *  @param delegate      代理 传实现协议的对象
 *
 */
- (void)postRequestWithURL:(NSString *)urlString parameters:(NSDictionary*)parameters target:(id<CSURLSessionDelegate>)delegate;

/**
 *  get请求
 *
 *  @param urlString    请求的协议地址
 *  @param delegate     代理  传实现协议的对象
 *
 */
+(CSURLSessionManager *)getRequestWithURL:(NSString *)urlString target:(id<CSURLSessionDelegate>)delegate;

/**
 *  get请求
 *
 *  @param urlString    请求的协议地址
 *  @param delegate     代理 传实现协议的对象
 *  @param type         用于直接区分不同的request对象 默认类型为 ZBRequestTypeDefault
 *
 */
+(CSURLSessionManager *)getRequestWithURL:(NSString *)urlString target:(id<CSURLSessionDelegate>)delegate apiType:(CSAPIType)type;

/**
 *  post 请求
 *
 *  @param urlString    请求的协议地址
 *  @param parameters   请求所用的字典
 *  @param delegate     代理 传实现协议的对象
 *
 */
+(CSURLSessionManager *)postRequestWithURL:(NSString *)urlString parameters:(NSDictionary*)parameters target:(id<CSURLSessionDelegate>)delegate;





@end
