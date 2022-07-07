package com.fl.rangers.app.log

import android.content.Context
import android.util.Log
import com.bytedance.applog.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import org.json.JSONObject

/**
 * FlRangersAppLogPlugin
 */
class FlRangersAppLogPlugin : FlutterPlugin, MethodCallHandler {
    private var context: Context? = null
    private var channel: MethodChannel? = null

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.fl.rangers.app.log")
        context = binding.applicationContext
        channel!!.setMethodCallHandler(this)
        val dataObserver = InnerDataObserver(channel!!)
        AppLog.addDataObserver(dataObserver)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel!!.setMethodCallHandler(null)
        AppLog.removeAllDataObserver()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initRangersAppLog" -> {
                val initConfig = InitConfig(
                    call.argument("appId")!!, call.argument("channel")!!
                )
                initConfig.setAutoStart(true)
                initConfig.isAbEnable = call.argument("enable_ab")!!
                AppLog.setEncryptAndCompress(call.argument("enable_encrypt")!!)
                if (call.argument<Boolean>("enable_log")!!) {
                    initConfig.logger = ILogger { s, _ -> Log.d("AppLog------->: ", "" + s) }
                }
                val host = call.argument<String?>("host")
                if (host != null) {
                    initConfig.uriConfig = UriConfig.createByDomain(host, null)
                }
                AppLog.init(context!!, initConfig)
                result.success(true)
            }
            "getDeviceId" -> result.success(AppLog.getDid())
            "getAbSdkVersion" -> result.success(AppLog.getAbSdkVersion())
            "getAllAbTestConfig" -> result.success(null)
            "getABTestConfigValueForKey" -> result.success(
                AppLog.getAbConfig(
                    call.argument("key"), call.argument("default")
                )
            )
            "onEventV3" -> {
                AppLog.onEventV3(call.argument<String>("event")!!, getJsonFromMap(call, "param"))
                result.success(true)
            }
            "setUserUniqueId" -> {
                AppLog.setUserUniqueID(call.arguments as String)
                result.success(true)
            }
            "setHeaderInfo" -> {
                AppLog.setHeaderInfo(call.arguments as HashMap<String, Any>?)
                result.success(true)
            }
            "removeHeaderInfo" -> {
                AppLog.removeHeaderInfo(call.arguments as String)
                result.success(true)
            }
            "profileSet" -> {
                AppLog.profileSet(getJsonFromMap(call, null))
                result.success(true)
            }
            "profileSetOnce" -> {
                AppLog.profileSetOnce(getJsonFromMap(call, null))
                result.success(true)
            }
            "profileIncrement" -> {
                AppLog.profileIncrement(getJsonFromMap(call, null))
                result.success(true)
            }
            "profileAppend" -> {
                AppLog.profileAppend(getJsonFromMap(call, null))
                result.success(true)
            }
            "profileUnSet" -> {
                AppLog.profileUnset(call.arguments as String)
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun getJsonFromMap(call: MethodCall, paramKey: String?): JSONObject {
        var paramMap = call.arguments as Map<*, *>
        if (paramKey != null) paramMap = paramMap[paramKey] as Map<*, *>
        val paramJson = JSONObject()
        for ((key, value) in paramMap) {
            paramJson.put(key as String, value)
        }
        return paramJson
    }


    private class InnerDataObserver(private val channel: MethodChannel) : IDataObserver {
        override fun onIdLoaded(s: String, s1: String, s2: String) {}
        override fun onRemoteIdGet(
            b: Boolean, s: String, s1: String, s2: String, s3: String, s4: String, s5: String
        ) {
        }

        override fun onRemoteConfigGet(b: Boolean, jsonObject: JSONObject) {}
        override fun onRemoteAbConfigGet(b: Boolean, jsonObject: JSONObject) {
            channel.invokeMethod("onABTest", jsonObject.toString())
        }

        override fun onAbVidsChange(s: String, s1: String) {
            channel.invokeMethod("onABTestVidsChanged", arrayListOf(s, s1));
        }
    }
}