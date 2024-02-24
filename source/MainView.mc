//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;


class MainView extends WatchUi.View 
{
    private var _dataModel as DeviceDataModel;
    var ppo2 = 1.4;
    var lastConnected = false;
    
    
    var myTimer;
    var lastCalibrating = false;
    var calibratingMillis = 0;

    //! Constructor
    //! @param dataModel The data to show
    public function initialize(dataModel as DeviceDataModel) {
        View.initialize();

        _dataModel = dataModel;
        _dataModel._view = self;
    }

    //! Update the view
    //! @param dc Device Context

    function timerCallback() as Void 
    {
        var millis = System.getTimer() - calibratingMillis;
       
        if (millis > 5000)
        {
            
            myTimer.stop();
            calibratingMillis = 0;
           
        }
        WatchUi.requestUpdate();
    }

    public function onUpdate(dc as Dc) as Void {
       
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
        dc.clear();            
        var midX = dc.getWidth()/2;
        var midY = dc.getHeight()/2;

        if (!_dataModel.isConnected()) {
            dc.drawText(midX, midY-20, Graphics.FONT_SMALL, "Connecting...", Graphics.TEXT_JUSTIFY_CENTER);
        }

        var profile = _dataModel.getActiveProfile();
        if ((lastConnected == true) && (_dataModel.isConnected() == false))
        {
            System.println("last connected is true but not connected");
            //_dataModel.unpair();
            //BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_SCANNING);
            //WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
        lastConnected = _dataModel.isConnected();
        if (_dataModel.isConnected() && (profile != null)) 
        {
            System.println("Connected and profile is present!");

            var temp = profile.getTemp();
            if (temp != null)
            {
                dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(midX, midY-20, Graphics.FONT_SMALL, Lang.format("Temp: $1$ C",[temp.format("%.2f")]), Graphics.TEXT_JUSTIFY_CENTER);
            }

            var cO2 = profile.getCO2();
            if (cO2 != null)
            {
                dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(midX, midY+20, Graphics.FONT_SMALL, Lang.format("CO2: $1$ ppm",[cO2.format("%.2f")]), Graphics.TEXT_JUSTIFY_CENTER);
            }
            
            var humidity = profile.getHumidity();
            if (humidity != null)
            {
                dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(midX, midY-60, Graphics.FONT_SMALL, Lang.format("Humidity: $1$ %",[humidity.format("%.2f")]), Graphics.TEXT_JUSTIFY_CENTER);
            }

            var pm25 = profile.getPM25();
            if (pm25 != null)
            {
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
                dc.drawText(midX, midY+80, Graphics.FONT_SMALL, Lang.format("PM 2.5: $1$ ppm",[pm25.format("%.2f")]), Graphics.TEXT_JUSTIFY_CENTER); 
            }
        }
    
    }

    
}
