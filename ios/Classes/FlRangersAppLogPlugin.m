#import "FlRangersAppLogPlugin.h"
#import <RangersAppLog/RangersAppLogCore.h>

@interface FlRangersAppLogPlugin ()
@end

@implementation FlRangersAppLogPlugin

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"com.fl.rangers.app.log"
                                                                binaryMessenger:[registrar messenger]];
    FlRangersAppLogPlugin *instance = [[FlRangersAppLogPlugin alloc] init];
    instance.channel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onABTestSuccess:)
                                                     name:BDAutoTrackNotificationABTestSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onABTestVidsChanged:)
                                                     name:BDAutoTrackNotificationABTestSuccess object:nil];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {

    if ([@"initialize" isEqualToString:call.method]) {
        NSString *appID = call.arguments[@"appId"];
        NSString *channel = call.arguments[@"channel"];
        //        BOOL enableAB = call.arguments[@"enable_ab"];
        BOOL enableEncrypt = [call.arguments[@"enable_encrypt"] boolValue];
        BOOL enableDebugLog = [call.arguments[@"enable_log"] boolValue];
        NSString *host = call.arguments[@"host"];
        BDAutoTrackConfig *config = [BDAutoTrackConfig configWithAppID:appID];
        if ([channel isKindOfClass:NSString.class] && channel.length > 0) {
            config.channel = channel;
        }
        config.logNeedEncrypt = enableEncrypt;
        //        config.abEnable = enableAB;
        config.showDebugLog = enableDebugLog;
        config.serviceVendor = BDAutoTrackServiceVendorCN;
#if DEBUG
        config.showDebugLog = YES;
        config.logger = ^(NSString *log) {
            NSLog(@"flutter-plugin applog %@", log);
        };
#endif
        if ([host isKindOfClass:NSString.class] && host.length > 0) {
            [BDAutoTrack setRequestURLBlock:^NSString *_Nullable(BDAutoTrackServiceVendor vendor, BDAutoTrackRequestURLType requestURLType) {
                return host;
            }];
        }
        [BDAutoTrack startTrackWithConfig:config];
        result(@(YES));
    } else if ([call.method isEqualToString:@"getDeviceId"]) {
        result([BDAutoTrack rangersDeviceID]);
    } else if ([call.method isEqualToString:@"getAbSdkVersion"]) {
        result([BDAutoTrack allAbVids]);
    } else if ([call.method isEqualToString:@"getAllAbTestConfig"]) {
        result([BDAutoTrack allABTestConfigs]);
    } else if ([call.method isEqualToString:@"getABTestConfigValueForKey"]) {
        NSString *key = call.arguments[@"key"];
        NSString *defaultStr = call.arguments[@"default"];
        [BDAutoTrack ABTestConfigValueForKey:key defaultValue:defaultStr];
        result(@"");
    } else if ([call.method isEqualToString:@"onEventV3"]) {
        NSString *event = call.arguments[@"event"];
        NSDictionary *param = call.arguments[@"param"];
        BOOL ret = [BDAutoTrack eventV3:event params:param];
        result(@(ret));
    } else if ([call.method isEqualToString:@"setUserUniqueId"]) {
        [BDAutoTrack setCurrentUserUniqueID:call.arguments];
        result(@(YES));
    } else if ([call.method isEqualToString:@"setHeaderInfo"]) {
        NSDictionary *customHeader = call.arguments;
        [BDAutoTrack setCustomHeaderBlock:^NSDictionary<NSString *, id> *_Nonnull {
            return customHeader;
        }];
        result(@(YES));
    } else if ([call.method isEqualToString:@"removeHeaderInfo"]) {
        //        NSString *key = call.arguments;
        result(@(YES));
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)onABTestSuccess:(NSNotification *)notification {
    [_channel invokeMethod:@"onABTestSuccess" arguments:notification.userInfo];
}

- (void)onABTestVidsChanged:(NSNotification *)notification {
    [_channel invokeMethod:@"onABTestVidsChanged" arguments:notification.userInfo];
}

@end
