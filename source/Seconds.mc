import Toybox.WatchUi;
import Toybox.System;
import Toybox.Graphics;

class Seconds {

    private var _x as Number;
    private var _y as Number;

    //! Constructor
    //! @param dc Device Content
    function initialize(dc as Dc) {
        _x = dc.getWidth() * 0.32;
        _y = dc.getHeight() * 0.81;
    }

    //! Draw the seconds after the time
	//! @param dc Device Content
	function drawSeconds(dc as Dc) as Void {	
		var secondsString = System.getClockTime().sec.toString();
		dc.setColor(themeColors[:foregroundPrimaryColor], Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _x,
            _y, 
            smallFont, 
            secondsString, 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
	}

	//! Gets the bounding box of the seconds to be able to use in 
	//! onPartialUpdate to update only the seconds region every seconds
	//! @param dc Device context
	//! @return Array of x, y, width, height of bounding box 
	function getSecondsBoundingBox(dc as Dc) as Array<Number> {
		var seconds = System.getClockTime().sec;
		// get the wider region in pixels of the current or the previous second
		var previousSecond = (seconds - 1) % 60;
		var maxTextDimensions = dc.getTextDimensions(previousSecond.toString(), smallFont)[0] > dc.getTextDimensions(seconds.toString(), smallFont)[0] ? 
			dc.getTextDimensions(previousSecond.toString(), smallFont) : 
			dc.getTextDimensions(seconds.toString(), smallFont);
		var width = maxTextDimensions[0] + 2;
		var height = maxTextDimensions[1];
		
		var x = _x - width / 2;
		var y = _y - height / 2;

		return [x, y + height * 0.20, width, height * 0.80];
	}
}