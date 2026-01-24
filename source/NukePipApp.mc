import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class NukePipApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new NukePipView() ];
    }

    function onSettingsChanged() as Void {
        BackgroundManager.clearCache();
        WatchUi.requestUpdate();
    }
}

function getApp() as NukePipApp {
    return Application.getApp() as NukePipApp;
}