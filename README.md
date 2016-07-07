# URLProtocolBridge
use NSURLProtocol and UIWebView to build a hybrid app
##Install
1.add the URLProtocolBridge project to your project 
2.add the `libURLProtocolBridge.a` to the `Link Binary With Libraries`
##Usage
in objc:
```
[[BridgePackagesManager shareManager]startWithWebView:rootWebView notificationCenterName:@"NotificationCenter" host:@"crossapi.test.com"];//init;the notificationCenterName use in the js; host match the bridge api 
[[BridgePackagesManager shareManager]add:[Device new] withName:@"device"];//add package
```
in js:
```
var Crossapi = function(url,parameters,callback){
                var request = new XMLHttpRequest();
                var parametersString = "";
                if(parameters){
                    for(var key in parameters){
                        parametersString += (key+'='+parameters[key]+'&');
                    }
                }
                request.open("POST",'http://crossapi.test.com'+url);
                request.onreadystatechange = function(){
                    if(request.readyState === XMLHttpRequest.DONE ){
                        callback && callback(request.responseText);
                    }
                };
        request.send(parametersString);
};
button1.onclick=function(){//invoke
    Crossapi("/device/sayHello",{test:"你好"},function(data){
             alert(data);
    });
};
       
//in objc:[[BridgePackagesManager shareManager]send:@"testMessage" message:@{@"message":@"go"}];
//in js:
window.NotificationCenter.addEventListener("testMessage",function(data){
     alert(JSON.stringify(data));//data={message:'go'}
});
```

in objc package:
```
//interface
#import <Foundation/Foundation.h>
#import "BridgePackage.h"
@interface Device : BridgePackage
-(void)sayHello:(DataBridge *)bridge;
@end

//implement
#import "Device.h"
#import "BridgePackagesManager.h"
@implementation Device
-(void)sayHello:(DataBridge *)bridge{
    NSString * value = [bridge getValueWithKey:@"test"];//'你好'
    [bridge setReturn:0 msg:@"hello" data:@{@"data":value}];//js can receive {code:0,msg:'hello',data:{'data':你好}}
}
@end
```


