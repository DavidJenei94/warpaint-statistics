import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

// Extend text to set as drawable text
class DataField extends WatchUi.Text {
	
	private var _selectedValue as Number or Null or Dictionary = null;

	private var _x as Float;
	private var _y as Float;
	private var _fixed as Boolean;
	private var _pixelsBetweenIconAndData as Number;
	
	//! Constructor
	//! @param params in the layout.xml the drawable object's param tags
	function initialize(params) {
		Text.initialize(params);
		_x = params[:locX];
		_y = params[:locY];
		_fixed = params[:fixed];
		
		_pixelsBetweenIconAndData = params[:iconSpace];
	}

	//! Set Selected Data
	//! @param selectedValue the selected datavalue
	function setSelectedData(selectedValue as Number) as Void {
		_selectedValue = selectedValue;
	}

	//! Draw the data Field
	//! @param dc Device Content
	function draw(dc as Dc) as Void {
		if (_selectedValue != null && _selectedValue[:valid]){
			drawData(dc, _selectedValue[:displayData], _selectedValue[:iconText], _selectedValue[:iconColor]);
		}
	}
	
	//! Draw the selected data
	//! @param dc Device Content
	//! @param dataText Data in string format
	//! @param iconText Letter for icon in string format
	//! @param iconColor color of the icon
	private function drawData(dc as Dc, dataText as String, iconText as String, iconColor as Number) as Void {
		drawIcon(dc, iconText, iconColor, dataText);
		
		if (_fixed) {
			self.setColor(themeColors[:foregroundSecondaryColor]);
		} else {
			self.setColor(themeColors[:foregroundPrimaryColor]);
		}
				
        self.setText(dataText);
		Text.draw(dc);
	}
	
	//! Draw icon in parameter and color
	//! @param dc Device Content
	//! @param iconText Letter for icon in string format
	//! @param color color of the icon
	//! @param dataText Data in string format
	private function drawIcon(dc as Dc, iconText as String, color as Number, dataText as String) as Void {
		if (!themeColors[:isColorful]) {
			if (_fixed) {
				dc.setColor(themeColors[:foregroundPrimaryColor], Graphics.COLOR_TRANSPARENT);
			} else {
				dc.setColor(themeColors[:foregroundSecondaryColor], Graphics.COLOR_TRANSPARENT);
			}
		} else {
			dc.setColor(color, Graphics.COLOR_TRANSPARENT);
		}
		
		if (_fixed) {
			dc.drawText(_x, _y, iconFont, iconText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		} else {
			if (side == SIDE_LEFT) {
				dc.drawText(_x - _pixelsBetweenIconAndData, _y, iconFont, iconText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
			} else if (side == SIDE_RIGHT) {
				dc.drawText(_x + _pixelsBetweenIconAndData, _y, iconFont, iconText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
			}
		}
	}
}
