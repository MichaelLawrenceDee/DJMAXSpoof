TARGET := iphone:clang:13.7:6.0
ARCHS = armv7

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WirewayAudioFix

# MUST match your file name in the root (e.g. WirewayAudioFix.x or Tweak.x)
WirewayAudioFix_FILES = WirewayAudioFix.x
WirewayAudioFix_FRAMEWORKS = AudioToolbox
WirewayAudioFix_CFLAGS = -fobjc-arc -fno-modules -Wno-deprecated-module-dot-map

include $(THEOS_MAKE_PATH)/tweak.mk
