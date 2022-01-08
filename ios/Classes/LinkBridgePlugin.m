#import "LinkBridgePlugin.h"
#if __has_include(<link_bridge/link_bridge-Swift.h>)
#import <link_bridge/link_bridge-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "link_bridge-Swift.h"
#endif

@implementation LinkBridgePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLinkBridgePlugin registerWithRegistrar:registrar];
}
@end
