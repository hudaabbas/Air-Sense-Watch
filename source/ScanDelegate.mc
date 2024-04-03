//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Lang;
import Toybox.WatchUi;

class MyProgressDelegate extends WatchUi.BehaviorDelegate {
    var _deviceDataModel; 
    var _viewController;

    function initialize(deviceDataModel, viewController) {
        _deviceDataModel = deviceDataModel;
        _viewController = viewController;
        BehaviorDelegate.initialize();
    }

    function onBack() {
        return true;
    }

}

class ScanDelegate extends WatchUi.BehaviorDelegate {
    private var _scanDataModel as ScanDataModel;
    private var _viewController as ViewController;
    var _deviceDataModel;

    //! Constructor
    //! @param scanDataModel The model containing the scan results
    //! @param viewController Object that controls pushing new views
    public function initialize(scanDataModel as ScanDataModel, viewController as ViewController) {
        BehaviorDelegate.initialize();

        _scanDataModel = scanDataModel;
        _viewController = viewController;
    }

    //! Handle the back behavior
    //! @return true if handled, false otherwise
    
    public function onBack() as Boolean 
    {
        if (null != _deviceDataModel ){
            _deviceDataModel.unpair();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        }
        return false;
    }

    //! Handle menu button press
    //! @return true if handled, false otherwise
    public function onMenu() as Boolean {
        return true;
    }

    //! Handle the select action
    //! @return true if handled, false otherwise
    public function onSelect() as Boolean 
    {
        return false;
    }

    public function onKey(evt) as Boolean 
    {
        var key = evt.getKey();
        System.println("Key: " + key.toString());
        if (WatchUi.KEY_START == key || WatchUi.KEY_ENTER == key) { 
            var displayResult = _scanDataModel.getDisplayResult();
            if (null != displayResult) 
            {
                _viewController.pushDeviceView(displayResult);
                _deviceDataModel = _viewController.getDeviceDataModel(displayResult);
                /*
                var progressBar = new WatchUi.ProgressBar("Connecting...", null); // null for busy indicator
                WatchUi.pushView(
                    progressBar,
                    new MyProgressDelegate(_deviceDataModel, _viewController),
                    WatchUi.SLIDE_DOWN
                );*/
            }                                               // return true for onSelect function
        }
        return false;
    } 

    //! Handle next page behavior
    //! @return true if handled, false otherwise
    public function onNextPage() as Boolean {
        _scanDataModel.nextResult();
        return true;
    }

    //! Handle previous page behavior
    //! @return true if handled, false otherwise
    public function onPreviousPage() as Boolean {
        _scanDataModel.previousResult();
        return true;
    }
}
