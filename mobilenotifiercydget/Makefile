include theos/makefiles/common.mk

BUNDLE_NAME  = MobileNotifierCydgetCydget
MobileNotifierCydgetCydget_RESOURCE_DIRS = cydget_resources
MobileNotifierCydgetCydget_INSTALL_PATH = /System/Library/LockCydgets
MobileNotifierCydgetCydget_BUNDLE_EXTENSION = cydget

BUNDLE_NAME += MobileNotifierCydgetPlugin
MobileNotifierCydgetPlugin_INSTALL_PATH = /System/Library/SpringBoardPlugins
MobileNotifierCydgetPlugin_FILES = MobileNotifierCydgetAwayViewController.mm
MobileNotifierCydgetPlugin_FRAMEWORKS = UIKit CoreGraphics
MobileNotifierCydgetPlugin_PRIVATE_FRAMEWORKS = SpringBoardUI

include $(FW_MAKEDIR)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
