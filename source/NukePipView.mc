import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;

class NukePipView extends WatchUi.WatchFace {
    private var backgroundBitmap;
    private var fontRegular;
    private var fontSmall;
    private var font40;
    private var currentBackground = 1;
    private var currentFont = 1;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        loadBackground();
        loadFonts();
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

    function loadBackground() as Void {
        var choice = SettingsHelper.getNumberProperty("BackgroundChoice", 1);
        currentBackground = choice;
        
        var backgrounds = [
            Rez.Drawables.Background1, Rez.Drawables.Background2, 
            Rez.Drawables.Background3, Rez.Drawables.Background4,
            Rez.Drawables.Background5, Rez.Drawables.Background6,
            Rez.Drawables.Background7, Rez.Drawables.Background8,
            Rez.Drawables.Background9, Rez.Drawables.Background10,
            Rez.Drawables.Background11, Rez.Drawables.Background12,
            Rez.Drawables.Background13
        ];
        
        var index = (choice >= 1 && choice <= 13) ? choice - 1 : 0;
        backgroundBitmap = Application.loadResource(backgrounds[index]);
    }

    function onUpdate(dc as Dc) as Void {
        // Sprawdź czy zmieniono ustawienia
        var bgChoice = SettingsHelper.getNumberProperty("BackgroundChoice", 1);
        if (bgChoice != currentBackground) { loadBackground(); }
        
        var fontChoice = SettingsHelper.getNumberProperty("FontChoice", 1);
        if (fontChoice != currentFont) { loadFonts(); }

        // Rysuj tło
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        if (backgroundBitmap != null) {
            var x = (dc.getWidth() - backgroundBitmap.getWidth()) / 2;
            var y = (dc.getHeight() - backgroundBitmap.getHeight()) / 2;
            dc.drawBitmap(x, y, backgroundBitmap);
        }
        
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

    function onShow() as Void {}
    function onHide() as Void {}
    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}
}