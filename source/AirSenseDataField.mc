using Toybox.FitContributor as Fit;
using Toybox.ActivityRecording;
using Toybox.WatchUi;

import Toybox.Graphics;

class AirSenseDataField extends WatchUi.DataField {

    private var _dataModel as DeviceDataModel;
    private var _session;

    const AIR_TEMP_FIELD_ID = 1; 
    hidden var mAirTempField; 

    const CO2_FIELD_ID = 2; 
    hidden var mCO2Field; 

    const PM25_FIELD_ID = 3; 
    hidden var mPM25Field; 

    const HUMIDITY_FIELD_ID = 4; 
    hidden var mHumidityField; 

    var activityRunning = false;

    var hr = 0;
    var time = 0;
    var loc = null;
    var temp = 0.0f;
    var pm25 = 0.0f;
    var co2 = 0.0f;
    var hum = 0.0f;

    // Initializes the new field in the activity file
    function initialize(dataModel as DeviceDataModel, session) {
        _session = session;
        _dataModel = dataModel;

        DataField.initialize();

        setupField(_session);
    }

    function setupField(session) {

        if( null == mAirTempField ) {
            //Create the custom FIT data field we want to record.
            mAirTempField = session.createField(
            "Temperature", 
            AIR_TEMP_FIELD_ID,
            FitContributor.DATA_TYPE_FLOAT, 
            { :mesgType=>Fit.MESG_TYPE_RECORD, :units=>"C" }  
            );

            mAirTempField.setData(0.0);
        }

        if( null == mCO2Field ) {
            //Create the custom FIT data field we want to record.
            mCO2Field = session.createField(
            "Carbon Dioxide", 
            CO2_FIELD_ID,
            FitContributor.DATA_TYPE_FLOAT, 
            { :mesgType=>Fit.MESG_TYPE_RECORD, :units=>"ppm" }   
            );

            mCO2Field.setData(0.0);
        }

        if( null == mPM25Field ) {
            //Create the custom FIT data field we want to record.
            mPM25Field = session.createField(
            "PM 2.5", 
            PM25_FIELD_ID,
            FitContributor.DATA_TYPE_FLOAT, 
            { :mesgType=>Fit.MESG_TYPE_RECORD, :units=>"ppm" }   
            );

            mPM25Field.setData(0.0);
        }

        if( null == mHumidityField ) {
            //Create the custom FIT data field we want to record.
            mHumidityField = session.createField(
            "Humidity", 
            HUMIDITY_FIELD_ID,
            FitContributor.DATA_TYPE_FLOAT, 
            { :mesgType=>Fit.MESG_TYPE_RECORD, :units=>"%" }
            );

            mHumidityField.setData(0.0);
        }
    }

    function refreshActivityStats() {
        var activityInfo = Activity.getActivityInfo();
        if (activityInfo == null) {
            return;
        }

        if (activityInfo.currentHeartRate != null ) {
            hr = activityInfo.currentHeartRate;
        }

        if(activityInfo.currentLocation != null){
            loc = activityInfo.currentLocation.toDegrees();
        }

        if(activityInfo.elapsedTime != null){
            time = activityInfo.elapsedTime;
        }
    }

    // Get the field layout
    /*function onLayout(dc) {
        View.setLayout(Rez.Layouts.MainLayout(dc));
    }

     function onShow() as Void {
        value = new WatchUi.Text({
            :text=>"Air Exposure Value",
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_LARGE,
            :locX =>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_CENTER
        });
    } */

    function compute(info) {
        var profile = _dataModel.getActiveProfile();

        if (_dataModel.isConnected() && (profile != null) ) {
            temp = profile.getTemp();
           
            if (temp != null)
            {
                //System.println("Temp is: " + temp);
                mAirTempField.setData(temp);
            }

            pm25 = profile.getPM25();
            if (pm25 != null)
            {
                //System.println("PM 2.5 is: " + pm25);
                mPM25Field.setData(pm25);
            }

            co2 = profile.getCO2();
            if (co2 != null)
            {
                mCO2Field.setData(co2);
            }

            hum = profile.getHumidity();
            if (hum != null)
            {
                mHumidityField.setData(hum);
            }
        }

        refreshActivityStats();
        return createActivityJson();
    }

    public function createActivityJson()
    {
        var intake_ppm_rate = Math.ln(Math.pow(Math.E, 1.16 + (0.021 * hr))) / Math.ln(12) * pm25; 

        var activity_body = {};

        if(loc != null) 
        {
            activity_body = { 
                "hr" => hr,
                "PM2.5" => pm25,
                "CO2" => co2,
                "location" => {
                    "lat" => loc[0],
                    "long" => loc[1] },
                "intake_rate"  => intake_ppm_rate
            };
        } else { 
            //user is indoors
            activity_body = { 
                "hr" => hr,
                "PM2.5" => pm25,
                "CO2" => co2,
                "intake_rate"  => intake_ppm_rate
            };
        }

        System.println("current stats: " + activity_body);
        
        return activity_body;
    }

}
