//a
import funkin.backend.assets.ModsFolder;
import haxe.io.Path;
import sys.FileSystem;

import funkin.editors.ui.UIState;
import funkin.editors.ui.UITextBox;

import funkin.backend.shaders.CustomShader;
importScript("Temp GameJolt API/gamejolt test");
importScript("LJ Arcade API/LoadImageURL");
var typesOfBGs = [];

var userIcon:FlxSprite;

var bg:FlxSprite;
var gamejoltIconName:FlxSprite;
var grayscaleShader:CustomShader;
function create() {
    grayscaleShader = new CustomShader("ljarcade.greenscale");

    FlxG.camera.bgColor = 0xFF808080;
    // var killme = GameJolt.get("users", [{name: "username", value: GameJolt.username}]);
    // // trace(killme.response.users[0].avatar_url);
    // urlImage(killme.response.users[0].avatar_url, function(bitmap) {
    //     userIcon = new FlxSprite().loadGraphic(bitmap);
    //     userIcon.screenCenter();
    //     add(userIcon);
    // });

    var path = "ModMenu/bgs";
    for (funnies in FileSystem.readDirectory(ModsFolder.modsPath+ModsFolder.currentModFolder+"/images/"+path)) {
        if (Path.extension(funnies) != "png") continue;
        funnies = Path.withoutExtension(funnies);
        typesOfBGs.push(Paths.image(path+"/"+funnies));
    }

    bg = new FlxSprite(0,0, typesOfBGs[FlxG.random.int(0, typesOfBGs.length-1)]);
    bg.setGraphicSize(FlxG.width, FlxG.height);
    bg.updateHitbox();
    bg.screenCenter();
    bg.shader = grayscaleShader;
    add(bg);

    gamejoltIconName = new FlxSprite(0,0, Paths.image("gamejolt/gamejolt icon name"));
    gamejoltIconName.setGraphicSize(450, gamejoltIconName.width/4);
    gamejoltIconName.updateHitbox();
    gamejoltIconName.setPosition(FlxG.width - gamejoltIconName.width - 10, -50);
    add(gamejoltIconName);
    
    textBoxTest = new UITextBox(0,0, "input", FlxG.width/8, 75, false);
    textBoxTest.screenCenter();
    textBoxTest.x -= textBoxTest.label.width/2; // we love not centering properly so fuck you
    add(textBoxTest);
}

function update(elapsed) {
    if (FlxG.keys.justPressed.ESCAPE) FlxG.switchState(new MainMenuState());
}
// { response => 
// { users =>
// [{ developer_name => ItsLJcool,
//     last_logged_in_timestamp => 1717967151, 
//     last_logged_in => 15 minutes ago, 
//     avatar_url => https://m.gjcdn.net/user-avatar/60/5874107-2dvg9hnh-v4.webp, 
//     status => Active, 
//     type => Developer, 
//     id => 5874107, 
//     signed_up_timestamp => 1630799253, 
//     developer_website => , 
//     username => ItsLJcool, 
//     signed_up => 2 years ago, 
//     developer_description => I am 15, I want to become a game maker :gj/innocent: }], 
//     success => true } 
// }