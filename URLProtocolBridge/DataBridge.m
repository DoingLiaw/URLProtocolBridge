//
//  DataBridge.m
//  HybridAppExample
//
//  Created by Doing Liaw on 16/7/4.
//  Copyright © 2016年 Doing. All rights reserved.
//

#import "DataBridge.h"

@interface DataBridge()

@property(nonatomic,strong) NSURLProtocol * protocol;
@property(nonatomic,strong) NSDictionary * parameters;

@end

@implementation DataBridge

-(id)initWithProtocol:(NSURLProtocol *)protocol{
    if(self = [super init]){
        self.protocol = protocol;
        NSString * dataString =  [[NSString alloc]initWithData:self.protocol.request.HTTPBody encoding:NSUTF8StringEncoding];
        
        self.parameters = [self parseParametersStringToDictionary:dataString];
    }
    return self;
}

-(NSString *)getValueWithKey:(NSString *)key{
    if( !self.protocol ){
        NSLog(@"already return");
    }
    return [self.parameters valueForKey:key];
}

-(void)setReturn:(NSInteger)code msg:(NSString *)msg data:(NSDictionary *)data{
    if( !self.protocol ){
        NSLog(@"only can return once");
        return;
    }
    
    NSMutableDictionary * resultDic = [[NSMutableDictionary alloc]init];
    
    [resultDic setObject:[NSNumber numberWithInteger:code] forKey:@"code"];
    
    if(msg){
        [resultDic setObject:msg forKey:@"msg"];
    }
    
    if(data){
        [resultDic setObject:data forKey:@"data"];
    }
    
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:nil];
    
    NSURLResponse * response = [[NSURLResponse alloc]initWithURL:self.protocol.request.URL MIMEType:@"data/*" expectedContentLength:jsonData.length textEncodingName:@"utf-8"];
    
    [self.protocol.client URLProtocol:self.protocol didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowedInMemoryOnly];
    [self.protocol.client URLProtocol:self.protocol didLoadData:jsonData];
    [self.protocol.client URLProtocolDidFinishLoading:self.protocol];
    
    self.protocol = nil;
}

-(NSDictionary *)parseParametersStringToDictionary:(NSString *)parameters{
    
    NSMutableDictionary * result = [[NSMutableDictionary alloc]init];
    NSArray * parasArray = [parameters componentsSeparatedByString:@"&"];
    
    for (NSString * para in parasArray) {
        NSArray * keyValue = [para componentsSeparatedByString:@"="];
    
        if(keyValue.count == 2){
            [result setValue:keyValue[1] forKey:keyValue[0]];
        }
    }
    
    return result;
}

@end

