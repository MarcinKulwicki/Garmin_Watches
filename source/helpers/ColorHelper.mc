import Toybox.Lang;
import Toybox.Application;

module ColorHelper {
    const COLOR_INVALID_HEX = 0xFF00FF;
    const COLOR_DEFAULT = 0xFFFFFF;
    const BATTERY_COLOR_FULL_DEFAULT = 0x008000;
    const BATTERY_COLOR_MID_DEFAULT = 0xFFFF12;
    const BATTERY_COLOR_LOW_DEFAULT = 0x6E0300;

    var PRESET_COLORS = [
        // === BASICS (1-10) ===
        0xFFFFFF,  // 1.  White
        0x000000,  // 2.  Black
        0x808080,  // 3.  Gray
        0xA9A9A9,  // 4.  Dark Gray
        0xD3D3D3,  // 5.  Light Gray
        0xC0C0C0,  // 6.  Silver
        0x36454F,  // 7.  Charcoal
        0x2F4F4F,  // 8.  Dark Slate Gray
        0x708090,  // 9.  Slate Gray
        0xB0C4DE,  // 10. Light Steel Blue
        
        // === REDS (11-20) ===
        0xFF0000,  // 11. Red
        0x380000,  // 12. Dark Red
        0xDC143C,  // 13. Crimson
        0xB22222,  // 14. Firebrick
        0xCD5C5C,  // 15. Indian Red
        0xF08080,  // 16. Light Coral
        0xFA8072,  // 17. Salmon
        0xE9967A,  // 18. Dark Salmon
        0xFFA07A,  // 19. Light Salmon
        0xFF6347,  // 20. Tomato
        
        // === ORANGES (21-28) ===
        0xFF8C00,  // 21. Dark Orange
        0xFF7F50,  // 22. Coral
        0xFF6B6B,  // 23. Light Coral Red
        0xFF4500,  // 24. Orange Red
        0xFFA500,  // 25. Orange
        0xFFB347,  // 26. Pastel Orange
        0xE65C00,  // 27. Burnt Orange
        0xCC5500,  // 28. Burnt Sienna
        
        // === YELLOWS (29-38) ===
        0xFFFF00,  // 29. Yellow
        0xFFD700,  // 30. Gold
        0xFFC125,  // 31. Goldenrod
        0xDAA520,  // 32. Dark Goldenrod
        0xF0E68C,  // 33. Khaki
        0xBDB76B,  // 34. Dark Khaki
        0xFFE135,  // 35. Banana Yellow
        0xFFEF00,  // 36. Canary Yellow
        0xFAFAD2,  // 37. Light Goldenrod
        0xEEE8AA,  // 38. Pale Goldenrod
        
        // === GREENS (39-55) ===
        0x00FF00,  // 39. Lime
        0x008000,  // 40. Green
        0x006400,  // 41. Dark Green
        0x228B22,  // 42. Forest Green
        0x32CD32,  // 43. Lime Green
        0x90EE90,  // 44. Light Green
        0x98FB98,  // 45. Pale Green
        0x00FA9A,  // 46. Medium Spring Green
        0x00FF7F,  // 47. Spring Green
        0x7CFC00,  // 48. Lawn Green
        0xADFF2F,  // 49. Green Yellow
        0x9ACD32,  // 50. Yellow Green
        0x6B8E23,  // 51. Olive Drab
        0x556B2F,  // 52. Dark Olive Green
        0x808000,  // 53. Olive
        0x2E8B57,  // 54. Sea Green
        0x3CB371,  // 55. Medium Sea Green
        
        // === CYANS & TEALS (56-65) ===
        0x00FFFF,  // 56. Cyan / Aqua
        0x00CED1,  // 57. Dark Turquoise
        0x40E0D0,  // 58. Turquoise
        0x48D1CC,  // 59. Medium Turquoise
        0x20B2AA,  // 60. Light Sea Green
        0x008B8B,  // 61. Dark Cyan
        0x008080,  // 62. Teal
        0x5F9EA0,  // 63. Cadet Blue
        0x66CDAA,  // 64. Medium Aquamarine
        0x7FFFD4,  // 65. Aquamarine
        
        // === BLUES (66-80) ===
        0x0000FF,  // 66. Blue
        0x000080,  // 67. Navy
        0x00008B,  // 68. Dark Blue
        0x0000CD,  // 69. Medium Blue
        0x1E90FF,  // 70. Dodger Blue
        0x4169E1,  // 71. Royal Blue
        0x4682B4,  // 72. Steel Blue
        0x00A0E3,  // 73. Cornflower Blue
        0x00BFFF,  // 74. Deep Sky Blue
        0x87CEEB,  // 75. Sky Blue
        0x87CEFA,  // 76. Light Sky Blue
        0xADD8E6,  // 77. Light Blue
        0xB0E0E6,  // 78. Powder Blue
        0x191970,  // 79. Midnight Blue
        0x483D8B,  // 80. Dark Slate Blue
        
        // === PURPLES & VIOLETS (81-92) ===
        0x8B00FF,  // 81. Violet
        0x800080,  // 82. Purple
        0x9400D3,  // 83. Dark Violet
        0x9932CC,  // 84. Dark Orchid
        0xBA55D3,  // 85. Medium Orchid
        0xDA70D6,  // 86. Orchid
        0xEE82EE,  // 87. Light Violet
        0xDDA0DD,  // 88. Plum
        0x8A2BE2,  // 89. Blue Violet
        0x6A5ACD,  // 90. Slate Blue
        0x7B68EE,  // 91. Medium Slate Blue
        0x9370DB,  // 92. Medium Purple
        
        // === PINKS & MAGENTAS (93-100) ===
        0xFF00FF,  // 93. Magenta / Fuchsia
        0xFF1493,  // 94. Deep Pink
        0xFF69B4,  // 95. Hot Pink
        0xFFB6C1,  // 96. Light Pink
        0xFFC0CB,  // 97. Pink
        0xDB7093,  // 98. Pale Violet Red
        0xC71585,  // 99. Medium Violet Red
        0x8B008B,   // 100. Dark Magenta

        // === BROWNS & BEIGES (101-112) ===
        0x8B4513,  // 101. Brown
        0x8B4513,  // 102. Saddle Brown
        0xA0522D,  // 103. Sienna
        0xD2691E,  // 104. Chocolate
        0xCD853F,  // 105. Peru
        0xF4A460,  // 106. Sandy Brown
        0xBC8F8F,  // 107. Rosy Brown
        0xD2B48C,  // 108. Tan
        0xDEB887,  // 109. Burlywood
        0xF5DEB3,  // 110. Wheat
        0xF5F5DC,  // 111. Beige
        0xFAEBD7   // 112. Antique White
    ];

    function getColorFromProperty(propertyId as String, customPropertyId as String, defaultColor as Number) as Number {
        var colorChoice = SettingsHelper.getNumberProperty(propertyId, 1);
        
        if (colorChoice >= 1 && colorChoice <= 112) {
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