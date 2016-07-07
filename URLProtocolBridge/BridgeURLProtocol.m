//
//  WebBridgeProtocol.m
//  HybridAppExample
//
//  Created by Doing Liaw on 16/6/30.
//  Copyright © 2016年 Doing. All rights reserved.
//

#import "BridgeURLProtocol.h"
#import "BridgePackagesManager.h"

#define kProtocolHandledKey @"BridgeProtocolHandledKey"

@interface BridgeURLProtocol()
@property (strong, nonatomic) NSURLSessionTask *sessionTask;;
@end

@implementation BridgeURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([NSURLProtocol propertyForKey:kProtocolHandledKey inRequest:request]) {
        return NO;
    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    //这边最好直接返回request
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    //这里一般默认返回super
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [self.request mutableCopy];

    if([[BridgePackagesManager shareManager] matchHostWith:request.URL.host]){
    
        [[BridgePackagesManager shareManager] callMethodWith:self];
       
        return;
    }
    // 给我们处理过的请求设置一个标识符
    [NSURLProtocol setProperty:@(YES) forKey:kProtocolHandledKey inRequest:request];
    
    __weak typeof(self) weakSelf = self;
    
    self.sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            return;
        }
        NSString *mimeType = response.MIMEType;
        if ([mimeType hasPrefix:@"image"]) {
            
        }
        [weakSelf.client URLProtocol:weakSelf didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowedInMemoryOnly];
        [weakSelf.client URLProtocol:weakSelf didLoadData:data];
        [weakSelf.client URLProtocolDidFinishLoading:weakSelf];
        
    }];
    [self.sessionTask resume];
}

- (void)stopLoading {
    [self.sessionTask cancel];
    self.sessionTask = nil;
}


@end
