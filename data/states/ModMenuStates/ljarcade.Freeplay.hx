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
import funkin.backend.utils.WindowUtils;


import StringTools;
import Type;
import Sys;
import funkin.options.OptionsMenu;

importScript('LJ Arcade API/tokens');

var freeplaySel:Int = (lastSelectedFreeplaySong == null) ? 0 : lastSelectedFreeplaySong;
public function changeFreeplaySelected(hur:Int = 0) {
    if (freeplayEntering) return;
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

    for (i in 0..._songItems) {
        var songItem = (i - _songCenter) + freeplaySel;
        songItem = ((songItem % songs.length) + songs.length) % songs.length; // this should be a positive modulo.

        songIcons[i].setIcon(songs[songItem].icon);
        songIcons[i].updateHitbox();
        if (songs[songItem].icon == "face" || !Assets.exists(Paths.image("icons/"+songs[songItem].icon))) {
            songIcons[i].offset.x = 20;
            songIcons[i].offset.y -= 2;
        }
    }

    var color = songs[freeplaySel].parsedColor;
    var maxColor = Math.max((color >> 16) & 0xFF, Math.max((color >> 8) & 0xFF, color & 0xFF));
    var minColor = Math.min((color >> 16) & 0xFF, Math.min((color >> 8) & 0xFF, color & 0xFF));
    var lightness = (maxColor - minColor) * 0.5;
    var nuhUh = (lightness) * 2;
    songSlideThingy.setColorTransform(nuhUh, nuhUh, nuhUh);
    
    shineTimer.cancel();
    songSlideThingy.alpha = 0.0001;
    shineTimer.start(0.5, function() {
        songSlideThingy.alpha = 0.6;
        songSlideThingy.animation.play("idle", true);
    });
}

var diffSel:Int = 0;
public function changeDifficulty(hur:Int = 0) {
    if (freeplayEntering) return;

    diffSel += hur;
    if (diffSel >= songs[freeplaySel].difficulties.length) diffSel = 0;
    if (diffSel < 0) diffSel = songs[freeplaySel].difficulties.length-1;

    diffSelecter.text = songs[freeplaySel].difficulties[diffSel].toLowerCase();
    diffSelecter.color = switch(diffSelecter.text) {
        case "hard": 0xFFFF0000;
        case "normal": 0xFFFFFF00;
        case "easy": 0xFF00FF00;
        default: 0xFFFFFFFF;
    };
    diffSelecter.updateHitbox();
    diffSelecter.setPosition(FlxG.width/2 - diffSelecter.width/2, bottomBar.y + bottomBar.height/2 - diffSelecter.height/2);
    for (i in 0...arrowSelectors.length) {
        var spr = arrowSelectors[i];
        var x = (i > 0) ? diffSelecter.x - spr.width - 20 : diffSelecter.x + diffSelecter.width + 20;
        spr.setPosition(x, bottomBar.y + bottomBar.height/2 - spr.height/2);

        if (songs[freeplaySel].difficulties.length == 1) spr.alpha = 0.0001;
    }
}

var freeplayEntering:Bool = false;
var freeplayAnimTimer:FlxTimer = new FlxTimer();
public function enterFreeplaySong() {
    if (freeplayEntering) return;
    CoolUtil.playMenuSFX(1);

    lastSelectedFreeplaySong = freeplaySel;
    freeplayEntering = true;

    freeplayAnimTimer.start(3.5, function(tmr) {
        loadAndPlaySong(songs[freeplaySel].name, songs[freeplaySel].difficulties[diffSel]);
    });
    for (idx in 0...songNames.length) {
        var spr = songNames[idx];
        FlxTween.tween(spr, {x: -songTab.width/2 + 150}, 0.75, {ease: FlxEase.quadIn, startDelay: 0.15*(idx+1)});
    }
}

var songTab:FlxSprite;
var songSlideThingy:FlxSprite;
var songNames:Array<FlxText> = [];
var songIcons:Array<HealthIcon> = [];

var shineTimer:FlxTimer = new FlxTimer();

var songs = [];
public function freeplayShit() {
    for (test in _loadedModAssetLibrary) { // just for support ig
        for (s in FileSystem.readDirectory(test.getPath("assets/songs"))) {
            if (Path.extension(s) != "") continue;
            var meta = Chart.loadChartMeta(s, "normal", false);
            songs.push(meta);
        }
    }

    songTab = new FlxSprite(-150, 0, Paths.image("Freeplay/songTag"));
    songTab.onDraw = updateSongTab;
    songTab.scale.set(1.25, 1.25);
    songTab.updateHitbox();
    add(songTab);

    songSlideThingy = new FlxSprite();
    songSlideThingy.frames = Paths.getSparrowAtlas("Freeplay/shineLoop");
    songSlideThingy.animation.addByPrefix("idle", "shineLoop", 24, false);
    songSlideThingy.animation.play("idle", true);
    songSlideThingy.color = 0xFFFFFFFF;
    
    songSlideThingy.scale.set(1.25, 1.25);
    songSlideThingy.updateHitbox();
    songSlideThingy.animation.finishCallback = function() {
        songSlideThingy.alpha = 0.0001;
        shineTimer.start(0.5, function() {
            songSlideThingy.alpha = 0.6;
            songSlideThingy.animation.play("idle", true);
        });
    }
    add(songSlideThingy);

    for (i in 0..._songItems) {
        var text = new FlxText((currentState != 1) ? -FlxG.width : 25, 0, 0, "poggor");
        text.antialiasing = true;
        text.color = 0xFF000000;
        text.alpha = 0.5;
        text.setFormat(Paths.font("goodbyeDespair.ttf"), 36, 0xFF0000000, "left");
        add(text);
        songNames.push(text);
        
        var data = songs[i % songs.length];
        var icon = new HealthIcon(data.icon);
        icon.scale.set(0.65, 0.65);
        icon.updateHitbox();
        if (data.icon == "face" || !Assets.exists(Paths.image("icons/"+data.icon))) {
            icon.offset.x = 20;
            icon.offset.y -= 2;
        }
        songIcons.push(icon);
        add(icon);
    }
    
    _cachePos.resize(_songItems);

    changeFreeplaySelected(0);
}

var _songItems:Int = 11;
var _songCenter:Int = Math.floor(_songItems * 0.5);
var _cachePos:Array<{x:Float, y:Float}> = [for (i in 0..._songItems) {x: ((currentState != 1) ? -FlxG.width : -150 * (i != _songCenter)), y: FlxG.height * 0.5 + 100 * (i - _songCenter), alpha: 1}];
public function updateSongTab(sprite:FlxSprite) {
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
        songIcons[i].y = _cachePos[i].y + songTab.height * 0.25 - songIcons[i].height * 0.25;

        songNames[i].scale.x = Math.min((songTab.width - 200) / songNames[i].frameWidth, 1);
        songNames[i].updateHitbox();
        
        songNames[i].x = FlxMath.lerp(songNames[i].x, (currentState == 1 && !freeplayEntering) ? 25 : xPos, elapsedTime);
        songNames[i].y = _cachePos[i].y + songTab.height * 0.5 - songNames[i].height * 0.5;
        songNames[i].text = (songs[songItem].displayName != null) ? songs[songItem].displayName : songs[songItem].name;

        sprite.color = songs[songItem].parsedColor;
        if (freeplayEntering) {
            _cachePos[i].alpha = FlxMath.lerp(_cachePos[i].alpha, (i == _songCenter) ? 1 : 0.45, elapsedTime);
            sprite.alpha = songIcons[i].alpha = _cachePos[i].alpha;
            
        }
        // this goes LAST!! in the for loop
        sprite.draw();
    }
}