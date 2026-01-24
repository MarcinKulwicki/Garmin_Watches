import Toybox.Application;
import Toybox.Lang;

module SettingsHelper {
    function getNumberProperty(id as String, defaultVal as Number) as Number {
        try {
            var val = Application.Properties.getValue(id);
            if (val != null && val instanceof Number) {
                return val as Number;
            }
        } catch (e) {}
        return defaultVal;
    }

    function getBooleanProperty(id as String, defaultVal as Boolean) as Boolean {
        try {
            var val = Application.Properties.getValue(id);
            if (val != null && val instanceof Boolean) {
                return val as Boolean;
            }
        } catch (e) {}
        return defaultVal;
    }

    function getStringProperty(id as String, defaultVal as String) as String {
        try {
            var val = Application.Properties.getValue(id);
            if (val != null && val instanceof String) {
                return val as String;
            }
        } catch (e) {}
        return defaultVal;
    }
}