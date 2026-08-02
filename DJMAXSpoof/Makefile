TARGET := iphone:clang:13.7:6.0
ARCHS = armv7

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DJMAXSpoof

DJMAXSpoof_FILES = Tweak.x
DJMAXSpoof_CFLAGS = -fobjc-arc -fno-modules

include $(THEOS_MAKE_PATH)/tweak.mk
