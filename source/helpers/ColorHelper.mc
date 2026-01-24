import Toybox.Lang;
import Toybox.Application;
import Toybox.Math;

module ColorHelper {
    const COLOR_INVALID_HEX = 0xFF00FF;
    const COLOR_DEFAULT = 0xFFFFFF;
    const BATTERY_COLOR_FULL_DEFAULT = 0x008000;
    const BATTERY_COLOR_MID_DEFAULT = 0xFFFF12;
    const BATTERY_COLOR_LOW_DEFAULT = 0x6E0300;

    var PRESET_COLORS = [
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
        
        // Usuń # jeśli jest na początku
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

    // Standardowa interpolacja (szybka)
    function interpolateColor(color1 as Number, color2 as Number, ratio as Float) as Number {
        // Sprawdź czy używać gamma correction
        var smoothness = SettingsHelper.getNumberProperty("GradientSmoothness", 2);
        if (smoothness >= 4) {
            return interpolateColorGamma(color1, color2, ratio);
        }
        
        return interpolateColorLinear(color1, color2, ratio);
    }
    
    // Liniowa interpolacja (szybka, standardowa)
    function interpolateColorLinear(color1 as Number, color2 as Number, ratio as Float) as Number {
        var r1 = (color1 >> 16) & 0xFF;
        var g1 = (color1 >> 8) & 0xFF;
        var b1 = color1 & 0xFF;
        
        var r2 = (color2 >> 16) & 0xFF;
        var g2 = (color2 >> 8) & 0xFF;
        var b2 = color2 & 0xFF;
        
        var r = (r1 + ((r2 - r1) * ratio)).toNumber();
        var g = (g1 + ((g2 - g1) * ratio)).toNumber();
        var b = (b1 + ((b2 - b1) * ratio)).toNumber();
        
        // Clamp wartości
        if (r > 255) { r = 255; } else if (r < 0) { r = 0; }
        if (g > 255) { g = 255; } else if (g < 0) { g = 0; }
        if (b > 255) { b = 255; } else if (b < 0) { b = 0; }
        
        return (r << 16) | (g << 8) | b;
    }
    
    // Interpolacja z gamma correction (lepsza jakość, wolniejsza)
    function interpolateColorGamma(color1 as Number, color2 as Number, ratio as Float) as Number {
        var r1 = (color1 >> 16) & 0xFF;
        var g1 = (color1 >> 8) & 0xFF;
        var b1 = color1 & 0xFF;
        
        var r2 = (color2 >> 16) & 0xFF;
        var g2 = (color2 >> 8) & 0xFF;
        var b2 = color2 & 0xFF;
        
        // Gamma 2.2 dla sRGB
        var gamma = 2.2;
        var invGamma = 1.0 / gamma;
        
        // Konwertuj do przestrzeni liniowej
        var r1Lin = Math.pow(r1 / 255.0, gamma);
        var g1Lin = Math.pow(g1 / 255.0, gamma);
        var b1Lin = Math.pow(b1 / 255.0, gamma);
        
        var r2Lin = Math.pow(r2 / 255.0, gamma);
        var g2Lin = Math.pow(g2 / 255.0, gamma);
        var b2Lin = Math.pow(b2 / 255.0, gamma);
        
        // Interpoluj w przestrzeni liniowej
        var rLin = r1Lin + (r2Lin - r1Lin) * ratio;
        var gLin = g1Lin + (g2Lin - g1Lin) * ratio;
        var bLin = b1Lin + (b2Lin - b1Lin) * ratio;
        
        // Konwertuj z powrotem do sRGB
        var r = (Math.pow(rLin, invGamma) * 255).toNumber();
        var g = (Math.pow(gLin, invGamma) * 255).toNumber();
        var b = (Math.pow(bLin, invGamma) * 255).toNumber();
        
        // Clamp wartości
        if (r > 255) { r = 255; } else if (r < 0) { r = 0; }
        if (g > 255) { g = 255; } else if (g < 0) { g = 0; }
        if (b > 255) { b = 255; } else if (b < 0) { b = 0; }
        
        return (r << 16) | (g << 8) | b;
    }

    // Kolor baterii z interpolacją
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
        
        if (batteryPercent >= 50) {
            var ratio = (100 - batteryPercent) / 50.0;
            return interpolateColorLinear(colorFull, colorMid, ratio);
        } else {
            var ratio = (50 - batteryPercent) / 50.0;
            return interpolateColorLinear(colorMid, colorLow, ratio);
        }
    }
    
    // Rozjaśnij kolor
    function lightenColor(color as Number, amount as Float) as Number {
        return interpolateColorLinear(color, 0xFFFFFF, amount);
    }
    
    // Przyciemnij kolor
    function darkenColor(color as Number, amount as Float) as Number {
        return interpolateColorLinear(color, 0x000000, amount);
    }
    
    // Uzyskaj luminancję koloru (0.0 - 1.0)
    function getLuminance(color as Number) as Float {
        var r = ((color >> 16) & 0xFF) / 255.0;
        var g = ((color >> 8) & 0xFF) / 255.0;
        var b = (color & 0xFF) / 255.0;
        
        // Wzór luminancji percepcyjnej
        return (0.299 * r + 0.587 * g + 0.114 * b);
    }
    
    // Sprawdź czy kolor jest jasny
    function isLightColor(color as Number) as Boolean {
        return getLuminance(color) > 0.5;
    }
    
    // Uzyskaj kontrastowy kolor (biały lub czarny)
    function getContrastColor(color as Number) as Number {
        if (isLightColor(color)) {
            return 0x000000;  // Czarny dla jasnych teł
        } else {
            return 0xFFFFFF;  // Biały dla ciemnych teł
        }
    }
}