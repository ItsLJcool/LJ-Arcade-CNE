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
import funkin.backend.utils.WindowUtils;


import StringTools;
import Type;
import Sys;
import funkin.options.OptionsMenu;
importScript('LJ Arcade API/tokens');

public var levelBar:FlxBar;
public var levelDropshadow:FlxSprite;

public var levelText:FlxText;

public var background:FlxTypedSpriteGroup;
/**
    This will contian `Path.image` strings to the file.
**/
public var typesOfBGs = [];

public var currentState = (_fromFreeplay) ? 1 : 0;

public var soon:FlxText;
public var args = __customArgs;

function update(elapsed) {
    
    if (FlxG.mouse.overlaps(optionIcon)) {
        if (FlxG.mouse.justPressed) FlxG.switchState(new OptionsMenu());
        var sinFunc = 0.75 + (Math.sin(Conductor.songPosition / 175) * 0.25);
        optionIcon.scale.x = optionIcon.scale.y = FlxMath.lerp(optionIcon.scale.x, 1.2, elapsed*10);
        optionIcon.alpha = FlxMath.lerp(optionIcon.alpha, sinFunc, elapsed*10);
    }
    else {
        optionIcon.scale.x = optionIcon.scale.y = FlxMath.lerp(optionIcon.scale.x, 1, elapsed*10);
        optionIcon.alpha = FlxMath.lerp(optionIcon.alpha, 1, elapsed*10);
    }

    if (FlxG.keys.justPressed.ESCAPE) {
        switch(currentState) {
            case 1: toMainMenu();
            default:
                lastSelectedFreeplaySong = null;
                removeModFromLibrary(args[0]); // testing, remove when done
                _forceMainMenu = true;
                ModsFolder.switchMod(ModsFolder.currentModFolder);
                // FlxG.switchState(new MainMenuState());
        }
    }
    
    if (FlxG.keys.justPressed.D || FlxG.keys.justPressed.RIGHT) {
        switch(currentState) {
            case 1: changeDifficulty(1);
        }
    }
    if (FlxG.keys.justPressed.A || FlxG.keys.justPressed.LEFT) {
        switch(currentState) {
            case 1: changeDifficulty(-1);
        }
    }
    
    if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP) {
        switch(currentState) {
            case 1: changeFreeplaySelected(-1);
            default: changeMainMenuSelected(-1);
        }
    }
    if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN) {
        switch(currentState) {
            case 1: changeFreeplaySelected(1);
            default: changeMainMenuSelected(1);
        }
    }

    if (FlxG.keys.justPressed.ENTER) {
        switch(currentState) {
            case 1: enterFreeplaySong();
            default: enterMainMenu();
        }
    }

    if (FlxG.keys.justPressed.R) ModsFolder.reloadMods();

}

// lj is blue // srt grrr

public var sectionTitle:FlxText;
public var currentModText:FlxText;
function stateDisplay() {
    sectionTitle = new FlxText(40,20, 0, "Main Menu");
    sectionTitle.setFormat(Paths.font("Gobold Extra2.otf"), 50, 0xFFFFFFFF, "center", FlxTextBorderStyle.SHADOW, 0xFF000000);
    sectionTitle.borderSize = 2;
    sectionTitle.shadowOffset.x = 0;
    sectionTitle.shadowOffset.y = 3;
    add(sectionTitle);

    currentModText = new FlxText(0,0, 0, args[0]);

    currentModText.setFormat(Paths.font("goodbyeDespair.ttf"), 32, 0xFFFFFFFF, "left", FlxTextBorderStyle.SHADOW, 0xFF000000);
    currentModText.borderSize = 2;
    currentModText.shadowOffset.x = 0;
    currentModText.shadowOffset.y = 3;
    currentModText.x = sectionTitle.x + sectionTitle.width + 25;
    currentModText.y = sectionTitle.y + 5;

    currentModText.scale.x = Math.min((150) / currentModText.frameWidth, 1);
    currentModText.updateHitbox();
    add(currentModText);

}

public var rank_data = {
    xp: get_xp(),
    rank: get_rank(),
};
function levelArt() {
    levelBar = new FlxBar(0,0, null, 350, 25, rank_data, "xp", 0, xpMaxLevels[rank_data.rank]);
    levelBar.x = FlxG.width - levelBar.width - 25;
    levelBar.y += 25;
    levelBar.createGradientBar([0xFFFFFFFF], [0xFF00FF6E, 0xFF00ff42, 0xFF00ff1e], 1, 0);
    
    levelDropshadow = new FlxSprite().makeGraphic(levelBar.width, levelBar.height, 0xFF000000);
    levelDropshadow.setPosition(levelBar.x, levelBar.y + 5);
    add(levelDropshadow);
    add(levelBar);

    levelText = new FlxText(0,0, 0, get_rankText());
    levelText.setFormat(Paths.font("goodbyeDespair.ttf"), 22, 0xFFFFFFFF, "left", FlxTextBorderStyle.SHADOW, 0xFF000000);
    levelText.borderSize = 2;
    levelText.shadowOffset.x = 0;
    levelText.shadowOffset.y = 2;
    levelText.setPosition(levelBar.x, levelBar.y + levelText.height + 10);
    add(levelText);
    

    xpToLevel = new FlxText(0,0, 0, rank_data.xp+"/"+xpMaxLevels[rank_data.rank]);
    xpToLevel.setFormat(Paths.font("goodbyeDespair.ttf"), 22, 0xFFFFFFFF, "right", FlxTextBorderStyle.SHADOW, 0xFF000000);
    xpToLevel.borderSize = 2;
    xpToLevel.shadowOffset.x = 0;
    xpToLevel.shadowOffset.y = 2;
    xpToLevel.setPosition(levelBar.x + levelBar.width - xpToLevel.width, levelBar.y + levelText.height + 10);
    add(xpToLevel);
}

public var bottomBar:FlxSprite;
public var line:FlxSprite;

public var glow:FlxSprite;
public var glowShader:CustomShader;

public var selectOption:FlxText;
public var optionText:FlxText;
public var optionIcon:FlxSprite;

public var diffSelecter:FlxText;
public var arrowSelectors:Array<FlxSprite> = [];
function bottomShit() {
    glowShader = new CustomShader("ljarcade.glow");

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

    optionIcon = new FlxSprite(0,0, Paths.image("ModMenu/optionsIcon"));
    optionIcon.setPosition(FlxG.width - optionIcon.width - 15, bottomBar.y + bottomBar.height/2 - optionIcon.height/2);
    add(optionIcon);

    optionText = new FlxText(0,0, 0, "Options");
    optionText.setFormat(Paths.font("goodbyeDespair.ttf"), 36, 0xFFFFFFFF, "right");
    optionText.setPosition(optionIcon.x - optionText.width - 20, bottomBar.y + bottomBar.height/2 - optionText.height/2);
    add(optionText);

    diffSelecter = new FlxText(0,0, 0, "normal");
    diffSelecter.setFormat(Paths.font("goodbyeDespair.ttf"), 36, 0xFFFFFFFF, "center");
    diffSelecter.setPosition(FlxG.width/2 - diffSelecter.width/2, bottomBar.y + bottomBar.height/2 - diffSelecter.height/2);
    diffSelecter.alpha = (currentState == 1) ? 1 : 0.0001;
    add(diffSelecter);

    for (i in 0...2) {
        var spr = new FlxSprite(0,0, Paths.image("Freeplay/ArrowThingie"));
        spr.flipX = (i == 0);
        spr.scale.set(0.8, 0.8);
        spr.updateHitbox();
        var x = (i > 0) ? diffSelecter.x - spr.width : diffSelecter.x + diffSelecter.width;
        spr.setPosition(x, bottomBar.y + bottomBar.height/2 - spr.height/2);
        spr.alpha = 0.0001;
        add(spr);
        arrowSelectors.push(spr);
    }
}

public var cycleTimer:FlxTimer = new FlxTimer();
/**
    @param time [Int] - `Default: 15s` | how fast the background cycles, calling it will reset its current timer and start new.
**/
public var currentBgID = 0;
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

public var selectItems:FlxTypedSpriteGroup;

function menuShit() {
    selectItems = new FlxTypedSpriteGroup();
    add(selectItems);

    for (idx in 0...selectableNames.length) {
        var name = selectableNames[idx];
        
        var text = new FlxSprite(0,0, Paths.image("ModMenu/"+name));
        text.ID = idx;
        text.scale.set(0.75, 0.75);
        text.updateHitbox();
        text.x = FlxG.width - text.width - 25;
        text.y = 150*(idx+1);
        selectItems.add(text);
    }
    if (currentState != 0) selectItems.forEach(function(item) { item.x = FlxG.width + 500; });
    changeMainMenuSelected(0);
}

public var curSel:Int = 0;
public var inactive:Array<Bool> = [false, true, true];
function changeMainMenuSelected(hur:Int = 0) {
    if (enteringMenu) return;
    curSel += hur;
    if (curSel >= selectableNames.length) curSel = selectableNames.length-1;
    if (curSel < 0) curSel = 0;

    selectItems.forEach(function(item) {
        if (inactive[item.ID]) {
            if (item.ID == curSel) item.setColorTransform(0.5, 0.75, 0.5);
            else item.setColorTransform(0.5, 0.5, 0.5);
            return;
        }
        if (item.ID == curSel) item.setColorTransform(0.25, 1, 0.25);
        else item.setColorTransform(1, 1, 1);
    });
}

function toMainMenu() {
    currentState = 0;
        
    enteringMenu = false;
    changeMainMenuSelected(0);
    enteringMenu = true;
    selectItems.forEach(function(item) {
        FlxTween.tween(item, {x: FlxG.width - item.width - 25}, 1, {ease: FlxEase.quadOut, startDelay: 0.1 * (1 - item.ID), onComplete: function() {
            if (item.ID != selectItems.members.length-1) return;
            enteringMenu = false;
        }});
    });
    FlxTween.tween(diffSelecter, {alpha: 0.0001}, 0.75, {ease:FlxEase.quadInOut});
}

public var enteringMenu:Bool = false;
function enterMainMenu() {
    if (enteringMenu || inactive[curSel]) return;
    CoolUtil.playMenuSFX(1);

    enteringMenu = true;
    var item = selectItems.members[curSel];
    new FlxTimer().start(0.075, function(tmr) {
        item.colorTransform.redMultiplier = (tmr.loopsLeft % 2 == 0) ? 1 : 0.25;
        item.colorTransform.blueMultiplier = (tmr.loopsLeft % 2 == 0) ? 1 : 0.25;

        if (tmr.loopsLeft != 0) return;
        
        selectItems.forEach(function(item) {
            FlxTween.tween(item, {x: FlxG.width + 500}, 1, {ease: FlxEase.quadIn, startDelay: 0.1 * (item.ID + 1), onComplete: function() {
                if (item.ID != selectItems.members.length-1) return;
                currentState = (curSel+1);
                endMenuAnimation();
            }});
        });
    }, 10);
}

function endMenuAnimation() {
    switch(selectableNames[curSel].toLowerCase()) {
        case "freeplay":
            changeFreeplaySelected(0);
            FlxTween.tween(diffSelecter, {alpha: 1}, 0.75, {ease:FlxEase.quadInOut});
            return;   
    }
    if (!inactive[curSel]) return;

    FlxTween.tween(soon, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
    new FlxTimer().start(4.5, function() {
        soon.text += "\n\nyou know what fuck you, get fucked idiot!!!11!!!";
        soon.screenCenter();
        new FlxTimer().start(1, function() { Sys.exit(0); });
    });
}

/**
    ModMenuStates
**/
public var selectableNames = [
    "Freeplay", "Challenges", "Shop"
];
for (itm in selectableNames) {
    if (!Assets.exists(Paths.script("data/states/ModMenuStates/ljarcade."+itm))) continue;
    
    importScript("data/states/ModMenuStates/ljarcade."+itm);
}

function new() {
    loadModToLibrary(args[0]); // testing, remove when done
}

function create() {

    var path = "ModMenu/bgs";
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

    soon = new FlxText(0,0, FlxG.width/2 + 200, "Damn, its not ready yet...\n\nwait how did you get here?..\n\nimagine hacking the game (editing hscript)");
    soon.setFormat(Paths.font("goodbyeDespair.ttf"), 32, 0xFFFFFFFF, "center", FlxTextBorderStyle.SHADOW, 0xFF000000);
    soon.borderSize = 2;
    soon.shadowOffset.x = 0;
    soon.shadowOffset.y = 3;
    soon.screenCenter();
    soon.alpha = 0.0001;
    add(soon);
}