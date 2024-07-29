//a
import flixel.ui.FlxBar;
import flixel.text.FlxTextBorderStyle;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxTypedSpriteGroup;
import flixel.util.FlxGradient;
import funkin.game.PlayState;
import funkin.game.ComboRating;
importScript("LJ Arcade API/tokens");

var cheated:Bool = (usingBotplay);

var cam:FlxCamera;

var topBar:FlxSprite;
var bottomGradient:FlxGradient;

var flip_score:Bool = true;
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
	bg.loadGraphic(Paths.image('results/ResultScreenBG'));
	bg.antialiasing = true;
    bg.velocity.set(50, 0);
	add(bg);

    topBar = new FlxSprite().makeGraphic(FlxG.width, 95, 0xFF000000);
    add(topBar);

    bottomGradient = FlxGradient.createGradientFlxSprite(FlxG.width - 50, 96, [0x00000000, 0xFF00FF00], 1, 0, true);
    bottomGradient.x = (flip_score) ? -bottomGradient.width - 25 : FlxG.width + bottomGradient.width + 25;
    bottomGradient.y = FlxG.height - bottomGradient.height;
    bottomGradient.flipX = flip_score;
    add(bottomGradient);

    bruh = new FlxText(15,15, 0, "** RATINGS SCREEN SUBJECT TO CHANGE **");
    bruh.setFormat(Paths.font("Funkin - No Outline.ttf"), 20, 0xFFFFFFFF, "left", FlxTextBorderStyle.SHADOW, 0xFF000000);
    bruh.borderSize = 2;
    bruh.shadowOffset.x = 0;
    bruh.shadowOffset.y = 2;
    add(bruh);
}

if (ratings_data.lastRating == "" || ratings_data.lastRating == null) ratings_data.lastRating = "F";
if (ratings_data.comboRatings == null || ratings_data.comboRatings.length == 0) ratings_data.comboRatings = [new ComboRating(0, "[N/A]", 0xFF888888)];

var xpGained:Int = rating_XP[ratings_data.lastRating] + ratings_data.extraXP;
xpGained = 150;
var _maxRank:Int = -1;
for (key in xpMaxLevels.keys()) _maxRank++;

// set_xp(0);
// set_rank(0);
// set_tokens(0);
var rank_data = {
    xp: get_xp(),
    rank: get_rank(),
    tokens: get_tokens(),
};
var tokenSongLength:Int = token_songLength(ratings_data.songLength);
var tokenRating:Int = token_rating(ratings_data.lastRating);
var newTokens:Int = tokenSongLength + tokenRating;

set_tokens(get_tokens() + newTokens);

var newRank = (cheated) ? false : update_xp(xpGained).rankedUp;
if (!newRank && !cheated) set_xp(rank_data.xp + xpGained);

var ratingSprite:FlxSprite;
var _ratingSprite_data = [
    {anim: "F", x: 0, y: 0},
];
var _ratingSprite_pos = {x: 0, y: 0};

var scoreText:FlxText;
function create() {

    scoreText = new FlxText(0,0, 0, "Score: 0");
    scoreText.setFormat(Paths.font("HELVETICA NEUE.TTF"), 48, 0xFFFFFFFF, "right", FlxTextBorderStyle.SHADOW, 0xFF000000);
    scoreText.setPosition((flip_score) ? -scoreText.width - 50 : bottomGradient.x, bottomGradient.y + bottomGradient.height/2 - scoreText.height/2);
    scoreText.borderSize = 3;
    scoreText.shadowOffset.x = 0;
    scoreText.shadowOffset.y = 1.5;
    add(scoreText);
    
    levelBar = new FlxBar(0,0, null, 350, 25, rank_data, "xp", 0, xpMaxLevels[rank_data.rank]);
    levelBar.x = FlxG.width - levelBar.width - 25;
    levelBar.y += 25;
    levelBar.createGradientBar([0xFFFFFFFF], [0xFF00FF6E, 0xFF00ff42, 0xFF00ff1e], 1, 0);
    add(levelBar);
    
    levelText = new FlxText(0,0, 0, get_rankText(rank_data.rank));
    levelText.setFormat(Paths.font("goodbyeDespair.ttf"), 22, 0xFFFFFFFF, "left");
    levelText.setPosition(levelBar.x, levelBar.y + levelText.height + 10);
    add(levelText);

    xpToLevel = new FlxText(0,0, 0, rank_data.xp+"/"+xpMaxLevels[rank_data.rank]);
    xpToLevel.setFormat(Paths.font("goodbyeDespair.ttf"), 22, 0xFFFFFFFF, "right");
    xpToLevel.setPosition(levelBar.x + levelBar.width - xpToLevel.width, levelBar.y + levelText.height + 10);
    add(xpToLevel);

    ratingSprite = new FlxSprite();
    ratingSprite.frames = Paths.getSparrowAtlas('Results/rating');
    for (rating in ["F", "D", "C", "B", "A", "S"]) 
        ratingSprite.animation.addByPrefix(rating, rating, 1, true);
    ratingSprite.animation.addByPrefix('-', "Minus", 1, true);
    ratingSprite.animation.addByPrefix('+', "Plus", 1, true);
    ratingSprite.animation.play('F', true);
    ratingSprite.antialiasing = true;
    ratingSprite.shader = noteColorShader;
    ratingSprite.scale.set(0.65, 0.65);
    ratingSprite.updateHitbox();
    ratingSprite.screenCenter();
    add(ratingSprite);

    ratingSprite.onDraw = function(sprite:FlxSprite) {
        for (i in 0..._ratingSprite_data.length) {
            var data = _ratingSprite_data[i];
            sprite.setPosition(_ratingSprite_pos.x + data.x, _ratingSprite_pos.y + data.y);
            sprite.animation.play(data.anim, true);
            sprite.draw();
        }
    };
    
    var _ratingPog = ratings_data.lastRating.split("");
    var theRating = _ratingPog.shift(0, 1);
    setRating(theRating, _ratingPog);

    _ratingSprite_pos.x = -ratingSprite.width*_ratingSprite_data.length;
    _ratingSprite_pos.y = FlxG.height * 0.5 - ratingSprite.height * 0.5;

    updateShit();

    new FlxTimer().start(1, startScoreDisplay);
    // doUpdateShit();
}

var noteColorShader:CustomShader = new CustomShader("ljarcade.ColoredNoteShader");
noteColorShader.enabled = true;
noteColorShader.r = 1;
noteColorShader.g = 0;
noteColorShader.b = 0;
noteColorShader.frameOffset = [0, 0];
noteColorShader.clipRect = [0, 0, 99999, 99999];
function setRating(type:String, ?addons:Array<String> = []) {
    if (addons == null) addons = [];

    var _hasRating = false;
    var theRating = null;
    for (rating in ratings_data.comboRatings) {
        if (rating.rating.toLowerCase() != type.toLowerCase()) continue;
        _hasRating = true;
        theRating = rating;
        break;
    }
    
    if (!_hasRating) {
        type = "F";
        _hasRating = true;
        theRating = new ComboRating(0, "F", 0xFFFF4444);
    }
    
	var r = (theRating.color >> 16) & 0xff;
	var g = (theRating.color >> 8) & 0xff;
	var b = (theRating.color & 0xff);
    noteColorShader.r = r/255;
    noteColorShader.g = g/255;
    noteColorShader.b = b/255;
    _ratingSprite_data[0].anim = type.toUpperCase();

    for (data in addons) {
        _ratingSprite_data.push({anim: data.toUpperCase(),
            x: 100 + (150*_ratingSprite_data.length), y: (data.toLowerCase() == "-") ? 50 : 0,
        });
    }

}

if (ratings_data.score == null) ratings_data.score = 0;
function startScoreDisplay() {
    var gradientPosX = (flip_score) ? 0 : FlxG.width - bottomGradient.width;
    var scorePosX = (flip_score) ? 50 : FlxG.width - scoreText.width - 50;
    FlxTween.tween(bottomGradient, {x: gradientPosX}, Conductor.crochet / 500, {ease: FlxEase.quadOut});
    FlxTween.tween(scoreText, {x: scorePosX}, Conductor.crochet / 250, {ease: FlxEase.quintOut, onComplete: function() {

        FlxTween.tween(_score, {theScore: ratings_data.score}, Conductor.crochet / 250,
        {startDelay: 0, ease: FlxEase.sineInOut, onUpdate: updateScoreText, onComplete: updateScoreText});

        new FlxTimer().start(Conductor.crochet / 250 + 0.15, function(tmr) {
            FlxTween.tween(_ratingSprite_pos, {x: ratingSprite.width*0.125}, 1.5, {ease: FlxEase.quadInOut, onComplete: doUpdateShit });
        });

    }});
}

var _score = { theScore: 0, };
function updateScoreText() {
    scoreText.text = "Score: " + Std.int(_score.theScore);
}

function doUpdateShit() {

    var _xp = (newRank) ? xpMaxLevels[rank_data.rank] : (rank_data.xp + xpGained);

    new FlxTimer().start(1, function(tmr) {
        FlxTween.tween(rank_data, {tokens: get_tokens() }, 1, {ease: FlxEase.sineOut});
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
        FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.1}, 1.95, {ease: FlxEase.backInOut});
        FlxTween.tween(rank_data, {xp: 0}, 1.95, {ease: FlxEase.quintIn, onUpdate: updateShit, onComplete: function() {
            rank_data.rank = get_rank();
            levelBar.setRange(0, xpMaxLevels[rank_data.rank]);
            updateShit();
            bloomaMount = 0.5;
            
            FlxTween.tween(FlxG.camera, {zoom: _zoom + 0.15}, 0.5, {ease: FlxEase.sineOut});
            FlxTween.tween(FlxG.camera, {zoom: _zoom}, 3, {startDelay: 0.5, ease: FlxEase.backInOut});
        }});
        FlxG.sound.music.volume = _vol;
    }});

}

function updateShit() {
    levelText.text = get_rankText(rank_data.rank);
    levelText.setPosition(levelBar.x, levelBar.y + levelText.height + 10);

    xpToLevel.text = Std.int(rank_data.xp)+"/"+xpMaxLevels[rank_data.rank];
    xpToLevel.setPosition(levelBar.x + levelBar.width - xpToLevel.width, levelBar.y + levelText.height + 10);
}

var bloomaMount = 1; // stolen from YTP lmao
function update(elapsed) {
    if (newRank) {
        bloomaMount = FlxMath.lerp(bloomaMount, 1, elapsed*0.15);
        bloom.data.dim.value = [bloomaMount, bloomaMount];
    }
    if (controls.ACCEPT) {
        FlxG.sound.music.stop();
        FlxG.sound.music = null;
        FlxG.switchState(new ModState("ModMainMenu"));
    }
}

function colorToShaderVec(color:Int, ?rgbUh:Bool = false) {
    if (color == null) return;
	if (rgbUh == null) rgbUh = false;
	var r = (color >> 16) & 0xff;
	var g = (color >> 8) & 0xff;
	var b = (color & 0xff);
	return (rgbUh) ? {r: r, g: g, b: b, a: (color >> 24) & 0xff} : [(r)/100, (g)/100, (b)/100];
}