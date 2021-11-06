import Toybox.WatchUi;
import Toybox.System;
import Toybox.Graphics;

// Extend text to set as drawable text
class Time extends WatchUi.Text {
	
	private var _settings as System.DeviceSettings;
	private var _burnInProtection as Boolean; //true if amoled is in low power mode

	private var _clockTime as ClockTime;
	
	//! Constructor
	//! @param params in the layout.xml the drawable object's param tags
	function initialize(params) {
		Text.initialize(params);
	}

	//! Draw the time, AM/PM and seconds
	//! @param dc Device Content
	function draw(dc as Dc) as Void {
		refreshTimeData();
		var id = self.identifier;
		if (id.equals("Hour") || id.equals("AlwaysOnHourLeft") || id.equals("AlwaysOnHourRight")) {
			drawHour(dc);
		} else if (id.equals("Minute") || id.equals("AlwaysOnMinuteLeft") || id.equals("AlwaysOnMinuteRight")) {
			drawMinute(dc);
		} else if (id.equals("AmPm")) {
			drawAmPm(dc);
		} 
	}

	//! Draw the hours
	//! @param dc Device Content
	function drawHour(dc as Dc) as Void {
		var hours = _clockTime.hour;

		if (_burnInProtection) {
			self.setColor(Graphics.COLOR_WHITE);
		}
        if (!_settings.is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }
		var hoursString = hours.format("%02d");

		// Manual value for display purposes
		if (uatDisplayData) {
			hoursString = "04";
		}

		if (_burnInProtection) {
			self.setColor(Graphics.COLOR_WHITE);
		} else {
			self.setColor(themeColors[:foregroundPrimaryColor]);
		}	
		self.setText(hoursString);
		Text.draw(dc);
	}

	//! Draw the minutes
	//! @param dc Device Content
	function drawMinute(dc as Dc) as Void {
		var minutesString = _clockTime.min.format("%02d");
		
		// Manual value for display purposes
		if (uatDisplayData) {
			minutesString = "57";
		}

		if (_burnInProtection) {
			self.setColor(Graphics.COLOR_WHITE);
		} else {
			self.setColor(themeColors[:foregroundSecondaryColor]);
		}	
		self.setText(minutesString);
		Text.draw(dc);
	}
	
	//! Draw AM or PM in front of time if 12 hour format is set
	//! @param dc Device Content
	function drawAmPm(dc as Dc) as Void {
		if (!_settings.is24Hour) {
			var AmPmString = _clockTime.hour >= 12 ? "PM" : "AM";

			// Manual value for display purposes
			if (uatDisplayData) {
				AmPmString = "AM";
			}

			self.setColor(themeColors[:foregroundSecondaryColor]);
			self.setText(AmPmString);
			Text.draw(dc);
		}
	}
	
	//! Refresh time data
	private function refreshTimeData() as Void {
		_clockTime = System.getClockTime();			
	}

	//! Set settings
	//! @param settings DeviceSettings
	function setSettings(settings as DeviceSettings) as Void {
		_settings = settings;
	}

	//! Set Burn In protection
	//! @param settings DeviceSettings
	function setBurnInProtection(burnInProtection as Boolean) as Void {
		_burnInProtection = burnInProtection;
	}
}
