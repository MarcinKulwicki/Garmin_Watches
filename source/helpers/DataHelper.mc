import Toybox.System;
import Toybox.ActivityMonitor;
import Toybox.Activity;
import Toybox.SensorHistory;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Weather;
import Toybox.Lang;

module DataHelper {
    enum {
        DATA_NONE = 0,
        DATA_TIME = 1,
        DATA_DATE = 2,
        DATA_HEART_RATE = 3,
        DATA_TEMPERATURE = 4,
        DATA_STEPS = 5,
        DATA_BATTERY = 6,
        DATA_CALORIES = 7,
        DATA_FLOORS = 8,
        DATA_ALTITUDE = 9,
        DATA_NOTIFICATIONS = 10,
        DATA_SECONDS = 11
    }

    function getDataString(dataType as Number) as String {
        switch (dataType) {
            case DATA_TIME: return getTimeString();
            case DATA_DATE: return getDateString();
            case DATA_HEART_RATE: return getHeartRateString();
            case DATA_TEMPERATURE: return getTemperatureString();
            case DATA_STEPS: return getStepsString();
            case DATA_BATTERY: return getBatteryString();
            case DATA_CALORIES: return getCaloriesString();
            case DATA_FLOORS: return getFloorsString();
            case DATA_ALTITUDE: return getAltitudeString();
            case DATA_NOTIFICATIONS: return getNotificationsString();
            case DATA_SECONDS: return getSecondsString();
            default: return "";
        }
    }

    function getTimeString() as String {
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var useMilitary = SettingsHelper.getBooleanProperty("UseMilitaryFormat", false);
        
        if (!useMilitary) {
            if (hours > 12) { hours = hours - 12; }
            else if (hours == 0) { hours = 12; }
        }
        return hours.format("%02d") + ":" + clockTime.min.format("%02d");
    }

    function getDateString() as String {
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var months = [" Jan", " Feb", " Mar", " Apr", " May", " Jun", 
                      " Jul", " Aug", " Sep", " Oct", " Nov", " Dec"];
        return today.day.format("%02d") + months[today.month - 1];
    }

    function getHeartRateString() as String {
        var hr = getHeartRate();
        return (hr != null) ? hr.toString() : "--";
    }

    function getHeartRate() {
        var info = Activity.getActivityInfo();
        if (info != null && info.currentHeartRate != null) { 
            return info.currentHeartRate; 
        }
        if (ActivityMonitor has :getHeartRateHistory) {
            var hrIterator = ActivityMonitor.getHeartRateHistory(1, true);
            if (hrIterator != null) {
                var sample = hrIterator.next();
                if (sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                    return sample.heartRate;
                }
            }
        }
        return null;
    }

    function getTemperatureString() as String {
        var temp = null;
        var source = SettingsHelper.getNumberProperty("TemperatureSource", 1);
        
        if (source == 2) { temp = getSensorTemperature(); }
        else { temp = getWeatherTemperature(); }
        
        if (temp == null) { return "--°"; }
        
        var unit = SettingsHelper.getNumberProperty("TemperatureUnit", 1);
        if (unit == 2) { temp = (temp * 9 / 5) + 32; }
        return temp.toNumber().toString() + "°";
    }

    function getWeatherTemperature() {
        if (Toybox has :Weather && Weather has :getCurrentConditions) {
            var conditions = Weather.getCurrentConditions();
            if (conditions != null && conditions.temperature != null) {
                return conditions.temperature;
            }
        }
        return null;
    }

    function getSensorTemperature() {
        if (Toybox has :SensorHistory && SensorHistory has :getTemperatureHistory) {
            var tempIter = SensorHistory.getTemperatureHistory({
                :period => 1, 
                :order => SensorHistory.ORDER_NEWEST_FIRST
            });
            if (tempIter != null) {
                var sample = tempIter.next();
                if (sample != null && sample.data != null) { 
                    return sample.data; 
                }
            }
        }
        return null;
    }

    function getStepsString() as String {
        var info = ActivityMonitor.getInfo();
        return (info.steps != null) ? info.steps.toString() : "--";
    }

    function getBatteryString() as String {
        var stats = System.getSystemStats();
        return stats.battery.toNumber().toString();
    }

    function getCaloriesString() as String {
        var info = ActivityMonitor.getInfo();
        return (info.calories != null) ? info.calories.toString() : "--";
    }

    function getFloorsString() as String {
        var info = ActivityMonitor.getInfo();
        if (info has :floorsClimbed && info.floorsClimbed != null) {
            return info.floorsClimbed.toString();
        }
        return "--";
    }

    function getAltitudeString() as String {
        var alt = getAltitude();
        if (alt == null) { return "--"; }
        
        var unit = SettingsHelper.getNumberProperty("AltitudeUnit", 1);
        if (unit == 2) { alt = alt * 3.28084; }
        return alt.toNumber().toString();
    }

    function getAltitude() {
        var actInfo = Activity.getActivityInfo();
        if (actInfo != null && actInfo.altitude != null) {
            return actInfo.altitude;
        }
        if (Toybox has :SensorHistory && SensorHistory has :getElevationHistory) {
            var elevIter = SensorHistory.getElevationHistory({
                :period => 1, 
                :order => SensorHistory.ORDER_NEWEST_FIRST
            });
            if (elevIter != null) {
                var sample = elevIter.next();
                if (sample != null && sample.data != null) {
                    return sample.data;
                }
            }
        }
        return null;
    }

    function getNotificationsString() as String {
        var settings = System.getDeviceSettings();
        if (settings has :notificationCount) {
            return settings.notificationCount.toString();
        }
        return "--";
    }

    function getSecondsString() as String {
        return System.getClockTime().sec.format("%02d");
    }
}