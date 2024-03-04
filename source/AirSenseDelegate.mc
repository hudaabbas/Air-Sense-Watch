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
    private var _viewController as ViewController;
    private var _dataModel as DeviceDataModel;
    
    var airExposureScore = 0.0f;

    const AIR_EXPOSURE_FIELD_ID = 0;  // Field ID from resources.
    hidden var mAirExposureField; //means protected

    //! Constructor
    //! @param deviceDataModel The device data model
    public function initialize(dataModel as DeviceDataModel, session,  viewController as ViewController) 
    {       
        BehaviorDelegate.initialize();

        _dataModel = dataModel;
        _session = session;
        _viewController = viewController;

    }

    public function setAirExposureFactor(airExposure){
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

        System.println("Air exposure score: " + airExposure);

        if(airExposure !=null) {
            mAirExposureField.setData(airExposure);
        }
    }

    // The user’s seven-day average resting heart rate (bpm)
    function getAverageRestingHR() {
        var profile = UserProfile.getProfile();
        var avgHR = profile.averageRestingHeartRate; 

        if (avgHR != null) {
            avgHR = avgHR;
        } else {
            avgHR = 0;
        }

        return avgHR;
    }

    // The user's gender
    function getSex() {
        var profile = UserProfile.getProfile();
        var sex = profile.gender; 

        if (sex == UserProfile.GENDER_FEMALE) {
            sex = "Female";
        } else if (sex == UserProfile.GENDER_MALE) {
            sex = "Male";
        } else {
            sex = "--"; // UserProfile.GENDER_UNSPECIFIED;
        }

        return sex;
    }

    // User's current age
    function getAge() {
        var profile = UserProfile.getProfile();
        var birth = profile.birthYear; // Year user was born
        var age = 0;

        if (birth != null) {
            var now = Time.now();
            var info = Gregorian.info(now, Time.FORMAT_LONG);
            age = info.year - birth;
        }

        return age;
    }

    // User's weight in grams
    function getWeight() {
        var profile = UserProfile.getProfile();
        var weight = profile.weight; 

        if (weight == null) {
            weight = 0;
        } 

        return weight;
    }

    // User's height in cm
    function getHeight() {
        var profile = UserProfile.getProfile();
        var height = profile.height; 

        if (height == null) {
            height = 0;
        } 

        return height;
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
        var time = 0;
        var activityInfo = Activity.getActivityInfo();
        if (activityInfo != null) {
            if (activityInfo.elapsedTime != null ) {
                time = activityInfo.elapsedTime;
            }
        }
        return time;
    }

    // Current respiration rate for the user, in breaths per minute
    function getRespirationRate(){ 
        var respRate = 0;       

        var monitorInfo = ActivityMonitor.getInfo();
        if (monitorInfo != null) {
            if (monitorInfo.respirationRate != null ) {
                respRate = monitorInfo.respirationRate;
            }
        }

        return respRate;
    }

    // A unique alphanumeric device identifier
    function getId()
    {
        var mySettings = System.getDeviceSettings();
        var id = mySettings.uniqueIdentifier;
        if (id != null) {
            System.println(id); 
        } else{
            id = "--";
        }
        return id.toString();
    }

    public function stopActivity()
    {
        var avgRestingHr = getAverageRestingHR();
        var sex = getSex();
        var age =  getAge(); 
        var activityHr = getAverageActivityHr();
        var rr = getRespirationRate();
        var id = getId();

        var body = { 
            "id"  => id,
            "age"  =>  age,
            "sex"  =>  sex,
            "avg_resting_hr"  =>  avgRestingHr,
            "respiration_rate"  =>  rr,
            "activity_hr"  =>  activityHr
        };

        if (Toybox has :ActivityRecording) {                         // check device for activity recording
            if ((_session != null) && _session.isRecording()) {
                makeRequest(body);
            }
        }
    }

    // if the Start/Enter key is pressed
    function onKey(evt) as Boolean 
    {
        var key = evt.getKey();
        if (WatchUi.KEY_START == key || WatchUi.KEY_ENTER == key) { 
            System.println("Stop activity recording!!");
            stopActivity();
            return true;    
        }
        return false;
    }
    
    // set up the response callback function
    function onReceive(responseCode as Number, data as Dictionary?) as Void {
        if (responseCode == 200) {
            System.println("Request Successful");                   // print success
            System.println("Data: " + data);
            airExposureScore = data.get("air_exposure_score");
            setAirExposureFactor(airExposureScore);
            _session.stop();                                      // stop the session
            _session.save();                                      // save the session
            _session = null;   // set session control variable to null
            var v = new $.AirExposureScoreView(airExposureScore);
            WatchUi.pushView(v, new $.AirExposureDelegate(), WatchUi.SLIDE_UP);
        } else {
            System.println("Response: " + responseCode);            // print response code
        }
    }

    function makeRequest(body) as Void {
        var url = "https://azureairsenseapi.azurewebsites.net/api/heartRate/140";                         // set the url

        var params = body; 

        var options = {                                             
            :method => Communications.HTTP_REQUEST_METHOD_POST,      
            :headers => {                                           
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        var responseCallback = method(:onReceive);                  

        Communications.makeWebRequest(url, params, options, responseCallback);
    }

}