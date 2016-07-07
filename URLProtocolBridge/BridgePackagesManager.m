//
//  BridgePackagesManager.m
//  HybridAppExample
//
//  Created by Doing Liaw on 16/7/2.
//  Copyright © 2016年 Doing. All rights reserved.
//
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#define THROW(name,reasons) \
    @throw [[NSException alloc] initWithName:name reason:reasons userInfo:nil];

#import "BridgePackagesManager.h"
#import "BridgeURLProtocol.h"

@interface BridgePackagesManager()

@property(nonatomic,strong)NSMutableDictionary * packages;
@property(nonatomic,strong)NSString * host;
@property(nonatomic,strong)UIWebView * webView;
@property(nonatomic,strong)NSString * notificationCenterName;

@end

@implementation BridgePackagesManager


+(BridgePackagesManager *)shareManager
{
    static BridgePackagesManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BridgePackagesManager alloc] init];
    });
    return instance;
}

-(instancetype)init{
    if(self = [super init]){
        self.packages = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)startWithWebView:(UIWebView *)webView notificationCenterName:(NSString * )name host:(NSString * )host{
    
    self.webView = webView;
    self.host = host;
    self.notificationCenterName = name;
    
    NSString * initJS = [NSString stringWithFormat:@"(function(){var __notificationCenter = {};__notificationCenter._funcs = {};__notificationCenter.addEventListener=function(name,func){if(!__notificationCenter._funcs[name]){__notificationCenter._funcs[name]=[];}__notificationCenter._funcs[name].push(func);};__notificationCenter.removeEventListener=function(name,func){var funcs=__notificationCenter._funcs[name];if(!funcs)return;if(func){var index=funcs.indexOf(func);if(index>=0)funcs.splice(index,1);}else{__notificationCenter._funcs[name]=null;}};__notificationCenter.send=function(name,data){var funcs=__notificationCenter._funcs[name];if(!funcs)return;for(var key in funcs){funcs[key](data);}};window.%@ = __notificationCenter;})();",self.notificationCenterName];
    
    [webView stringByEvaluatingJavaScriptFromString:initJS];
    [NSURLProtocol registerClass:[BridgeURLProtocol class]];
}

-(BOOL)matchHostWith:(NSString *)host{
    if(!self.host){
        return NO;
    }
    if([self.host isEqualToString:host]){
        return YES;
    }
    return NO;
}

-(void)add:(BridgePackage *)package withName:(NSString *)name{
    [self.packages setObject:package forKey:name];
}

-(void)callMethodWith:(NSURLProtocol *)protocol{
    
    DataBridge * bridge = [[DataBridge alloc]initWithProtocol:protocol];
    
    if( protocol.request.URL.pathComponents && protocol.request.URL.pathComponents.count > 2){
        
        [self callPackage:protocol.request.URL.pathComponents[1] method:protocol.request.URL.pathComponents[2] withBridge:bridge];
        
        return;
    }
    
    [bridge setReturn:1 msg:@"没有该方法" data:nil];
    
}

-(void)callPackage:(NSString *)packageName method:(NSString *)methodName withBridge:(DataBridge *)bridge{
    
    @try {
        id package = [self.packages objectForKey:packageName];
        if(!package){
            NSString * string = [NSString stringWithFormat:@"have't the package %@",packageName];
            THROW(@"error",string);
        }
        
        SEL method = NSSelectorFromString(methodName);
        SEL methodWithBridge = NSSelectorFromString([NSString stringWithFormat:@"%@:",methodName]);
        
        if([package respondsToSelector:method]){
            [package performSelector:method withObject:bridge];
        }else if([package respondsToSelector:methodWithBridge]){
            [package performSelector:methodWithBridge withObject:bridge];
        }else{
            @throw [[NSException alloc] initWithName:@"ERROR" reason:[NSString stringWithFormat:@" the package %@ haven't the method %@",packageName,methodName] userInfo:nil];
        }
        
    } @catch (NSException *exception) {
        [bridge setReturn:1 msg:exception.reason data:nil];
        NSLog(@"%@,%@",exception.name,exception.reason);
        }
    @finally {
        
    }
}


-(void)send:(NSString *)tag message:(NSDictionary *)data{
    
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString * jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString * injectMessage = [NSString stringWithFormat:@"%@.send('%@',%@);",self.notificationCenterName,tag,jsonString];
    
    [self.webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:injectMessage waitUntilDone:NO];
}


@end
