import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Graphics;

// Extend text to set as drawable text
class Date extends WatchUi.Text {
	
    private var _dayOfWeeks = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
    private var _months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
	
	//! Constructor
	//! @param params in the layout.xml the drawable object's param tags
	function initialize(params) {
		Text.initialize(params);
	}
	
	//! Draw the date
	//! @param dc Device Content
	function draw(dc as Dc) as Void {
		drawDate(dc);
	}

	//! Draw the date
	//! @param dc Device Content
	private function drawDate(dc as Dc) as Void {
		var date = getDate();
		self.setColor(themeColors[:foregroundSecondaryColor]);	
        self.setText(date);
		Text.draw(dc);
	}
	
	//! Get actual date
	//! @return formatted date as string
	private function getDate() as String {
		var actualDate = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        return _dayOfWeeks[(actualDate.day_of_week - 1) % 7] + ", " + _months[actualDate.month - 1] + " " + actualDate.day;
	}
}
