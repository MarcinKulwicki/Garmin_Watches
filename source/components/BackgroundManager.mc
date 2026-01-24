import Toybox.Graphics;
import Toybox.Application;
import Toybox.Lang;

module BackgroundManager {
    
    const BG_TYPE_IMAGE_MAX = 13;
    const BG_TYPE_SOLID = 14;
    
    var cachedBitmap = null;
    var cachedBitmapId = -1;
    
    function drawBackground(dc as Dc) as Void {
        var bgType = SettingsHelper.getNumberProperty("BackgroundType", 1);
        
        if (bgType >= 1 && bgType <= BG_TYPE_IMAGE_MAX) {
            drawBitmapBackground(dc, bgType);
        } else if (bgType == BG_TYPE_SOLID) {
            drawSolidBackground(dc);
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
    
    function clearCache() as Void {
        cachedBitmap = null;
        cachedBitmapId = -1;
    }
}