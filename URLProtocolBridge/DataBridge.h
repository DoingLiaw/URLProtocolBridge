//
//  DataBridge.h
//  HybridAppExample
//
//  Created by Doing Liaw on 16/7/4.
//  Copyright © 2016年 Doing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBridge : NSObject

-(id)initWithProtocol:(NSURLProtocol *)protocol;

-(void)setReturn:(NSInteger)code msg:(NSString * )msg data:(NSDictionary *)data;

-(NSString * )getValueWithKey:(NSString *)key;

@end
