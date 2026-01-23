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

    // ===========================================
    // USTAWIENIA WSKAŹNIKA BATERII
    // ===========================================
    private const BATTERY_TICK_LENGTH = 12;      // Długość widocznej części kreski w px
    private const BATTERY_TICK_WIDTH = 5;        // Grubość kreski w pikselach
    private const BATTERY_TICK_OVERFLOW = 20;    // Ile px kreska wychodzi ZA krawędź
    private const BATTERY_MAX_TICKS = 60;        // Maksymalna ilość kresek (jak minuty)
    
    // Domyślne kolory baterii (gradient)
    private const BATTERY_COLOR_FULL_DEFAULT = 0x008000;    // Zielony - pełna bateria
    private const BATTERY_COLOR_MID_DEFAULT = 0xFFFF12;     // Żółty - średnia
    private const BATTERY_COLOR_LOW_DEFAULT = 0x6E0300;     // Ciemny czerwony - niska

    // ===========================================
    // DOMYŚLNE KOLORY (format 0xRRGGBB):
    // ===========================================
    private const COLOR_TIME = 0xFFFFFF;
    private const COLOR_DATE = 0xFFFFFF;
    private const COLOR_HEART_RATE = 0xFF0000;
    private const COLOR_TEMPERATURE = 0xFFFF00;
    private const COLOR_STEPS = 0x00AAFF;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        loadBackground();
        loadFonts();
    }

    function loadFonts() as Void {
        var choice = 1;
        try {
            var val = Application.Properties.getValue("FontChoice");
            if (val != null && val instanceof Number) {
                choice = val as Number;
            }
        } catch (e) {
            choice = 1;
        }
        
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
        var choice = 1;
        try {
            var val = Application.Properties.getValue("BackgroundChoice");
            if (val != null && val instanceof Number) {
                choice = val as Number;
            }
        } catch (e) {
            choice = 1;
        }
        
        currentBackground = choice;
        
        switch (choice) {
            case 2:
                backgroundBitmap = Application.loadResource(Rez.Drawables.Background2);
                break;
            case 3:
                backgroundBitmap = Application.loadResource(Rez.Drawables.Background3);
                break;
            case 4:
                backgroundBitmap = Application.loadResource(Rez.Drawables.Background4);
                break;
            case 5:
                backgroundBitmap = Application.loadResource(Rez.Drawables.Background5);
                break;
            case 6:
                backgroundBitmap = Application.loadResource(Rez.Drawables.Background6);
                break;
            case 7:
                backgroundBitmap = Application.loadResource(Rez.Drawables.Background7);
                break;
            case 8:
                backgroundBitmap = Application.loadResource(Rez.Drawables.Background8);
                break;
            case 9:
                backgroundBitmap = Application.loadResource(Rez.Drawables.Background9);
                break;
            case 10:
                backgroundBitmap = Application.loadResource(Rez.Drawables.Background10);
                break;
            case 11:
                backgroundBitmap = Application.loadResource(Rez.Drawables.Background11);
                break;
            case 12:
                backgroundBitmap = Application.loadResource(Rez.Drawables.Background12);
                break;
            case 13:
                backgroundBitmap = Application.loadResource(Rez.Drawables.Background13);
                break;
            default:
                backgroundBitmap = Application.loadResource(Rez.Drawables.Background1);
        }
    }

    function getColor(propertyId as String, defaultColor as Number) as Number {
        try {
            var color = Application.Properties.getValue(propertyId);
            if (color != null && color instanceof Number) {
                return color as Number;
            }
        } catch (e) {}
        return defaultColor;
    }

    // Interpolacja między dwoma kolorami
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
        
        return (r << 16) | (g << 8) | b;
    }

    // Pobierz kolor dla danego poziomu baterii (0-100)
    function getBatteryColor(batteryPercent as Number) as Number {
        // Sprawdź czy używamy custom kolorów
        var useCustom = false;
        try {
            var val = Application.Properties.getValue("BatteryColorMode");
            if (val != null && val instanceof Number && val == 2) {
                useCustom = true;
            }
        } catch (e) {}
        
        var colorFull = BATTERY_COLOR_FULL_DEFAULT;
        var colorMid = BATTERY_COLOR_MID_DEFAULT;
        var colorLow = BATTERY_COLOR_LOW_DEFAULT;
        
        if (useCustom) {
            colorFull = getColor("BatteryColorFull", BATTERY_COLOR_FULL_DEFAULT);
            colorMid = getColor("BatteryColorMid", BATTERY_COLOR_MID_DEFAULT);
            colorLow = getColor("BatteryColorLow", BATTERY_COLOR_LOW_DEFAULT);
        }
        
        if (batteryPercent >= 50) {
            // Od 50% do 100%: pełna -> średnia
            var ratio = (100 - batteryPercent) / 50.0;
            return interpolateColor(colorFull, colorMid, ratio);
        } else {
            // Od 0% do 50%: średnia -> niska
            var ratio = (50 - batteryPercent) / 50.0;
            return interpolateColor(colorMid, colorLow, ratio);
        }
    }

    function drawBatteryIndicator(dc as Dc) as Void {
        var stats = System.getSystemStats();
        var batteryPercent = stats.battery.toNumber();
        
        // Oblicz ile kresek narysować
        var tickCount = ((batteryPercent * BATTERY_MAX_TICKS) / 100.0).toNumber();
        if (tickCount < 1 && batteryPercent > 0) {
            tickCount = 1;
        }
        
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        
        // Radius WIĘKSZY niż ekran - kreski zaczynają się ZA krawędzią
        var outerRadius = dc.getWidth() / 2 + BATTERY_TICK_OVERFLOW;
        var innerRadius = outerRadius - BATTERY_TICK_LENGTH - BATTERY_TICK_OVERFLOW;
        
        // Kolor zależny od poziomu baterii
        var tickColor = getBatteryColor(batteryPercent);
        dc.setColor(tickColor, Graphics.COLOR_TRANSPARENT);
        
        // Włącz antyaliasing jeśli dostępny
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        
        // Rysuj kreski - zaczynamy od góry (12:00) i idziemy zgodnie z ruchem wskazówek
        for (var i = 0; i < tickCount; i++) {
            var angle = -90 + (i * 360.0 / BATTERY_MAX_TICKS);
            var angleRad = Math.toRadians(angle);
            
            var cosA = Math.cos(angleRad);
            var sinA = Math.sin(angleRad);
            
            // Punkt zewnętrzny (ZA krawędzią ekranu)
            var outerX = centerX + (outerRadius * cosA);
            var outerY = centerY + (outerRadius * sinA);
            
            // Punkt wewnętrzny (w kierunku środka)
            var innerX = centerX + (innerRadius * cosA);
            var innerY = centerY + (innerRadius * sinA);
            
            // Rysuj grubą kreskę jako wypełniony polygon dla lepszej jakości
            var perpX = sinA * BATTERY_TICK_WIDTH / 2;
            var perpY = -cosA * BATTERY_TICK_WIDTH / 2;
            
            var points = [
                [outerX - perpX, outerY - perpY],
                [outerX + perpX, outerY + perpY],
                [innerX + perpX, innerY + perpY],
                [innerX - perpX, innerY - perpY]
            ];
            
            dc.fillPolygon(points);
        }
        
        // Wyłącz antyaliasing
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(false);
        }
    }

    function onUpdate(dc as Dc) as Void {
        var bgChoice = 1;
        try {
            var val = Application.Properties.getValue("BackgroundChoice");
            if (val != null && val instanceof Number) {
                bgChoice = val as Number;
            }
        } catch (e) {}
        
        if (bgChoice != currentBackground) {
            loadBackground();
        }

        var fontChoice = 1;
        try {
            var val = Application.Properties.getValue("FontChoice");
            if (val != null && val instanceof Number) {
                fontChoice = val as Number;
            }
        } catch (e) {}
        
        if (fontChoice != currentFont) {
            loadFonts();
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        if (backgroundBitmap != null) {
            var imgW = backgroundBitmap.getWidth();
            var imgH = backgroundBitmap.getHeight();
            var x = (dc.getWidth() - imgW) / 2;
            var y = (dc.getHeight() - imgH) / 2;
            dc.drawBitmap(x, y, backgroundBitmap);
        }

        // Rysuj wskaźnik baterii
        drawBatteryIndicator(dc);

        drawDate(dc);
        drawTime(dc);
        drawHeartRate(dc);
        drawTemperature(dc);
        drawSteps(dc);
    }

    function drawDate(dc as Dc) as Void {
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var months = [" Jan", " Feb", " Mar", " Apr", " May", " Jun", 
                      " Jul", " Aug", " Sep", " Oct", " Nov", " Dec"];
        var monthStr = months[today.month - 1];
        var dateStr = today.day.format("%02d") + monthStr;

        var dateColor = getColor("DateColor", COLOR_DATE);
        
        dc.setColor(dateColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 7,
            font40,
            dateStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawTime(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var minutes = clockTime.min;

        try {
            var useMilitary = Application.Properties.getValue("UseMilitaryFormat");
            if (useMilitary == null || !useMilitary) {
                if (hours > 12) {
                    hours = hours - 12;
                } else if (hours == 0) {
                    hours = 12;
                }
            }
        } catch (e) {
            if (hours > 12) {
                hours = hours - 12;
            } else if (hours == 0) {
                hours = 12;
            }
        }

        var hoursStr = hours.format("%02d");
        var minsStr = minutes.format("%02d");

        var centerX = dc.getWidth() / 2;
        var topY = dc.getHeight() * 4 / 10;

        var timeColor = getColor("TimeColor", COLOR_TIME);

        dc.setColor(timeColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX, 
            topY,
            fontRegular, 
            hoursStr + ":" + minsStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawHeartRate(dc as Dc) as Void {
        var hr = getHeartRate();
        var hrStr = (hr != null) ? hr.toString() : "--";

        var hrColor = getColor("HeartRateColor", COLOR_HEART_RATE);

        dc.setColor(hrColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 6,
            dc.getHeight() * 6 / 10,
            fontSmall,
            hrStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
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

    function drawTemperature(dc as Dc) as Void {
        var temp = null;
        
        var source = 1;
        try {
            var val = Application.Properties.getValue("TemperatureSource");
            if (val != null && val instanceof Number) {
                source = val as Number;
            }
        } catch (e) {}
        
        if (source == 2) {
            temp = getSensorTemperature();
        } else {
            temp = getWeatherTemperature();
        }
        
        var tempStr = "--°";
        
        if (temp != null) {
            var unit = 1;
            try {
                var val = Application.Properties.getValue("TemperatureUnit");
                if (val != null && val instanceof Number) {
                    unit = val as Number;
                }
            } catch (e) {}
            
            if (unit == 2) {
                temp = (temp * 9 / 5) + 32;
            }
            tempStr = temp.toNumber().toString() + "°";
        }

        var tempColor = getColor("TemperatureColor", COLOR_TEMPERATURE);

        dc.setColor(tempColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() * 5 / 6,
            dc.getHeight() * 6 / 10,
            fontSmall,
            tempStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
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
                if (sample != null && sample.data != null) {
                    return sample.data;
                }
            }
        }
        return null;
    }

    function drawSteps(dc as Dc) as Void {
        var activityInfo = ActivityMonitor.getInfo();
        var steps = activityInfo.steps;

        if (steps != null) {
            var stepsStr = steps.toString();

            var stepsColor = getColor("StepsColor", COLOR_STEPS);

            dc.setColor(stepsColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() * 13 / 16,
                fontSmall,
                stepsStr,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }

    function onShow() as Void {}
    function onHide() as Void {}
    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}
}