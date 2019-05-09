package core {
import starling.core.Starling;
import starling.textures.Texture;

public class nestAssets {


    [Embed(source="/assets/images/NEST-API_Logo_256px.png")]
    private static const NEST_LOGO_DSK:Class;
    private static var nestLogoTextureDsk:Texture;
    public static function get NestLogoTextureDsk():Texture{
        if (!nestLogoTextureDsk){
            nestLogoTextureDsk=Texture.fromBitmap(new NEST_LOGO_DSK(),false,false, Starling.contentScaleFactor );
        }
        return nestLogoTextureDsk;
    }

    [Embed(source="/assets/images/NEST-API_Logo_128px.png")]
    private static const NEST_LOGO_MOB:Class;
    private static var nestLogoTextureMob:Texture;
    public static function get NestLogoTextureMob():Texture{
        if (!nestLogoTextureMob){
            nestLogoTextureMob=Texture.fromBitmap(new NEST_LOGO_MOB(),false,false, Starling.contentScaleFactor );
        }
        return nestLogoTextureMob;
    }
}
}
