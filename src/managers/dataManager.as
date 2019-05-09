package managers {
import core.nest;

import events.nestEvent;

import flash.events.Event;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import events.nestEvent;

[Event(name="dataEval", type="events.nestEvent")]
public class dataManager {

    public static var _nestVirtual_db:Object;

    private static var _plist:Object;
    private static var _user:Object;
    private static var _nest_db:Object;


    public static function eval(firstRunSim:Boolean):void {
        trace("dataManager.eval(firstRunSim=" + firstRunSim + ")");
        var asData:Boolean = firstRunSim ? false : File.applicationStorageDirectory.resolvePath("nest.plist").exists;
        nest._core.dispatchEventWith(nestEvent.DATA_EVAL, false, {d: asData})
    }


    /**
     * Plist
     */

    public static function getLocalPlist():void {
        var file:File = File.applicationStorageDirectory.resolvePath("nest.plist");
        var fileStream:FileStream = new FileStream();
        //fileStream.openAsync(file, FileMode.READ);
        fileStream.open(file, FileMode.READ);
        var rawfile:String = fileStream.readUTFBytes(file.size);
        //fileStream.addEventListener(Event.CLOSE, plistRead);
        plist = JSON.parse(rawfile);
        trace("_plist : " + JSON.stringify(_plist));
        fileStream.close();
        nest._core.dispatchEventWith(nestEvent.PLIST_COMPLETE);
    }

    private static function plistRead(event:Event):void {
        trace("_plist : " + JSON.stringify(_plist));
    }


    /**
     * USER
     */
    public static function setUserFromLocalPlist():void {
        plist.remember_me == true ? user = {login: plist.last_user, pass: plist.last_pass, remember_me:true} : user = {};
        trace("_user from plist : " + JSON.stringify(user));
    }

    public static function setUserFromOnLineCoonection():void {
        user.id=connectionManager.authResultObject.user.id;
        user.roles=connectionManager.authResultObject.user.roles;
    }

    /**
     * db
     */
    public static function getLocal_db():void {
        var file:File = File.applicationStorageDirectory.resolvePath("nest.db");
        var fileStream:FileStream = new FileStream();
        //fileStream.openAsync(file, FileMode.READ);
        fileStream.open(file, FileMode.READ);
        var rawfile:String = fileStream.readUTFBytes(file.size);
        //fileStream.addEventListener(Event.CLOSE, plistRead);
        nest_db = JSON.parse(rawfile);
        trace("nest_db : " + JSON.stringify(nest_db));
        fileStream.close();
        nest._core.dispatchEventWith(nestEvent.DB_COMPLETE);

    }




    /**
     * GETTERS AND SETTERS
     */
    public static function get nest_db():Object {
        return _nest_db;
    }

    public static function set nest_db(nest_db:Object):void {
        _nest_db = nest_db;
    }

    public static function get plist():Object {
        return _plist;
    }

    public static function set plist(value:Object):void {
        _plist = value;
    }


    public static function get user():Object {
        return _user;
    }

    public static function set user(value:Object):void {
        _user = value;
    }


}
}
