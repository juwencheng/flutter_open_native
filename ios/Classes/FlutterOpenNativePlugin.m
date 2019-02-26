#import "FlutterOpenNativePlugin.h"

@implementation FlutterOpenNativePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_open_native"
            binaryMessenger:[registrar messenger]];
  FlutterOpenNativePlugin* instance = [[FlutterOpenNativePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if([@"ping" isEqualToString:call.method]){
    result(@"从iOS返回: pong");
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
