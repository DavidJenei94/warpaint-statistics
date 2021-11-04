import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// global variables
var myView as View;

var smallFont as Font;
var mediumFont as Font;
var largeFont as Font;
var iconFont as Font;

var theme as Number;
var themeColors = {
    :foregroundPrimaryColor => 0xFFFFFF,
    :foregroundSecondaryColor => 0xFFFFFF,
    :backgroundColor => 0x000000,
    :isColorful => false
};

var side as Integer;

var displaySecond as Integer;

var selectedValueForDataFieldTop as Integer;
var selectedValueForDataFieldBottom as Integer;
var selectedValueForDataField1 as Integer;
var selectedValueForDataField2 as Integer;
var selectedValueForDataField3 as Integer;
var selectedValueForDataField4 as Integer;
var selectedValueForDataField5 as Integer;
var selectedValueForDataField6 as Integer;

var selectedToDate as Number;

var selectedValueForDataBarOuterLeftTop as Integer;
var selectedValueForDataBarInnerRightBottom as Integer;
var dataBarSplit as Integer;
var sunriseSunsetDrawingEnabled as Boolean;
var sunriseSunset as SunriseSunset;

var totalCaloriesGoal as Number;

// Store in storage/property
var locationLat as Float;
var locationLng as Float;

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
    function getInitialView() as Array<Views or InputDelegates>? {
        myView = new WarpaintStatisticsView();
        setGlobalVariables();
        Theme.selectThemeColors();
        myView.loadFonts();
        
        return [ myView ] as Array<Views or InputDelegates>;
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
    private function setGlobalVariablesWithStorage() as void {
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
    private function setGlobalVariablesWithoutStorage() as void {
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
