package managers {
import core.nest;
import core.nest;

import deng.fzip.FZip;
import deng.fzip.FZipFile;

import events.nestEvent;

import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.utils.ByteArray;

import starling.core.Starling;

import utils.stringUtils;
import core.nest;
import core.nest;

public class installer {

    private static var _new_plist:Object;
    private static var _new_users_list:Array;
    private static var _new_user:Object;

    private static var _ddlList:Array = [];
    private static var _ddlList_l:uint;

    private static var _nameslist:Array = [];
    private static var _streamList:Array = [];

    private static var _fToLoadNumber:uint;
    //private static var _current_f_to_load:uint;
    private static var _fLoadedCount:uint;

    private static var _zip:FZip;
    private static var _zipDone:Boolean = false;

    private static var _dirName:String;

    private static var _index:uint = 0;
    private static var _zipIndex:uint = 0;
    private static var _unzipIndex:uint = 0;


    public static function Init():void {
        trace("installer.Init()...")
        directoriesInstall()

    }

    private static function directoriesInstall():void {
        trace("directoriesInstall()");

        var content:File = File.applicationStorageDirectory.resolvePath("Contents/");
        if (!content.exists) {
            content.createDirectory();
        }

        /*var f:File;
        var i:int;
        var j:int;
        var parentAr:Array = [];
        var childAr:Array = [];
        var parentLength:uint = parentAr.length;
        var childLength:uint = childAr.length;

        for (i = 0; i < parentLength; ++i) {
            for (j = 0; j < childLength; ++j) {
                f = File.applicationStorageDirectory.resolvePath(parentAr[i] + childAr[j]);
                if (!f.exists) f.createDirectory();
            }
        }*/
        plistInstall()
    }

    private static function plistInstall():void {
        _new_plist = {};
        _new_plist.lastUpdate = connectionManager.authResultObject.lastpostdate;
        _new_plist.last_user = dataManager.user.login;
        _new_plist.last_pass = dataManager.user.pass;
        _new_plist.remember_me = dataManager.user.remember_me;
        var plist_data:String = JSON.stringify(_new_plist);
        trace("plist data : " + plist_data);
        var file:File = File.applicationStorageDirectory.resolvePath("nest.plist");
        var fileStream:FileStream = new FileStream();
        fileStream.openAsync(file, FileMode.WRITE);
        fileStream.addEventListener(Event.CLOSE, plistInstalled);
        fileStream.writeUTFBytes(plist_data);
        fileStream.close();
    }

    private static function plistInstalled(event:Event):void {
        trace("nest.plist created");
        usersInstall();
    }

    private static function usersInstall():void {

        _new_user = {};
        _new_user.id = connectionManager.authResultObject.user.id;
        _new_user.roles = connectionManager.authResultObject.user.roles;
        _new_user.login = dataManager.user.login;
        _new_user.pass = dataManager.user.pass;
        _new_user.remember_me = dataManager.user.remember_me;

        _new_users_list = [_new_user];
        var _users_data:String = JSON.stringify(_new_users_list);
        trace("users data : " + _users_data);
        var file:File = File.applicationStorageDirectory.resolvePath("nest.usr");
        var fileStream:FileStream = new FileStream();
        fileStream.openAsync(file, FileMode.WRITE);
        fileStream.addEventListener(Event.CLOSE, usersInstalled);
        fileStream.writeUTFBytes(_users_data);
        fileStream.close();

    }

    private static function usersInstalled(event:Event):void {
        trace("nest.usr created");

        if (nest._core._nest_db_Sim) {
            dataManager.nest_db = dataManager._nestVirtual_db;
            // contentManager.organize();
            dbInstall();

        } else {
            connectionManager.contentRequestForInstall();
        }
    }

    public static function dbInstall():void {
        var db_data:String = JSON.stringify(dataManager.nest_db);
        trace("install db data : " + db_data);
        var file:File = File.applicationStorageDirectory.resolvePath("nest.db");
        var fileStream:FileStream = new FileStream();
        fileStream.openAsync(file, FileMode.WRITE);
        fileStream.addEventListener(Event.CLOSE, dbInstalled);
        fileStream.writeUTFBytes(db_data);
        fileStream.close();

    }

    private static function dbInstalled(event:Event):void {
        trace("nest.db created");
        //nest._core.dispatchEventWith(nestEvent.nest_INSTALL, false, {succes: true});
        pre_ddlInstall();
    }

    private static function pre_ddlInstall():void {
        trace("pre_ddlInstall()... ");
        var p_db:Object = dataManager.nest_db.presentation;
        var p_db_l:uint = p_db.length;
        var i:uint;
        var fwddl:Array = nest._fieldsWithDdl;
        var fwddl_l:uint = fwddl.length;
        var j:uint;
        var nbProps:int;
        for (i = 0; i < p_db_l; ++i) {

            for (j = 0; j < fwddl_l; ++j) {

                nbProps = 0;
                for (var props:Object in p_db[i].acf[fwddl[j]]) {
                    trace("props : " + props);
                    trace("props Value: " + p_db[i].acf[fwddl[j]][props]);

                    nbProps++;
                    trace(props + " as to be ddl : " + p_db[i].acf[fwddl[j]][props]);
                    if (stringUtils.val_for_ddl(p_db[i].acf[fwddl[j]][props]))
                        _ddlList.push(p_db[i].acf[fwddl[j]][props]);
                }


                if (nbProps == 0) {
                    trace("nb props : " + nbProps);
                    trace(props + " as to be ddl : " + p_db[i].acf[fwddl[j]]);
                    if (stringUtils.val_for_ddl(p_db[i].acf[fwddl[j]]))
                        _ddlList.push(p_db[i].acf[fwddl[j]]);

                }


                /*trace("array : " + (p_db[i].acf[fwddl[j]] is Array));


                var f:Array = String(fwddl[j]).split(".");
                var startUrl:Object = p_db[i].acf;
                var finalUrl:Object = startUrl;

                for (var g:uint = 0; g < f.length; ++g) {
                    var tempUrl:Object = finalUrl[f[g]];
                    finalUrl = tempUrl;
                    //trace(fwddl[j] + " as to be ddl : " + p_db[i].acf["cliche_url"]["mini"]);
                }

                trace("finalUrl: " + finalUrl);*/
                //trace(fwddl[j] + " as to be ddl : " + p_db[i].acf["cliche_url"]["mini"]);
                //if (stringUtils.val_for_ddl(p_db[i].acf[fwddl[j]])) _ddlList.push(nest._nestServer + p_db[i].acf[fwddl[j]]);
            }
            /*for (var props:Object in p_db[i].acf) {
                trace("props : " + props);
                for (j = 0; j < fwddl_l; ++j) {
                    if (props == fwddl[j]) {
                        trace(props + " as to be ddl : " + p_db[i].acf[props]);
                        if (stringUtils.val_for_ddl(p_db[i].acf[props]))
                            _ddlList.push(nest._nestServer+p_db[i].acf[props]);
                    }
                }

            }*/

        }

        _ddlList_l = _ddlList.length;
        trace("before clean : " + _ddlList + " / _ddlList_l : " + _ddlList_l);

        for (i = _ddlList_l; i > 0; --i) {
            if (_ddlList.indexOf(_ddlList[i - 1]) != i - 1) {
                _ddlList.splice(i - 1, 1);
            }
        }

        _ddlList_l = _ddlList.length;
        trace("after clean : " + _ddlList + " / _ddlList_l : " + _ddlList_l);
        ddlInstallInit();
    }


    private static function ddlInstallInit():void {
        trace("ddlInstall()... ");


        if (_ddlList_l == 0) {
            nest._core.dispatchEventWith(nestEvent.NEST_INSTALL, false, {succes: true});
        } else {

            trace("loading Process starting ... ");

            _fToLoadNumber = _ddlList_l;
            //_current_f_to_load = 0;
            _fLoadedCount = 0;

            ddlInstallLoop();
            /*for (i = 0; i < _ddlList_l; ++i) {
                var ur:URLRequest = new URLRequest(_ddlList[i]);
                var us:URLStream = new URLStream();
                us.addEventListener(Event.COMPLETE, loadindFileComplete);
                us.load(ur);
                _streamList.push(us);
                _nameslist.push(stringUtils.nameFromUrl(ur.url));
            }*/
        }
    }

    private static function ddlInstallLoop():void {
        /*_zipDone = false;
        _index = 0;
        _zipIndex = 0;
        _unzipIndex = 0;
        trace("_ddlList[_fLoadedCount] : " + _ddlList[_fLoadedCount]);
        if (_ddlList[_fLoadedCount]) {
            _dirName = stringUtils.directoryFromUrl(_ddlList[_fLoadedCount]);
            alertManager.ShowAlert("DDL", null, ""+_dirName);
            trace("dirName : " + _dirName);
            var dir:File = File.applicationStorageDirectory.resolvePath("Contents/" + _dirName);
            if (!dir.exists) {
                dir.createDirectory();
                trace("dir created");
            }
            _zip = new FZip();
            _zip.addEventListener(Event.OPEN, onZipOpen)
            _zip.addEventListener(Event.COMPLETE, onZipComplete)
            _zip.load(new URLRequest(_ddlList[_fLoadedCount]));
        }
*/
        //trace("_ddlList : "+_ddlList[_fLoadedCount])
        var ur:URLRequest = new URLRequest(_ddlList[_fLoadedCount]);
        var us:URLStream = new URLStream();
        var name:String;
        name = stringUtils.nameFromUrl(ur.url)
        alertManager.ShowAlert("DDL", null, "" + name);
        us.addEventListener(Event.COMPLETE, loadindFileComplete);
        trace("ur : "+ur.url)
        us.load(ur);
        _streamList.push(us);
        _nameslist.push(name);
    }

    private static function onZipOpen(event:Event):void {
        alertManager.Clear();
        alertManager.ShowAlert("DDL", null, "" + _dirName);
        Starling.current.nativeOverlay.addEventListener(Event.ENTER_FRAME, onEnterFrame);

    }

    private static function onEnterFrame(event:Event):void {
        //trace("_zip.getFileCount() : " + _zip.getFileCount());
        trace("onEnterFrame()...");
        var f:FZipFile;
        var name:String;
        for (var i:uint = 0; i < 32; ++i) {
            if (_zip.getFileCount() > _index) {
                f = _zip.getFileAt(_index);
                if (f.filename.charAt(f.filename.length - 1) != "/" && f.filename.indexOf("__MACOSX/") == -1) {
                    trace("name : " + f.filename);
                    /*if (f.filename.indexOf("/") != -1) {
                        var temp:Array=f.filename.split("/")
                        name = temp[temp.length - 1];
                    }else{
                        name = f.filename;
                    }*/
                    name = f.filename;
                    var unzippedFile:File = File.applicationStorageDirectory.resolvePath("Contents/" + _dirName + "/" + name);
                    var stream:FileStream = new FileStream();
                    stream.addEventListener(Event.COMPLETE, writingFileComplete);
                    stream.openAsync(unzippedFile, FileMode.UPDATE);
                    stream.writeBytes(f.content);
                    _zipIndex++;
                }
                _index++
            } else {
                if (_zipDone) {
                    Starling.current.nativeOverlay.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                }
                break;
            }
        }

    }

    private static function loadindFileComplete(event:Event):void {
        var i:uint;
        var ba:ByteArray = new ByteArray();
        var s:URLStream = event.currentTarget as URLStream;
        var n:String;
        for (i = 0; i < _streamList.length; ++i) {
            if (s == _streamList[i]) {
                n = _nameslist[i];
                break;
            }
        }
        s.readBytes(ba, 0, s.bytesAvailable);
        try {
            var f:File = File.applicationStorageDirectory.resolvePath("Contents/" + n);
            var fs:FileStream = new FileStream();
            fs.addEventListener(Event.COMPLETE, writingFileComplete);
            fs.openAsync(f, FileMode.UPDATE);
            fs.writeBytes(ba);
        } catch (e:Error) {
            trace(e.message);
        }

    }

    private static function writingFileComplete(event:Event):void {
        event.target.close();
        //_fLoaded++;
        //_unzipIndex++;
        //trace("writingFileComplete :  _zipIndex : " + _zipIndex + " / _unzipIndex : " + _unzipIndex);
        //if (_zipDone  && _unzipIndex==_zipIndex) {
        alertManager.Clear();
        //nestInstalled();
        _fLoadedCount++;
        trace("_fLoadedCount / _fToLoadNumber : " + _fLoadedCount + " / " + _fToLoadNumber);
        if (_fLoadedCount == _fToLoadNumber) {
            nestInstalled();
        } else {
            ddlInstallLoop();
        }


        //nest._context.activeScreen.dispatchEventWith(nestEvent.SLIDE_READY,false,{dir:_dirName, files:_slidesFiles});
        //if(_fLoaded == _fToLoad ) nestInstalled();
    }

    private static function onZipComplete(event:Event):void {
        trace("onZipComplete : Done");
        trace("_zip.getFileCount() : " + _zip.getFileCount());
        _zipDone = true;

    }

    /*private static function writingFileComplete(event:Event):void {
        event.target.close();
        _fLoadedCount++;
        trace("loading Process : " + _fLoadedCount + " / " + _fToLoadNumber);
        if(_fLoadedCount == _fToLoadNumber ) nestInstalled();
    }*/

    private static function nestInstalled():void {
        trace(" !!! nestInstalled !!!");
        nest._core.dispatchEventWith(nestEvent.NEST_INSTALL, false, {succes: true});
    }

    public static function get dirName():String {
        return _dirName;
    }
}
}
