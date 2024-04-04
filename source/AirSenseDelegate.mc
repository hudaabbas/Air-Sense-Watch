using Toybox.FitContributor as Fit;

using Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Activity as Activity;
using Toybox.UserProfile;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Communications;

class AirSenseDelegate extends WatchUi.BehaviorDelegate {
    private var _session;
   // private var _viewController as ViewController;
   // private var _dataModel as DeviceDataModel;
    
    var airExposureScore = 0.0f; // personal AQHI
    var risk_score = 1.0f;
    var real_aqhi = 0.0f;
    var activities = null;
    var time;
    var avgPM25;

    const AIR_EXPOSURE_FIELD_ID = 0;  // Field ID from resources.
    hidden var mAirExposureField; //means protected

    const AQHI_FIELD_ID = 5;  // Field ID from resources.
    hidden var mAQHIField; //means protected


    //! Constructor
    //! @param deviceDataModel The device data model
    public function initialize(dataModel as DeviceDataModel, session,  viewController as ViewController) 
    {       
        BehaviorDelegate.initialize();

        //_dataModel = dataModel;
        _session = session;
       // _viewController = viewController;

    }

    // The average heart rate during the current activity in beats per minute (bpm).
    function getAverageActivityHr() {
        var hr = 0;
        var activityInfo = Activity.getActivityInfo();
        if (activityInfo != null) {
            if (activityInfo.averageHeartRate != null ) {
                hr = activityInfo.averageHeartRate;
            }
        }
        return hr;
    }

    // Elapsed time of the current activity in milliseconds (ms).
    function getDuration(){
        time = 0;
        var activityInfo = Activity.getActivityInfo();
        if (activityInfo != null) {
            if (activityInfo.elapsedTime != null ) {
                time = activityInfo.elapsedTime;
            }
        }
        return time;
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
            System.println("ID" + id); 
        } else{
            id = "--";
        }
        return id.toString();
    }

    // if the Start/Enter key is pressed
    function onKey(evt) as Boolean 
    {
        var key = evt.getKey();
        if (WatchUi.KEY_START == key || WatchUi.KEY_ENTER == key) { 
            System.println("Stop activity recording!!");
            var progressBar = new WatchUi.ProgressBar("Calculating Air Quality...", null); // null for busy indicator
            
            WatchUi.pushView(
                progressBar,
                self,
                WatchUi.SLIDE_DOWN
            );
            //var v = new $.EndActivityView();
            //WatchUi.pushView(v, self, WatchUi.SLIDE_UP);
            stopActivity();
            return true;    
        }
        return false;
    }

    public function stopActivity()
    {
        if (Toybox has :ActivityRecording) {                         // check device for activity recording
            if ((_session != null) && _session.isRecording()) {
                makeAQHIRequest(); // get real AQHI
            }
        }
    }

    function onAQHIReceive(responseCode as Number, data as Dictionary?) as Void {
    if (responseCode == 200) {
        System.println("Request Successful");                   // print success
        System.println("AQHI Data: " + data);
        real_aqhi = data.get("features")[0].get("properties").get("aqhi");
        System.println("AQHI: " + real_aqhi);
        getUserRiskScore(); // get user risk score
    } else {
        System.println("Response: " + responseCode);            // print response code
    }
    }

    function makeAQHIRequest() as Void {
        // geocode to name , but inside location would be null
        var city = "Calgary";
        var url = "https://api.weather.gc.ca/collections/aqhi-observations-realtime/items?f=json&location_name_en=" + city + "&latest=true";      

        var params = null; 

        var options = {                                             
            :method => Communications.HTTP_REQUEST_METHOD_GET,      
            :headers => {                                           
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        var responseCallback = method(:onAQHIReceive);                  

        Communications.makeWebRequest(url, params, options, responseCallback);
    }

    // set up the response callback function
    function onRiskScoreReceive(responseCode as Number, data as Dictionary?) as Void {
        if (responseCode == 200) {
            System.println("Request Successful");                   // print success
            System.println("User Data: " + data);
            System.println("size:" + data["documents"].size());
            if(data["documents"].size() != 0){ // user found
                var lastDocument = data["documents"][data["documents"].size() - 1]; // Get the last document
                var risk = lastDocument["risk_score"]; // Extract risk score from the last document
                if(risk != null){
                    risk_score = risk;
                }
            } else {
                //keep at default of 1
                System.println("User not found in database. Please fill in questionaire");
            }
            System.println("Risk score: " + risk_score);
            getActivity(); // get the activity stats
        } else {
            System.println("Response: " + responseCode);            // print response code
        }
    }

    function getUserRiskScore() as Void {
        var url = "https://us-west-2.aws.data.mongodb-api.com/app/data-nbfdj/endpoint/data/v1/action/find"; 
        var id = getId();
    
        var params = { 
            "collection" => "user",
            "database" => "airsense",
            "dataSource" => "AirSense",
            "filter" => {
                "uid"  => id
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

        var responseCallback = method(:onRiskScoreReceive);                  

        Communications.makeWebRequest(url, params, options, responseCallback);
    }

    function onActivityReceive(responseCode as Number, data as Dictionary?) as Void {
        if (responseCode == 200) {
            System.println("Request Successful");                   // print success
            System.println("Activity Data: " + data);
            if(data["document"] != null){ // activity found
                activities = data["document"]["activity"];
                if(activities.size() == 0){
                     activities = [{ 
                        "hr" => 0,
                        "PM2.5" => 0,
                        "CO2" => 0,
                        "intake_rate"  => 0
                    }];
                    System.println("Activity not found");
                }
                System.println("Activity: " + activities);
            } else {
                //delay a little and try and search for activity again, has not been added yet
                getActivity();
                System.println("Search for activity again");
                return;
            }
            saveScore(); // calculate risk, save in database and fit file
        } else {
            System.println("Response: " + responseCode);            // print response code
        }
    }

    function getActivity() as Void {
        var url = "https://us-west-2.aws.data.mongodb-api.com/app/data-nbfdj/endpoint/data/v1/action/findOne"; 
        var id = getId();
        var start = getStartTime();
    
        var params = { 
            "collection" => "activity",
            "database" => "airsense",
            "dataSource" => "AirSense",
            "filter" => {
                "id"  => id,
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

        var responseCallback = method(:onActivityReceive);                  

        Communications.makeWebRequest(url, params, options, responseCallback);
    }

    // Assuming intake_rate is an array of Numbers and risk, aqhi are Numbers
    function determineRelativeRisk(intake_rate, risk, aqhi) {
        System.println("Average intake rate: " + intake_rate); 
        System.println("Risk score is: " + risk); 
        System.println("AQHI is: " + aqhi); 

        var lower = [0, 20, 40, 60, 70, 80, 85, 90, 95, 100];
        var upper = [20, 40, 60, 70, 80, 90, 95, 100, 105, 110];

        var intermediateRisk = intake_rate * risk;
        
        var index = (aqhi-1).toNumber();
        var intermediateLower = lower[index] / risk;
        var intermediateUpper = upper[index];

        var relativeRisk = (intermediateRisk - intermediateLower) / (intermediateUpper - intermediateLower) / 1.5;

        if (relativeRisk < 0) {
            relativeRisk = 0;
        }

        var experiencedRisk = aqhi + relativeRisk;

        experiencedRisk = Math.round(experiencedRisk * 100) / 100;

        if (experiencedRisk > 11) {
            experiencedRisk = 11;
        }

        return experiencedRisk;
    }

    public function saveScore()
    {
        var totalHr = 0;
        var totalPM25 = 0.0f;
        var totalCO2 = 0.0f;
        var totalIntakeRate = 0.0f;

        var numActivities = activities.size();
        System.println("Number of activites" + numActivities);
        for (var i = 0; i < numActivities; i++) {
            // Accumulate values
            totalHr += activities[i]["hr"];
            totalPM25 += activities[i]["PM2.5"];
            totalCO2 += activities[i]["CO2"];
            totalIntakeRate += activities[i]["intake_rate"];
        }

        // Calculate averages
        var avgHr = totalHr / numActivities;
        avgPM25 = totalPM25 / numActivities;
        var avgCO2 = totalCO2 / numActivities;
        var avgIntakeRate = totalIntakeRate / numActivities;

        var aqhi = Math.floor(real_aqhi);
        airExposureScore = determineRelativeRisk(avgIntakeRate, risk_score, aqhi); // calculate the personal risk
        var id = getId();
        var time = getDuration();
        var start = getStartTime();

        var body = { 
            "collection" => "score",
            "database" => "airsense",
            "dataSource" => "AirSense",
            "document" => {
            "id"  => id,
            "activity_avg"  =>  {
                "hr" => avgHr,
                "PM2.5" => avgPM25,
                "CO2" => avgCO2,
                "intake_rate"  => avgIntakeRate},
            "AQHI"  =>  real_aqhi,
            "personal_AQHI"  =>  airExposureScore,
            "duration_ms"  =>  time,
            "start_time"  =>  start,
            "risk"  =>  risk_score
            }
        };

        System.println("Adding to database: " + body);

        makeRequest(body); 
    }

    function makeRequest(body) as Void {
       var url = "https://us-west-2.aws.data.mongodb-api.com/app/data-nbfdj/endpoint/data/v1/action/insertOne"; 
       
       var params = body; 

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

    // set up the response callback function
    function onReceive(responseCode as Number, data as Dictionary?) as Void {
        if (responseCode == 200 || responseCode == 201) {
            System.println("Request Successful");                   // print success
            System.println("Data: " + data);
            var actual_aqhi = Math.floor(real_aqhi);
            setPersonalAQHI(airExposureScore);
            setRealAQHI(actual_aqhi);
            _session.stop();                                      // stop the session
            _session.save();                                      // save the session
            _session = null;   // set session control variable to null
            var v = new $.AirExposureScoreView(airExposureScore, actual_aqhi, time, avgPM25);
            WatchUi.pushView(v, new $.AirExposureDelegate(airExposureScore), WatchUi.SLIDE_UP);
        } else {
            System.println("Response: " + responseCode);            // print response code
        }
    }

    public function setPersonalAQHI(airExposure){
        if( null == mAirExposureField ) {
            //Create the custom FIT data field we want to record.
            mAirExposureField = _session.createField(
            WatchUi.loadResource(Rez.Strings.air_exposure_label), 
            AIR_EXPOSURE_FIELD_ID,
            FitContributor.DATA_TYPE_FLOAT, 
            { :mesgType=>Fit.MESG_TYPE_SESSION, :units=>WatchUi.loadResource(Rez.Strings.air_exposure_units) }   //    FitContributor.MESG_TYPE_RECORD for graph information (FitContributor.MESG_TYPE_SESSION` for summary information)
            );

            mAirExposureField.setData(0.0);
        }

        var personal_aqhi = airExposure.format("%.2f").toFloat();
        System.println("Personal AQHI: " + personal_aqhi);

        if(airExposure !=null) {
            mAirExposureField.setData(personal_aqhi);
        }
    }

    public function setRealAQHI(aqhi){
        if( null == mAQHIField ) {
            //Create the custom FIT data field we want to record.
            mAQHIField = _session.createField(
            WatchUi.loadResource(Rez.Strings.aqhi_label), 
            AQHI_FIELD_ID,
            FitContributor.DATA_TYPE_FLOAT, 
            { :mesgType=>Fit.MESG_TYPE_SESSION, :units=>WatchUi.loadResource(Rez.Strings.air_exposure_units) }   //    FitContributor.MESG_TYPE_RECORD for graph information (FitContributor.MESG_TYPE_SESSION` for summary information)
            );

            mAQHIField.setData(0.0);
        }

        System.println("Real AQHI: " + aqhi);

        if(aqhi !=null) {
            mAQHIField.setData(aqhi);
        }
    }

}