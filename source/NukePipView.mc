import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;
import Toybox.Activity;
import Toybox.SensorHistory;

class NukePipView extends WatchUi.WatchFace {
    private const NUKE_YELLOW = 0xCCCC00;
    private const NUKE_BLACK = 0x1A1A1A;
    private const NUKE_ORANGE = 0xFF6600;
    private const NUKE_GREEN = 0x00FF00;
    private const BLOOD_RED = 0x8B0000;

    private var screenWidth;
    private var screenHeight;
    private var centerX;
    private var centerY;
    private var radius;
    
    // Bitmapa sekundnika
    private var secondHandBitmap;
    private var secondHandWidth;
    private var secondHandHeight;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        screenWidth = dc.getWidth();
        screenHeight = dc.getHeight();
        centerX = screenWidth / 2;
        centerY = screenHeight / 2;
        radius = (screenWidth < screenHeight ? screenWidth : screenHeight) / 2;
        
        loadSecondHandBitmap();
    }
    
    function loadSecondHandBitmap() as Void {
        // Załaduj PNG bezpośrednio (packingFormat="png" w drawables.xml)
        secondHandBitmap = WatchUi.loadResource(Rez.Drawables.SecondHand);
        secondHandWidth = secondHandBitmap.getWidth();
        secondHandHeight = secondHandBitmap.getHeight();
    }

    function onShow() as Void {}

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawRadiationSymbol(dc);
        drawOuterRing(dc);
        drawBatteryIndicator(dc);
        drawSecondHand(dc);
        drawTime(dc);
        drawDate(dc);
        drawTemperature(dc);
        drawStats(dc);
    }

    function drawRadiationSymbol(dc as Dc) as Void {
        var symbolRadius = radius * 0.85;
        var innerRadius = radius * 0.22;

        dc.setColor(NUKE_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, symbolRadius.toNumber());

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 3; i++) {
            var startAngle = i * 120 + 30;
            drawBlackSegment(dc, startAngle, 60, 0, symbolRadius + 5);
        }

        dc.setColor(NUKE_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, innerRadius.toNumber());
    }

    function drawBlackSegment(dc as Dc, startAngle as Number, width as Number, innerR as Number, outerR as Float) as Void {
        var points = new [82];
        var idx = 0;
        
        for (var i = 0; i <= 40; i++) {
            var angle = Math.toRadians(startAngle + (width * i / 40.0) - 90);
            points[idx] = [
                centerX + (outerR * Math.cos(angle)).toNumber(),
                centerY + (outerR * Math.sin(angle)).toNumber()
            ];
            idx++;
        }
        
        for (var i = 40; i >= 0; i--) {
            var angle = Math.toRadians(startAngle + (width * i / 40.0) - 90);
            points[idx] = [
                centerX + (innerR * Math.cos(angle)).toNumber(),
                centerY + (innerR * Math.sin(angle)).toNumber()
            ];
            idx++;
        }
        
        dc.fillPolygon(points);
    }

    function drawOuterRing(dc as Dc) as Void {
        var outerR = radius - 5;

        dc.setColor(0x333333, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(12);
        dc.drawCircle(centerX, centerY, outerR - 6);

        dc.setColor(NUKE_YELLOW, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 60; i++) {
            var angle = Math.toRadians(i * 6 - 90);
            var len = (i % 5 == 0) ? 10 : 5;
            var x1 = centerX + ((outerR - 2) * Math.cos(angle)).toNumber();
            var y1 = centerY + ((outerR - 2) * Math.sin(angle)).toNumber();
            var x2 = centerX + ((outerR - 2 - len) * Math.cos(angle)).toNumber();
            var y2 = centerY + ((outerR - 2 - len) * Math.sin(angle)).toNumber();
            dc.setPenWidth((i % 5 == 0) ? 2 : 1);
            dc.drawLine(x1, y1, x2, y2);
        }
    }

    // Wskazówka sekundnika z PNG
    function drawSecondHand(dc as Dc) as Void {
        if (secondHandBitmap == null) {
            return;
        }
        
        var clockTime = System.getClockTime();
        var seconds = clockTime.sec;
        
        // Kąt rotacji: 6 stopni na sekundę
        var angleRad = Math.toRadians(seconds * 6);
        
        // Punkt obrotu - środek kółka na PNG (72% od góry)
        var pivotX = secondHandWidth / 2;
        var pivotY = (secondHandHeight * 0.72).toNumber();
        
        // Skalowanie - dopasuj do 92% promienia ekranu
        var desiredLength = radius * 0.92;
        var scale = desiredLength.toFloat() / secondHandHeight.toFloat();
        
        // Transformacja
        var transform = new Graphics.AffineTransform();
        transform.translate(centerX, centerY);
        transform.rotate(angleRad);
        transform.scale(scale, scale);
        transform.translate(-pivotX, -pivotY);
        
        // Rysuj
        dc.drawBitmap2(0, 0, secondHandBitmap, {
            :transform => transform,
            :filterMode => Graphics.FILTER_MODE_BILINEAR
        });
    }

    function drawTime(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var minutes = clockTime.min;

        if (!System.getDeviceSettings().is24Hour && hours > 12) {
            hours = hours - 12;
        }
        if (!System.getDeviceSettings().is24Hour && hours == 0) {
            hours = 12;
        }

        var hoursStr = hours.format("%02d");
        var minsStr = minutes.format("%02d");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX - radius * 0.51, centerY - radius * 0.3, 
                    Graphics.FONT_NUMBER_HOT, hoursStr, 
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.drawText(centerX + radius * 0.51, centerY - radius * 0.3, 
                    Graphics.FONT_NUMBER_HOT, minsStr, 
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawTemperature(dc as Dc) as Void {
        var temp = getTemperature();
        var tempNum = "--";
        
        if (temp != null) {
            tempNum = temp.format("%d");
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY - radius * 0.55, 
                    Graphics.FONT_SMALL, tempNum, 
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        
        var tempWidth = dc.getTextWidthInPixels(tempNum, Graphics.FONT_SMALL);
        dc.drawText(centerX + tempWidth / 2 + 2, centerY - radius * 0.57, 
                    Graphics.FONT_XTINY, "o", 
                    Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function getTemperature() as Number? {
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

    function drawDate(dc as Dc) as Void {
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateStr = Lang.format("$1$ $2$", [today.day_of_week.toUpper().substring(0, 3), today.day]);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY + radius * 0.58, 
                    Graphics.FONT_XTINY, dateStr, 
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawStats(dc as Dc) as Void {
        var activityInfo = ActivityMonitor.getInfo();

        if (activityInfo.steps != null) {
            var steps = activityInfo.steps;
            
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(centerX + radius * 0.55, centerY + radius * 0.28, 4);
            
            dc.drawText(centerX + radius * 0.42, centerY + radius * 0.28, 
                        Graphics.FONT_TINY, steps.toString(), 
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        var heartRate = getHeartRate();
        if (heartRate != null && heartRate > 0) {
            var hrStr = heartRate.toString();
            
            dc.setColor(BLOOD_RED, Graphics.COLOR_TRANSPARENT);
            drawHeart(dc, centerX - radius * 0.55, centerY + radius * 0.28);
            
            dc.drawText(centerX - radius * 0.42, centerY + radius * 0.28, 
                        Graphics.FONT_TINY, hrStr, 
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    function getHeartRate() as Number? {
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

    function drawHeart(dc as Dc, x as Number, y as Number) as Void {
        dc.fillCircle(x - 4, y - 3, 5);
        dc.fillCircle(x + 4, y - 3, 5);
        var points = [[x - 9, y - 1], [x, y + 9], [x + 9, y - 1]];
        dc.fillPolygon(points);
    }

    function drawBatteryIndicator(dc as Dc) as Void {
        var stats = System.getSystemStats();
        var battery = stats.battery.toNumber();
        var batteryColor = NUKE_GREEN;
        
        if (battery < 20) {
            batteryColor = Graphics.COLOR_RED;
        } else if (battery < 50) {
            batteryColor = NUKE_ORANGE;
        }

        var bw = 28;
        var bh = 14;
        var bx = centerX - bw / 2;
        var by = centerY - bh / 2 - 5;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(bx, by, bw, bh);
        dc.fillRectangle(bx + bw, by + 4, 3, 6);

        var fillWidth = ((bw - 4) * battery / 100).toNumber();
        dc.setColor(batteryColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(bx + 2, by + 2, fillWidth, bh - 4);

        var remainingTime = getBatteryTimeRemaining(battery);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, by + bh + 6, Graphics.FONT_XTINY, 
                    remainingTime, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function getBatteryTimeRemaining(battery as Number) as String {
        var stats = System.getSystemStats();
        
        if (stats has :batteryInDays && stats.batteryInDays != null) {
            var days = stats.batteryInDays;
            if (days >= 1) {
                return days.format("%d") + "d";
            } else {
                var hours = (days * 24).toNumber();
                return hours.toString() + "h";
            }
        }
        
        return battery.toString() + "%";
    }

    function onHide() as Void {}
    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}
}