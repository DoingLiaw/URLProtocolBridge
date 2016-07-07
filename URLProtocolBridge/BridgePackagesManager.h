//
//  BridgePackagesManager.h
//  HybridAppExample
//
//  Created by Doing Liaw on 16/7/2.
//  Copyright © 2016年 Doing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BridgePackage.h"
#import "DataBridge.h"

@interface BridgePackagesManager : NSObject

+(BridgePackagesManager *)shareManager;

-(void)startWithWebView:(UIWebView *)webView notificationCenterName:(NSString * )name host:(NSString * )host;

-(void)send:(NSString *)tag message:(NSDictionary *)data;

-(void)setHost:(NSString *)url;

-(void)add:(BridgePackage *)package withName:(NSString *)name;

-(void)callMethodWith:(NSURLProtocol *)protocol;

-(BOOL)matchHostWith:(NSString *)host;

@end
