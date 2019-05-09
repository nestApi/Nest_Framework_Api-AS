package events {
import starling.events.Event;

public class nestEvent extends Event {

    public static const CONNECTION_EVAL:String = "connectionEval";
    public static const DATA_EVAL:String = "dataEval";
    public static const AUTHENTICATION:String = "authentication";
    public static const NEST_INSTALL:String = "nestInstall";
    public static const NEST_UPDATE:String = "nestUpdate";
    public static const PLIST_COMPLETE:String = "plistComplete";
    public static const DB_COMPLETE:String = "dbComplete";
    public static const SLIDE_READY:String = "slideReady";
    public static const APP_READY:String = "appReady";


    public function nestEvent(type:String, bubbles:Boolean = false, data:Object = null) {
        super(type, bubbles, data);
    }
}
}
