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

class NukePipView extends WatchUi.WatchFace {
    private var backgroundBitmap;
    private var fontRegular;
    private var fontSmall;
    private var font40;
    private var currentBackground = 1;

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
        fontRegular = Application.loadResource(Rez.Fonts.FontRegular);
        fontSmall = Application.loadResource(Rez.Fonts.FontSmall);
        font40 = Application.loadResource(Rez.Fonts.Font40);
        loadBackground();
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
        } catch (e) {
            // Fallback
        }
        return defaultColor;
    }

    function onUpdate(dc as Dc) as Void {
        // Sprawdź czy tło się zmieniło
        var choice = 1;
        try {
            var val = Application.Properties.getValue("BackgroundChoice");
            if (val != null && val instanceof Number) {
                choice = val as Number;
            }
        } catch (e) {}
        
        if (choice != currentBackground) {
            loadBackground();
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
        var temp = getTemperature();
        var tempStr = "--°";
        
        if (temp != null) {
            // Sprawdź jednostkę temperatury
            var unit = 1;
            try {
                var val = Application.Properties.getValue("TemperatureUnit");
                if (val != null && val instanceof Number) {
                    unit = val as Number;
                }
            } catch (e) {}
            
            if (unit == 2) {
                // Fahrenheit: (C * 9/5) + 32
                temp = (temp * 9 / 5) + 32;
            }
            tempStr = temp.toString() + "°";
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

    function getTemperature() {
        if (Toybox has :SensorHistory && SensorHistory has :getTemperatureHistory) {
            var tempIter = SensorHistory.getTemperatureHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
            if (tempIter != null) {
                var sample = tempIter.next();
                if (sample != null && sample.data != null) {
                    return sample.data.toNumber();
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