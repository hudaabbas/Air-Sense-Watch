import Toybox.Graphics;
import Toybox.WatchUi;

class UserPromptView extends WatchUi.View {

    var  _personal_aqhi;

    function initialize(airExposureScore) {
        View.initialize();
        _personal_aqhi = airExposureScore;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.UserPrompt(dc));
    }

    public function onUpdate(dc) { 
        var blurb = Lang.format("Your personal AQHI is $1$.", [_personal_aqhi.format("%.1f") ]);
        var view = (View.findDrawableById("pAQHI") as Toybox.WatchUi.Text);
        view.setText( blurb );

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

        var prompt = "";
    
        if(_personal_aqhi < 2){
            prompt = "Skies are clean and clear.";
        } else if(_personal_aqhi < 4) {
            prompt = "Be mindful of the rest \nof your time outdoors.";
        } else if(_personal_aqhi < 6) {
            prompt = "Consider going somewhere \nindoors and well-ventilated.";
        } else if(_personal_aqhi < 8) {
            prompt = "Take a break from the outdoors \n and go get some rest inside.";
        } else {
            prompt = "Try to make your way indoors \n as soon as possible. \n Any more exposure could \n cause health side \n effects.";
        }
        
        view = (View.findDrawableById("blurb") as Toybox.WatchUi.Text);
        view.setText( prompt );
        
        
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        dc.setColor(Graphics.COLOR_GREEN,Graphics.COLOR_BLACK); // 0 to 2
        dc.fillRectangle(94,100,40,8);
        dc.setColor(Graphics.COLOR_BLUE,Graphics.COLOR_BLACK); // Blue: 2 to 4
        dc.fillRectangle(137,100,40,8);
        dc.setColor(Graphics.COLOR_YELLOW,Graphics.COLOR_BLACK); // Yellow: 4 to 6
        dc.fillRectangle(180,100,40,8);
        dc.setColor(Graphics.COLOR_ORANGE,Graphics.COLOR_BLACK); //Orange: 6 to 8
        dc.fillRectangle(223,100,40,8);
        dc.setColor(Graphics.COLOR_RED,Graphics.COLOR_BLACK); // Red: 8 to 10
        dc.fillRectangle(266,100,40,8);
        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);
        dc.fillRectangle(pointer,94,8,20); //pointer, change x value
    }
}