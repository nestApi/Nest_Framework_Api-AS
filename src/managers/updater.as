package managers {
import deng.fzip.FZip;
import deng.fzip.FZipFile;

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
import events.nestEvent;

public class updater {
    private static var _new_plist:Object;
    private static var _new_users_list:Array;
    private static var _new_user:Object;

    private static var _ddlList:Array = [];
    private static var _ddlList_l:uint;

    private static var _nameslist:Array = [];
    private static var _streamList:Array = [];

    private static var _fToLoadNumber:uint;
    private static var _fLoadedCount:uint;

    private static var _zip:FZip;
    private static var _zipDone:Boolean = false;
    private static var _index:uint = 0;
    private static var _zipIndex:uint = 0;
    private static var _unzipIndex:uint = 0;

    private static var _dirName:String;

    public static function get dirName():String {
        return _dirName;
    }

    public static function Init():void {
        trace("updater.Init");
        plistUpdate();
    }

    public static function dbUpdate():void {
        var db_data:String = JSON.stringify(dataManager.nest_db);
        trace("update db data : " + db_data);
        var file:File = File.applicationStorageDirectory.resolvePath("nest.db");
        var fileStream:FileStream = new FileStream();
        fileStream.openAsync(file, FileMode.WRITE);
        fileStream.addEventListener(Event.CLOSE, dbUpdated);
        fileStream.writeUTFBytes(db_data);
        fileStream.close();
    }

    private static function plistUpdate():void {
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
        fileStream.addEventListener(Event.CLOSE, plistUdated);
        fileStream.writeUTFBytes(plist_data);
        fileStream.close();
    }

    private static function getPreviousUsers():void {
        var file:File = File.applicationStorageDirectory.resolvePath("nest.usr");
        var fileStream:FileStream = new FileStream();
        fileStream.open(file, FileMode.READ);
        var userList:Object = JSON.parse(fileStream.readUTFBytes(file.size));
        fileStream.close();
        compareUsers(userList);
    }

    private static function compareUsers(userList:Object):void {
        var nb:uint = userList.length;
        var userExist:Boolean = false;
        var updateUser:Boolean = false;

        for (var i:uint = 0; i < nb; ++i) {
            if (connectionManager.authResultObject.user.id == userList[i].id) {
                trace("User Exist");
                userExist = true;
                if (dataManager.user.pass != userList[i].pass) {
                    trace("User PassUpdate");
                    updateUser = true;
                    userList[i].pass = dataManager.user.pass;
                }
            }
        }
        if (!userExist) {
            userList.push(dataManager.user);
            trace("User Added");
            updateUserFile(userList);
        } else {
            if (updateUser) {
                updateUserFile(userList);
            } else {

                if (nest._core._nest_db_Sim) {
                    dataManager.nest_db = dataManager._nestVirtual_db;
                    // contentManager.organize();
                    dbUpdate();

                } else {
                    connectionManager.contentRequestForUpdate();
                }
            }

        }
    }

    private static function updateUserFile(userList:Object):void {
        var _users_data:String = JSON.stringify(userList);
        var file:File = File.applicationStorageDirectory.resolvePath("nest.usr");
        var fileStream:FileStream = new FileStream();
        fileStream.openAsync(file, FileMode.WRITE);
        fileStream.addEventListener(Event.CLOSE, usersUpdated);
        fileStream.writeUTFBytes(_users_data);
        fileStream.close();
    }

    private static function pre_ddlUpdate():void {
        trace("pre_ddlUpdate()... ");
        var p_db:Object = dataManager.nest_db.presentation;
        var p_db_l:uint = p_db.length;
        var i:uint;
        var fwddl:Array = nest._fieldsWithDdl;
        var fwddl_l:uint = fwddl.length;
        var j:uint;
        var nbProps:int;

        /** Listing Des Fichiers à telecharger **/
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

            }
        }

        /*for (i = 0; i < p_db_l; ++i) {
            //trace("p : "+p_db[i].acf.presentation_generalites_titre);
            for (var props:* in p_db[i].acf) {
                for (j = 0; j < fwddl_l; ++j) {
                    if (props == fwddl[j]) {
                        trace(props + " as to be ddl : " + p_db[i].acf[props]);
                        if (stringUtils.val_for_ddl(p_db[i].acf[props]))
                            _ddlList.push(Nest._nestServer+p_db[i].acf[props]);
                    }
                }
            }
        }*/
        /** **/

        /** suppression des doublons dans la liste de telechargements **/
        _ddlList_l = _ddlList.length;
        trace("before clean : " + _ddlList + " / _ddlList_l : " + _ddlList_l);
        for (i = _ddlList_l; i > 0; --i) {
            if (_ddlList.indexOf(_ddlList[i - 1]) != i - 1) {
                _ddlList.splice(i - 1, 1);
            }
        }
        _ddlList_l = _ddlList.length;
        trace("after duplicate clean : " + _ddlList + " / _ddlList_l : " + _ddlList_l);
        //ddlUpdateInit();
        /** **/


        /** Tri Dossiers Exitants Vs Fichiers à télécharger **/

        var f:File = File.applicationStorageDirectory.resolvePath("Contents");
        if (f.exists) {
            var exlist:Array = f.getDirectoryListing();
            var ex_l:uint = exlist.length;
            if (ex_l != 0) {
                for (var ex_i:int = 0; ex_i < exlist.length; ex_i++) {
                    var found:Boolean = false;
                    for (var ddl_i:int = _ddlList.length - 1; ddl_i >= 0; ddl_i--) {
                        if (_ddlList[ddl_i].indexOf(exlist[ex_i].name) == -1) {

                        } else {
                            trace("/////// list[" + ex_i + "].name : " + exlist[ex_i].name + " / " + "_ddlList[" + ddl_i + "] : " + _ddlList[ddl_i]);
                            found = true;
                            _ddlList.splice(ddl_i, 1);
                        }
                    }
                    trace("ex_i : " + ex_i + "/ found :" + found);
                    /**  Suppression des Dossiers Obsoletes **/
                    if (!found) {
                        trace("list[ " + ex_i + " ].name : " + exlist[ex_i].name + " deleting...");
                        File(exlist[ex_i]).deleteDirectory(true);
                    }
                }
            }
        }
        trace("_ddlList : " + _ddlList);
        _ddlList_l = _ddlList.length;
        /** **/
        ddlUpdateInit()
    }

    private static function ddlUpdateInit():void {
        trace("ddlUpdate()... ");
        if (_ddlList_l == 0) {
            nest._core.dispatchEventWith(nestEvent.NEST_UPDATE, false, {succes: true});
        } else {
            trace("loading Process starting ... ");
            _fToLoadNumber = _ddlList_l;
            _fLoadedCount = 0;

            ddlUpdateLoop();
        }
    }

    private static function ddlUpdateLoop():void {
        /* _zipDone = false;
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
             _zip.addEventListener(Event.OPEN, onZipOpen);
             _zip.addEventListener(Event.COMPLETE, onZipComplete);
             _zip.load(new URLRequest(_ddlList[_fLoadedCount]));
         }*/
        var ur:URLRequest = new URLRequest(nest._nestServer+ _ddlList[_fLoadedCount]);
        var us:URLStream = new URLStream();
        var name:String;
        name = stringUtils.nameFromUrl(ur.url)
        alertManager.ShowAlert("DDL", null, "" + name);
        us.addEventListener(Event.COMPLETE, loadindFileComplete);
        us.load(ur);
        _streamList.push(us);
        _nameslist.push(name);
    }

    private static function nestUpdated():void {
        trace(" !!! nestUpdated !!!");
        nest._core.dispatchEventWith(nestEvent.NEST_UPDATE, false, {succes: true});

    }

    private static function plistUdated(event:Event):void {
        trace("nest.plist updated");
        getPreviousUsers();
    }

    private static function usersUpdated(event:Event):void {
        trace("updater.usersUpdated()...");
        if (nest._core._nest_db_Sim) {
            dataManager.nest_db = dataManager._nestVirtual_db;
            // contentManager.organize();
            dbUpdate();

        } else {
            connectionManager.contentRequestForUpdate();
        }
    }

    private static function dbUpdated(event:Event):void {
        trace("nest.db updated");
        //Nest._core.dispatchEventWith(NestEvent.NEST_INSTALL, false, {succes: true});
        pre_ddlUpdate();
    }

    private static function onZipOpen(event:Event):void {
        alertManager.Clear();
        alertManager.ShowAlert("EXTRACT", null, "" + _dirName);
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
            nestUpdated();
        } else {
            ddlUpdateLoop();
        }


        //Nest._context.activeScreen.dispatchEventWith(NestEvent.SLIDE_READY,false,{dir:_dirName, files:_slidesFiles});
        //if(_fLoaded == _fToLoad ) nestInstalled();
    }

    private static function onZipComplete(event:Event):void {
        trace("onZipComplete : Done");
        trace("_zip.getFileCount() : " + _zip.getFileCount());
        _zipDone = true;

    }
}
}
