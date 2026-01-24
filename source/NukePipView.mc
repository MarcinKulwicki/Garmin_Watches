import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Lang;

class NukePipView extends WatchUi.WatchFace {
    private var fontRegular;
    private var fontSmall;
    private var font40;
    private var currentFont = 1;
    private var isLowPowerMode = false;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        loadFonts();
        // Inicjalizuj bufor gradientu z wymiarami ekranu
        BackgroundManager.initBuffer(dc.getWidth(), dc.getHeight());
    }

    function loadFonts() as Void {
        var choice = SettingsHelper.getNumberProperty("FontChoice", 1);
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

    function onUpdate(dc as Dc) as Void {
        // Sprawdź czy zmieniono font
        var fontChoice = SettingsHelper.getNumberProperty("FontChoice", 1);
        if (fontChoice != currentFont) { 
            loadFonts(); 
        }

        // Tryb niskiego zużycia energii
        if (isLowPowerMode) {
            drawLowPowerMode(dc);
            return;
        }

        // Rysuj tło (obrazek, solid color lub gradient)
        BackgroundManager.drawBackground(dc);
        
        // Rysuj wskaźnik sekund
        SecondsIndicator.draw(dc);
        
        // Rysuj pola danych
        var centerX = dc.getWidth() / 2;
        
        FieldRenderer.drawField(dc, "Upper", centerX, dc.getHeight() / 7, 
                                font40, Graphics.TEXT_JUSTIFY_CENTER);
        FieldRenderer.drawField(dc, "Middle", centerX, dc.getHeight() * 4 / 10, 
                                fontRegular, Graphics.TEXT_JUSTIFY_CENTER);
        FieldRenderer.drawField(dc, "Lower", centerX, dc.getHeight() * 13 / 16, 
                                fontSmall, Graphics.TEXT_JUSTIFY_CENTER);
        
        FieldRenderer.drawSideField(dc, "Left", dc.getHeight() * 6 / 10, true, fontSmall);
        FieldRenderer.drawSideField(dc, "Right", dc.getHeight() * 6 / 10, false, fontSmall);
    }

    function drawLowPowerMode(dc as Dc) as Void {
        // Czarne tło - minimum energii
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Tylko czas - bez sekund, bez gradientu
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var timeString = DataHelper.getTimeString();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY, fontRegular, timeString, 
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onShow() as Void {
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
        isLowPowerMode = false;
        WatchUi.requestUpdate();
    }

    function onEnterSleep() as Void {
        isLowPowerMode = true;
        WatchUi.requestUpdate();
    }
}