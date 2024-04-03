using Toybox.FitContributor as Fit;
using Toybox.ActivityRecording;
using Toybox.WatchUi;
import Toybox.Lang;

class AirSenseView extends WatchUi.View {

   // private var _dataModel as DeviceDataModel;

    var activityRunning = false;
    var airSensor = null;
    var activity_array = [];

    // Initializes the new field in the activity file
    public function initialize(dataModel as DeviceDataModel, session) {
        View.initialize();

        //_dataModel = dataModel;
       // _dataModel._view = self;

        airSensor = new AirSenseDataField(dataModel, session); // set up new air exposure factor data field
    }

    public function onLayout(dc) as Void {
        setLayout( Rez.Layouts.Summary( dc ) );
    }

    // Update the field layout and display the field data
    public function onUpdate(dc) {
        //dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
        //dc.clear(); 
        var activity = airSensor.compute(Activity.getActivityInfo());
        activity_array.add(activity);

        var timeInSec = airSensor.time/1000;
        var view = (View.findDrawableById("hr") as Toybox.WatchUi.Text);

        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$",[clockTime.hour, clockTime.min.format("%02d")]);
    
        view.setText( Lang.format("$1$", [airSensor.hr]) );
        view = (View.findDrawableById("pm25") as Toybox.WatchUi.Text);
        view.setText( Lang.format("$1$ ", [airSensor.pm25.format("%.2f") ]));
        view = (View.findDrawableById("co2") as Toybox.WatchUi.Text);
        view.setText( Lang.format("$1$ ", [airSensor.co2.format("%.0f")]) );
        view = (View.findDrawableById("timer") as Toybox.WatchUi.Text);
        view.setText( timeString);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    } 

    // called when this View is removed from the screen
    function onHide() {
        makeRequest();
        //TODO: ensure this finishes before it is needed to calculate score
    }

    // set up the response callback function
    function onReceive(responseCode as Number, data as Dictionary?) as Void {
        if (responseCode == 200 || responseCode == 201) {
            System.println("Activity Added Successfully");                   // print success
            System.println("Data: " + data);
        } else {
            System.println("Response: " + responseCode);            // print response code
        }
    }

    // The starting time of the current activity. 
    function getStartTime(){
        var date = 0;
        var activityInfo = Activity.getActivityInfo();
        if (activityInfo != null) {
            if (activityInfo.startTime != null ) {
                var moment = activityInfo.startTime;
                date = moment.value(); //Get the UTC value of a Moment.
            }
        }
        return date;
    }

    // A unique alphanumeric device identifier
    function getId()
    {
        var mySettings = System.getDeviceSettings();
        var id = mySettings.uniqueIdentifier;
        if (id != null) {
            System.println("ID:" + id); 
        } else{
            id = "--";
        }
        return id.toString();
    }

    function makeRequest() as Void {
       var url = "https://us-west-2.aws.data.mongodb-api.com/app/data-nbfdj/endpoint/data/v1/action/insertOne"; 
        var id = getId();
        var start = getStartTime();

       var params = { 
            "collection" => "activity",
            "database" => "airsense",
            "dataSource" => "AirSense",
            "document" => {
            "id"  => id,
            "activity"  =>  activity_array,
            "start_time"  =>  start
            }
        };

        var options = {                                             
            :method => Communications.HTTP_REQUEST_METHOD_POST,      
            :headers => {                                           
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
                "Access-Control-Request-Headers" => "*",
                "api-key" => "BtY9dwfdxm1o1svQYUbERkov0woXEVmkVTXpJ2Gi1vhTml6Qfiktf5qDUzmYYEay"
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        var responseCallback = method(:onReceive);                  

        Communications.makeWebRequest(url, params, options, responseCallback);
    }
}
