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

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        backgroundBitmap = Application.loadResource(Rez.Drawables.BackgroundImage);
        fontRegular = Application.loadResource(Rez.Fonts.FontRegular);
        fontSmall = Application.loadResource(Rez.Fonts.FontSmall);
        font40 = Application.loadResource(Rez.Fonts.Font40);
    }

    // Pomocnicza funkcja do pobierania koloru z ustawień
    function getColor(propertyId as String, defaultColor as Number) as Number {
        try {
            var color = Application.Properties.getValue(propertyId);
            if (color != null && color instanceof Number) {
                return color as Number;
            }
        } catch (e) {
            // Fallback do domyślnego koloru
        }
        return defaultColor;
    }

    function onUpdate(dc as Dc) as Void {
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

        var dateColor = getColor("DateColor", 0xFFFFFF);
        
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

        // Sprawdź format 12/24h
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
            // Domyślnie 12h format
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

        var timeColor = getColor("TimeColor", 0xFFFFFF);

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

        var hrColor = getColor("HeartRateColor", 0xFF0000);

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
        var tempStr = (temp != null) ? temp.toString() + "°" : "--°";

        var tempColor = getColor("TemperatureColor", 0xFFFF00);

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

            var stepsColor = getColor("StepsColor", 0x00AAFF);

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