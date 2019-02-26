#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "WebVC.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    
    FlutterViewController *controller = (FlutterViewController *)self.window.rootViewController;
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"baizi.io.flutter_open_native" binaryMessenger:controller];
    [channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        if ([@"open_webview" isEqualToString:call.method]) {
            result(@"调用成功");
            NSString *url = call.arguments[@"url"];
            if ([url isKindOfClass:[NSString class]] && url.length > 0) {
                WebVC *webVC = [[WebVC alloc] initWithUrlString:url];
                UINavigationController* navigationController =
                [[UINavigationController alloc] initWithRootViewController:webVC];
                navigationController.navigationBar.topItem.title = @"浏览器";
                [controller presentViewController:navigationController animated:YES completion:nil];
                result(@1);
            }else {
                result(@0);
            }
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
    
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
