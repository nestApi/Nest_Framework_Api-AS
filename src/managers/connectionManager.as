package managers {
import air.net.URLMonitor;

import core.nest;

import core.nest;

import core.nest;

import core.nest;

import events.nestEvent;

import flash.events.Event;
import flash.events.HTTPStatusEvent;

import flash.events.IOErrorEvent;

import flash.events.StatusEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;

import flash.net.URLRequest;
import flash.net.URLRequestMethod;

import managers.dataManager;

import starling.events.Event;
import events.nestEvent;

public class connectionManager {

    public static var _default_login:String="nestadmin";
    public static var _default_pass:String="zg6yYHpRN2dm";
    public static var _default_remember_me:Boolean = true;


    private static var _wpArguments:String = "/wp-json/custom-data/v1/datas/";
    private static var _updateArguments:String = "&get_last_update=1";
    private static var _contentArguments:String = "&get_flat_array=0&add_posts_key=0";

    private static var _authResultObject:Object;


    public static function eval():void {
        trace("connectionManager.eval(" + nest._onLineTestServer + ")")
        var monitor:URLMonitor = new URLMonitor(new URLRequest(nest._onLineTestServer));
        monitor.start();
        monitor.addEventListener(StatusEvent.STATUS, getStatus)
    }

    private static function getStatus(event:StatusEvent):void {
        trace("connectionManager.getStatus()");
        var state:Boolean;
        switch (event.code) {
            case "Service.available":
                state = true;
                break;
            case "Service.unavailable":
                state = false;
                break;
        }
        nest._core.dispatchEventWith(nestEvent.CONNECTION_EVAL, false, {_state: state})
    }

    public static function authentication():void {
        trace("authentication / anonymous : " + nest._anonymousMode);
        nest._anonymousMode ? authenticationRequest() : setUserAuthenticationScreen();
    }

    private static function setUserAuthenticationScreen():void {
        trace("setUserAuthenticationScreen()");
        trace("nest._context :" + nest._context);
        nest._context.activeScreen.dispatchEventWith(starling.events.Event.CHANGE)
    }

    public static function authenticationRequest():void {
        nest._onLineMode ? onLineAuthentication() : offLineAuthentication();
    }

    private static function offLineAuthentication():void {
        trace("offLineAuthentication()")
        var f:File = File.applicationStorageDirectory.resolvePath("nest.usr");
        var rs:FileStream = new FileStream();
        rs.open(f, FileMode.READ);
        var users:Object = JSON.parse(rs.readUTFBytes(f.size));
        rs.close();
        var nbUsers:uint = users.length;
        var i:uint;
        var allow:Boolean = false;
        for (i = 0; i < nbUsers; ++i) {
            if (dataManager.user.login == users[i].login && dataManager.user.pass == users[i].pass) {
                allow = true;
                break;
            }
        }
        !allow ? autError() : nest._core.dispatchEventWith(nestEvent.AUTHENTICATION);

    }

    private static function onLineAuthentication():void {
        trace("onLineAuthentication()...");
        trace("?username=" + dataManager.user.login + "&password=" + dataManager.user.pass)
        var args:String=nest._nestServer + _wpArguments + "?username=" + dataManager.user.login + "&password=" + dataManager.user.pass + _updateArguments
        var request:URLRequest = new URLRequest(args);
        request.method=URLRequestMethod.GET
        trace("request : " + request.url);
        var l:URLLoader = new URLLoader();
        l.dataFormat = URLLoaderDataFormat.TEXT;
        l.addEventListener(IOErrorEvent.IO_ERROR, IOerrorHandler);
        l.addEventListener(HTTPStatusEvent.HTTP_STATUS, onStatusReponse);
        //l.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onStatusReponse);
        l.addEventListener(flash.events.Event.COMPLETE, onLineAuthenticationResult, false, 0, true);
        l.load(request);
    }

    private static function onStatusReponse(event:HTTPStatusEvent):void {
        trace(event.toString());

    }

    private static function onLineAuthenticationResult(event:flash.events.Event):void {
        trace("authenticationResult() Raw DATA : " + event.currentTarget.data);
        _authResultObject= JSON.parse(event.currentTarget.data);
        _authResultObject.error == "bad authentification" ? autError() : authSucces();
    }

    private static function autError():void {
        alertManager.ShowAlert("AUTH_FAILED");
    }

    private static function authSucces():void {
        trace("authSucces");
        dataManager.setUserFromOnLineCoonection()
        nest._core.dispatchEventWith(nestEvent.AUTHENTICATION)
    }

    private static function IOerrorHandler(event:IOErrorEvent):void {
        trace("IOerrorHandler : " + event.toString());
    }

    /**INSTALL**/
    public static function contentRequestForInstall():void {
        var request:URLRequest = new URLRequest(nest._nestServer + _wpArguments + "?username=" + dataManager.user.login + "&password=" + dataManager.user.pass + _contentArguments);
        trace("Install request : " + request.url);
        var l:URLLoader = new URLLoader();
        l.dataFormat = URLLoaderDataFormat.TEXT;
        l.addEventListener(IOErrorEvent.IO_ERROR, IOerrorHandler);
        l.addEventListener(flash.events.Event.COMPLETE, contentRequestForInstallResult);
        l.load(request);

    }

    private static function contentRequestForInstallResult(event:flash.events.Event):void {
       // trace("contentRequestResult() JSON PARSED STRINGED : " + JSON.stringify(JSON.parse(event.currentTarget.data)));
        dataManager.nest_db = JSON.parse(event.currentTarget.data);
        installer.dbInstall();
    }
    /** **/



   /**UPDATE**/
    public static function contentRequestForUpdate():void {
        var request:URLRequest = new URLRequest(nest._nestServer + _wpArguments + "?username=" + dataManager.user.login + "&password=" + dataManager.user.pass + _contentArguments);
        trace("Update request : " + request.url);
        var l:URLLoader = new URLLoader();
        l.dataFormat = URLLoaderDataFormat.TEXT;
        l.addEventListener(IOErrorEvent.IO_ERROR, IOerrorHandler);
        l.addEventListener(flash.events.Event.COMPLETE, contentRequestForUpdateResult);
        l.load(request);

    }

    private static function contentRequestForUpdateResult(event:flash.events.Event):void {
        // trace("contentRequestResult() JSON PARSED STRINGED : " + JSON.stringify(JSON.parse(event.currentTarget.data)));
        dataManager.nest_db = JSON.parse(event.currentTarget.data);
        updater.dbUpdate()
    }
    /** **/


    public static function get authResultObject():Object {
        return _authResultObject;
    }

}
}
