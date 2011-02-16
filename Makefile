include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MobileNotifier

MobileNotifier_FILES = Tweak.xm MNAlertData.m MNAlertManager.m MNAlertViewController.m MNAlertDashboardViewController.m MNWhistleBlowerController.m
SUBPROJECTS = settings mobilenukifier

include $(FW_MAKEDIR)/tweak.mk
MobileNotifier_FRAMEWORKS = UIKit Foundation QuartzCore AudioToolbox
MobileNotifier_LDFLAGS = -lactivator

SUBPROJECTS = settings mobilenukifier
include $(FW_MAKEDIR)/aggregate.mk
