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
    var lastConnected = false;
    var button;

    //! Constructor
    //! @param dataModel The data to show
    public function initialize(dataModel as DeviceDataModel) {
        View.initialize();
        button = WatchUi.loadResource(Rez.Drawables.topRight);

        _dataModel = dataModel;
        _dataModel._view = self;
    }

    public function onUpdate(dc as Dc) as Void {
       
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
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
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

            dc.drawText(midX, midY-150, Graphics.FONT_XTINY, "Humidity", Graphics.TEXT_JUSTIFY_CENTER);
            var humidity = profile.getHumidity();
            if (humidity != null)
            {
                dc.drawText(midX, midY-125, Graphics.FONT_SMALL, Lang.format("$1$ %",[humidity.format("%.2f")]), Graphics.TEXT_JUSTIFY_CENTER);
            } else {
                dc.drawText(midX, midY-125, Graphics.FONT_SMALL, "--", Graphics.TEXT_JUSTIFY_CENTER);
            }

            dc.drawText(midX, midY-65, Graphics.FONT_XTINY, "PM 2.5", Graphics.TEXT_JUSTIFY_CENTER);
            var pm25 = profile.getPM25();
            if (pm25 != null)
            {
                dc.drawText(midX, midY-40, Graphics.FONT_SMALL, Lang.format("$1$ µg/m3",[pm25.format("%.2f")]), Graphics.TEXT_JUSTIFY_CENTER); 
            } else {
                dc.drawText(midX, midY-40, Graphics.FONT_SMALL, "--", Graphics.TEXT_JUSTIFY_CENTER);
            }

            dc.drawText(midX, midY+20, Graphics.FONT_XTINY, "CO2", Graphics.TEXT_JUSTIFY_CENTER);
            var cO2 = profile.getCO2();
            if (cO2 != null)
            {
                dc.drawText(midX, midY+45, Graphics.FONT_SMALL, Lang.format("$1$ ppm",[cO2.format("%.0f")]), Graphics.TEXT_JUSTIFY_CENTER);
            } else {
                dc.drawText(midX, midY+45, Graphics.FONT_SMALL, "--", Graphics.TEXT_JUSTIFY_CENTER);
            }

            dc.drawText(midX, midY+105, Graphics.FONT_XTINY, "Temperature", Graphics.TEXT_JUSTIFY_CENTER);
            var temp = profile.getTemp();
            if (temp != null)
            {
                dc.drawText(midX, midY+130, Graphics.FONT_SMALL, Lang.format("$1$ C",[temp.format("%.1f")]), Graphics.TEXT_JUSTIFY_CENTER);
            } else {
                dc.drawText(midX, midY+130, Graphics.FONT_SMALL, "--", Graphics.TEXT_JUSTIFY_CENTER);
            }

            if(temp != null && cO2 !=  null && pm25 != null && humidity != null){
                dc.drawBitmap(305, 60, button);
            }
            
        }
    
    }

    
}
