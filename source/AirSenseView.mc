using Toybox.FitContributor as Fit;
using Toybox.ActivityRecording;
using Toybox.WatchUi;

class AirSenseView extends WatchUi.View {

   // private var _dataModel as DeviceDataModel;

    var activityRunning = false;
    var airSensor = null;

    // Initializes the new field in the activity file
    public function initialize(dataModel as DeviceDataModel, session) {
        View.initialize();

        //_dataModel = dataModel;
       // _dataModel._view = self;

        airSensor = new AirSenseDataField(dataModel, session); // set up new air exposure factor data field
    }

    // Update the field layout and display the field data
    public function onUpdate(dc) {
       
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
        dc.clear();            
        var midX = dc.getWidth()/2;
        var midY = dc.getHeight()/2;

        airSensor.compute(Activity.getActivityInfo());
        var timeInSec = airSensor.time/1000;

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(midX, midY-100, Graphics.FONT_SMALL, Lang.format("Temp: $1$ C",[airSensor.temp.format("%.2f")]), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(midX, midY-60, Graphics.FONT_SMALL, Lang.format("PM 2.5: $1$ ppm",[airSensor.pm25.format("%.2f")]), Graphics.TEXT_JUSTIFY_CENTER); 
        dc.drawText(midX, midY-20, Graphics.FONT_SMALL, Lang.format("CO2: $1$ ppm",[airSensor.co2.format("%.2f")]), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(midX, midY+20, Graphics.FONT_SMALL, Lang.format("Humidity: $1$ %",[airSensor.hum.format("%.2f")]), Graphics.TEXT_JUSTIFY_CENTER); 
    
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(midX, midY+70, Graphics.FONT_SMALL, Lang.format("HR: $1$ bpm",[airSensor.hr]), Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(midX, midY+110, Graphics.FONT_SMALL, Lang.format("Time: $1$ s",[timeInSec.format("%.0f")]), Graphics.TEXT_JUSTIFY_CENTER);
    }
}
