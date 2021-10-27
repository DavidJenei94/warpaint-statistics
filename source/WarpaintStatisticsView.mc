import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class WarpaintStatisticsView extends WatchUi.WatchFace {

    private var viewDrawables = {};
	private var _isAwake as Boolean;
	private var _partialUpdatesAllowed as Boolean;
	private var _SecondsBoundingBox = new Number[4];

    private var _data as Data;

	private var _burnInProtection as Boolean;
	private var _burnInTimeChanged as Boolean;
	private var _burnInTimeDisplayed as Boolean;

	private var _deviceSettings as System.DeviceSettings;

    function initialize() {
        WatchFace.initialize();
        _deviceSettings = System.getDeviceSettings();
        _isAwake = true;
        _partialUpdatesAllowed = (WatchUi.WatchFace has :onPartialUpdate);
        _data = new Data(_deviceSettings);

        // check Burn in Protect requirement
		_burnInProtection = (_deviceSettings has :requiresBurnInProtection) ? _deviceSettings.requiresBurnInProtection : false;
		if (_burnInProtection) {
			_burnInTimeChanged = true;
			_burnInTimeDisplayed = false;
		}
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        loadDrawables();
    }

    //! Load drawables
    private function loadDrawables() as Void {
        viewDrawables[:hourText] = View.findDrawableById("Hour");
        viewDrawables[:minuteText] = View.findDrawableById("Minute");
		// if (_burnInProtection) {
		// 	viewDrawables[:timeTextTop] = View.findDrawableById("AlwaysOnTimeLabelTopLabel");
		// 	viewDrawables[:timeTextBottom] = View.findDrawableById("AlwaysOnTimeLabelBottomLabel");
		// }
        // viewDrawables[:dateText] = View.findDrawableById("DateLabel");

        viewDrawables[:dataField1Text] = View.findDrawableById("DataField1");
		viewDrawables[:dataField2Text] = View.findDrawableById("DataField2");
		viewDrawables[:dataField3Text] = View.findDrawableById("DataField3");
		viewDrawables[:dataField4Text] = View.findDrawableById("DataField4");
		viewDrawables[:dataField5Text] = View.findDrawableById("DataField5");
		viewDrawables[:dataField6Text] = View.findDrawableById("DataField6");
		viewDrawables[:dataField7Text] = View.findDrawableById("DataField7");

		viewDrawables[:leftDataBar] = View.findDrawableById("OuterLeftTopDataBar");
		viewDrawables[:rightDataBar] = View.findDrawableById("InnerRightBottomDataBar");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {

        // Set anti-aliasing if possible
		if (dc has :setAntiAlias) {
			dc.setAntiAlias(true);
		}

        // Set settings to the Time and databars
        viewDrawables[:hourText].setSettings(_deviceSettings);
        viewDrawables[:leftDataBar].setSettings(_deviceSettings);
        viewDrawables[:rightDataBar].setSettings(_deviceSettings);
        // Set BurnInProtection for Time layout
        viewDrawables[:hourText].setBurnInProtection(_burnInTimeDisplayed);
        viewDrawables[:minuteText].setBurnInProtection(_burnInTimeDisplayed);

        // Refresh data 
        _data.refreshData(_deviceSettings);

        // Check if refresh sunriseSunset is necessary
        SunriseSunset.checkSunriseSunsetRefresh();

        // Set data for data fields
        viewDrawables[:dataField1Text].setSelectedData(_data.getDataForDataField(selectedValueForDataField1));
        viewDrawables[:dataField2Text].setSelectedData(_data.getDataForDataField(selectedValueForDataField2));
        viewDrawables[:dataField3Text].setSelectedData(_data.getDataForDataField(selectedValueForDataField3));
        viewDrawables[:dataField4Text].setSelectedData(_data.getDataForDataField(selectedValueForDataField4));
        viewDrawables[:dataField5Text].setSelectedData(_data.getDataForDataField(selectedValueForDataField5));
        viewDrawables[:dataField6Text].setSelectedData(_data.getDataForDataField(selectedValueForDataField6));
        viewDrawables[:dataField7Text].setSelectedData(_data.getDataForDataField(selectedValueForDataField7));
        
        // Set data for databars
        if (!sunriseSunsetDrawingEnabled) {
            viewDrawables[:leftDataBar].setSelectedData(_data.getDataForDataField(selectedValueForDataBarOuterLeftTop));
        }
        viewDrawables[:rightDataBar].setSelectedData(_data.getDataForDataField(selectedValueForDataBarInnerRightBottom));

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    //! Load fonts - in View, because WatchUI is not supported in background events
    function loadFonts() as Void {
		// smallFont = WatchUi.loadResource(Rez.Fonts.SmallFont);
		mediumFont = WatchUi.loadResource(Rez.Fonts.MediumFont);
		largeFont = WatchUi.loadResource(Rez.Fonts.LargeFont);
		iconFont = WatchUi.loadResource(Rez.Fonts.IconFont);
    }

}
