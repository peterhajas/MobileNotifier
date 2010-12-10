include theos/makefiles/common.mk

TWEAK_NAME = MobileNotifier

MobileNotifier_FILES = Tweak.xm MNAlertData.m MNAlertManager.m MNAlertViewController.m
SUBPROJECTS = settings

include $(FW_MAKEDIR)/tweak.mk
MobileNotifier_FRAMEWORKS = UIKit Foundation
MobileNotifier_LDFLAGS = -lactivator

SUBPROJECTS = settings
include $(FW_MAKEDIR)/aggregate.mk
