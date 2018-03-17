LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := lua_pluginx_static

LOCAL_MODULE_FILENAME := libcocos2dxluapluginx

LUA_INCLUDE_PATH := $(LOCAL_PATH)/../../external/lua/luajit/include

LOCAL_SRC_FILES := \
auto/lua_cocos2dx_pluginx_auto.cpp \
manual/lua_pluginx_basic_conversions.cpp \
manual/lua_pluginx_manual_callback.cpp \
manual/lua_pluginx_manual_protocols.cpp

LOCAL_CFLAGS := -std=c++11

LOCAL_C_INCLUDES := \
$(LOCAL_PATH)/../../external/lua/tolua \
$(LUA_INCLUDE_PATH) \
$(LOCAL_PATH)/../../cocos/scripting/lua-bindings/manual \
$(LOCAL_PATH)/manual \
$(LOCAL_PATH)/auto \
$(LOCAL_PATH)/../../cocos \
$(LOCAL_PATH)/../protocols/include 
                   

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/manual \
                           $(LOCAL_PATH)/auto

LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static
LOCAL_WHOLE_STATIC_LIBRARIES += PluginProtocolStatic

include $(BUILD_STATIC_LIBRARY)

$(call import-module,.)
$(call import-module,plugin/protocols/proj.android/jni)
