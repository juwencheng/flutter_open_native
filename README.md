## 背景

在项目中，有在App内打开三方网站的需求，找了几个`Flutter`的插件，和需求最匹配的是`flutter_webview_plugin`，可集成到项目中以后，出现明显的卡顿现象，因此无法较好的满足需求。
回想`Flutter`官方给出的例子，其中有一个就是切换原生界面和`Flutter`界面的，于是尝试实现效果。
PS：在实现之前，本想封装成插件，结果写完插件的联通方法后，发现无法操作界面，于是重新回到上面的思路，只能写死到项目中。首先介绍下如何使用插件来打通原生和`Flutter`，使用 `iOS` 代码演示。

## 插件实现

大致思路是，`Flutter` 和 `iOS` 之间定义好 Channel 名，可以理解为一个通信频道，建立后，可以相互发送消息，接收到消息后，执行各自的操作，由此可以看出几点注意事项

1. 打开一个相同的 Channel 频道，如果没法通信，请仔细检查名称是否正确。
2. 发送和接收要对应，从 `Flutter` 发送一条消息给原生，原生对应有个方法来处理改消息。当然，不处理不会有问题，养成习惯，先检测通信是否正常，再做其他逻辑操作。
接下来就是详细的步骤

### 创建项目

通过 Android Studio 创建 Flutter 项目，选择 Plugin 类型，如图  
![屏幕快照 2019-02-26 下午4.42.45.png](https://groups.google.com/group/baizi-blog/attach/6be997a0cfab2/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-02-26%20%E4%B8%8B%E5%8D%884.42.45.png?part=0.5&view=1&authuser=1)

### 运行项目

创建好后，直接运行项目，启动后`Flutter`默认会通过`Channel`获取系统版本，结果如下

![屏幕快照 2019-02-26 下午4.45.24.png](https://groups.google.com/group/baizi-blog/attach/6be997a0cfab2/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-02-26%20%E4%B8%8B%E5%8D%884.45.24.png?part=0.6&view=1&authuser=1)

### 在`Flutter`端编写调用方法测试代码

打开 lib 下的文件（该文件和插件名一致，我的叫flutter_open_native_page），新增名为`ping`的方法

```dart
static Future<String> ping() async {
  final String result = await _channel.invokeMethod("ping");
  return result;
}
```

### 在 `iOS` 端编写响应方法实现代码
打开 iOS/Classes/ 下的文件的 .m 文件，和上面一样，和插件名对应的，我的为 FlutterOpenNativePlugin.m，在 `- handleMethodCall:result:` 方法中新增接收到`ping`消息的实现方法

```objectivec
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if([@"ping" isEqualToString:call.method]){
    result(@"从iOS返回: pong");
  } else {
    result(FlutterMethodNotImplemented);
  }
}
```

### 测试插件

打开 example/lib/main.dart 文件，在 `initState` 方法中新增`testPing`方法，

```dart
void testPing() async {  
  String result;  
  
  try {  
  result = await FlutterOpenNative.ping();  
 } on PlatformException {  
  result = "通信故障，检查channel名是否匹配";  
 }  
  print("结果：$result");  
}
```

更多的用法请参考官网。下面进入主题，实现`Flutter`打开原生界面的代码。

  
## `Flutter` 打开原生界面

通过上文的介绍，大致了解了如何实现相互调用。也可以看到，插件代码并未涉及到界面相关的代码，没有合适的入口就无法打开新的界面。通过查看`Flutter`官方 [Demo PlatformView](https://github.com/flutter/flutter/tree/master/examples/platform_view) 发现了合适的入口，即`AppDelegate`。先修改 `AppDelegate` 中的处理代码，然后再实现`Flutter`的调用。

### AppDelegate 中的处理代码

下面是 `PlatformView` 的代码

```objectivec
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  FlutterViewController* controller =
  (FlutterViewController*)self.window.rootViewController;
  FlutterMethodChannel* channel =
  [FlutterMethodChannel methodChannelWithName:@"samples.flutter.io/platform_view"
                              binaryMessenger:controller];
  [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    if ([@"switchView" isEqualToString:call.method]) {
      _flutterResult = result;
      PlatformViewController* platformViewController =
      [controller.storyboard instantiateViewControllerWithIdentifier:@"PlatformView"];
      platformViewController.counter = ((NSNumber*)call.arguments).intValue;
      platformViewController.delegate = self;
      UINavigationController* navigationController =
      [[UINavigationController alloc] initWithRootViewController:platformViewController];
      navigationController.navigationBar.topItem.title = @"Platform View";
      [controller presentViewController:navigationController animated:NO completion:nil];
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
```

我们做适当修改，如下

```objectivec

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  FlutterViewController* controller =
  (FlutterViewController*)self.window.rootViewController;
  FlutterMethodChannel* channel =
  [FlutterMethodChannel methodChannelWithName:@"io.baizi.flutter_open_native"
                              binaryMessenger:controller];
  [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    if ([@"open_webview" isEqualToString:call.method]) { // 修改了方法名
      UIViewController *vc = [[UIViewController alloc] init]; // 使用最简单的viewcontroller
      vc.view.backgroundColor = [UIColor whiteColor]; // 不设置背景颜色，会出现空白，并且掉帧情
      UINavigationController* navigationController =
      [[UINavigationController alloc] initWithRootViewController:vc];
      navigationController.navigationBar.topItem.title = @"浏览器";
      [controller presentViewController:navigationController animated:YES completion:nil];// 增加动画，否则不容易看出来变化
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
```


### Flutter 端调用代码实现

在 example/lib/main.dart 中，增加一个 `FloatingActionButton` ，点击后通过 `MethodChannel` 向原生发送消息，打开新的VC。

```dart
@override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {
          _methodChannel
              .invokeMethod("open_webview");
        }),
      ),
    );
  }
```

别忘了定义 `_methodChannel` ，在`_MyAppState` 类中定义

```dart

static const MethodChannel _methodChannel =

MethodChannel('baizi.io.flutter_open_native');

```

运行代码测试是否打开了新界面。

### 后续

只要能打开原生界面，后面的流程就与`Flutter`无关了，可以起飞～～。完结之前，还有个小知识，就是`Flutter`调用方法时，传递参数，方法如下

```dart
static const MethodChannel _methodChannel =
MethodChannel('baizi.io.flutter_open_native', {url: "https://www.baidu.com"});
```

接收参数代码

```objc
NSString *url = call.arguments[@"url"];  
```

完结🎉