//a
import funkin.game.PlayState;
import funkin.backend.assets.ModsFolder;
import StringTools;
import haxe.Json;
import flixel.ui.FlxBar;
import flixel.text.FlxTextBorderStyle;
import funkin.backend.shaders.CustomShader;
import flixel.group.FlxTypedSpriteGroup;
import flixel.math.FlxMath;

import haxe.io.Path;
import sys.FileSystem;
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
function create() {
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

    stateDisplay();
    levelArt();
    bottomShit();
    menuShit();
    
    ref = new FlxSprite(0,0, Paths.image("References/MainMenuStateNewConcept"));
    ref.setGraphicSize(FlxG.width, FlxG.height);
    ref.screenCenter();
    ref.alpha = 0.1;
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

    if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP) changeSelected(-1);
    if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN) changeSelected(1);
}

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
    "Freeplay", "Challenges", "Shop (wip)"
];
var selectedColor = {bg: 0xFFf1f16c, text: 0xFF9b9b3d};
var notSelectedColor = {bg: 0xFFcaf8c6, text: 0xFF54ad45};

function menuShit() {
    selectItems = new FlxTypedSpriteGroup();
    add(selectItems);

    for (idx in 0...selectableNames.length) {
        var name = selectableNames[idx];

        newItem = new FlxTypedSpriteGroup();
        newItem.ID = idx;
        selectItems.add(newItem);

        var item = new FlxSprite().makeGraphic(400, 115, 0xFFFFFFFF);
        item.ID = 0;
        item.color = (idx == curSel) ? selectedColor.bg : notSelectedColor.bg;
        item.y = 150 + (155*idx);
        item.x = FlxG.width - item.width;
        newItem.add(item);
        
        var text = new FlxText(0,0, item.width, name);
        text.ID = 1;
        text.setFormat(Paths.font("Gobold Extra2.otf"), 64, 0xFFFFFFFF, "center");
        text.x = item.x;
        text.y = item.y - text.height/2 + item.height/2;
        text.color = (idx == curSel) ? selectedColor.text : notSelectedColor.text;
        newItem.add(text);
    }
    changeSelected(0);
}

var curSel:Int = 0;
function changeSelected(hur:Int = 0) {
    curSel += hur;
    if (curSel >= selectableNames.length) curSel = selectableNames.length-1;
    if (curSel < 0) curSel = 0;

    selectItems.forEach(function(item) {
        item.members[0].color = (item.ID == curSel) ? selectedColor.bg : notSelectedColor.bg;
        item.members[1].color = (item.ID == curSel) ? selectedColor.text : notSelectedColor.text;
    });
}








function test() {
    PlayState.loadSong("sighting", "hard", false, false);
    FlxG.switchState(new PlayState());
}

function loadTest(modToLoad:String) {
    for (mod in ModsFolder.getLoadedMods()) {
        var modSplit = mod.split("/");
        var actualMod = modSplit[modSplit.length-1];
        if (actualMod.toLowerCase() == modToLoad.toLowerCase()) return;
    }
    Paths.assetsTree.addLibrary(ModsFolder.loadModLib(ModsFolder.modsPath+modToLoad, modToLoad));
}