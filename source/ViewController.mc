//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.BluetoothLowEnergy;
import Toybox.Lang;
import Toybox.WatchUi;

class ViewController {
    private var _modelFactory as DataModelFactory;
    var session;

    //! Constructor
    //! @param modelFactory Factory to create models
    public function initialize(modelFactory as DataModelFactory) {
        _modelFactory = modelFactory;
    }

    //! Return the initial views for the app
    //! @return Array Pair [View, InputDelegate]
    public function getInitialView() as Array<ScanView or ScanDelegate> 
    {
        var scanDataModel = _modelFactory.getScanDataModel();
        BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_SCANNING);
        return [new $.ScanView(scanDataModel), new $.ScanDelegate(scanDataModel, self)] as Array<ScanView or ScanDelegate>;
    }

    //! Push the device view
    //! @param scanResult The scan result for the device view to push
    public function pushDeviceView(scanResult as ScanResult) as Void 
    {
        var deviceDataModel = _modelFactory.getDeviceDataModel(scanResult);
        var v = new $.MainView(deviceDataModel);
        WatchUi.pushView(v, new $.MainViewDelegate(deviceDataModel,v, self), WatchUi.SLIDE_UP);
    }

    public function getDeviceDataModel(scanResult as ScanResult) as DeviceDataModel 
    {
        var deviceDataModel = _modelFactory.getDeviceDataModel(scanResult);
        return deviceDataModel;
    }

    public function pushActivityView(deviceDataModel) as Void
    {
        if (Toybox has :ActivityRecording) {                         // check device for activity recording
            if ((session == null) || (session.isRecording() == false)) { 
                System.println("Start activity recording!!");
                session = ActivityRecording.createSession({          // set up recording session
                        :name=>"Air Sensor Run",                              // set session name
                        :sport=>Activity.SPORT_GENERIC,                // set sport type
                        :subSport=>Activity.SUB_SPORT_GENERIC          // set sub sport type SUB_SPORT_INDOOR_CYCLING
                });
                session.start();                                             // call start session
            }
        }

        var v = new $.AirSenseView(deviceDataModel, session);
        WatchUi.pushView(v, new $.AirSenseDelegate(deviceDataModel, session, self), WatchUi.SLIDE_UP);
    }

}