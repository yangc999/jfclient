LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := dragonbones_static

LOCAL_MODULE_FILENAME := libdragonbones


LOCAL_SRC_FILES := ../../../../../prebuilt/android/$(TARGET_ARCH_ABI)/libdragonbones.a



LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../../.. \
$(LOCAL_PATH)/../../../.. \
$(LOCAL_PATH)/../../../../../external/sources

LOCAL_CFLAGS += -Wno-psabi
LOCAL_EXPORT_CFLAGS += -Wno-psabi

include $(PREBUILT_STATIC_LIBRARY)
