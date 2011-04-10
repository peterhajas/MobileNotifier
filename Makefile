MODULES=congruence
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MobileNotifier

MobileNotifier_FILES = Tweak.xm MNAlertData.m MNAlertManager.m MNAlertViewController.m MNAlertDashboardViewController.m MNLockScreenViewController.m MNAlertWindow.m MNWhistleBlowerController.m  MNTableViewCell.m MNPreferenceManager.m
SUBPROJECTS = settings

include $(FW_MAKEDIR)/tweak.mk
MobileNotifier_FRAMEWORKS = UIKit Foundation QuartzCore AudioToolbox CoreGraphics
MobileNotifier_LDFLAGS = -lactivator

SUBPROJECTS = settings
include $(FW_MAKEDIR)/aggregate.mk
