TARGET := iphone:clang:latest:15.0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = SpringBoard
include $(THEOS)/makefiles/common.mk
TWEAK_NAME = ColdWhite
ColdWhite_FILES = Tweak.xm
ColdWhite_CFLAGS = -fobjc-arc
ColdWhite_FRAMEWORKS = UIKit CoreGraphics
include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += ColdWhitePrefs
include $(THEOS_MAKE_PATH)/aggregate.mk
after-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences
	cp ColdWhitePrefs/ColdWhitePrefs.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/
