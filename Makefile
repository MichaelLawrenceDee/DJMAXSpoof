TARGET = iphone:clang:latest:7.0
ARCHS = armv7

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DJMAXSpoof
DJMAXSpoof_FILES = Tweak.x
DJMAXSpoof_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
