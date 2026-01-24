import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

module GradientRenderer {
    
    enum {
        GRADIENT_LINEAR_V = 1,
        GRADIENT_LINEAR_H = 2,
        GRADIENT_DIAGONAL = 3,
        GRADIENT_RADIAL_CENTER = 4,
        GRADIENT_RADIAL_CORNER = 5,
        GRADIENT_DIAMOND = 6,
        GRADIENT_SWEEP = 7
    }
    
    enum {
        DIR_TOP_BOTTOM = 1,
        DIR_BOTTOM_TOP = 2,
        DIR_LEFT_RIGHT = 3,
        DIR_RIGHT_LEFT = 4
    }
    
    // Pobierz liczbę kroków na podstawie ustawienia płynności
    function getGradientSteps() as Number {
        var smoothness = SettingsHelper.getNumberProperty("GradientSmoothness", 2);
        switch (smoothness) {
            case 1: return 8;   // Low - szybkie
            case 2: return 16;   // Medium
            case 3: return 128;  // High
            case 4: return 256;  // Ultra - bardzo płynne ale wolniejsze
            default: return 64;
        }
    }
    
    // Główna funkcja rysująca gradient
    function drawGradient(dc as Dc, color1 as Number, color2 as Number, 
                          gradientType as Number, direction as Number) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        switch (gradientType) {
            case GRADIENT_LINEAR_V:
                drawLinearVertical(dc, color1, color2, width, height, direction);
                break;
            case GRADIENT_LINEAR_H:
                drawLinearHorizontal(dc, color1, color2, width, height, direction);
                break;
            case GRADIENT_DIAGONAL:
                drawDiagonal(dc, color1, color2, width, height, direction);
                break;
            case GRADIENT_RADIAL_CENTER:
                drawRadialCenter(dc, color1, color2, width, height);
                break;
            case GRADIENT_RADIAL_CORNER:
                drawRadialCorner(dc, color1, color2, width, height);
                break;
            case GRADIENT_DIAMOND:
                drawDiamond(dc, color1, color2, width, height);
                break;
            case GRADIENT_SWEEP:
                drawSweep(dc, color1, color2, width, height);
                break;
            default:
                drawLinearVertical(dc, color1, color2, width, height, DIR_TOP_BOTTOM);
        }
    }
    
    // Gradient liniowy pionowy
    function drawLinearVertical(dc as Dc, color1 as Number, color2 as Number,
                                 width as Number, height as Number, direction as Number) as Void {
        var steps = getGradientSteps();
        var stepHeight = (height.toFloat() / steps) + 1;
        
        for (var i = 0; i < steps; i++) {
            var ratio = i.toFloat() / (steps - 1);
            
            if (direction == DIR_BOTTOM_TOP) {
                ratio = 1.0 - ratio;
            }
            
            var color = ColorHelper.interpolateColor(color1, color2, ratio);
            var y = ((i * height).toFloat() / steps).toNumber();
            
            dc.setColor(color, color);
            dc.fillRectangle(0, y, width, stepHeight.toNumber() + 1);
        }
    }
    
    // Gradient liniowy poziomy
    function drawLinearHorizontal(dc as Dc, color1 as Number, color2 as Number,
                                   width as Number, height as Number, direction as Number) as Void {
        var steps = getGradientSteps();
        var stepWidth = (width.toFloat() / steps) + 1;
        
        for (var i = 0; i < steps; i++) {
            var ratio = i.toFloat() / (steps - 1);
            
            if (direction == DIR_RIGHT_LEFT) {
                ratio = 1.0 - ratio;
            }
            
            var color = ColorHelper.interpolateColor(color1, color2, ratio);
            var x = ((i * width).toFloat() / steps).toNumber();
            
            dc.setColor(color, color);
            dc.fillRectangle(x, 0, stepWidth.toNumber() + 1, height);
        }
    }
    
    // Gradient diagonalny - ulepszona wersja
    function drawDiagonal(dc as Dc, color1 as Number, color2 as Number,
                          width as Number, height as Number, direction as Number) as Void {
        var steps = getGradientSteps();
        var maxDist = (width + height).toFloat();
        
        for (var i = 0; i < steps; i++) {
            var ratio = i.toFloat() / (steps - 1);
            
            if (direction == DIR_BOTTOM_TOP || direction == DIR_RIGHT_LEFT) {
                ratio = 1.0 - ratio;
            }
            
            var color = ColorHelper.interpolateColor(color1, color2, ratio);
            dc.setColor(color, color);
            
            // Oblicz pozycję przekątnej
            var offset = (i * maxDist / steps).toNumber();
            var thickness = (maxDist / steps).toNumber() + 3;
            
            // Punkty dla równoległoboku przekątnego
            var points = [
                [offset - height, 0],
                [offset + thickness - height, 0],
                [offset + thickness, height],
                [offset, height]
            ];
            
            dc.fillPolygon(points);
        }
    }
    
    // Gradient radialny od środka - ulepszona wersja z antyaliasingiem
    function drawRadialCenter(dc as Dc, color1 as Number, color2 as Number,
                               width as Number, height as Number) as Void {
        var centerX = width / 2;
        var centerY = height / 2;
        var maxRadius = Math.sqrt(centerX * centerX + centerY * centerY).toNumber() + 5;
        var steps = getGradientSteps();
        
        // Włącz antyaliasing jeśli dostępny
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        
        // Rysuj od zewnątrz do środka
        for (var i = steps - 1; i >= 0; i--) {
            var ratio = i.toFloat() / (steps - 1);
            var color = ColorHelper.interpolateColor(color1, color2, ratio);
            var radius = (((steps - i).toFloat() * maxRadius) / steps).toNumber();
            
            dc.setColor(color, color);
            dc.fillCircle(centerX, centerY, radius + 1);
        }
        
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(false);
        }
    }
    
    // Gradient radialny od rogu
    function drawRadialCorner(dc as Dc, color1 as Number, color2 as Number,
                               width as Number, height as Number) as Void {
        var maxRadius = Math.sqrt(width * width + height * height).toNumber() + 5;
        var steps = getGradientSteps();
        
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        
        for (var i = steps - 1; i >= 0; i--) {
            var ratio = i.toFloat() / (steps - 1);
            var color = ColorHelper.interpolateColor(color1, color2, ratio);
            var radius = (((steps - i).toFloat() * maxRadius) / steps).toNumber();
            
            dc.setColor(color, color);
            dc.fillCircle(0, 0, radius + 1);
        }
        
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(false);
        }
    }
    
    // Gradient diamentowy
    function drawDiamond(dc as Dc, color1 as Number, color2 as Number,
                          width as Number, height as Number) as Void {
        var centerX = width / 2;
        var centerY = height / 2;
        var maxDist = centerX + centerY;
        var steps = getGradientSteps();
        
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        
        for (var i = steps - 1; i >= 0; i--) {
            var ratio = i.toFloat() / (steps - 1);
            var color = ColorHelper.interpolateColor(color1, color2, ratio);
            var size = (((steps - i).toFloat() * maxDist) / steps).toNumber() + 1;
            
            dc.setColor(color, color);
            dc.fillPolygon([
                [centerX, centerY - size],
                [centerX + size, centerY],
                [centerX, centerY + size],
                [centerX - size, centerY]
            ]);
        }
        
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(false);
        }
    }
    
    // Gradient kątowy/sweep - ulepszona wersja
    function drawSweep(dc as Dc, color1 as Number, color2 as Number,
                        width as Number, height as Number) as Void {
        var centerX = width / 2;
        var centerY = height / 2;
        var maxRadius = Math.sqrt(centerX * centerX + centerY * centerY).toNumber() + 15;
        
        // Dla sweep użyj więcej segmentów dla płynności
        var segments = getGradientSteps();
        if (segments < 60) {
            segments = 60;
        }
        
        var angleStep = 360.0 / segments;
        
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        
        for (var i = 0; i < segments; i++) {
            var ratio = i.toFloat() / segments;
            var color = ColorHelper.interpolateColor(color1, color2, ratio);
            
            var angle1 = Math.toRadians(i * angleStep - 90);
            var angle2 = Math.toRadians((i + 1.5) * angleStep - 90); // Lekki overlap
            
            var x1 = centerX + (maxRadius * Math.cos(angle1));
            var y1 = centerY + (maxRadius * Math.sin(angle1));
            var x2 = centerX + (maxRadius * Math.cos(angle2));
            var y2 = centerY + (maxRadius * Math.sin(angle2));
            
            dc.setColor(color, color);
            dc.fillPolygon([
                [centerX, centerY],
                [x1.toNumber(), y1.toNumber()],
                [x2.toNumber(), y2.toNumber()]
            ]);
        }
        
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(false);
        }
    }
    
    // Rysuj jednolity kolor tła
    function drawSolidColor(dc as Dc, color as Number) as Void {
        dc.setColor(color, color);
        dc.clear();
    }
}