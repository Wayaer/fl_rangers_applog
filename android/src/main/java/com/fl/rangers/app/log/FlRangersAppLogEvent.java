package com.fl.rangers.app.log;

import android.os.Handler;
import android.os.Looper;

import com.bytedance.applog.AppLog;
import com.bytedance.applog.IDataObserver;

import org.json.JSONObject;

import java.util.HashSet;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;

class FlRangersAppLogEvent {

    private static InnerDataObserver dataObserver;
    private static boolean init;

    private FlRangersAppLogEvent() {
    }

    static void init(FlutterPlugin.FlutterPluginBinding binding) {
        if (!init) {
            dataObserver = new InnerDataObserver();
            AppLog.addDataObserver(dataObserver);
            EventChannel eventChannel = new EventChannel(binding.getBinaryMessenger(), "com.fl.rangers.app.log/event");
            eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
                @Override
                public void onListen(Object args, EventChannel.EventSink events) {
                    dataObserver.setEventSink(events);
                }

                @Override
                public void onCancel(Object args) {
                }
            });
            init = true;
        }
    }

    private static class InnerDataObserver implements IDataObserver {

        private EventChannel.EventSink eventSink;
        private final Handler handler;
        private final HashSet<Object> cache;

        public InnerDataObserver() {
            this.handler = new Handler(Looper.getMainLooper());
            cache = new HashSet<>();
        }

        private void sendEvent(final Object event) {
            handler.post(() -> {
                if (eventSink == null) {
                    cache.add(event);
                } else {
                    eventSink.success(event);
                }
            });
        }

        public void setEventSink(final EventChannel.EventSink events) {
            handler.post(() -> {
                if (events != eventSink) {
                    eventSink = events;
                    for (Object event : cache) {
                        eventSink.success(event);
                    }
                    cache.clear();
                }
            });
        }

        @Override
        public void onIdLoaded(String s, String s1, String s2) {
        }

        @Override
        public void onRemoteIdGet(boolean b, String s, String s1, String s2, String s3, String s4, String s5) {
        }

        @Override
        public void onRemoteConfigGet(boolean b, JSONObject jsonObject) {
        }

        @Override
        public void onRemoteAbConfigGet(boolean b, JSONObject jsonObject) {
            sendEvent("onABTestSuccess");
        }

        @Override
        public void onAbVidsChange(String s, String s1) {
            sendEvent("onABTestVidsChanged");
        }
    }
}
