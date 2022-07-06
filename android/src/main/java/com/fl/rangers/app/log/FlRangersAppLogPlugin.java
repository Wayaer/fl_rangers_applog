package com.fl.rangers.app.log;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.bytedance.applog.AppLog;
import com.bytedance.applog.ILogger;
import com.bytedance.applog.InitConfig;
import com.bytedance.applog.UriConfig;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlRangersAppLogPlugin
 */
public class FlRangersAppLogPlugin implements FlutterPlugin, MethodCallHandler {

    private Context context;
    private MethodChannel channel;

    @Override
    public void onMethodCall(MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "initRangersAppLog":
                InitConfig initConfig = new InitConfig((String) Objects.requireNonNull(call.argument("appid")), (String) call.argument("channel"));
                initConfig.setAutoStart(true);
                initConfig.setAbEnable((Boolean) call.argument("enable_ab"));
                AppLog.setEncryptAndCompress((Boolean) call.argument("enable_encrypt"));
                if ((Boolean) call.argument("enable_log")) {
                    initConfig.setLogger(new ILogger() {
                        @Override
                        public void log(String s, Throwable throwable) {
                            Log.d("AppLog------->: ", "" + s);
                        }
                    });
                }
                if ((String) call.argument("host") != null) {
                    initConfig.setUriConfig(UriConfig.createByDomain((String) call.argument("host"), null));
                }
                AppLog.init(context, initConfig);
                break;
            case "getDeviceId":
                result.success(AppLog.getDid());
                break;
            case "getAbSdkVersion":
                result.success(AppLog.getAbSdkVersion());
                break;
            case "getABTestConfigValueForKey":
                result.success(AppLog.getAbConfig((String) call.argument("key"), call.argument("default")));
                break;
            case "onEventV3":
                String eventName = (String) call.argument("event");
                assert eventName != null;
                AppLog.onEventV3(eventName, getJsonFromMap(call, "param"));
                break;
            case "setUserUniqueId":
                AppLog.setUserUniqueID((String) call.argument("uuid"));
                break;
            case "setHeaderInfo":
                AppLog.setHeaderInfo((HashMap<String, Object>) call.argument("customHeader"));
                break;
            case "profileSet":
                AppLog.profileSet(getJsonFromMap(call, "profileDict"));
                break;
            case "profileSetOnce":
                AppLog.profileSetOnce(getJsonFromMap(call, "profileDict"));
                break;
            case "profileIncrement":
                AppLog.profileIncrement(getJsonFromMap(call, "profileDict"));
                break;
            case "profileAppend":
                AppLog.profileAppend(getJsonFromMap(call, "profileDict"));
                break;
            case "profileUnSet":
                AppLog.profileUnset((String) call.argument("key"));
                break;
            case "getAllAbTestConfig":
                break;
            case "removeHeaderInfo":
                AppLog.removeHeaderInfo((String) call.argument("key"));
            default:
                result.notImplemented();
                break;
        }
    }

    private JSONObject getJsonFromMap(MethodCall call, String param) {
        HashMap<String, Object> paramMap = (HashMap<String, Object>) call.argument(param);
        JSONObject paramJson = new JSONObject();
        assert paramMap != null;
        for (Map.Entry<String, Object> entry : paramMap.entrySet()) {
            try {
                paramJson.put(entry.getKey(), entry.getValue());
            } catch (JSONException ignored) {
            }
        }
        return paramJson;
    }


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "com.fl.rangers.app.log");
        context = binding.getApplicationContext();
        channel.setMethodCallHandler(this);
        FlRangersAppLogEvent.init(binding);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

}
