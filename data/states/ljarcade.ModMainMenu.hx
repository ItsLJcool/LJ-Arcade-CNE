//a
import funkin.game.PlayState;
import funkin.backend.assets.ModsFolder;
import haxe.Json;
import flixel.ui.FlxBar;
import flixel.text.FlxTextBorderStyle;
import funkin.backend.shaders.CustomShader;
import flixel.graphics.frames.FlxImageFrame;
import flixel.group.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;

import haxe.ds.StringMap;
import haxe.io.Path;
import sys.FileSystem;

import funkin.menus.FreeplayState;
import funkin.menus.FreeplaySonglist;

import sys.FileSystem;
import funkin.backend.chart.Chart;


import StringTools;
import Type;
importScript('LJ Arcade API/tokens');

var ref;

var levelBar:FlxBar;
var levelDropshadow:FlxSprite;

var levelText:FlxText;

var background:FlxTypedSpriteGroup;
/**
    This will contian `Path.image` strings to the file.
**/
var typesOfBGs = [];

var currentState = 0;
function create() {
    
    loadModToLibrary("Treeshot-Funkin"); // testing, remove when done


    initTokens();
    var path = "MainMenu/bgs";
    for (funnies in FileSystem.readDirectory(ModsFolder.modsPath+ModsFolder.currentModFolder+"/images/"+path)) {
        if (Path.extension(funnies) != "png") continue;
        funnies = Path.withoutExtension(funnies);
        typesOfBGs.push(Paths.image(path+"/"+funnies));
    }
    // TODO: In LJ Arcade folder in the mod your in, add those images as well
    // and they can toggle priority on or off, or just disable default and only have mod specific.

    FlxG.mouse.visible = true;
    FlxG.camera.bgColor = 0xFF808080;

    background = new FlxTypedSpriteGroup();
    add(background);
    currentBgID = FlxG.random.int(0, typesOfBGs.length-1);
    for (idx in 0...typesOfBGs.length) {
        var bgs = typesOfBGs[idx];
        var bg = new FlxSprite(0,0, bgs);
        bg.ID = idx;
        bg.setGraphicSize(FlxG.width, FlxG.height);
        bg.screenCenter();
        bg.alpha = (currentBgID == idx) ? 1 : 0.0001;
        background.add(bg);
    }
    cycleBg();

    menuShit();
    freeplayShit();
    
    bottomShit();
    
    stateDisplay();
    levelArt();
    
    ref = new FlxSprite(0,0, Paths.image("References/mainMenuStateV2"));
    ref.setGraphicSize(FlxG.width, FlxG.height);
    ref.screenCenter();
    ref.alpha = 0;
    add(ref);
}

function update(elapsed) {
    if (FlxG.mouse.overlaps(optionIcon)) {
        var sinFunc = 0.75 + (Math.sin(Conductor.songPosition / 175) * 0.25);
        optionIcon.scale.x = optionIcon.scale.y = FlxMath.lerp(optionIcon.scale.x, 1.2, elapsed*10);
        optionIcon.alpha = FlxMath.lerp(optionIcon.alpha, sinFunc, elapsed*10);
    }
    else {
        optionIcon.scale.x = optionIcon.scale.y = FlxMath.lerp(optionIcon.scale.x, 1, elapsed*10);
        optionIcon.alpha = FlxMath.lerp(optionIcon.alpha, 1, elapsed*10);
    }

    if (FlxG.keys.justPressed.P) ref.alpha += 0.1;
    if (FlxG.keys.justPressed.O) ref.alpha -= 0.1;

    if (FlxG.keys.justPressed.ESCAPE) FlxG.switchState(new MainMenuState());

    if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP) {
        switch(currentState) {
            case 1: changeFreeplaySelected(-1);
            default: 
                changeMainMenuSelected(-1);
        }
    }
    if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN) {
        switch(currentState) {
            case 1: changeFreeplaySelected(1);
            default: 
                changeMainMenuSelected(1);
        }
    }

    if (FlxG.keys.justPressed.ENTER) {
        switch(currentState) {
            case 1: enterFreeplaySong();
            default: 
                // changeMainMenuSelected(1);
        }
    }

    if (FlxG.keys.justPressed.T) {
        currentState = (currentState == 0) ? 1 : 0;
    }

    if (FlxG.keys.justPressed.G) {
        removeModFromLibrary("Treeshot-Funkin");
    }
    if (FlxG.keys.justPressed.R) ModsFolder.reloadMods();

}

// lj is blue

var sectionTitle:FlxText;
var currentModText:FlxText;
function stateDisplay() {
    sectionTitle = new FlxText(40,20, 0, "Main Menu");
    sectionTitle.setFormat(Paths.font("Gobold Extra2.otf"), 50, 0xFFFFFFFF, "center", FlxTextBorderStyle.SHADOW, 0xFF000000);
    sectionTitle.borderSize = 2;
    sectionTitle.shadowOffset.x = 0;
    sectionTitle.shadowOffset.y = 3;
    add(sectionTitle);

    currentModText = new FlxText(0,0, 0, "[ModName]");
    currentModText.setFormat(Paths.font("goodbyeDespair.ttf"), 32, 0xFFFFFFFF, "left", FlxTextBorderStyle.SHADOW, 0xFF000000);
    currentModText.borderSize = 2;
    currentModText.shadowOffset.x = 0;
    currentModText.shadowOffset.y = 3;
    currentModText.x = sectionTitle.x + sectionTitle.width + 25;
    currentModText.y = sectionTitle.y + 5;
    add(currentModText);

}

function levelArt() {
    levelBar = new FlxBar(0,0, null, 350, 25, levels, "xp", 0, xpMaxLevels[levels.level]);
    levelBar.x = FlxG.width - levelBar.width - 25;
    levelBar.y += 25;
    levelBar.createGradientBar([0xFFFFFFFF], [0xFF00FF6E, 0xFF00ff42, 0xFF00ff1e], 1, 0);
    
    levelDropshadow = new FlxSprite().makeGraphic(levelBar.width, levelBar.height, 0xFF000000);
    levelDropshadow.setPosition(levelBar.x, levelBar.y + 5);
    add(levelDropshadow);
    add(levelBar);

    levelText = new FlxText(0,0, 0, "Level:  "+levels.level);
    levelText.setFormat(Paths.font("goodbyeDespair.ttf"), 22, 0xFFFFFFFF, "left", FlxTextBorderStyle.SHADOW, 0xFF000000);
    levelText.borderSize = 2;
    levelText.shadowOffset.x = 0;
    levelText.shadowOffset.y = 2;
    levelText.setPosition(levelBar.x, levelBar.y + levelText.height + 10);
    add(levelText);
    

    xpToLevel = new FlxText(0,0, 0, levels.xp+"/"+xpMaxLevels[levels.level]);
    xpToLevel.setFormat(Paths.font("goodbyeDespair.ttf"), 22, 0xFFFFFFFF, "right", FlxTextBorderStyle.SHADOW, 0xFF000000);
    xpToLevel.borderSize = 2;
    xpToLevel.shadowOffset.x = 0;
    xpToLevel.shadowOffset.y = 2;
    xpToLevel.setPosition(levelBar.x + levelBar.width - xpToLevel.width, levelBar.y + levelText.height + 10);
    add(xpToLevel);
}

var bottomBar:FlxSprite;
var line:FlxSprite;

var glow:FlxSprite;
var glowShader:CustomShader;

var selectOption:FlxText;
var optionText:FlxText;
var optionIcon:FlxSprite;
function bottomShit() {
    glowShader = new CustomShader("glow");

    bottomBar = new FlxSprite().makeGraphic(FlxG.width, 85, 0xFF000000);
    bottomBar.alpha = 0.8;
    bottomBar.screenCenter();
    bottomBar.y = FlxG.height - bottomBar.height + 1;
    add(bottomBar);

    glow = new FlxSprite().makeGraphic(FlxG.width, 35, 0xFFFFFFFF);
    glow.screenCenter();
    glow.y = bottomBar.y - glow.height;
    glow.shader = glowShader;
    add(glow);

    line = new FlxSprite().makeGraphic(FlxG.width, 3, 0xFFFFFFFF);
    line.screenCenter();
    line.y = bottomBar.y - line.height/2;
    add(line);

    selectOption = new FlxText(0,0, 0, "Select an Option");
    selectOption.setFormat(Paths.font("goodbyeDespair.ttf"), 36, 0xFFFFFFFF, "left");
    selectOption.setPosition(25, bottomBar.y + bottomBar.height/2 - selectOption.height/2);
    add(selectOption);

    optionIcon = new FlxSprite(0,0, Paths.image("MainMenu/optionsIcon"));
    optionIcon.setPosition(FlxG.width - optionIcon.width - 15, bottomBar.y + bottomBar.height/2 - optionIcon.height/2);
    add(optionIcon);

    optionText = new FlxText(0,0, 0, "Options");
    optionText.setFormat(Paths.font("goodbyeDespair.ttf"), 36, 0xFFFFFFFF, "right");
    optionText.setPosition(optionIcon.x - optionText.width - 20, bottomBar.y + bottomBar.height/2 - optionText.height/2);
    add(optionText);
}

var cycleTimer:FlxTimer = new FlxTimer();
/**
    @param time [Int] - `Default: 15s` | how fast the background cycles, calling it will reset its current timer and start new.
**/
var currentBgID = 0;
function cycleBg(?time:Int = 15) {
    if (time == null) time = 15;
    
    var cancelNextCycle = false;
    if (cycleTimer.active) {
        cycleTimer.cancel();
        cancelNextCycle = true;
        cycleBg(time);
        return;
    }

    cycleTimer.start(time, function(tmr) {
        if (typesOfBGs.length == 1) return;
        var newBgId = FlxG.random.int(0, typesOfBGs.length-1, [currentBgID]);
        var spr = background.members[newBgId]; // backup in case it doesn't set
        background.forEach(function(bg) { if (bg.ID == newBgId) spr = bg; });
        background.remove(spr, true);
        background.add(spr);
        FlxTween.tween(spr, {alpha: 1}, 1.5, {ease: FlxEase.quadInOut, onComplete: function() {
            background.forEach(function(bg) { if (bg.ID == currentBgID) bg.alpha = 0.0001; });
            if (!cancelNextCycle) cycleBg(time);
            currentBgID = newBgId;
        }});
    });
}

var selectItems:FlxTypedSpriteGroup;

var selectableNames = [
    "Freeplay", "Challenges", "Shop"
];

function menuShit() {
    selectItems = new FlxTypedSpriteGroup();
    add(selectItems);

    for (idx in 0...selectableNames.length) {
        var name = selectableNames[idx];
        
        var text = new FlxSprite(0,0, Paths.image("MainMenu/"+name));
        text.scale.set(0.75, 0.75);
        text.updateHitbox();
        text.x = FlxG.width - text.width - 25;
        text.y = 150*(idx+1);
        selectItems.add(text);
    }
    changeMainMenuSelected(0);
}

var curSel:Int = 0;
var inactive:Array<Bool> = [false, true, true];
function changeMainMenuSelected(hur:Int = 0) {
    if (curSel >= selectableNames.length) curSel = selectableNames.length-1;
    if (curSel < 0) curSel = 0;

    selectItems.forEach(function(item) {
        // if (inactive[item.ID]) {
        //     item.colorTransform.redMultiplier = 0;
        //     item.colorTransform.greenMultiplier = 0;
        //     item.colorTransform.blueMultiplier = 0;
        //     return;
        // }
        // if (item.ID == curSel) {
        //     item.colorTransform.redMultiplier = 0.25;
        //     item.colorTransform.greenMultiplier = 0.5;
        //     item.colorTransform.blueMultiplier = 0.25;
        // } else {
        //     item.colorTransform.redMultiplier = 1;
        //     item.colorTransform.greenMultiplier = 1;
        //     item.colorTransform.blueMultiplier = 1;
        // }
        item.setColorTransform(0.25, 0.5, 0.25);
    });
}

var freeplaySel:Int = 0;
function changeFreeplaySelected(hur:Int = 0) {
    if (freeplayEntering) return;

    shineTimer.cancel();
    songSlideThingy.alpha = 0.0001;
    shineTimer.start(0.5, function() {
        songSlideThingy.alpha = 1;
        songSlideThingy.animation.play("idle", true);
    });
    freeplaySel += hur;
    if (freeplaySel >= songs.length) freeplaySel = 0;
    if (freeplaySel < 0) freeplaySel = songs.length-1;

    if (hur > 0) {
        var firstPos = _cachePos.shift();
        firstPos.y = _cachePos[_cachePos.length - 1].y + 100;
        _cachePos.push(firstPos);
    } else if (hur < 0){
        var lastPos = _cachePos.pop();
        lastPos.y = _cachePos[0].y - 100;
        _cachePos.insert(0, lastPos);
    }
}

var freeplayEntering:Bool = false;
var freeplayAnimTimer:FlxTimer = new FlxTimer();
function enterFreeplaySong() {
    if (freeplayEntering) return;
    CoolUtil.playMenuSFX(1);
    freeplayEntering = true;

    freeplayAnimTimer.start(2.5, function(tmr) {
        loadAndPlaySong(songs[freeplaySel].name, "hard");
    });
    for (idx in 0...songNames.length) {
        var spr = songNames[idx];
        FlxTween.tween(spr, {x: -songTab.width/2}, 0.75, {ease: FlxEase.quadIn, startDelay: 0.15*(idx+1)});
    }
}

var songs = [];

var songTab:FlxSprite;
var songSlideThingy:FlxSprite;
var songNames:Array<FlxText> = [];
var songIcons:Array<HealthIcon> = [];

var shineTimer:FlxTimer = new FlxTimer();
function freeplayShit() {
    
    for (test in _loadedModAssetLibrary) { // just for support ig
        for (s in FileSystem.readDirectory(test.getPath("assets/songs"))) {
            if (Path.extension(s) != "") continue;
            var meta = Chart.loadChartMeta(s, "normal", false);
            songs.push(meta);
        }
    }

    songTab = new FlxSprite(-150,0, Paths.image("Freeplay/songTag"));
    songTab.onDraw = updateSongTab;
    songTab.scale.set(1.25, 1.25);
    songTab.updateHitbox();
    add(songTab);

    songSlideThingy = new FlxSprite();
    songSlideThingy.frames = Paths.getSparrowAtlas("Freeplay/shineLoop");
    songSlideThingy.animation.addByPrefix("idle", "shineLoop", 24, false);
    songSlideThingy.animation.play("idle", true);
    songSlideThingy.color = 0x13CCCCCC;
    songSlideThingy.scale.set(1.25, 1.25);
    songSlideThingy.updateHitbox();
    songSlideThingy.animation.finishCallback = function() {
        songSlideThingy.alpha = 0.0001;
        shineTimer.start(0.5, function() {
            songSlideThingy.alpha = 1;
            songSlideThingy.animation.play("idle", true);
        });
    }
    add(songSlideThingy);

    for (i in 0..._songItems) {
        var text = new FlxText((currentState != 1) ? -FlxG.width : 25, 0, 0, "poggor");
        text.color = 0xFF000000;
        text.alpha = 0.5;
        text.setFormat(Paths.font("goodbyeDespair.ttf"), 36, 0xFF0000000, "left");
        add(text);
        songNames.push(text);
        
        var data = songs[i % songs.length];
        var icon = new HealthIcon(data.icon);
        icon.scale.set(0.65, 0.65);
        icon.updateHitbox();
        icon.offset.x = -5;
        icon.offset.y -= 6;
        songIcons.push(icon);
        add(icon);
    }
    
    _cachePos.resize(_songItems);

    changeFreeplaySelected(0);
}

var _songItems:Int = 11;
var _songCenter:Int = Math.floor(_songItems * 0.5);
var _cachePos:Array<{x:Float, y:Float}> = [for (i in 0..._songItems) {x: ((currentState != 1) ? -FlxG.width : -150 * (i != _songCenter)), y: FlxG.height * 0.5 + 100 * (i - _songCenter), alpha: 1}];
function updateSongTab(sprite:FlxSprite) {
    for (i in 0..._songItems) {
        var songItem = (i - _songCenter) + freeplaySel;
        songItem = ((songItem % songs.length) + songs.length) % songs.length; // this should be a positive modulo.

        var xPos = (!freeplayEntering) ?  -150 * (i != _songCenter) :  -300 * (i != _songCenter);

        if (currentState != 1) xPos = -FlxG.width;

        var elapsedTime = (!freeplayEntering) ? FlxG.elapsed * 8 : FlxG.elapsed * 3;
        if (currentState == 0) elapsedTime = FlxG.elapsed * 0.75;
        _cachePos[i].x = FlxMath.lerp(_cachePos[i].x, xPos, elapsedTime);
        _cachePos[i].y = FlxMath.lerp(_cachePos[i].y, FlxG.height * 0.5 - songTab.height * 0.5 + 100 * (i - _songCenter), FlxG.elapsed * 10);
        
        sprite.x = _cachePos[i].x;
        sprite.y = _cachePos[i].y;

        if (i == _songCenter) {
            songSlideThingy.x = _cachePos[i].x;
            songSlideThingy.y = _cachePos[i].y;
        }

        songIcons[i].x = _cachePos[i].x + songTab.width - 125;
        songIcons[i].y = _cachePos[i].y + songTab.height * 0.5 - songIcons[i].height * 0.5;

        songNames[i].x = FlxMath.lerp(songNames[i].x, (currentState == 1) ? 25 : xPos, elapsedTime);
        songNames[i].y = _cachePos[i].y + songTab.height * 0.5 - songNames[i].height * 0.5;
        songNames[i].text = (songs[songItem].displayName != null) ? songs[songItem].displayName : songs[songItem].name;
        songNames[i].scale.x = Math.min((songTab.width - 200) / songNames[i].frameWidth, 1);
        songNames[i].updateHitbox();

        // this goes LAST!! in the for loop
        sprite.color = songs[songItem].parsedColor;

        if (freeplayEntering) {
            _cachePos[i].alpha = FlxMath.lerp(_cachePos[i].alpha, (i == _songCenter) ? 1 : 0.45, elapsedTime);
            sprite.alpha = songIcons[i].alpha = _cachePos[i].alpha;
            
        }
        sprite.draw();
    }
}