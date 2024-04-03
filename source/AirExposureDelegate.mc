import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

import Rez.Styles;

class AirExposureDelegate extends  WatchUi.BehaviorDelegate {

    var  _personal_aqhi;
    function initialize(personal_aqhi) {
        BehaviorDelegate.initialize();
        _personal_aqhi = personal_aqhi;
    }

    public function onBack() as Boolean
    {
        // TODO: need clean exit of app
        System.println("Exit app");
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
        //System.exit();
    }

    (:typecheck(false))
    function isActionButton(button as WatchUi.Key) as Boolean {
        if (Styles.system_input__action_menu has :button &&
            button == Styles.system_input__action_menu.button) {
                return true;
        }
        return false;
    }

    function onKey(evt as KeyEvent) as Boolean {
        if (isActionButton(evt.getKey())) {
            onAction();
            return true;
        }
        return false;
    }

    function onSwipe(swipeEvent as WatchUi.SwipeEvent) {
        if(swipeEvent.getDirection() == SWIPE_UP){
            onAction();
            return true;
        }
        return false;
    }

    function onAction() {
        WatchUi.switchToView(
            new UserPromptView(_personal_aqhi),
            self,
            WatchUi.SLIDE_UP
        );
    }

}