package managers {
import assets.texts.alerts;

import feathers.controls.Alert;
import feathers.data.ListCollection;

import starling.events.Event;

public class alertManager {
    public static var _alert:Alert = new Alert();

    public static function ShowAlert(type:String, CLOSE_HANDLER:Function = null, EXTRA:String = null):void {
        var buts:Array = [];
        if (alerts[type].cancelButtonTitle) buts.push({label: alerts[type].cancelButtonTitle, id:0});
        if (alerts[type].closeButtonTitle) buts.push({label: alerts[type].closeButtonTitle,id:1});
        //trace(" _alert.buttonsDataProvider " + _alert.buttonsDataProvider);
        _alert = Alert.show(alerts[type].message + (EXTRA != null ? EXTRA : ""), alerts[type].title, new ListCollection(buts));
        _alert.addEventListener(Event.CLOSE, CLOSE_HANDLER);
    }

    public static function Clear():void {
        _alert.removeFromParent(true);
    }
}
}
