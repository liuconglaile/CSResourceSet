//
//  ViewController.m
//  CSNetworkRequestTool
//
//  Created by mac on 17/2/25.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import "CSURLSessionTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* url = @"https://api.cs.juworker.com/home/index/get/";
    
    [CSURLSessionTool postRequestWithURL:url Parameters:@{} CacheType:CSCacheTypeReturnCacheDataThenLoad completionHandler:^(id data, NSError *error) {
        
        if (!error) {
            NSLog(@"请求成功!返回数据:%@",data);
        }else{
            NSLog(@"请求失败,原因:%@",error);
        }
        
    }];
    
}



@end
