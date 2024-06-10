//a
import haxe.io.Path;
import openfl.display.BitmapData;

/**
    @param urlString [String] - The URL which the game will load into a Bitmap
    Returns BitmapData

    `How to add to your sprite:`
    urlImage(url).onComplete(function(bitmap) {
        add(new FlxSprite().loadGraphic(bitmap));
    });
**/

public function urlImage(urlString:String, onComplete:BitmapData->Void) {
    urlString = Path.withoutExtension(urlString)+".png"; // Force to .png, if URL doesn't accept than we cannot load the image, sowwy
    
    return BitmapData.loadFromFile(urlString).onError(function(error) {
        trace("Error Loading " + urlString + " | Error: " + error);
    }).onComplete(onComplete);
}