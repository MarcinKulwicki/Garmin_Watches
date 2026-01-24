import Toybox.Lang;
import Toybox.Application;

module ColorHelper {
    const COLOR_INVALID_HEX = 0xFF00FF;
    const COLOR_DEFAULT = 0xFFFFFF;
    const BATTERY_COLOR_FULL_DEFAULT = 0x008000;
    const BATTERY_COLOR_MID_DEFAULT = 0xFFFF12;
    const BATTERY_COLOR_LOW_DEFAULT = 0x6E0300;

    var PRESET_COLORS = [
        0xFFFFFF,
        0x000000,
        0xFF0000,
        0x8B0000,
        0x00FF00,
        0x006400,
        0x0000FF,
        0xFFFF00,
        0xFF8C00,
        0x8B00FF,
        0xFF69B4,
        0x00FFFF,
        0x20B2AA,
        0xFFD700,
        0xC0C0C0,
        0x32CD32,
        0xFF6B6B,
        0x000080,
        0xF5DEB3,
        0x808080
    ];

    function getColorFromProperty(propertyId as String, customPropertyId as String, defaultColor as Number) as Number {
        var colorChoice = SettingsHelper.getNumberProperty(propertyId, 1);
        
        if (colorChoice == 21) {
            var hexVal = SettingsHelper.getStringProperty(customPropertyId, "");
            return parseHexColor(hexVal, defaultColor);
        } else if (colorChoice >= 1 && colorChoice <= 20) {
            return PRESET_COLORS[colorChoice - 1];
        }
        return defaultColor;
    }

    function parseHexColor(hexString as String, defaultColor as Number) as Number {
        if (hexString == null || hexString.length() == 0) { 
            return defaultColor; 
        }
        
        var hex = hexString.toUpper();
        
        if (hex.substring(0, 1).equals("#")) { 
            hex = hex.substring(1, hex.length()); 
        }
        
        if (hex.length() != 6) { 
            return COLOR_INVALID_HEX; 
        }
        
        var r = parseHexByte(hex.substring(0, 2));
        var g = parseHexByte(hex.substring(2, 4));
        var b = parseHexByte(hex.substring(4, 6));
        
        if (r < 0 || g < 0 || b < 0) { 
            return COLOR_INVALID_HEX; 
        }
        
        return (r << 16) | (g << 8) | b;
    }

    function parseHexByte(hexByte as String) as Number {
        if (hexByte.length() != 2) { 
            return -1; 
        }
        
        var result = 0;
        for (var i = 0; i < 2; i++) {
            var c = hexByte.substring(i, i + 1);
            var val = charToHex(c);
            if (val < 0) { 
                return -1; 
            }
            result = result * 16 + val;
        }
        return result;
    }

    function charToHex(c as String) as Number {
        if (c.equals("0")) { return 0; }
        if (c.equals("1")) { return 1; }
        if (c.equals("2")) { return 2; }
        if (c.equals("3")) { return 3; }
        if (c.equals("4")) { return 4; }
        if (c.equals("5")) { return 5; }
        if (c.equals("6")) { return 6; }
        if (c.equals("7")) { return 7; }
        if (c.equals("8")) { return 8; }
        if (c.equals("9")) { return 9; }
        if (c.equals("A")) { return 10; }
        if (c.equals("B")) { return 11; }
        if (c.equals("C")) { return 12; }
        if (c.equals("D")) { return 13; }
        if (c.equals("E")) { return 14; }
        if (c.equals("F")) { return 15; }
        return -1;
    }

    function interpolateColor(color1 as Number, color2 as Number, ratio as Float) as Number {
        var r1 = (color1 >> 16) & 0xFF;
        var g1 = (color1 >> 8) & 0xFF;
        var b1 = color1 & 0xFF;
        
        var r2 = (color2 >> 16) & 0xFF;
        var g2 = (color2 >> 8) & 0xFF;
        var b2 = color2 & 0xFF;
        
        var r = (r1 + ((r2 - r1) * ratio)).toNumber();
        var g = (g1 + ((g2 - g1) * ratio)).toNumber();
        var b = (b1 + ((b2 - b1) * ratio)).toNumber();
        
        if (r > 255) { r = 255; } else if (r < 0) { r = 0; }
        if (g > 255) { g = 255; } else if (g < 0) { g = 0; }
        if (b > 255) { b = 255; } else if (b < 0) { b = 0; }
        
        return (r << 16) | (g << 8) | b;
    }

    function getBatteryColor(batteryPercent as Number) as Number {
        var colorFull = getColorFromProperty(
            "BatteryColorFull", 
            "BatteryColorFullCustom", 
            BATTERY_COLOR_FULL_DEFAULT
        );
        var colorMid = getColorFromProperty(
            "BatteryColorMid", 
            "BatteryColorMidCustom", 
            BATTERY_COLOR_MID_DEFAULT
        );
        var colorLow = getColorFromProperty(
            "BatteryColorLow", 
            "BatteryColorLowCustom", 
            BATTERY_COLOR_LOW_DEFAULT
        );
        
        if (batteryPercent >= 30) {
            var ratio = (100 - batteryPercent) / 70.0;
            return interpolateColor(colorFull, colorMid, ratio);
        } else {
            var ratio = (30 - batteryPercent) / 30.0;
            return interpolateColor(colorMid, colorLow, ratio);
        }
    }
}