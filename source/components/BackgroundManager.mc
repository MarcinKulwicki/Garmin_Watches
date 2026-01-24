import Toybox.Graphics;
import Toybox.Application;
import Toybox.Lang;

module BackgroundManager {
    
    const BG_TYPE_IMAGE_MAX = 13;
    const BG_TYPE_SOLID = 14;
    const BG_TYPE_GRADIENT = 15;
    
    // Cache dla bitmap
    var cachedBitmap = null;
    var cachedBitmapId = -1;
    
    // Cache dla gradientu
    var gradientBuffer = null;
    var gradientCacheKey = null;
    var screenWidth = 0;
    var screenHeight = 0;
    
    // Inicjalizacja z wymiarami ekranu
    function initBuffer(width as Number, height as Number) as Void {
        screenWidth = width;
        screenHeight = height;
    }
    
    function drawBackground(dc as Dc) as Void {
        var bgType = SettingsHelper.getNumberProperty("BackgroundType", 1);
        
        if (bgType >= 1 && bgType <= BG_TYPE_IMAGE_MAX) {
            drawBitmapBackground(dc, bgType);
        } else if (bgType == BG_TYPE_SOLID) {
            drawSolidBackground(dc);
        } else if (bgType == BG_TYPE_GRADIENT) {
            drawGradientBackground(dc);
        } else {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            dc.clear();
        }
    }
    
    function drawBitmapBackground(dc as Dc, bgId as Number) as Void {
        if (cachedBitmapId != bgId || cachedBitmap == null) {
            cachedBitmap = loadBackgroundBitmap(bgId);
            cachedBitmapId = bgId;
        }
        
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        if (cachedBitmap != null) {
            var x = (dc.getWidth() - cachedBitmap.getWidth()) / 2;
            var y = (dc.getHeight() - cachedBitmap.getHeight()) / 2;
            dc.drawBitmap(x, y, cachedBitmap);
        }
    }
    
    function loadBackgroundBitmap(bgId as Number) {
        switch (bgId) {
            case 1: return Application.loadResource(Rez.Drawables.Background1);
            case 2: return Application.loadResource(Rez.Drawables.Background2);
            case 3: return Application.loadResource(Rez.Drawables.Background3);
            case 4: return Application.loadResource(Rez.Drawables.Background4);
            case 5: return Application.loadResource(Rez.Drawables.Background5);
            case 6: return Application.loadResource(Rez.Drawables.Background6);
            case 7: return Application.loadResource(Rez.Drawables.Background7);
            case 8: return Application.loadResource(Rez.Drawables.Background8);
            case 9: return Application.loadResource(Rez.Drawables.Background9);
            case 10: return Application.loadResource(Rez.Drawables.Background10);
            case 11: return Application.loadResource(Rez.Drawables.Background11);
            case 12: return Application.loadResource(Rez.Drawables.Background12);
            case 13: return Application.loadResource(Rez.Drawables.Background13);
            default: return Application.loadResource(Rez.Drawables.Background1);
        }
    }
    
    function drawSolidBackground(dc as Dc) as Void {
        var color = ColorHelper.getColorFromProperty(
            "BackgroundSolidColor", 
            "BackgroundSolidColorCustom", 
            Graphics.COLOR_BLACK
        );
        dc.setColor(color, color);
        dc.clear();
    }
    
    function drawGradientBackground(dc as Dc) as Void {
        var color1 = ColorHelper.getColorFromProperty(
            "GradientColor1", 
            "GradientColor1Custom", 
            0x8B0000
        );
        var color2 = ColorHelper.getColorFromProperty(
            "GradientColor2", 
            "GradientColor2Custom", 
            0x000000
        );
        var gradientType = SettingsHelper.getNumberProperty("GradientType", 1);
        var direction = SettingsHelper.getNumberProperty("GradientDirection", 1);
        var smoothness = SettingsHelper.getNumberProperty("GradientSmoothness", 2);
        
        // Klucz cache
        var newCacheKey = buildCacheKey(color1, color2, gradientType, direction, smoothness);
        
        // Sprawdź czy mamy zbuforowany gradient
        if (gradientBuffer != null && gradientCacheKey != null && gradientCacheKey.equals(newCacheKey)) {
            dc.drawBitmap(0, 0, gradientBuffer);
            return;
        }
        
        // Próbuj utworzyć bufor
        var buffer = createGradientBuffer(dc, color1, color2, gradientType, direction);
        
        if (buffer != null) {
            gradientBuffer = buffer;
            gradientCacheKey = newCacheKey;
            dc.drawBitmap(0, 0, gradientBuffer);
        } else {
            // Fallback - rysuj bezpośrednio
            GradientRenderer.drawGradient(dc, color1, color2, gradientType, direction);
        }
    }
    
    function buildCacheKey(c1 as Number, c2 as Number, gt as Number, dir as Number, sm as Number) as String {
        return c1.format("%06X") + "_" + c2.format("%06X") + "_" + 
               gt.toString() + "_" + dir.toString() + "_" + sm.toString();
    }
    
    function createGradientBuffer(dc as Dc, color1 as Number, color2 as Number,
                                   gradientType as Number, direction as Number) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        if (!(Graphics has :BufferedBitmap)) {
            return null;
        }
        
        try {
            // Użyj createBufferedBitmap jeśli dostępne (nowsze API)
            if (Graphics has :createBufferedBitmap) {
                var bufferRef = Graphics.createBufferedBitmap({
                    :width => width,
                    :height => height
                });
                
                if (bufferRef != null) {
                    var buffer = bufferRef.get();
                    if (buffer != null) {
                        var bufferDc = buffer.getDc();
                        GradientRenderer.drawGradient(bufferDc, color1, color2, gradientType, direction);
                        return buffer;
                    }
                }
            }
            
            // Starsza metoda - bezpośredni konstruktor
            var buffer = new Graphics.BufferedBitmap({
                :width => width,
                :height => height
            });
            
            var bufferDc = buffer.getDc();
            GradientRenderer.drawGradient(bufferDc, color1, color2, gradientType, direction);
            return buffer;
            
        } catch (e) {
            // Buforowanie nie działa na tym urządzeniu
            return null;
        }
    }
    
    function clearCache() as Void {
        cachedBitmap = null;
        cachedBitmapId = -1;
        gradientBuffer = null;
        gradientCacheKey = null;
    }
}