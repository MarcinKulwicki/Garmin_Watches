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

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        screenWidth = dc.getWidth();
        screenHeight = dc.getHeight();
        centerX = screenWidth / 2;
        centerY = screenHeight / 2;
        radius = (screenWidth < screenHeight ? screenWidth : screenHeight) / 2;
    }

    function onShow() as Void {}

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawRadiationSymbol(dc);
        drawOuterRing(dc);
        drawSecondHand(dc);
        drawTime(dc);
        drawDate(dc);
        drawTemperature(dc);
        drawStats(dc);
        drawBatteryIndicator(dc);
    }

    function drawRadiationSymbol(dc as Dc) as Void {
        var symbolRadius = radius * 0.85;
        var innerRadius = radius * 0.22;

        // 1. Narysuj pełne żółte koło
        dc.setColor(NUKE_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, symbolRadius.toNumber());

        // 2. Wytnij 3 czarne segmenty - wierzchołki w środku ekranu
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 3; i++) {
            var startAngle = i * 120 + 30;
            drawBlackSegment(dc, startAngle, 60, 0, symbolRadius + 5);
        }

        // 3. Czarny środek
        dc.setColor(NUKE_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, innerRadius.toNumber());
    }

    function drawBlackSegment(dc as Dc, startAngle as Number, width as Number, innerR as Number, outerR as Float) as Void {
        // Więcej punktów = gładsze krawędzie
        var points = new [82];
        var idx = 0;
        
        // Zewnętrzny łuk (40 punktów)
        for (var i = 0; i <= 40; i++) {
            var angle = Math.toRadians(startAngle + (width * i / 40.0) - 90);
            points[idx] = [
                centerX + (outerR * Math.cos(angle)).toNumber(),
                centerY + (outerR * Math.sin(angle)).toNumber()
            ];
            idx++;
        }
        
        // Wewnętrzny łuk (40 punktów, odwrotnie) - gdy innerR=0, wszystkie punkty w centrum
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

    // Wskazówka sekundnika - nuklearny styl
    function drawSecondHand(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var seconds = clockTime.sec;
        
        var angle = Math.toRadians(seconds * 6 - 90);
        var handLength = radius * 0.78;
        var tailLength = radius * 0.18;
        
        var cosA = Math.cos(angle);
        var sinA = Math.sin(angle);
        
        var endX = centerX + (handLength * cosA).toNumber();
        var endY = centerY + (handLength * sinA).toNumber();
        var tailX = centerX - (tailLength * cosA).toNumber();
        var tailY = centerY - (tailLength * sinA).toNumber();
        
        // Kąt prostopadły do wskazówki (dla grotu strzałki)
        var perpCos = Math.cos(angle + Math.PI / 2);
        var perpSin = Math.sin(angle + Math.PI / 2);
        
        // Efekt "glow" - szerszy, półprzezroczysty cień
        dc.setColor(0x552200, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(5);
        dc.drawLine(tailX, tailY, endX, endY);
        
        // Główna linia - pomarańczowa
        dc.setColor(NUKE_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(tailX, tailY, endX, endY);
        
        // Grot strzałki na końcu
        var arrowSize = 8;
        var arrowBack = 12; // jak daleko od końca zaczyna się grot
        var arrowBaseX = endX - (arrowBack * cosA).toNumber();
        var arrowBaseY = endY - (arrowBack * sinA).toNumber();
        
        var arrowLeft = [
            (arrowBaseX - arrowSize * perpCos).toNumber(),
            (arrowBaseY - arrowSize * perpSin).toNumber()
        ];
        var arrowRight = [
            (arrowBaseX + arrowSize * perpCos).toNumber(),
            (arrowBaseY + arrowSize * perpSin).toNumber()
        ];
        var arrowTip = [endX, endY];
        
        dc.fillPolygon([arrowLeft, arrowTip, arrowRight]);
        
        // Mały okrągły "ogon" na końcu
        dc.fillCircle(tailX, tailY, 4);
        
        // Środkowa kropka - pomarańczowa z czarnym środkiem
        dc.setColor(NUKE_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, 6);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, 3);
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

        // Godziny - 5% wyżej i 5% w lewo
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX - radius * 0.51, centerY - radius * 0.3, 
                    Graphics.FONT_NUMBER_HOT, hoursStr, 
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Minuty - 5% wyżej i 5% w prawo
        dc.drawText(centerX + radius * 0.51, centerY - radius * 0.3, 
                    Graphics.FONT_NUMBER_HOT, minsStr, 
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Temperatura na górnym czarnym polu
    function drawTemperature(dc as Dc) as Void {
        var temp = getTemperature();
        var tempNum = "--";
        
        if (temp != null) {
            tempNum = temp.format("%d");
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        // Liczba wyśrodkowana
        dc.drawText(centerX, centerY - radius * 0.55, 
                    Graphics.FONT_SMALL, tempNum, 
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        
        // Stopień obok (mała czcionka)
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

    // Data - przesunięta niżej, mniejsza czcionka
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

        // Kroki - bardziej w prawo, czarna czcionka
        if (activityInfo.steps != null) {
            var steps = activityInfo.steps;
            
            // Kropka po prawej - czarna
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(centerX + radius * 0.55, centerY + radius * 0.28, 4);
            
            // Liczba kroków - czarna
            dc.drawText(centerX + radius * 0.42, centerY + radius * 0.28, 
                        Graphics.FONT_TINY, steps.toString(), 
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Puls - ciemny krwisty czerwony
        var heartRate = getHeartRate();
        if (heartRate != null && heartRate > 0) {
            var hrStr = heartRate.toString();
            
            // Serduszko - krwiste
            dc.setColor(BLOOD_RED, Graphics.COLOR_TRANSPARENT);
            drawHeart(dc, centerX - radius * 0.55, centerY + radius * 0.28);
            
            // Liczba pulsu - krwista
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
        // Używa koloru ustawionego przed wywołaniem
        dc.fillCircle(x - 4, y - 3, 5);
        dc.fillCircle(x + 4, y - 3, 5);
        var points = [[x - 9, y - 1], [x, y + 9], [x + 9, y - 1]];
        dc.fillPolygon(points);
    }

    // Bateria - wyśrodkowana z pozostałym czasem
    function drawBatteryIndicator(dc as Dc) as Void {
        var stats = System.getSystemStats();
        var battery = stats.battery.toNumber();
        var batteryColor = NUKE_GREEN;
        
        if (battery < 20) {
            batteryColor = Graphics.COLOR_RED;
        } else if (battery < 50) {
            batteryColor = NUKE_ORANGE;
        }

        // Ramka baterii - wyśrodkowana
        var bw = 28;
        var bh = 14;
        var bx = centerX - bw / 2;
        var by = centerY - bh / 2 - 5;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(bx, by, bw, bh);
        dc.fillRectangle(bx + bw, by + 4, 3, 6);

        // Wypełnienie
        var fillWidth = ((bw - 4) * battery / 100).toNumber();
        dc.setColor(batteryColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(bx + 2, by + 2, fillWidth, bh - 4);

        // Pozostały czas baterii
        var remainingTime = getBatteryTimeRemaining(battery);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, by + bh + 6, Graphics.FONT_XTINY, 
                    remainingTime, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function getBatteryTimeRemaining(battery as Number) as String {
        var stats = System.getSystemStats();
        
        // Użyj wbudowanego szacowania Garmina jeśli dostępne
        if (stats has :batteryInDays && stats.batteryInDays != null) {
            var days = stats.batteryInDays;
            if (days >= 1) {
                return days.format("%d") + "d";
            } else {
                var hours = (days * 24).toNumber();
                return hours.toString() + "h";
            }
        }
        
        // Fallback - samo % jeśli brak szacowania
        return battery.toString() + "%";
    }

    function onHide() as Void {}
    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}
}