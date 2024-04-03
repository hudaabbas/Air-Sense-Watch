using Toybox.ActivityRecording;
using Toybox.WatchUi;
using Toybox.System;

class EndActivityView extends WatchUi.View {

    // Initializes the new field in the activity file
    public function initialize() {
        View.initialize();
    }

    // Update the field layout and display the field data
    public function onUpdate(dc) {
       
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_WHITE);
        dc.clear();    
        
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight()/2 - 120, Graphics.FONT_SMALL, "Calculating \nyour Air Quality...", Graphics.TEXT_JUSTIFY_CENTER);
       
    }
}
