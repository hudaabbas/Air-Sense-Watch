using Toybox.ActivityRecording;
using Toybox.WatchUi;
using Toybox.System;

class AirExposureScoreView extends WatchUi.View {

    var  _airExposureScore;
    // Initializes the new field in the activity file
    public function initialize(airExposureScore) {
        View.initialize();

        _airExposureScore = airExposureScore;

        if(_airExposureScore == null){
            _airExposureScore = 0.0f;
        }
    }

    // Update the field layout and display the field data
    public function onUpdate(dc) {
       
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_WHITE);
        dc.clear();    
        
        var midX = dc.getWidth()/2;
        var midY = dc.getHeight()/2;
            
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(midX, midY-90, Graphics.FONT_SMALL, Lang.format("Air Exposure \n Score: $1$ ",[_airExposureScore.format("%.2f")]), Graphics.TEXT_JUSTIFY_CENTER);
    }
}
