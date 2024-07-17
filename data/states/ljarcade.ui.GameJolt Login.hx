//a
import Type;
import funkin.backend.assets.ModsFolder;
import haxe.io.Path;
import sys.FileSystem;

import funkin.editors.ui.UIState;
import funkin.editors.ui.UITextBox;
import funkin.editors.ui.UIButton;
import funkin.editors.ui.UIText;
import funkin.editors.ui.UIUtil;
import funkin.editors.ui.UIWindow;
import funkin.editors.ui.UIScrollBar;

import funkin.backend.shaders.CustomShader;

import openfl.desktop.Clipboard; // paste for UITextBox is broken

import flixel.group.FlxTypedGroup;
import flixel.group.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;

// REDO THE GAMEJOLT API CODE TO WORK WITH NEW API
// importScript("Temp GameJolt API/gamejolt test");
importScript("LJ Arcade API/LoadImageURL");
var typesOfBGs = [];

var userIcon:FlxSprite;

var bg:FlxSprite;
var gamejoltIconName:FlxSprite;
var grayscaleShader:CustomShader;

var usernameBox:UITextBox;

var tokenBox:UITextBox;
var tokenHiddenText:UIText;

var loginButton:UIButton;
var logOutButton:UIButton;

var gamejoltUserAvitar:FlxSprite;

var gamejoltCamera:FlxCamera;
function create() {
    grayscaleShader = new CustomShader("ljarcade.greenscale");
    if (FlxG.sound.music == null) CoolUtil.playMusic(Paths.music("logInState"), true, 1, true, 100);

    FlxG.camera.bgColor = 0xFF808080;

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
    
    usernameBox = new UITextBox(0,0, usernameInput, FlxG.width/4, 45, false);
    usernameBox.screenCenter();
    usernameBox.x -= usernameBox.bWidth/2; // we love not centering properly so fuck you
    usernameBox.y -= usernameBox.bHeight*2 - 5; // we love not centering properly so fuck you
    add(usernameBox);
    usernameBox.onChange = function(text:String) { usernameInput = text; };
    usernameBox.autoAlpha = false;
    
    tokenBox = new UITextBox(0,0, tokenInput, usernameBox.bWidth, usernameBox.bHeight, false);
    tokenBox.setPosition(usernameBox.x, usernameBox.y + usernameBox.bHeight + tokenBox.bHeight/2);
    add(tokenBox);
    tokenBox.onChange = function(text:String) {
        tokenInput = text;
    };
    tokenBox.autoAlpha = false;

    tokenHiddenText = new UIText(tokenBox.x, tokenBox.y, tokenBox.bWidth, "");
    tokenHiddenText.alpha = 1;
    add(tokenHiddenText);

    loginButton = new UIButton(0, 0, "Login To GameJolt", onLoginGameJolt, usernameBox.bWidth/2, usernameBox.bHeight*0.9);
    loginButton.setPosition(tokenBox.x + tokenBox.bWidth/2 - tokenBox.bWidth/4, tokenBox.y + tokenBox.bHeight*2 + tokenBox.bHeight);
    add(loginButton);
    loginButton.autoAlpha = false;
    
    logOutButton = new UIButton(0, 0, "Log Out Of GameJolt", function() {
        GameJolt.username = "";
        GameJolt.token = "";
        usingGameJolt = false;
    }, loginButton.bWidth, loginButton.bHeight);
    logOutButton.setPosition(tokenBox.x + tokenBox.bWidth/2 - tokenBox.bWidth/4, tokenBox.y + tokenBox.bHeight*2 + tokenBox.bHeight);
    logOutButton.y += loginButton.bHeight*1.5;
    add(logOutButton);
    logOutButton.autoAlpha = false;

    profileWindow = new UIWindow(0,0, 450, FlxG.height*0.75, "GameJolt Profile");
    profileWindow.y = FlxG.height/2 - profileWindow.bHeight/2;
    profileWindow.x = 5;
    profileWindow.titleSpr.y = profileWindow.y + ((30 - profileWindow.titleSpr.height) / 2);
    profileWindow.titleSpr.x = profileWindow.x + (profileWindow.bWidth / 2) - profileWindow.titleSpr.width/4 + 30;
    add(profileWindow);
    
    gamejoltCamera = new FlxCamera(profileWindow.x, profileWindow.y+profileWindow.bHeight*0.35, profileWindow.bWidth, profileWindow.bHeight*0.65);
    // gamejoltCamera.bgColor = 0x66FF0000;
    gamejoltCamera.bgColor = 0;
    FlxG.cameras.add(gamejoltCamera, false);

    allTrophies = new FlxTypedSpriteGroup();
    allTrophies.cameras = [gamejoltCamera];
    add(allTrophies);
    
    
    var userData = GameJolt.get("users", [{name: "username", value: GameJolt.username}]);
    if (userData.response.success == "true") {
        gamejoltUserAvitar = new FlxSprite();
        gamejoltUserAvitar.antialiasing = true;
        gamejoltUserAvitar.width = gamejoltUserAvitar.height = 100;
        gamejoltUserAvitar.setPosition(profileWindow.x + gamejoltUserAvitar.width*0.25, (profileWindow.y + 30) + gamejoltUserAvitar.height*0.15);
        urlImage(userData.response.users[0].avatar_url, gamejoltUserAvitar, function(bitmap) {
            gamejoltUserAvitar.setGraphicSize(100, 100);
            gamejoltUserAvitar.updateHitbox();
            gamejoltUserAvitar.setPosition(profileWindow.x + gamejoltUserAvitar.width*0.25, (profileWindow.y + 30) + gamejoltUserAvitar.height*0.15);
        });
        add(gamejoltUserAvitar);
    }
    
    var userTrophies = GameJolt.get("trophies", [{name: "username", value: GameJolt.username}, {name: "user_token", value: GameJolt.token},]);
    trace(userTrophies.response.success);
    if (userTrophies.response.success == "true") {
        for (idx in 0...userTrophies.response.trophies.length) {
            var item = userTrophies.response.trophies[idx];
            addTrophy(item.image_url, idx);
        }
    }

}

var profileWindow:UIWindow;

var maxWidth:Int = 4;
var offsetTrophy:Float = 50;
var yOffset:Float = 30;

var allTrophies:FlxTypedSpriteGroup;
function addTrophy(url:String, idx) {
    var trophy = new FlxSprite().makeGraphic(75, 75, 0xFFFFFFFF);
    trophy.ID = idx;
    trophy.x = (trophy.width + 15)*(idx % maxWidth) + offsetTrophy;
    trophy.y = (trophy.height + yOffset)*Std.int(idx / maxWidth) + offsetTrophy;
    trophy.antialiasing = true;
    allTrophies.add(trophy);

    urlImage(url, trophy, function(bitmap) {
        trophy.setGraphicSize(75, 75);
        trophy.updateHitbox();
        
        trophy.x = (trophy.width + 15)*(trophy.ID % maxWidth) + offsetTrophy;
        trophy.y = (trophy.height + yOffset)*Std.int(trophy.ID / maxWidth) + offsetTrophy;
    });
}

var _defaultText:Array<String> = ["Username", "Token"];
var usernameInput:String = "";
var tokenInput:String = "";

var userTyping:Bool = false;
var tokenTyping:Bool = false;
function update(elapsed) {
    if (FlxG.keys.justPressed.ESCAPE) FlxG.switchState(new MainMenuState());

    updateTextBoxPlaceholder(elapsed);
}

function onLoginGameJolt() {
    var _cacheUsername = usernameInput;
    var _cacheToken = tokenInput;

    var userAuth = GameJolt.auth(_cacheUsername, _cacheToken);
    trace("Auth: "+userAuth.response.success);
    if (userAuth.response.success == "true" || userAuth.response.success == true) {
        GameJolt.username = _cacheUsername;
        GameJolt.token = tokenInput;
        usingGameJolt = true;
    } else {
        GameJolt.username = "";
        GameJolt.token = "";
        FlxG.save.data.GameJoltUsername = FlxG.save.data.GameJoltToken = null;
        usingGameJolt = false;
    }
    
}

function updateTextBoxPlaceholder(elapsed) {
    tokenHiddenText.setPosition(tokenBox.x, tokenBox.y);
    
    var off = (tokenBox.multiline) ? 4 : ((tokenBox.bHeight - tokenBox.label.height) / 2);
    UIUtil.follow(tokenHiddenText, tokenBox, tokenBox.label.autoSize ? (tokenBox.bWidth - tokenBox.label.textField.width)/2 : 4, off);
    
    if (usernameBox.focused && FlxG.keys.justPressed.V && FlxG.keys.pressed.CONTROL) {
        var data:String = Clipboard.generalClipboard.getData(2);
        if (data != null) {
            usernameBox.label.text = data;
            usernameBox.position = data.length;
        }
    }
    
    if (tokenBox.focused && FlxG.keys.justPressed.V && FlxG.keys.pressed.CONTROL) {
        var data:String = Clipboard.generalClipboard.getData(2);
        if (data != null) {
            tokenBox.label.text = data;
            tokenBox.position = data.length;
        }
    }
    
    if (usernameBox.label.text == "" && !usernameBox.focused) {
        userTyping = false;
        usernameBox.label.text = _defaultText[0];
        usernameBox.label.alpha = 0.3;
    } else if (usernameBox.focused && usernameBox.label.text != "" && !userTyping) {
        userTyping = true;
        usernameBox.label.text = "";
        usernameBox.label.alpha = 1;
    }
    
    if (tokenBox.label.text == "" && tokenHiddenText.text != "") tokenHiddenText.text = "";
    if (tokenBox.label.text == "" && !tokenBox.focused) {
        tokenTyping = false;
        tokenBox.label.text = _defaultText[1];
        tokenBox.label.alpha = 0.3;
    } else if (tokenBox.focused && tokenBox.label.text != "") {
        if (!tokenTyping) {
            tokenTyping = true;
            tokenBox.label.text = "";
            tokenBox.label.alpha = 0;
        }
        var newText = "";
        for (i in 0...tokenBox.label.text.length) newText += "*";
        tokenHiddenText.text = newText;
    }

    loginButton.shouldPress = ((!usernameBox.focused && !tokenBox.focused) && !usingGameJolt);
    loginButton.alpha = FlxMath.lerp(loginButton.alpha, (loginButton.shouldPress) ? 1 : 0.25, elapsed*5);
    loginButton.field.alpha = loginButton.alpha;
    
    logOutButton.shouldPress = (usingGameJolt);
    logOutButton.alpha = FlxMath.lerp(logOutButton.alpha, (logOutButton.shouldPress) ? 1 : 0.25, elapsed*5);
    logOutButton.field.alpha = logOutButton.alpha;
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