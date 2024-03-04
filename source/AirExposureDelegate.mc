import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class AirExposureDelegate extends  WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    public function onBack() as Boolean
    {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

}