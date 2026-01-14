import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;

class NukePipView extends WatchUi.WatchFace {
    private var backgroundBitmap;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // Załaduj obrazek RAZ przy starcie
        backgroundBitmap = Application.loadResource(Rez.Drawables.BackgroundImage);
    }

    function onUpdate(dc as Dc) as Void {
        // Czarne tło
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Wyświetl obrazek wyśrodkowany
        if (backgroundBitmap != null) {
            var imgW = backgroundBitmap.getWidth();
            var imgH = backgroundBitmap.getHeight();
            var x = (dc.getWidth() - imgW) / 2;
            var y = (dc.getHeight() - imgH) / 2;
            dc.drawBitmap(x, y, backgroundBitmap);
        }
    }

    function onShow() as Void {}
    function onHide() as Void {}
    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}
}