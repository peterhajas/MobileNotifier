include theos/makefiles/common.mk

TWEAK_NAME = MobileNotifier
MobileNotifier_FILES = Tweak.xm AlertController.m AlertDisplayController.m AlertDataController.m

include $(FW_MAKEDIR)/tweak.mk
MobileNotifier_FRAMEWORKS = UIKit Foundation
MobileNotifier_LDFLAGS = -lactivator
