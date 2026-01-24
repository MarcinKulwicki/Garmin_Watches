import Toybox.Graphics;
import Toybox.System;
import Toybox.Math;
import Toybox.Lang;

module SecondsIndicator {
    const TICK_LENGTH = 12;
    const TICK_WIDTH = 4;
    const TICK_OVERFLOW = 10;
    const MAX_TICKS = 60;

    function draw(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var tickCount = clockTime.sec + 1;
        
        var stats = System.getSystemStats();
        var tickColor = ColorHelper.getBatteryColor(stats.battery.toNumber());
        
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var outerRadius = dc.getWidth() / 2 + TICK_OVERFLOW;
        var innerRadius = outerRadius - TICK_LENGTH - TICK_OVERFLOW;
        
        dc.setColor(tickColor, Graphics.COLOR_TRANSPARENT);
        if (dc has :setAntiAlias) { dc.setAntiAlias(true); }
        
        for (var i = 0; i < tickCount; i++) {
            drawTick(dc, centerX, centerY, outerRadius, innerRadius, i);
        }
        
        if (dc has :setAntiAlias) { dc.setAntiAlias(false); }
    }

    function drawTick(dc as Dc, cx as Number, cy as Number, 
                      outerR as Number, innerR as Number, index as Number) as Void {
        var angle = -90 + (index * 360.0 / MAX_TICKS);
        var angleRad = Math.toRadians(angle);
        var cosA = Math.cos(angleRad);
        var sinA = Math.sin(angleRad);
        
        var outerX = cx + (outerR * cosA);
        var outerY = cy + (outerR * sinA);
        var innerX = cx + (innerR * cosA);
        var innerY = cy + (innerR * sinA);
        
        var perpX = sinA * TICK_WIDTH / 2;
        var perpY = -cosA * TICK_WIDTH / 2;
        
        dc.fillPolygon([
            [outerX - perpX, outerY - perpY],
            [outerX + perpX, outerY + perpY],
            [innerX + perpX, innerY + perpY],
            [innerX - perpX, innerY - perpY]
        ]);
    }
}