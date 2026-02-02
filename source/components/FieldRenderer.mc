import Toybox.Graphics;
import Toybox.Lang;

module FieldRenderer {
    function drawField(dc as Dc, fieldName as String, x as Number, y as Number, 
                       font, justification as Number) as Void {
        var dataType = SettingsHelper.getNumberProperty(fieldName + "FieldData", DataHelper.DATA_NONE);
        if (dataType == DataHelper.DATA_NONE) { return; }
        
        var color = ColorHelper.getColorFromProperty(
            fieldName + "FieldColor", 
            fieldName + "FieldColorCustom", 
            ColorHelper.COLOR_DEFAULT
        );
        var text = DataHelper.getDataString(dataType);
        
        if (fieldName.equals("Middle")) {
            var leftData = SettingsHelper.getNumberProperty("LeftFieldData", DataHelper.DATA_NONE);
            var rightData = SettingsHelper.getNumberProperty("RightFieldData", DataHelper.DATA_NONE);
            if (leftData == DataHelper.DATA_NONE && rightData == DataHelper.DATA_NONE) {
                y = dc.getHeight() / 2;
            }
        }
        
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, justification | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawSideField(dc as Dc, fieldName as String, y as Number, 
                           isLeft as Boolean, font) as Void {
        var dataType = SettingsHelper.getNumberProperty(fieldName + "FieldData", DataHelper.DATA_NONE);
        if (dataType == DataHelper.DATA_NONE) { return; }
        
        var color = ColorHelper.getColorFromProperty(
            fieldName + "FieldColor", 
            fieldName + "FieldColorCustom", 
            ColorHelper.COLOR_DEFAULT
        );
        var text = DataHelper.getDataString(dataType);
        var textLen = text.length();
        
        var x;
        var justification;
        
        if (textLen <= 3) {
            x = isLeft ? dc.getWidth() / 5 : dc.getWidth() * 4 / 5;
            justification = Graphics.TEXT_JUSTIFY_CENTER;
        } else {
            var margin = 25;
            if (isLeft) {
                x = margin;
                justification = Graphics.TEXT_JUSTIFY_LEFT;
            } else {
                x = dc.getWidth() - margin;
                justification = Graphics.TEXT_JUSTIFY_RIGHT;
            }
        }
        
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, justification | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}