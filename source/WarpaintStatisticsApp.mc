import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Lang;

// global variables
var myView;

var smallFont;
var mediumFont;
var largeFont;
var iconFont;

var theme as Number = 0;
var themeColors as Dictionary = {
    :foregroundPrimaryColor => 0xFFFFFF,
    :foregroundSecondaryColor => 0xFFFFFF,
    :backgroundColor => 0x000000,
    :isColorful => false
};

var side as Integer = 0;

var displaySecond as Integer = 0;

var selectedValueForDataFieldTop as Integer = 0;
var selectedValueForDataFieldBottom as Integer = 0;
var selectedValueForDataField1 as Integer = 0;
var selectedValueForDataField2 as Integer = 0;
var selectedValueForDataField3 as Integer = 0;
var selectedValueForDataField4 as Integer = 0;
var selectedValueForDataField5 as Integer = 0;
var selectedValueForDataField6 as Integer = 0;

var selectedToDate as Number = 0;

var selectedValueForDataBarOuterLeftTop as Integer = 0;
var selectedValueForDataBarInnerRightBottom as Integer = 0;
var dataBarSplit as Integer = 0;
var sunriseSunsetDrawingEnabled as Boolean = false;
var sunriseSunset as SunriseSunset? = null;

var totalCaloriesGoal as Number = 0;

// Store in storage/property
var locationLat as Float = 0.0;
var locationLng as Float = 0.0;

enum { 
    DATA_BATTERY,  //0 
    DATA_STEPS,
    DATA_HEARTRATE,
    DATA_CALORIES,
    DATA_SUNRISE_SUNSET,
    DATA_DISTANCE, //5
    DATA_FLOORS_CLIMBED,
    DATA_ACTIVE_MINUTES_WEEK,
    DATA_WEATHER,
    DATA_DEVICE_INDICATORS,
    // Deleted data field //10
    DATA_MOVEBAR = 11,
    DATA_REMAINING_TIME,
    DATA_METERS_CLIMBED,
    DATA_SUNRISE,
    DATA_SUNSET, //15
    DATA_OFF = -1
}

enum { 
    SIDE_LEFT,
    SIDE_RIGHT
}

enum { 
    DATABAR_OUTER_LEFT_TOP,
    DATABAR_INNER_RIGHT_BOTTOM
}

enum { 
    DATABAR_SPLIT_OFF,
    DATABAR_SPLIT_OUTER_LEFT_TOP,
    DATABAR_SPLIT_INNER_RIGHT_BOTTOM,
    DATABAR_SPLIT_ALL
}

class WarpaintStatisticsApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
    	myView = new WarpaintStatisticsView();
        setGlobalVariables();
        Theme.selectThemeColors();
        myView.loadFonts();
        
        return [ myView ];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        setGlobalVariables();
        Theme.selectThemeColors();
        myView.loadFonts();
        myView.onSettingsChanged();

        WatchUi.requestUpdate();
    }

    //! Set global variables (fonts are in the View)
    private function setGlobalVariables() as Void {
    	if (Toybox.Application has :Storage) {
            setGlobalVariablesWithStorage();
		} else {
            setGlobalVariablesWithoutStorage();
		}
    }

    //! Set global variables with storage enabled
    (:has_storage)
    private function setGlobalVariablesWithStorage() as Void {
        theme = Properties.getValue("Theme");

        side = Properties.getValue("Side");

        displaySecond = Properties.getValue("DisplaySecond");

        selectedValueForDataFieldTop = Properties.getValue("DataFieldTop");
        selectedValueForDataFieldBottom = Properties.getValue("DataFieldBottom");
        selectedValueForDataField1 = Properties.getValue("DataField1");
        selectedValueForDataField2 = Properties.getValue("DataField2");
        selectedValueForDataField3 = Properties.getValue("DataField3");
        selectedValueForDataField4 = Properties.getValue("DataField4");
        selectedValueForDataField5 = Properties.getValue("DataField5");
        selectedValueForDataField6 = Properties.getValue("DataField6");
        selectedValueForDataBarOuterLeftTop = Properties.getValue("DataBarOuterLeftTop");
        selectedValueForDataBarInnerRightBottom = Properties.getValue("DataBarInnerRightBottom");
        sunriseSunsetDrawingEnabled = Properties.getValue("SunriseSunsetDrawing");
        dataBarSplit = Properties.getValue("DataBarSplit");

        selectedToDate = Properties.getValue("RemainingTimeToDate");

        totalCaloriesGoal = Properties.getValue("CaloriesGoal");

        locationLat = Storage.getValue("LastLocationLat");
        locationLng = Storage.getValue("LastLocationLng");
    }

    //! Set global variables without storage enabled
    (:has_no_storage)
    private function setGlobalVariablesWithoutStorage() as Void {
        theme = getApp().getProperty("Theme");

        side = getApp().getProperty("Side");

        displaySecond = getApp().getProperty("DisplaySecond");

        selectedValueForDataFieldTop = getApp().getProperty("DataFieldTop");
        selectedValueForDataFieldBottom = getApp().getProperty("DataFieldBottom");
        selectedValueForDataField1 = getApp().getProperty("DataField1");
        selectedValueForDataField2 = getApp().getProperty("DataField2");
        selectedValueForDataField3 = getApp().getProperty("DataField3");
        selectedValueForDataField4 = getApp().getProperty("DataField4");
        selectedValueForDataField5 = getApp().getProperty("DataField5");
        selectedValueForDataField6 = getApp().getProperty("DataField6");
        selectedValueForDataBarOuterLeftTop = getApp().getProperty("DataBarOuterLeftTop");
        selectedValueForDataBarInnerRightBottom = getApp().getProperty("DataBarInnerRightBottom");
        sunriseSunsetDrawingEnabled = getApp().getProperty("SunriseSunsetDrawing");
        dataBarSplit = getApp().getProperty("DataBarSplit");

        selectedToDate = getApp().getProperty("RemainingTimeToDate");

        totalCaloriesGoal = getApp().getProperty("CaloriesGoal");

        locationLat = getApp().getProperty("LastLocationLat");
        locationLng = getApp().getProperty("LastLocationLng");
    }
}

function getApp() as WarpaintStatisticsApp {
    return Application.getApp() as WarpaintStatisticsApp;
}
