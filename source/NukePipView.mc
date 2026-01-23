import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.System;
import Toybox.ActivityMonitor;
import Toybox.Activity;
import Toybox.SensorHistory;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Weather;
import Toybox.Math;

class NukePipView extends WatchUi.WatchFace {
    private var backgroundBitmap;
    private var fontRegular;
    private var fontSmall;
    private var font40;
    private var currentBackground = 1;
    private var currentFont = 1;

    // Typy danych
    enum {
        DATA_NONE = 0,
        DATA_TIME = 1,
        DATA_DATE = 2,
        DATA_HEART_RATE = 3,
        DATA_TEMPERATURE = 4,
        DATA_STEPS = 5,
        DATA_BATTERY = 6,
        DATA_CALORIES = 7,
        DATA_DISTANCE = 8,
        DATA_FLOORS = 9,
        DATA_ALTITUDE = 10,
        DATA_NOTIFICATIONS = 11,
        DATA_SECONDS = 12
    }

    // Ustawienia wskaźnika baterii
    private const BATTERY_TICK_LENGTH = 12;
    private const BATTERY_TICK_WIDTH = 4;
    private const BATTERY_TICK_OVERFLOW = 10;
    private const BATTERY_MAX_TICKS = 60;
    
    private const BATTERY_COLOR_FULL_DEFAULT = 0x008000;
    private const BATTERY_COLOR_MID_DEFAULT = 0xFFFF12;
    private const BATTERY_COLOR_LOW_DEFAULT = 0x6E0300;
    private const COLOR_INVALID_HEX = 0xFF00FF;
    private const COLOR_DEFAULT = 0xFFFFFF;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        loadBackground();
        loadFonts();
    }

    function loadFonts() as Void {
        var choice = getNumberProperty("FontChoice", 1);
        currentFont = choice;
        
        switch (choice) {
            case 2:
                fontRegular = Application.loadResource(Rez.Fonts.GoldmanRegular);
                fontSmall = Application.loadResource(Rez.Fonts.GoldmanSmall);
                font40 = Application.loadResource(Rez.Fonts.Goldman40);
                break;
            case 3:
                fontRegular = Application.loadResource(Rez.Fonts.SilkscreenRegular);
                fontSmall = Application.loadResource(Rez.Fonts.SilkscreenSmall);
                font40 = Application.loadResource(Rez.Fonts.Silkscreen40);
                break;
            case 4:
                fontRegular = Application.loadResource(Rez.Fonts.TourneyCondensedRegular);
                fontSmall = Application.loadResource(Rez.Fonts.TourneyCondensedSmall);
                font40 = Application.loadResource(Rez.Fonts.TourneyCondensed40);
                break;
            case 5:
                fontRegular = Application.loadResource(Rez.Fonts.OrbitronRegular);
                fontSmall = Application.loadResource(Rez.Fonts.OrbitronSmall);
                font40 = Application.loadResource(Rez.Fonts.Orbitron40);
                break;
            default:
                fontRegular = Application.loadResource(Rez.Fonts.HandjetRegular);
                fontSmall = Application.loadResource(Rez.Fonts.HandjetSmall);
                font40 = Application.loadResource(Rez.Fonts.Handjet40);
        }
    }

    function loadBackground() as Void {
        var choice = getNumberProperty("BackgroundChoice", 1);
        currentBackground = choice;
        
        switch (choice) {
            case 2: backgroundBitmap = Application.loadResource(Rez.Drawables.Background2); break;
            case 3: backgroundBitmap = Application.loadResource(Rez.Drawables.Background3); break;
            case 4: backgroundBitmap = Application.loadResource(Rez.Drawables.Background4); break;
            case 5: backgroundBitmap = Application.loadResource(Rez.Drawables.Background5); break;
            case 6: backgroundBitmap = Application.loadResource(Rez.Drawables.Background6); break;
            case 7: backgroundBitmap = Application.loadResource(Rez.Drawables.Background7); break;
            case 8: backgroundBitmap = Application.loadResource(Rez.Drawables.Background8); break;
            case 9: backgroundBitmap = Application.loadResource(Rez.Drawables.Background9); break;
            case 10: backgroundBitmap = Application.loadResource(Rez.Drawables.Background10); break;
            case 11: backgroundBitmap = Application.loadResource(Rez.Drawables.Background11); break;
            case 12: backgroundBitmap = Application.loadResource(Rez.Drawables.Background12); break;
            case 13: backgroundBitmap = Application.loadResource(Rez.Drawables.Background13); break;
            default: backgroundBitmap = Application.loadResource(Rez.Drawables.Background1);
        }
    }

    function getNumberProperty(id as String, defaultVal as Number) as Number {
        try {
            var val = Application.Properties.getValue(id);
            if (val != null && val instanceof Number) {
                return val as Number;
            }
        } catch (e) {}
        return defaultVal;
    }

    // Tablica predefiniowanych kolorów (indeksy 1-20, 21 = custom)
    private var PRESET_COLORS = [
        0xFFFFFF,  // 1 - White
        0x000000,  // 2 - Black
        0xFF0000,  // 3 - Red
        0x8B0000,  // 4 - Dark Red
        0x00FF00,  // 5 - Green
        0x006400,  // 6 - Dark Green
        0x0000FF,  // 7 - Blue
        0xFFFF00,  // 8 - Yellow
        0xFF8C00,  // 9 - Orange
        0x8B00FF,  // 10 - Purple
        0xFF69B4,  // 11 - Pink
        0x00FFFF,  // 12 - Cyan
        0x20B2AA,  // 13 - Teal
        0xFFD700,  // 14 - Gold
        0xC0C0C0,  // 15 - Silver
        0x32CD32,  // 16 - Lime
        0xFF6B6B,  // 17 - Coral
        0x000080,  // 18 - Navy
        0xF5DEB3,  // 19 - Beige
        0x808080   // 20 - Gray
    ];

    function getColorFromProperty(propertyId as String, customPropertyId as String, defaultColor as Number) as Number {
        var colorChoice = getNumberProperty(propertyId, 1);
        
        if (colorChoice == 21) {
            // Custom HEX
            try {
                var hexVal = Application.Properties.getValue(customPropertyId);
                if (hexVal != null && hexVal instanceof String) {
                    return parseHexColor(hexVal as String, defaultColor);
                }
            } catch (e) {}
            return defaultColor;
        } else if (colorChoice >= 1 && colorChoice <= 20) {
            return PRESET_COLORS[colorChoice - 1];
        }
        return defaultColor;
    }
    
    function getColor(propertyId as String, defaultColor as Number) as Number {
        try {
            var hexVal = Application.Properties.getValue(propertyId);
            if (hexVal != null && hexVal instanceof String) {
                return parseHexColor(hexVal as String, defaultColor);
            }
        } catch (e) {}
        return defaultColor;
    }

    function parseHexColor(hexString as String, defaultColor as Number) as Number {
        if (hexString == null || hexString.length() == 0) { return defaultColor; }
        var hex = hexString.toUpper();
        if (hex.substring(0, 1).equals("#")) { hex = hex.substring(1, hex.length()); }
        if (hex.length() != 6) { return COLOR_INVALID_HEX; }
        
        var r = parseHexByte(hex.substring(0, 2));
        var g = parseHexByte(hex.substring(2, 4));
        var b = parseHexByte(hex.substring(4, 6));
        
        if (r < 0 || g < 0 || b < 0) { return COLOR_INVALID_HEX; }
        return (r << 16) | (g << 8) | b;
    }
    
    function parseHexByte(hexByte as String) as Number {
        if (hexByte.length() != 2) { return -1; }
        var result = 0;
        for (var i = 0; i < 2; i++) {
            var c = hexByte.substring(i, i + 1);
            var val = 0;
            if (c.equals("0")) { val = 0; }
            else if (c.equals("1")) { val = 1; }
            else if (c.equals("2")) { val = 2; }
            else if (c.equals("3")) { val = 3; }
            else if (c.equals("4")) { val = 4; }
            else if (c.equals("5")) { val = 5; }
            else if (c.equals("6")) { val = 6; }
            else if (c.equals("7")) { val = 7; }
            else if (c.equals("8")) { val = 8; }
            else if (c.equals("9")) { val = 9; }
            else if (c.equals("A")) { val = 10; }
            else if (c.equals("B")) { val = 11; }
            else if (c.equals("C")) { val = 12; }
            else if (c.equals("D")) { val = 13; }
            else if (c.equals("E")) { val = 14; }
            else if (c.equals("F")) { val = 15; }
            else { return -1; }
            result = result * 16 + val;
        }
        return result;
    }

    function interpolateColor(color1 as Number, color2 as Number, ratio as Float) as Number {
        var r1 = (color1 >> 16) & 0xFF; var g1 = (color1 >> 8) & 0xFF; var b1 = color1 & 0xFF;
        var r2 = (color2 >> 16) & 0xFF; var g2 = (color2 >> 8) & 0xFF; var b2 = color2 & 0xFF;
        var r = (r1 + ((r2 - r1) * ratio)).toNumber();
        var g = (g1 + ((g2 - g1) * ratio)).toNumber();
        var b = (b1 + ((b2 - b1) * ratio)).toNumber();
        return (r << 16) | (g << 8) | b;
    }

    function getBatteryColor(batteryPercent as Number) as Number {
        var colorFull = getColorFromProperty("BatteryColorFull", "BatteryColorFullCustom", BATTERY_COLOR_FULL_DEFAULT);
        var colorMid = getColorFromProperty("BatteryColorMid", "BatteryColorMidCustom", BATTERY_COLOR_MID_DEFAULT);
        var colorLow = getColorFromProperty("BatteryColorLow", "BatteryColorLowCustom", BATTERY_COLOR_LOW_DEFAULT);
        
        if (batteryPercent >= 50) {
            return interpolateColor(colorFull, colorMid, (100 - batteryPercent) / 50.0);
        } else {
            return interpolateColor(colorMid, colorLow, (50 - batteryPercent) / 50.0);
        }
    }

    function drawBatteryIndicator(dc as Dc) as Void {
        var stats = System.getSystemStats();
        var batteryPercent = stats.battery.toNumber();
        var tickCount = ((batteryPercent * BATTERY_MAX_TICKS) / 100.0).toNumber();
        if (tickCount < 1 && batteryPercent > 0) { tickCount = 1; }
        
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var outerRadius = dc.getWidth() / 2 + BATTERY_TICK_OVERFLOW;
        var innerRadius = outerRadius - BATTERY_TICK_LENGTH - BATTERY_TICK_OVERFLOW;
        
        dc.setColor(getBatteryColor(batteryPercent), Graphics.COLOR_TRANSPARENT);
        if (dc has :setAntiAlias) { dc.setAntiAlias(true); }
        
        for (var i = 0; i < tickCount; i++) {
            var angle = -90 + (i * 360.0 / BATTERY_MAX_TICKS);
            var angleRad = Math.toRadians(angle);
            var cosA = Math.cos(angleRad);
            var sinA = Math.sin(angleRad);
            
            var outerX = centerX + (outerRadius * cosA);
            var outerY = centerY + (outerRadius * sinA);
            var innerX = centerX + (innerRadius * cosA);
            var innerY = centerY + (innerRadius * sinA);
            
            var perpX = sinA * BATTERY_TICK_WIDTH / 2;
            var perpY = -cosA * BATTERY_TICK_WIDTH / 2;
            
            dc.fillPolygon([
                [outerX - perpX, outerY - perpY], [outerX + perpX, outerY + perpY],
                [innerX + perpX, innerY + perpY], [innerX - perpX, innerY - perpY]
            ]);
        }
        if (dc has :setAntiAlias) { dc.setAntiAlias(false); }
    }

    function onUpdate(dc as Dc) as Void {
        var bgChoice = getNumberProperty("BackgroundChoice", 1);
        if (bgChoice != currentBackground) { loadBackground(); }
        
        var fontChoice = getNumberProperty("FontChoice", 1);
        if (fontChoice != currentFont) { loadFonts(); }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        if (backgroundBitmap != null) {
            var x = (dc.getWidth() - backgroundBitmap.getWidth()) / 2;
            var y = (dc.getHeight() - backgroundBitmap.getHeight()) / 2;
            dc.drawBitmap(x, y, backgroundBitmap);
        }

        drawBatteryIndicator(dc);
        
        var centerX = dc.getWidth() / 2;
        var margin = 35; // Margines od krawędzi dla długich tekstów
        
        // Rysuj wszystkie pola
        // Górne, środkowe i dolne - wycentrowane
        drawField(dc, "Upper", centerX, dc.getHeight() / 7, font40, Graphics.TEXT_JUSTIFY_CENTER);
        drawField(dc, "Middle", centerX, dc.getHeight() * 4 / 10, fontRegular, Graphics.TEXT_JUSTIFY_CENTER);
        drawField(dc, "Lower", centerX, dc.getHeight() * 13 / 16, fontSmall, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Lewe i prawe - pozycja zależy od długości tekstu
        drawSideField(dc, "Left", dc.getHeight() * 6 / 10, true);
        drawSideField(dc, "Right", dc.getHeight() * 6 / 10, false);
    }
    
    function drawSideField(dc as Dc, fieldName as String, y as Number, isLeft as Boolean) as Void {
        var dataType = getNumberProperty(fieldName + "FieldData", DATA_NONE);
        if (dataType == DATA_NONE) { return; }
        
        var color = getColorFromProperty(fieldName + "FieldColor", fieldName + "FieldColorCustom", COLOR_DEFAULT);
        var text = getDataString(dataType);
        var textLen = text.length();
        
        var x;
        var justification;
        
        if (textLen <= 3) {
            // Krótki tekst - pozycja jak oryginalne HR/Temperature (bliżej krawędzi)
            if (isLeft) {
                x = dc.getWidth() / 5;
            } else {
                x = dc.getWidth() * 4 / 5;
            }
            justification = Graphics.TEXT_JUSTIFY_CENTER;
        } else {
            // Długi tekst - przy krawędzi z marginesem
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
        dc.drawText(x, y, fontSmall, text, justification | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawField(dc as Dc, fieldName as String, x as Number, y as Number, font, justification as Number) as Void {
        var dataType = getNumberProperty(fieldName + "FieldData", DATA_NONE);
        if (dataType == DATA_NONE) { return; }
        
        var color = getColorFromProperty(fieldName + "FieldColor", fieldName + "FieldColorCustom", COLOR_DEFAULT);
        var text = getDataString(dataType);
        
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, justification | Graphics.TEXT_JUSTIFY_VCENTER);
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
            case DATA_DISTANCE: return getDistanceString();
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
        var useMilitary = false;
        try {
            var val = Application.Properties.getValue("UseMilitaryFormat");
            if (val != null && val instanceof Boolean) { useMilitary = val as Boolean; }
        } catch (e) {}
        
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
        if (info != null && info.currentHeartRate != null) { return info.currentHeartRate; }
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
        var source = getNumberProperty("TemperatureSource", 1);
        
        if (source == 2) { temp = getSensorTemperature(); }
        else { temp = getWeatherTemperature(); }
        
        if (temp == null) { return "--°"; }
        
        var unit = getNumberProperty("TemperatureUnit", 1);
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
            var tempIter = SensorHistory.getTemperatureHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
            if (tempIter != null) {
                var sample = tempIter.next();
                if (sample != null && sample.data != null) { return sample.data; }
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
        if (info.calories != null) { return info.calories.toString(); }
        return "--";
    }

    function getDistanceString() as String {
        var info = ActivityMonitor.getInfo();
        if (info.distance != null) {
            var distCm = info.distance;
            var unit = getNumberProperty("DistanceUnit", 1);
            if (unit == 2) {
                var miles = distCm / 160934.0;
                return miles.format("%.1f");
            } else {
                var km = distCm / 100000.0;
                return km.format("%.1f");
            }
        }
        return "--";
    }

    function getFloorsString() as String {
        var info = ActivityMonitor.getInfo();
        if (info has :floorsClimbed && info.floorsClimbed != null) {
            return info.floorsClimbed.toString();
        }
        return "--";
    }

    function getAltitudeString() as String {
        var actInfo = Activity.getActivityInfo();
        if (actInfo != null && actInfo.altitude != null) {
            var alt = actInfo.altitude;
            var unit = getNumberProperty("AltitudeUnit", 1);
            if (unit == 2) {
                alt = alt * 3.28084;
            }
            return alt.toNumber().toString();
        }
        if (Toybox has :SensorHistory && SensorHistory has :getElevationHistory) {
            var elevIter = SensorHistory.getElevationHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
            if (elevIter != null) {
                var sample = elevIter.next();
                if (sample != null && sample.data != null) {
                    var alt = sample.data;
                    var unit = getNumberProperty("AltitudeUnit", 1);
                    if (unit == 2) {
                        alt = alt * 3.28084;
                    }
                    return alt.toNumber().toString();
                }
            }
        }
        return "--";
    }

    function getNotificationsString() as String {
        var settings = System.getDeviceSettings();
        if (settings has :notificationCount) {
            return settings.notificationCount.toString();
        }
        return "--";
    }

    function getSecondsString() as String {
        var clockTime = System.getClockTime();
        return clockTime.sec.format("%02d");
    }

    function onShow() as Void {}
    function onHide() as Void {}
    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}
}