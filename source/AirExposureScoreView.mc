using Toybox.ActivityRecording;
using Toybox.WatchUi;
using Toybox.System;

class AirExposureScoreView extends WatchUi.View {

    var  _personal_aqhi;
    var  _aqhi;
    var time;
    var avgPM25;
    // Initializes the new field in the activity file
    public function initialize(airExposureScore, actual_aqhi, duration, avgpm25) {
        View.initialize();

        _personal_aqhi = airExposureScore;
        _aqhi = actual_aqhi;
        time = duration;
        avgPM25 = avgpm25;

        if(_personal_aqhi == null){
            _personal_aqhi = 0.0f;
        }

        if(_aqhi == null){
            _aqhi = 0.0f;
        }
    }

    public function onLayout(dc) as Void {
        setLayout( Rez.Layouts.Score( dc ) );
    }

    // Update the field layout and display the field data
    public function onUpdate(dc) {  
        var view = (View.findDrawableById("AQHI") as Toybox.WatchUi.Text);
        view.setText( Lang.format("$1$ ", [_aqhi.format("%.f")]) );
        view = (View.findDrawableById("time") as Toybox.WatchUi.Text);
        var total_seconds = time / 1000;
        var minutes = total_seconds / 60;
        var seconds = total_seconds % 60;
        var timeString = Lang.format("$1$:$2$",[minutes, seconds.format("%02d")]);
        view.setText(timeString);
        view = (View.findDrawableById("maxPM25") as Toybox.WatchUi.Text);
        view.setText( Lang.format("$1$ ", [avgPM25.format("%.2f") ]));
        view = (View.findDrawableById("personalAQHI") as Toybox.WatchUi.Text);
        view.setText( Lang.format("$1$ ", [_personal_aqhi.format("%.2f") ]));
    
        var pointer = 94;
        if(_personal_aqhi < 2){
            pointer = 115;
            view.setColor(Graphics.COLOR_GREEN);
        } else if(_personal_aqhi < 4) {
            pointer = 155;
            view.setColor(Graphics.COLOR_BLUE);
        } else if(_personal_aqhi < 6) {
            pointer = 200;
            view.setColor(Graphics.COLOR_YELLOW);
        } else if(_personal_aqhi < 8) {
            pointer = 243;
            view.setColor(Graphics.COLOR_ORANGE);
        } else {
            pointer = 286;
            view.setColor(Graphics.COLOR_RED);
        }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);
        dc.fillRoundedRectangle(198,100,4,155,20);
        dc.setColor(Graphics.COLOR_GREEN,Graphics.COLOR_BLACK); // 0 to 2
        dc.fillRectangle(94,280,40,8);
        dc.setColor(Graphics.COLOR_BLUE,Graphics.COLOR_BLACK); // Blue: 2 to 4
        dc.fillRectangle(137,280,40,8);
        dc.setColor(Graphics.COLOR_YELLOW,Graphics.COLOR_BLACK); // Yellow: 4 to 6
        dc.fillRectangle(180,280,40,8);
        dc.setColor(Graphics.COLOR_ORANGE,Graphics.COLOR_BLACK); //Orange: 6 to 8
        dc.fillRectangle(223,280,40,8);
        dc.setColor(Graphics.COLOR_RED,Graphics.COLOR_BLACK); // Red: 8 to 10
        dc.fillRectangle(266,280,40,8);

        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);
        dc.fillRectangle(pointer,274,8,20); //pointer, change x value
    } 
}
