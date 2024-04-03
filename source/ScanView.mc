//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Graphics;
import Toybox.WatchUi;

class ScanView extends WatchUi.View {
    private var _scanDataModel as ScanDataModel;
    var background;
    var icon;
    var button;

    //! Constructor
    //! @param scanDataModel The model containing the scan results
    public function initialize(scanDataModel as ScanDataModel) {
        View.initialize();

        background = WatchUi.loadResource(Rez.Drawables.Bg);
        icon = WatchUi.loadResource(Rez.Drawables.Icon);
        button = WatchUi.loadResource(Rez.Drawables.topRight);

        _scanDataModel = scanDataModel;
    }

    //! Load your resources here
    //! @param dc Device context
    public function onLayout(dc as Dc) as Void 
    {
        setLayout( Rez.Layouts.Start( dc ) );
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    public function onShow() as Void 
    {
    }

    //! Update the view
    //! @param dc Device context
    public function onUpdate(dc as Dc) as Void 
    {
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawBitmap(-18, -20, background);
       
        var displayResult = _scanDataModel.getDisplayResult();

        if (null != displayResult) 
        {
            System.println("\nDevice Found! Click to connect"); 
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() / 2, 170, Graphics.FONT_XTINY, "Ready", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawBitmap(305, 60, button);
        } else{
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() / 2, 170, Graphics.FONT_XTINY, "Wait for Device", Graphics.TEXT_JUSTIFY_CENTER);
        }
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.fillRectangle(145,205,100,2);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 270, Graphics.FONT_XTINY, "Air Sense", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawBitmap(140, 300, icon);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    public function onHide() as Void {
    }

}
