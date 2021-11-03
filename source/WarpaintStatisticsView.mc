import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class WarpaintStatisticsView extends WatchUi.WatchFace {

    private var viewDrawables = {};
	private var _isAwake as Boolean;
	private var _seconds as Seconds;
    private var _partialUpdatesAllowed as Boolean;

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
        setLayout(Rez.Layouts.WatchFaceLeft(dc));
        loadDrawables();

        _seconds = new Seconds(dc);
    }

    //! Load drawables
    private function loadDrawables() as Void {
        viewDrawables[:hourText] = View.findDrawableById("Hour");
        viewDrawables[:minuteText] = View.findDrawableById("Minute");
        viewDrawables[:AmPmText] = View.findDrawableById("AmPm");
		if (_burnInProtection) {
			viewDrawables[:hourTextLeft] = View.findDrawableById("AlwaysOnHourLeft");
			viewDrawables[:minuteTextLeft] = View.findDrawableById("AlwaysOnMinuteLeft");
			viewDrawables[:hourTextRight] = View.findDrawableById("AlwaysOnHourRight");
			viewDrawables[:minuteTextRight] = View.findDrawableById("AlwaysOnMinuteRight");
		}
        viewDrawables[:dateText] = View.findDrawableById("DateLabel");

        viewDrawables[:dataFieldTopText] = View.findDrawableById("DataFieldTop");
        viewDrawables[:dataFieldBottomText] = View.findDrawableById("DataFieldBottom");
        viewDrawables[:dataField1Text] = View.findDrawableById("DataField1");
		viewDrawables[:dataField2Text] = View.findDrawableById("DataField2");
		viewDrawables[:dataField3Text] = View.findDrawableById("DataField3");
		viewDrawables[:dataField4Text] = View.findDrawableById("DataField4");
		viewDrawables[:dataField5Text] = View.findDrawableById("DataField5");
		viewDrawables[:dataField6Text] = View.findDrawableById("DataField6");

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

        // If AMOLED watch is in low power mode it shows different layout
		if (_burnInProtection && !_isAwake) {
            // Load actual layout
            // Free memory of other drawables (reload later when awake)
            if (_burnInTimeChanged) {
                setLayout(Rez.Layouts.AlwaysOnLeft(dc));
            } else {
                setLayout(Rez.Layouts.AlwaysOnRight(dc));
            }
            loadDrawables();

            _burnInTimeDisplayed = true;

			// Draw To AlwaysOnLayout
			drawAlwaysOn(dc);

            _burnInTimeChanged = !_burnInTimeChanged;
            
		} else {
            // Reload drawables if changed from low power mode in case of AMOLED
			if (_burnInProtection && _burnInTimeDisplayed) {
				setLayout(Rez.Layouts.WatchFaceLeft(dc));
				loadDrawables();

				_burnInTimeDisplayed = false;
			}

            // Set settings to the Time and databars
            viewDrawables[:hourText].setSettings(_deviceSettings);
            viewDrawables[:AmPmText].setSettings(_deviceSettings);
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
            viewDrawables[:dataFieldTopText].setSelectedData(_data.getDataForDataField(selectedValueForDataFieldTop));
            viewDrawables[:dataFieldBottomText].setSelectedData(_data.getDataForDataField(selectedValueForDataFieldBottom));
            viewDrawables[:dataField1Text].setSelectedData(_data.getDataForDataField(selectedValueForDataField1));
            viewDrawables[:dataField2Text].setSelectedData(_data.getDataForDataField(selectedValueForDataField2));
            viewDrawables[:dataField3Text].setSelectedData(_data.getDataForDataField(selectedValueForDataField3));
            viewDrawables[:dataField4Text].setSelectedData(_data.getDataForDataField(selectedValueForDataField4));
            viewDrawables[:dataField5Text].setSelectedData(_data.getDataForDataField(selectedValueForDataField5));
            viewDrawables[:dataField6Text].setSelectedData(_data.getDataForDataField(selectedValueForDataField6));
            
            // Set data for databars
            if (!sunriseSunsetDrawingEnabled) {
                viewDrawables[:leftDataBar].setSelectedData(_data.getDataForDataField(selectedValueForDataBarOuterLeftTop));
            }
            viewDrawables[:rightDataBar].setSelectedData(_data.getDataForDataField(selectedValueForDataBarInnerRightBottom));

            // Call the parent onUpdate function to redraw the layout
            View.onUpdate(dc);
            
            // Draw seconds
			if (System.getClockTime().sec != 0) {
				if (_partialUpdatesAllowed && displaySecond == 2) {
					// If this device supports partial updates
					onPartialUpdate(dc);
				} else if (_isAwake && displaySecond != 0) {
					_seconds.drawSeconds(dc);
				}
			}
        }
    }

    //! Handle the partial update event - Draw seconds every second
    //! @param dc Device context
	(:partial_update)
    public function onPartialUpdate(dc as Dc) as Void {
		if (displaySecond == 2 && System.getClockTime().sec != 0) {
            var secondsBoundingBox = _seconds.getSecondsBoundingBox(dc);
        
            // Set clip to the region of bounding box and which only updates that
            dc.setClip(secondsBoundingBox[0], secondsBoundingBox[1], secondsBoundingBox[2], secondsBoundingBox[3]);
            dc.setColor(themeColors[:foregroundPrimaryColor], themeColors[:backgroundColor]);
            dc.clear();

            _seconds.drawSeconds(dc);
            
            dc.clearClip();

            // dc.setPenWidth(1);
            // dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            // dc.drawRectangle(secondsBoundingBox[0], secondsBoundingBox[1], secondsBoundingBox[2], secondsBoundingBox[3]);
        }
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() as Void {
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        _isAwake = true;
		WatchUi.requestUpdate();
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        _isAwake = false;
		WatchUi.requestUpdate(); // call onUpdate() in order to draw seconds
    }

    //! Load fonts - in View, because WatchUI is not supported in background events
    function loadFonts() as Void {
		smallFont = WatchUi.loadResource(Rez.Fonts.SmallFont);
		mediumFont = WatchUi.loadResource(Rez.Fonts.MediumFont);
		largeFont = WatchUi.loadResource(Rez.Fonts.LargeFont);
		iconFont = WatchUi.loadResource(Rez.Fonts.IconFont);
    }

	//! Reload DeviceSettings when settings are changed
    function onSettingsChanged() as Void {
		_deviceSettings = System.getDeviceSettings();
	}

	//! Draw To AlwaysOnLayout
	//! @param dc Device context
	(:burn_in_protection)
	function drawAlwaysOn(dc as Dc) as Void {
        if (_burnInTimeChanged) {
            // Set settings and BurnInProtection for Time layout
            viewDrawables[:hourTextLeft].setSettings(_deviceSettings);
            viewDrawables[:hourTextLeft].setBurnInProtection(_burnInTimeDisplayed);
            viewDrawables[:minuteTextLeft].setBurnInProtection(_burnInTimeDisplayed);
        } else {
            // Set settings and BurnInProtection for Time layout
            viewDrawables[:hourTextRight].setSettings(_deviceSettings);
            viewDrawables[:hourTextRight].setBurnInProtection(_burnInTimeDisplayed);
            viewDrawables[:minuteTextRight].setBurnInProtection(_burnInTimeDisplayed);
        }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var height = dc.getHeight();
        var width = dc.getWidth();
        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        if (_burnInTimeChanged) {
            dc.drawLine(width * 0.5, height * 0.1, width * 0.5, height * 0.9);
        } else {
            dc.drawLine(width * 0.5 - 1, height * 0.1, width * 0.5 - 1, height * 0.9);
        }
	}
}
