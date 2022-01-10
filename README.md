# link_bridge

Flutter 和 Native 通信桥

### 设计

1. 基于插件思想 每个Link负责自己的通信桥
2. 多个Link 管理不同业务类型的通信
3. 解耦业务因跨端通信通道数量导致的耦合

### 集成

flutter常规集成方法集成

## 使用

#### iOS端

自定义一个业务的Link, 集成FlutterChannelLink， 实现对应业务的方法调用。当前业务对的调用收归到唯一的Link内。

methodChannelName 用于方法调用 eventChannelName用于通知。

```swift
//支持Decodable
struct LinkTestData: Decodable {
    let t1: String
    let t2: String
}

class FlutterLinkTest: FlutterChannelLink {
  	var timer: Timer?
    var methodChannel: FlutterMethodChannel?
    var eventChannel: FlutterEventChannel?
    required init() {
    }
    var handlers: [SwiftFlutterBridgeHandler] = []
  	//定义当前Link 的 methodChannelName
    var methodChannelName: String? {
        return "com.jjimmy.link_test_action"
    }
  //定义当前Link 的 eventChannelName
    var eventChannelName: String? {
        return "com.jimmy.link_test_event"
    }
    
    var streamHandler: FlutterEnvironmentStreamHandler?
    func registerMethodHandlers() {
      	//注册当前link 管理的业务相关的flutter 和 native的通信方法
        handlers = [
            SwiftFlutterBridgeHandler(methodName: "link_action_1", handler: { callback in
            callback.resolve(["link_action_1" : "native_ok"])
        }),
            SwiftFlutterBridgeHandler(methodName: "link_action_2", handler: { (param: LinkTestData, callback) in
                NSLog("[Link Tag] flutter notify native data:\(param.t1) ->\(param.t2)")
                let st = "[Link Tag] flutter notify native data:\(param.t1) ->\(param.t2)"
                callback.resolve(["link_action_2" : st])
            })
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
          //native 调用flutter的方法  link_action_3 方法名
            self.methodChannel?.invokeMethod("link_action_3", arguments: ["link_action_3": "link_action_3 notify ok"])
        } 
    }
    //注册 native 主动发消息通知flutter的， flutter端监听
    func registerStreamHandlers() {
         DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if #available(iOS 10.0, *) {
                self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { _ in
                    self.streamHandler?.streamEvent?(["event": "yuyuiio"])
                })
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

```

```Swift
// 在flutter插件注册前  把对应的Link 加到 FlutterLinkChannelManger 中
FlutterLinkChannelManger.addChannel(channel: FlutterLinkTest.self)
GeneratedPluginRegistrant.register(with: self)
```



#### Android端

跟iOS的用法基本一致

```kotlin
class TestChannel(val activity: Activity): FlutterChannelLink {
    private var  t = Timer()
    override var methodChannel: MethodChannel? = null
    override var eventChannel: EventChannel? = null
    override var handlers: List<KotlinFlutterBridgeHandler> = listOf<KotlinFlutterBridgeHandler>()
    override var methodChannelName: String?
        get() = "com.jjimmy.link_test_action"
        set(value) {}

    override var eventChannelName: String?
        get() = "com.jimmy.link_test_event"
        set(value) {}

    override var streamHandler: FlutterEnviromentStreamHandler? = null

    override fun registerMethodHandlers() {
        handlers = listOf(
            KotlinFlutterBridgeHandler("link_action_1", handler = { callback ->
                callback.resolve(mapOf("link_action_1" to "native_ok"))
        }),
            KotlinFlutterBridgeHandler("link_action_2", handler = { params, callback ->
                val st = "[Link Tag] flutter notify native data: $params"
                callback.resolve(mapOf("link_action_2" to st))
            })
        )

        Timer().schedule(10000) {
            activity.runOnUiThread {
                methodChannel?.invokeMethod("link_action_3", mapOf("link_action_3" to "link_action_3 notify ok"))
            }
        }

    }

    override fun registerStreamHandlers() {
        Timer().schedule(10000) {
            t.schedule(timerTask {
                activity.runOnUiThread {
                    streamHandler?.streamEvent?.success(mapOf("event" to "yuyuiio"))
                }

            }, Date(), 2000)
        }
    }
}
```

```kotlin
//类似的只要是在flutter plugin注册到native前加入FlutterLinkChannelManager 就行
class MainActivity: FlutterActivity() {
    init {
        FlutterLinkChannelManager.addChannel(TestChannel(this))
    }
}
```

#### Flutter端

```dart
class LinkChannelTest {
  //定义跟native相同的method channel name
  static const MethodChannel channel =
      MethodChannel('com.jjimmy.link_test_action');
	//定义跟native相同的event channel name
  static const EventChannel echannel =
      EventChannel("com.jimmy.link_test_event");
  
  //调用native方法
  static Future<void> link_action_1() async {
    var r = await channel.invokeMethod('link_action_1');
    print(r);
  }
	//调用native方法  带参数的
  static Future<void> link_action_2() async {
    var r = await channel.invokeMethod(
        'link_action_2', json.encode({"t1": "t1 hahah", "t2": "t2 yyt"}));
    print(r);
  }
	
 //注册给native调用的flutter方法
  static void link_action_3() {
    channel.setMethodCallHandler(
      (call) async {
        print("link_action_3  callback ${call.method}  -> ${call.arguments}");
      },
    );
  }

  //接收native的通知
  static void link_event() {
    echannel.receiveBroadcastStream().listen(
      (data) {
        print("link_event => $data");
      },
    );
  }
}
```

