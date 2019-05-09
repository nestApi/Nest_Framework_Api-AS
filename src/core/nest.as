package core {
import events.nestEvent;

import feathers.core.StackScreenNavigatorApplication;
import feathers.motion.Slide;

import managers.alertManager;
import managers.connectionManager;
import managers.contentManager;
import managers.dataManager;
import managers.installer;
import managers.installerExpress;
import managers.updater;
import managers.updaterExpress;

import starling.core.Starling;
import starling.events.Event;
import starling.events.EventDispatcher;

[Event(name="connectionEval", type="events.nestEvent")]
[Event(name="dataEval", type="events.nestEvent")]

public class nest extends EventDispatcher {

    public static var _core:nest;
    public static var _context:StackScreenNavigatorApplication;
    public static var _current:uint = 0;

    public static var _nestServer:String;
    public static var _onLineTestServer:String;
    public static var _skipUpdateDetection:Boolean;

    /* MODES */
    public static var _onLineMode:Boolean;
    public static var _express:Boolean;
    public static var _anonymousMode:Boolean;
    public static var _liveUpdateMode:Boolean;
    public static var _fieldsWithDdl:Array;

    /* DATAS */

    /**
     *
     * @param server
     * @param userMode authentification via login ou anonyme
     * @param debugModes simulateurs:  onLineSimu, offLineSimu, firstRunSimu
     *
     */
    //public function Nest(nestServer:String = "http://d001.nest-api.com", onLineTestServer:String = "https://duckduckgo.com", fieldsWithDdl:Array = null, anonymousMode:Boolean = true, debugModes:Object = null, virtual_db:Object = null) {
    public function nest(config:Object, debugModes:Object = null, virtual_db:Object = null) {

        super();
        trace("nest_initialisation 1.0");

        _core = this;

        _onLineTestServer = config.onLineTestServer;
        _nestServer = config.nestServer;

        _anonymousMode = config.anonymousMode;
        _express = config.express;
        _liveUpdateMode = config.liveUpdate != null ? config.liveUpdate : false;
        _fieldsWithDdl = config.fieldsWithDdl != null ? config.fieldsWithDdl : [];

        _firstRunSim = debugModes ? debugModes.firstRunSimu : false;
        _onLineModeSim = debugModes ? debugModes.onLineSimu : false;
        _offLineModeSim = debugModes ? debugModes.offLineSimu : false;
        _updateSim = debugModes ? debugModes.updateSim : false;
        _nest_db_Sim = debugModes ? debugModes.nest_db_Simu : false;

        dataManager._nestVirtual_db = virtual_db != null ? virtual_db : {};

        init();
    }

    public var _asData:Boolean;
    public var _liveUpdateIsActive:Boolean = false;
    public var _updateSim:Boolean;
    public var _nest_db_Sim:Boolean;
    /*SIMULATION*/
    private var _firstRunSim:Boolean;
    private var _onLineModeSim:Boolean;

    /*---------*/
    private var _offLineModeSim:Boolean;


    //------------ START OF INIT PROCESS
    private function init():void {
        trace("init() : " + "context : " + _context);
        alertManager.ShowAlert("LAUNCH");
        addEventListener(nestEvent.CONNECTION_EVAL, connectionHandler);
        connectionManager.eval();
    }

    private function retry():void {
        _onLineMode = null;
        //init();
    }

    private function updateDetection(event:Event, data:Object):void {

        _skipUpdateDetection = data.id == 0 ? true : false;
        getStockPlist()

    }

    //------------ END OF INIT PROCESS
    

    private function getStockPlist():void {
        addEventListener(nestEvent.PLIST_COMPLETE, plistCompleteHandler);
        dataManager.getLocalPlist()
    }

    private function updateSelection(event:Event, data:Object):void {

        if (data.id == 0) {
            dataManager.getLocal_db();
        } else {
            addEventListener(nestEvent.NEST_UPDATE, nestUpdateHandler);
            _express ? updaterExpress.Init() : updater.Init();
        }
    }

    //------------ START OF INSTALL PROCESS
    private function authenticationInstall():void {
        trace("authenticationInstall()");
        addEventListener(nestEvent.AUTHENTICATION, authenticationInstallHandler);
        dataManager.user = {
            login: connectionManager._default_login,
            pass: connectionManager._default_pass,
            remember_me: connectionManager._default_remember_me
        };
        connectionManager.authentication();
    }

    private function nestInstall():void {
        trace("Nest.nestInstall()...");
        addEventListener(nestEvent.NEST_INSTALL, nestInstallHandler);
        _express ? installerExpress.Init() : installer.Init();
    }

    private function liveUpdateLoop():void {
        trace("liveUpdateLoop...");
        getStockPlist()
    }

    private function connectionHandler(event:Event):void {
        trace("event.data._state : " + event.data._state);
        alertManager.Clear();
        removeEventListener(nestEvent.CONNECTION_EVAL, connectionHandler);
        _context = Starling.current.root as StackScreenNavigatorApplication;
        if (_offLineModeSim == true) {
            _onLineMode = false;

        } else if (_onLineModeSim == true) {
            _onLineMode = false;
        } else {
            _onLineMode = event.data._state;
        }
        trace("_isConnected : " + _onLineMode + "/ _offLineModeSim : " + _offLineModeSim + " / _onLineModeSim : " + _onLineModeSim);
        addEventListener(nestEvent.DATA_EVAL, dataEvalHandler);
        dataManager.eval(_firstRunSim);
    }

    private function dataEvalHandler(event:Event):void {
        removeEventListener(nestEvent.DATA_EVAL, dataEvalHandler);
        _asData = event.data.d;
        trace("_asData :" + _asData);
        if (!_asData && !_onLineMode) {
            alertManager.ShowAlert("INSTALL_FAILED", retry);
        } else if (_asData && !_onLineMode) {
            alertManager.ShowAlert("OFFLINE_CONNECTION", getStockPlist);
        } else if (!_asData && _onLineMode) {
            alertManager.ShowAlert("FIRST_LAUNCH", authenticationInstall);
        } else if (_asData && _onLineMode) {
            alertManager.ShowAlert("CHECK_UPDATE", updateDetection);
        }
    }

    private function plistCompleteHandler(event:Event):void {
        removeEventListener(nestEvent.PLIST_COMPLETE, plistCompleteHandler);
        trace("plistCompleteHandler()...");
        dataManager.setUserFromLocalPlist();
        addEventListener(nestEvent.AUTHENTICATION, authenticationHandler);
        connectionManager.authentication();

    }

    private function authenticationHandler(event:Event):void {
        trace("authenticationHandler()");
        removeEventListener(nestEvent.AUTHENTICATION, authenticationHandler);
        if (_skipUpdateDetection) {
            addEventListener(nestEvent.DB_COMPLETE, dbCompleteHandler);
            dataManager.getLocal_db();
        } else {
            //var updatable:Boolean = !_onLineMode ? false : (dataManager.plist.lastUpdate !== connectionManager.authResultObject.lastpostdate);
            var updatable:Boolean;

            if (!_onLineMode) {
                updatable = false;
            } else {

                trace("_updateSim : " + _updateSim);

                if (_updateSim) {
                    updatable = true;
                } else {
                    updatable = dataManager.plist.lastUpdate !== connectionManager.authResultObject.lastpostdate;
                }
            }
            trace(" UPDATE NEEDED : " + updatable);

            if (updatable) {
                if (_liveUpdateIsActive) {
                    trace("LIVE UPDATE PROCESS");
                    Starling.juggler.removeDelayedCalls(liveUpdateLoop);
                    contentManager.clear();
                    addEventListener(nestEvent.NEST_UPDATE, nestUpdateHandler);
                    _express ? updaterExpress.Init() : updater.Init();
                }else{
                    addEventListener(nestEvent.DB_COMPLETE, dbCompleteHandler);
                    alertManager.ShowAlert("UPDATE", updateSelection);
                }
            } else {
                if (_liveUpdateIsActive) {
                    trace("NO LIVE UPDATE NEEDED")
                } else {
                    addEventListener(nestEvent.DB_COMPLETE, dbCompleteHandler);
                    dataManager.getLocal_db();
                }
            }

        }

    }

    private function nestUpdateHandler(event:Event):void {
        removeEventListener(nestEvent.NEST_UPDATE, nestUpdateHandler);
        trace("Nest Update : " + event.data.succes);
        addEventListener(nestEvent.APP_READY, nestReady);
        contentManager.organize();
    }

    private function dbCompleteHandler(event:Event):void {
        removeEventListener(nestEvent.DB_COMPLETE, dbCompleteHandler);
        trace("dbCompleteHandler()");
        addEventListener(nestEvent.APP_READY, nestReady);
        contentManager.organize();
    }

//------------ END OF INSTALL PROCESS

    private function authenticationInstallHandler(event:Event):void {
        trace("authenticationInstallHandler()");
        removeEventListener(nestEvent.AUTHENTICATION, authenticationInstallHandler);
        nestInstall()
    }

    private function nestInstallHandler(event:Event):void {
        removeEventListener(nestEvent.NEST_INSTALL, nestInstallHandler);
        trace("Nest Installed : " + event.data.succes);
        addEventListener(nestEvent.APP_READY, nestReady);
        contentManager.organize();
    }

    private function nestReady(event:Event):void {
        trace("NEST IS READY ");
        if (_liveUpdateIsActive){
            nest._current = 0;
            _context.pushScreen("cliche", null, Slide.createSlideLeftTransition());
        }else{
            _context.activeScreen.dispatchEventWith(Event.COMPLETE);
        }

        if (_liveUpdateMode && _onLineMode) {
            initLiveUpdate();
        }
    }

    /* LIVE UPDATE PROCESS */
    public function initLiveUpdate():void {
        _skipUpdateDetection = false;
        _liveUpdateIsActive = true;
        Starling.juggler.repeatCall(liveUpdateLoop, 15);
    }
}
}
