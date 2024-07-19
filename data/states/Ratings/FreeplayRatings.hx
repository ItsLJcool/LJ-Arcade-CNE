//a
import flixel.ui.FlxBar;
import flixel.text.FlxTextBorderStyle;
import flixel.addons.display.FlxBackdrop;
importScript("LJ Arcade API/tokens");

var cam:FlxCamera;
function new() {
    cam = new FlxCamera();
    cam.bgColor = 0;
    FlxG.cameras.add(cam, false);
    
    _fromFreeplay = true;
    if (FlxG.sound.music != null) {
        FlxG.sound.music.stop();
        FlxG.sound.music = null;
    }
    if (FlxG.sound.music == null) CoolUtil.playMusic(Paths.music("Results/resultsNORMAL/resultsNORMAL"), true, 1, true, 112);
    FlxG.sound.music.volume = 0.8;
    
	bg = new FlxBackdrop();
	bg.loadGraphic(Paths.image('editors/bgs/charter'));
	bg.antialiasing = true;
    bg.velocity.set(50, 50);
	add(bg);
}

if (_lastRating == "") _lastRating = "F";

var xpGained:Int = rating_XP[_lastRating];
var _maxRank:Int = 0;
for (key in xpMaxLevels.keys()) _maxRank++;

// set_xp(0);
// set_rank(0);
var rank_data = {
    xp: get_xp(),
    rank: get_rank(),
};
var newRank = ((rank_data.xp + xpGained) >= xpMaxLevels[rank_data.rank]);
var newXP = (newRank) ? xpGained + (rank_data.xp - xpMaxLevels[rank_data.rank]) : (get_xp() + xpGained);

set_xp(newXP);

if (newRank && (rank_data.rank < _maxRank)) set_rank(rank_data.rank + 1);

var ljToken:FlxSprite;
var ljTokenText:FlxText;
function create() {

    ljTokenText = new FlxText(0,0, 0, "[Tokens Gained]");
    ljTokenText.setFormat(Paths.font("Funkin - No Outline.ttf"), 36, 0xFFFFFFFF, "center");
    ljTokenText.screenCenter();
    add(ljTokenText);

    ljToken = new FlxSprite(0, 0, Paths.image("ljtoken"));
    ljToken.setGraphicSize(150, 150);
    ljToken.updateHitbox();
    ljToken.screenCenter();
    add(ljToken);
    
    ljToken.x -= ljTokenText.width * 0.5;
    ljTokenText.x += ljToken.width * 0.5;
    
    levelBar = new FlxBar(0,0, null, 350, 25, rank_data, "xp", 0, xpMaxLevels[rank_data.rank]);
    levelBar.x = FlxG.width - levelBar.width - 25;
    levelBar.y += 25;
    levelBar.createGradientBar([0xFFFFFFFF], [0xFF00FF6E, 0xFF00ff42, 0xFF00ff1e], 1, 0);
    
    levelDropshadow = new FlxSprite().makeGraphic(levelBar.width, levelBar.height, 0xFF000000);
    levelDropshadow.setPosition(levelBar.x, levelBar.y + 5);
    add(levelDropshadow);
    add(levelBar);
    
    levelText = new FlxText(0,0, 0, "Rank:  "+rank_data.rank);
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

    doUpdateShit();
}

function doUpdateShit() {

    var _xp = (newRank) ? xpMaxLevels[rank_data.rank] : (rank_data.xp + xpGained);

    new FlxTimer().start(1, function(tmr) {
        FlxTween.tween(rank_data, {xp: _xp }, 1.75, {ease: FlxEase.quadInOut, onUpdate: updateShit, onComplete: updateShit});
        if (newRank) do_rankUp();
    });
}

var bloom:CustomShader = new CustomShader("ljarcade.bloom");
function do_rankUp() {
    bloom.Size = 3;
    FlxG.camera.addShader(bloom);

    var _vol = FlxG.sound.music.volume;
    FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.85, {startDelay: 0.75, ease: FlxEase.sineIn, onComplete: function() {
        FlxG.sound.music.stop();
        FlxG.sound.music = null;
        CoolUtil.playMusic(Paths.music("Results/resultsEXCELLENT/resultsEXCELLENT-intro"), false, 1, false, 112);
        FlxG.sound.music.onComplete = function() {
            new FlxTimer().start(0.25, function(tmr) {
                FlxTween.tween(rank_data, {xp: get_xp() }, 1, {ease: FlxEase.quadInOut, onUpdate: updateShit, onComplete: updateShit});
                CoolUtil.playMusic(Paths.music("Results/resultsEXCELLENT/resultsEXCELLENT"), false, 1, true, 112);
            });
        };
        var _zoom = FlxG.camera.zoom;
        FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.1}, 1.95, {ease: FlxEase.backIn});
        FlxTween.tween(rank_data, {xp: 0}, 1.95, {ease: FlxEase.quintIn, onUpdate: updateShit, onComplete: function() {
            rank_data.rank = get_rank();
            levelBar.setRange(0, xpMaxLevels[rank_data.rank]);
            updateShit();
            bloomaMount = 0.5;
            
            FlxTween.tween(FlxG.camera, {zoom: _zoom}, 3, {ease: FlxEase.backIn});
        }});
        FlxG.sound.music.volume = _vol;
    }});

}

function updateShit() {
    levelText.text = "Rank:  "+rank_data.rank;
    levelText.setPosition(levelBar.x, levelBar.y + levelText.height + 10);

    xpToLevel.text = Std.int(rank_data.xp)+"/"+xpMaxLevels[rank_data.rank];
    xpToLevel.setPosition(levelBar.x + levelBar.width - xpToLevel.width, levelBar.y + levelText.height + 10);
}

var bloomaMount = 1; // stolen from YTP lmao
function update(elapsed) {
    if (newRank) {
        bloomaMount = FlxMath.lerp(bloomaMount, 1, elapsed*0.5);
        bloom.data.dim.value = [bloomaMount, bloomaMount];
    }
    if (controls.ACCEPT) {
        FlxG.sound.music.stop();
        FlxG.sound.music = null;
        FlxG.switchState(new ModState("ModMainMenu"));
    }
}