//
//  CSCacheManager.m
//  NetworkRequestTool
//
//  Created by mac on 17/2/13.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSCacheManager.h"
#import <CommonCrypto/CommonDigest.h>

NSString *const PathSpace = @"CSKit";
NSString *const PathDefault = @"CSNetworkCache";


static const NSInteger cacheMaxCacheAge  = 60*60*24*7; //一星期存储期
static const CGFloat unit = 1000.0;
//static const NSInteger cacheMixCacheAge = 60;

@interface CSCacheManager ()

@property (nonatomic ,copy) NSString *diskCachePath;
@property (nonatomic ,strong) dispatch_queue_t operationQueue;

@end

@implementation CSCacheManager

+ (CSCacheManager *)sharedInstance{
    static CSCacheManager *cacheInstance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheInstance = [[CSCacheManager alloc] init];
    });
    return cacheInstance;
}

- (id)init{
    self = [super init];
    if (self) {
        
        _operationQueue = dispatch_queue_create("com.dispatch.ZBCacheManager", DISPATCH_QUEUE_SERIAL);
        
        [self initCachesfileWithName:PathDefault];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(automaticCleanCache) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(automaticCleanCache) name:UIApplicationWillTerminateNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backgroundCleanCache) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        
    }
    return self;
}
- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - 创建存储文件夹
- (void)initCachesfileWithName:(NSString *)name{
    
    
    self.diskCachePath = [[self CSKitPath] stringByAppendingPathComponent:name];
    
    [self createDirectoryAtPath:self.diskCachePath];
}


/**
 创建沙盒文件夹
 
 @param path 路径
 */
- (void)createDirectoryAtPath:(NSString *)path{
    if (![self isExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        // NSLog(@"FileDir is exists.");
    }
}


/**
 判断沙盒是否有值
 
 @param path 路径
 @return  YES?NO
 */
- (BOOL)isExistsAtPath:(NSString *)path{
    return  [[NSFileManager defaultManager] fileExistsAtPath:path];
}




#pragma  mark - 存储

/**
 写入数据
 
 @param content 保存数据
 @param path 保存路径
 @return 是否成功
 */
- (BOOL)setContent:(NSObject *)content writeToFile:(NSString *)path{
    if (!content||!path){
        return NO;
    }
    if ([content isKindOfClass:[NSMutableArray class]]) {
        [(NSMutableArray *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSArray class]]) {
        [(NSArray *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSMutableData class]]) {
        [(NSMutableData *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSData class]]) {
        [(NSData *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSMutableDictionary class]]) {
        [(NSMutableDictionary *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSDictionary class]]) {
        [(NSDictionary *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSJSONSerialization class]]) {
        [(NSDictionary *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSMutableString class]]) {
        [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSString class]]) {
        [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[UIImage class]]) {
        [UIImagePNGRepresentation((UIImage *)content) writeToFile:path atomically:YES];
    }else if ([content conformsToProtocol:@protocol(NSCoding)]) {
        [NSKeyedArchiver archiveRootObject:content toFile:path];
    }else {
        
        [NSException raise:@"非法的文件内容" format:@"文件类型%@异常。", NSStringFromClass([content class])];
        return NO;
    }
    return YES;
}


/**
 查找存储的文件 默认缓存路径/Library/Caches/CSKit/AppCache
 
 @param name 存储的文件名
 @return 根据存储的文件名，返回在本地的存储路径
 */
- (NSString *)pathWithFileName:(NSString *)name{
    
    NSString *path=[self cachePathForKey:name inPath:self.diskCachePath];
    
    return path;
}


/**
 拼接路径与编码后的文件
 
 @param key 文件
 @param CachePath 自定义路径
 @return 完整的文件路径
 */
- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)CachePath {
    @synchronized (self) {
        NSString *filename = [self cachedFileNameForKey:key];
        return [CachePath stringByAppendingPathComponent:filename];
    }
}

/**
 编码格式化路径
 
 @param key 要转编码的字符串
 @return 转编码后的路径
 */
- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [[key pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", [key pathExtension]]];
    return filename;
}

#pragma  mark - 计算大小与个数

/**
 显示data文件缓存大小 默认缓存路径/Library/Caches/CSKit/AppCache
 
 @return 缓存大小
 */
- (NSUInteger)getCacheSize {
    return [self getFileSizeWithpath:self.diskCachePath];
}


/**
 显示data文件缓存个数 默认缓存路径/Library/Caches/CSKit/AppCache
 
 @return 缓存文件个数
 */
- (NSUInteger)getCacheCount {
    return [self getFileCountWithpath:self.diskCachePath];
}


/**
 显示文件大小
 
 @param path 自定义路径
 @return 大小
 */
- (NSUInteger)getFileSizeWithpath:(NSString *)path{
    __block NSUInteger size = 0;
    //sync
    dispatch_sync(self.operationQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    
    return size;
}

/**
 显示文件个数
 
 @param path 自定义路径
 @return 数量
 */
- (NSUInteger)getFileCountWithpath:(NSString *)path{
    __block NSUInteger count = 0;
    //sync
    dispatch_sync(self.operationQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        count = [[fileEnumerator allObjects] count];
    });
    return count;
}


/**
 显示文件的大小(单位)
 
 @param size 得到的大小
 @return 显示的单位 GB/MB/KB
 */
- (NSString *)fileUnitWithSize:(float)size{
    if (size >= unit * unit * unit) { // >= 1GB
        return [NSString stringWithFormat:@"%.2fGB", size / unit / unit / unit];
    } else if (size >= unit * unit) { // >= 1MB
        return [NSString stringWithFormat:@"%.2fMB", size / unit / unit];
    } else { // >= 1KB
        return [NSString stringWithFormat:@"%.2fKB", size / unit];
    }
}

/**
 磁盘总空间大小
 
 @return 大小
 */
- (NSUInteger)diskSystemSpace{
    
    __block NSUInteger size = 0.0;
    dispatch_sync(self.operationQueue, ^{
        NSError *error=nil;
        NSDictionary *dic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[self homePath] error:&error];
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
        }else{
            NSNumber *systemNumber = [dic objectForKey:NSFileSystemSize];
            size = [systemNumber floatValue];
        }
    });
    return size;
    
}


/**
 磁盘空闲系统空间
 
 @return 剩余大小
 */
- (NSUInteger)diskFreeSystemSpace{
    
    __block NSUInteger size = 0.0;
    dispatch_sync(self.operationQueue, ^{
        NSError *error=nil;
        NSDictionary *dic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[self homePath] error:&error];
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
        }else{
            NSNumber *freeSystemNumber = [dic objectForKey:NSFileSystemFreeSize];
            size = [freeSystemNumber floatValue];
        }
    });
    return size;
}


/**
 返回某个路径下的所有数据文件
 
 @param path 路径
 @return 所有数据
 */
- (NSArray *)getCacheFileWithPath:(NSString *)path{
    NSMutableArray *array=[[NSMutableArray alloc]init];
    
    dispatch_sync(self.operationQueue, ^{
        
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        for (NSString *fileName in fileEnumerator)
        {
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            
            [array addObject:filePath];
        }
    });
    return array;
}


/**
 返回缓存文件的数据
 
 @param key 文件名
 @return 文件数据
 */
- (NSDictionary* )getFileAttributes:(NSString *)key{
    NSString *path =[self pathWithFileName:key];
    NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return info;
}

#pragma  mark - 清除文件


/**
 自动清除过期缓存
 */
-(void)automaticCleanCache{
    [self automaticCleanCacheWithPath:self.diskCachePath CompletionHandler:nil];
}

/**
 自动清除过期缓存
 
 @param path 路径
 @param completionHandler 完成后自定义操作
 */
- (void)automaticCleanCacheWithPath:(NSString *)path CompletionHandler:(CompletionHandler)completionHandler{
    dispatch_async(self.operationQueue,^{
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-cacheMaxCacheAge];
        
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        
        for (NSString *fileName in fileEnumerator)
        {
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            
            NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            NSDate *current = [info objectForKey:NSFileModificationDate];
            
            if ([[current laterDate:expirationDate] isEqualToDate:expirationDate])
            {
                
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                
            }
        }
        if (completionHandler) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completionHandler();
            });
        }
    });
}


/**
 后台清理缓存(监听方法)
 */
- (void)backgroundCleanCache {
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        //通过标记您在哪里，清理任何未完成的任务业务
        //停止或终止任务。
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // 启动长时间运行的任务并立即返回
    [self automaticCleanCacheWithPath:self.diskCachePath CompletionHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}


/**
 清除某一个缓存文件    默认路径/Library/Caches/CSKit/AppCache
 
 @param key 请求的协议地址
 */
- (void)clearCacheForkey:(NSString *)key{
    
    [self clearCacheForkey:key CompletionHandler:nil];
}


/**
 清除某一个缓存文件   默认路径/Library/Caches/CSKit/AppCache
 
 @param key 请求的协议地址
 @param completionHandler 完成后操作
 */
- (void)clearCacheForkey:(NSString *)key CompletionHandler:(CompletionHandler)completionHandler{
    
    [self clearCacheForkey:key path:self.diskCachePath CompletionHandler:completionHandler];
}


/**
 清除某一个缓存文件(自定义路径)
 
 @param key 请求的协议地址
 @param path 自定义路径
 @param completionHandler 完成后操作
 */
- (void)clearCacheForkey:(NSString *)key path:(NSString *)path CompletionHandler:(CompletionHandler)completionHandler{
    
    NSString *filePath=[self cachePathForKey:key inPath:path];
    dispatch_async(self.operationQueue,^{
        
        [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
        
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(),^{
                completionHandler();
            });
        }
    });
}


/**
 清除全部缓存 /Library/Caches/CSKit/AppCache
 */
- (void)clearCache{
    [self clearCacheOnCompletionHandler:nil];
}


/**
 清除全部缓存 /Library/Caches/CSKit/AppCache
 
 @param completionHandler 完成后操作
 */
- (void)clearCacheOnCompletionHandler:(CompletionHandler)completionHandler{
    
    dispatch_async(self.operationQueue, ^{
        
        //[self clearDiskWithpath:self.diskCachePath];
        [[NSFileManager defaultManager] removeItemAtPath:self.diskCachePath error:nil];
        [self createDirectoryAtPath:self.diskCachePath];
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(),^{
                completionHandler();
            });
        }
    });
}


/**
 清除某一路径下的文件
 
 @param path 路径
 */
- (void)clearDiskWithpath:(NSString *)path{
    [self clearDiskWithpath:path CompletionHandler:nil];
}


/**
 清除某一路径下的文件
 
 @param path 路径
 @param completionHandler 完成后操作
 */
- (void)clearDiskWithpath:(NSString *)path CompletionHandler:(CompletionHandler)completionHandler{
    dispatch_async(self.operationQueue, ^{
        
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        for (NSString *fileName in fileEnumerator)
        {
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            
        }
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(),^{
                completionHandler();
            });
        }
        
    });
}












#pragma mark - 获取沙盒目录
/**
 获取沙盒Home的文件目录
 
 @return Home 路径
 */
- (NSString *)homePath {
    return NSHomeDirectory();
}
/**
 获取沙盒Document的文件目录
 
 @return Document 路径
 */
- (NSString *)documentPath{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
/**
 获取沙盒Library的文件目录
 
 @return Document 路径
 */
- (NSString *)libraryPath{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}
/**
 获取沙盒Library/Caches的文件目录
 
 @return Library/Caches 路径
 */
- (NSString *)cachesPath{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}
/**
 获取沙盒tmp的文件目录
 
 @return tmp路径
 */
- (NSString *)tmpPath{
    return NSTemporaryDirectory();
}
/**
 获取沙盒自创建的CSKit文件目录
 
 @return Library/Caches/CSKit路径
 */
- (NSString *)CSKitPath{
    
    NSString* tempStr = [NSString stringWithFormat:@"%@%@",PathSpace,[self appVersionString]];
    
    return [[self cachesPath] stringByAppendingPathComponent:tempStr];
}
/**
 获取沙盒自创建的AppCache文件目录
 
 @return Library/Caches/CSKit/AppCache路径
 */
- (NSString *)CSAppCachePath{
    return self.diskCachePath;
}

//MARK: 获取应用版本号
- (NSString *)appVersionString {
    
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}



@end
