package utils {
import flash.filesystem.File;
import flash.filesystem.File;

public class stringUtils {

    public static function isValidEmail(email:String):Boolean {
        var emailExpression:RegExp = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/i;
        return emailExpression.test(email);
    }

    public static function val_for_ddl(Field:*):Boolean {
        var isVal:Boolean = false;
        (Field && Field != undefined && Field != "" && Field != "/") ? isVal = true : isVal = false;
        return isVal;
    }

    public static function nameFromUrl(URL:String):String {
        var urlSplitResult:Array = URL.split("/");
        var urlResult:String = urlSplitResult[urlSplitResult.length - 1];
        return urlResult;
    }

    public static function filePathFromUrl(URL:String):String {
        var urlResult:String = File.applicationStorageDirectory.resolvePath("Contents/" + nameFromUrl(URL)).url;
        return urlResult;
    }

    public static function directoryFromUrl(URL:String):String {
        trace("directoryFromUrl()...");
        trace("URL : " + URL);
        var urlToName:String = nameFromUrl(URL);
        trace("urlToName : " + urlToName);
        return urlToName.split(".")[0];
    }

    public static function TypeFromUrl(URL:String):String {
        trace("TypeFromUrl()...");
        trace("URL : " + URL);
        var urlToName:String = nameFromUrl(URL);
        trace("urlToName : " + urlToName);
        var nameSplit:Array = urlToName.split(".");
        var type:String = nameSplit[nameSplit.length - 1];
        return type;
    }
    public static function pathForAttachment(URL:String):String {
        trace("pathForAttachment()...");
        trace("URL : " + URL);
        var urlSplit:Array = URL.split("wp-content");
        trace("urlSplit @ wp-content : " +urlSplit)
        var path:String = urlSplit[1];
        return path;
    }


    public static function TypeFromDirectory(directoryListing:Array):String {
        var type:String;
        var as_html:Boolean = false;
        var as_pdf:Boolean = false;
        var as_video:Boolean = false;
        for each (var f:File in directoryListing) {
            if(f.name=="index.html") {
                as_html = true;
            } else if (f.name.indexOf("pdf") != -1) {
                as_pdf = true;
            }else if (f.name.indexOf("mp4") != -1) {
                as_video = true;
            }

        }
        type = as_html ? "web" : as_pdf ? "pdf" : as_video ? "movie" : "slideShow";
        return type;
    }
}
}
