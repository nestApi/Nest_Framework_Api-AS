package managers {
import core.nest;

import events.nestEvent;

import feathers.data.ArrayCollection;

import flash.filesystem.File;

import utils.stringUtils;

public class contentManager {


    private static var _number_of_presentations:uint;
    //private static var _number_of_slides:uint;
    private static var _menuTitle:String;
    private static var _titlesList:Array = [];
    private static var _menuListCollection:ArrayCollection = new ArrayCollection();
    private static var _subTitlesList:Array = [];

    private static var _contentsList:Array = [];
    private static var _typesList:Array = [];

    private static var _slidesFiles:Array = [];

    private static var _dirName:String;
    private static var _mailingList:Array = [];
    private static var _state:String;


    public static function clear():void{
        _number_of_presentations = 0;
        _menuTitle = "";
        _titlesList = [];
        _menuListCollection.removeAll();
        _subTitlesList = [];
        _contentsList = [];
        _typesList = [];
        _slidesFiles = [];
        _dirName = "";
    }


    public static function organize():void {
        trace("ORGANIZING WITH TYPE...");
        //trace("structure length: " + dataManager.nest_db.presentation.length);
        var _ps:Array = dataManager.nest_db.presentation;
        number_of_presentations = _ps.length;
        //number_of_slides = dataManager.nest_db.slide.length;
        menuTitle = dataManager.nest_db.structure[0].title;

       /* trace(" number_of_presentations : " + number_of_presentations);
        trace(" menuTitle : " + menuTitle);*/

        var i:uint;
        for (i = 0; i < number_of_presentations; ++i) {
            _titlesList.push(_ps[i].acf.presentation_generalites_titre);
            _subTitlesList.push(_ps[i].acf.presentation_generalites_soustitre);
            _menuListCollection.push({title: _ps[i].title, text: (_titlesList[i] + " : " + _subTitlesList[i]), id: i /*,ic:stringUtils.filePathFromUrl(_ps[i].acf.cliche_url.icon)*/});

            if (nest._express) {
                _contentsList.push(_ps[i].acf.presentation_url_zip != null ? stringUtils.directoryFromUrl(_ps[i].acf.presentation_url_zip) : "empty");
                _typesList.push(_contentsList[i] != "empty" ? stringUtils.TypeFromDirectory(File.applicationStorageDirectory.resolvePath("Contents/" + _contentsList[i]).getDirectoryListing()) : "empty");

                if (_contentsList[i] != "empty") {
                    switch (_typesList[i]) {
                        case "slideShow":
                            _slidesFiles[i] = slideShowBuilder(_contentsList[i]);
                            break;
                        default:
                            _slidesFiles[i] = [];
                            break
                    }
                } else {
                    _slidesFiles[i] = [];
                }
                //_slidesFiles[i] = _contentsList[i] != "empty" ? slideShowBuilder(_contentsList[i], _typesList[i]) : [];
               /* trace("// ______ EXPRESS MODE");
                trace("_titlesList : " + _titlesList);
                trace("_subTitlesList : " + _subTitlesList);
                trace("_contentsList : " + _contentsList);
                trace("_typesList : " + _typesList);
                trace("_slidesFiles : " + _slidesFiles);
                trace("// ______ ");*/
            } else {
                _contentsList.push(_ps[i].acf);
                /*trace("// ______ CLASSIC MODE");
                trace("_titlesList : " + _titlesList);
                trace("_subTitlesList : " + _subTitlesList);
                trace("_contentsList : " + _contentsList);*/
            }
        }
        nest._core.dispatchEventWith(nestEvent.APP_READY);
    }

    private static function slideShowBuilder(contentsListElement:String):Array {
        trace("slideShowBuilder()...");
        var A:Array = [];
        var tmp:Array = File.applicationStorageDirectory.resolvePath("Contents/" + contentsListElement).getDirectoryListing();
        var subTmp:Array;
        var f:File;
        var sf:File;
        for each (f in tmp) {
            trace("f.name : " + f.name + " / f.isDirectory :" + f.isDirectory)
            if (!f.isDirectory) {
                A.push(f)
            } else {
                subTmp = f.getDirectoryListing();
                for each (sf in subTmp) {
                    A.push(sf)
                }
            }
        }
        return A;
    }

    public static function builtSlide():void {

        /*var f:File = File.applicationStorageDirectory.resolvePath("Contents/");
        var l:Array = f.getDirectoryListing();

        for (var i:uint = 0; i < l.length; ++i) {

            trace(l[i].name + " : " + l[i].size);

        }


       _dirName= contentsList[0].split(".")[0];
        trace("dirName : " + _dirName);
        var dir:File = File.applicationStorageDirectory.resolvePath("Contents/" + _dirName);
        if (!dir.exists) {
            dir.createDirectory();
            trace("dir created");
        }*/
        nest._context.activeScreen.dispatchEventWith(nestEvent.SLIDE_READY, false, {
            dir: _contentsList[nest._current],
            files: _slidesFiles[nest._current]
        });

    }


    public static function get number_of_presentations():uint {
        return _number_of_presentations;
    }

    public static function set number_of_presentations(value:uint):void {
        _number_of_presentations = value;
    }

    /*public static function get number_of_slides():uint {
        return _number_of_slides;
    }

    public static function set number_of_slides(value:uint):void {
        _number_of_slides = value;
    }*/

    public static function get menuTitle():String {
        return _menuTitle;
    }

    public static function set menuTitle(value:String):void {
        _menuTitle = value;
    }

    public static function get titlesList():Array {
        return _titlesList;
    }

    public static function get subTitlesList():Array {
        return _subTitlesList;
    }

    public static function get contentsList():Array {
        return _contentsList;
    }

    public static function get typesList():Array {
        return _typesList;
    }

    public static function get slidesFiles():Array {
        return _slidesFiles;
    }

    public static function get menuListCollection():ArrayCollection {
        return _menuListCollection;
    }

    public static function get mailingList():Array {
        return _mailingList;
    }

    public static function set mailingList(value:Array):void {
        _mailingList = value;
    }

    public static function get state():String {
        return _state;
    }

    public static function set state(value:String):void {
        _state = value;
    }
}
}
