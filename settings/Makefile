include theos/makefiles/common.mk

BUNDLE_NAME = MobileNotifierSettings
MobileNotifierSettings_FILES = MobileNotifierSettings.mm
MobileNotifierSettings_INSTALL_PATH = /Library/PreferenceBundles
MobileNotifierSettings_FRAMEWORKS = UIKit
MobileNotifierSettings_PRIVATE_FRAMEWORKS = Preferences

include $(FW_MAKEDIR)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(FW_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(FW_STAGING_DIR)/Library/PreferenceLoader/Preferences/MobileNotifierSettings.plist$(ECHO_END)
