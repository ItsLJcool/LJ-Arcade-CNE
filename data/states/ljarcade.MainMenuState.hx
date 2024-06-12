//a
import funkin.backend.system.Controls;
import funkin.backend.assets.ModsFolder;
import funkin.menus.ModSwitchMenu;

import sys.FileSystem;
import haxe.io.Path;

var modsInFolder:Array<String> = [];

var modCardSprite:FlxSprite;

var modNames:Array<FlxText> = [];

var arcadeMachine:FlxSprite;

var iconSpr:FlxSprite;
var bgIconSpr:FlxSprite;

var sideBoxes:Array<FlxSprite> = [];
var arrow:FlxSprite;

function new() {
    for (item in FileSystem.readDirectory(ModsFolder.modsPath)) {
        if (Path.extension(item) != "" || item == ModsFolder.currentModFolder) continue;
        modsInFolder.push(item);
    }
}
function create() {
    FlxG.mouse.visible = true;
    FlxG.camera.bgColor = 0xFF808080;

    iconSpr = new FlxSprite(0,0, Paths.image("ModMenu/bgs/arcadeBG")); // placeholdor
    // iconSpr = new FlxSprite().makeGraphic(200, 200, 0xFF000000); // placeholdor

    bgIconSpr = new FlxSprite().makeGraphic(375, 375, 0xFF000000); // placeholdor
    bgIconSpr.onDraw = function(spr:FlxSprite) {
        spr.setPosition(iconSpr.x, iconSpr.y - 50);
        spr.draw();
    };
    add(bgIconSpr);
    add(iconSpr);
    

    arcadeMachine = new FlxSprite();
    arcadeMachine.frames = Paths.getSparrowAtlas("MainMenu/arcadebox");
    arcadeMachine.animation.addByPrefix("ad", "ADVERTISEMENT0", 24, true);
    arcadeMachine.animation.addByPrefix("shell", "ARCADESHELL0", 24, false);
    arcadeMachine.animation.addByPrefix("transition", "ARCADETRANSITION0", 24, true);
    arcadeMachine.animation.play("transition", true);
    arcadeMachine.scale.set(0.7, 0.7);
    arcadeMachine.updateHitbox();
    arcadeMachine.x = FlxG.width - arcadeMachine.width - 15;
    arcadeMachine.y = FlxG.height - arcadeMachine.height + 100;
    add(arcadeMachine);
    arcadePlay("ad", 0.5, 2);
    
    iconSpr.setGraphicSize(375, 375);
    // iconSpr.scale.set(Math.min(iconSpr.scale.x, iconSpr.scale.y), Math.min(iconSpr.scale.x, iconSpr.scale.y));
    iconSpr.updateHitbox();
    iconSpr.x = arcadeMachine.x + arcadeMachine.width/2 - iconSpr.width/2;
    iconSpr.y = arcadeMachine.y + arcadeMachine.height/2 - iconSpr.height/2 - 75;

    // temp graphic, replace with something cooler pls
    modCardSprite = new FlxSprite().makeGraphic(400, 150, 0xFFFFFFFF);
    modCardSprite.onDraw = cardUpdate;
    modCardSprite.screenCenter();
    add(modCardSprite);

    for (i in 0..._songItems) {
        var text = new FlxText(_cachePos[i].x, _cachePos[i].y, 0, "poggor " + i);
        text.color = 0xFF000000;
        text.alpha = 0.5;
        text.setFormat(Paths.font("goodbyeDespair.ttf"), 36, 0xFF0000000, "center");
        add(text);
        modNames.push(text);
    }
    
    _cachePos.resize(_songItems);


    for (i in 0...2) {
        var spr = new FlxSprite();
        spr.ID = i;
        spr.frames = Paths.getSparrowAtlas("MainMenu/sidebox");
        spr.animation.addByPrefix("idle", "Sidebox instance 1", 24, true);
        spr.animation.play("idle", true);
        spr.scale.set(0.65, 0.65);
        spr.updateHitbox();
        spr.screenCenter();
        spr.flipX = (i > 0);
        
        spr.x = (i == 0) ? -spr.width/1.25: FlxG.width - spr.width/4;
        add(spr);
        sideBoxes.push(spr);
    }

    arrow = new FlxSprite();
    arrow.frames = Paths.getSparrowAtlas("MainMenu/arrowanim");
    arrow.animation.addByPrefix("idle", "arrowanim instance 1", 24, true);
    arrow.animation.play("idle", true);
    arrow.x = FlxG.width - arrow.width - 15;
    arrow.y += 35;
    arrow.angle -= 7.5;
    add(arrow);
}

function arcadePlay(anim, timeTransition:Int = 0.5, other:Int = 0.5) {
    if (timeTransition == null) timeTransition = 0.5;
    if (other == null) other = 0.5;
    if (arcadeMachine.animation.name != "transition") arcadeMachine.animation.play("transition", true);
    new FlxTimer().start(timeTransition, function(tmr) {
        switch(anim) {
            case "ad", 0:
                arcadeMachine.animation.play("ad", true);
                new FlxTimer().start(other, function(tmr) { arcadePlay("mod"); });
            case "mod", 1: arcadeMachine.animation.play("shell", true);
        }
    });
}


var prevSel:Int = 0;
var curSel:Int = 0;
var enteringMod:Bool = false;


var selectionTimer:FlxTimer = new FlxTimer();
var hoveringOverSelTimer:FlxTimer = new FlxTimer();
function changeSelected(hur:Int = 0) {
    if (enteringMod || selectionTimer.active) return;
    
    selectionTimer.start(0.15);
    
    curSel += hur;
    if (curSel >= modsInFolder.length) curSel = 0;
    if (curSel < 0) curSel = modsInFolder.length-1;
    
    if (hur > 0) {
        var firstPos = _cachePos.shift();
        firstPos.y = _cachePos[_cachePos.length - 1].y + 100;
        _cachePos.push(firstPos);
    } else if (hur < 0){
        var lastPos = _cachePos.pop();
        lastPos.y = _cachePos[0].y - 100;
        _cachePos.insert(0, lastPos);
    }
    
    prevSel = curSel;
    hoveringOverSelTimer.start(1, hoveringOverSelectedMod);
}

function enterModState() {
    if (enteringMod && modsInFolder.length < 1) return;
    enteringMod = true;
    
    trace(modsInFolder[curSel]);
    __customArgs = [modsInFolder[curSel]];
    FlxG.switchState(new ModState("ModMainMenu"));
}

function hoveringOverSelectedMod(tmr:FlxTimer) {
    if (prevSel != curSel) return;
    
    arcadePlay("mod");
}

var _songItems:Int = 11;

var angleStep = 2 * (Math.PI / _songItems);
var arcScale = 650;
var offsetPosX = 725;

var _songCenter:Int = Math.floor(_songItems * 0.5);
var _cachePos:Array<{x:Float, y:Float}> = [for (i in 0..._songItems) {x: (offsetPosX-250) + (arcScale * Math.cos(angleStep * (i+0.3))), y: (FlxG.height * 0.5) - (150*1.25) * (i - _songCenter) + 100, alpha: 1}];
function cardUpdate(sprite:FlxSprite) {
    for (i in 0..._songItems) {
        var songItem = (i - _songCenter) + curSel;
        songItem = ((songItem % modsInFolder.length) + modsInFolder.length) % modsInFolder.length; // this should be a positive modulo.
        
        var angle = angleStep * (i+0.3);
        var xPos = arcScale * Math.cos(angle);


        var elapsedTime = FlxG.elapsed * 15;
        _cachePos[i].x = FlxMath.lerp(_cachePos[i].x, offsetPosX + xPos, FlxG.elapsed * 8);
        _cachePos[i].y = FlxMath.lerp(_cachePos[i].y, (FlxG.height * 0.5) - (modCardSprite.height*1.1) * (i - _songCenter) + 100, FlxG.elapsed * 8);
        
        sprite.x = _cachePos[i].x;
        sprite.y = _cachePos[i].y;

        modNames[i].scale.x = Math.min((sprite.width - 15) / modNames[i].frameWidth, 1);
        modNames[i].updateHitbox();
        modNames[i].x = _cachePos[i].x + sprite.width * 0.5 - modNames[i].width * 0.5;
        modNames[i].y = _cachePos[i].y + sprite.height * 0.5 - modNames[i].height * 0.5;
        modNames[i].text = modsInFolder[songItem];

        sprite.draw();
    }
}

function update(elapsed) {
    if (controls.SWITCHMOD) {
        openSubState(new ModSwitchMenu());
        persistentUpdate = false;
        persistentDraw = true;
    }

    if (FlxG.mouse.overlaps(arrow)) {
        if (FlxG.mouse.justPressed) doFunnyTest();
        var sinFunc = 0.45 + (Math.sin(Conductor.songPosition / 175) * 0.35);
        arrow.alpha = FlxMath.lerp(arrow.alpha, sinFunc, elapsed*10);
    } else arrow.alpha = FlxMath.lerp(arrow.alpha, 1, elapsed*10);

    if (controls.ACCEPT) enterModState();

    if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP) {
        changeSelected(1);
    }
    if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN) {
        changeSelected(-1);
    }

    if (FlxG.keys.justPressed.D || FlxG.keys.justPressed.RIGHT) doFunnyTest();
}

function doFunnyTest() {
    trace("do something with the boxes and then transition to debug settings or smth, its going to be used for the Global Shop and Events and what not");
}