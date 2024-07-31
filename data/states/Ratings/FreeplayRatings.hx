//a
import flixel.ui.FlxBar;
import flixel.text.FlxTextBorderStyle;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxTypedSpriteGroup;
import flixel.util.FlxGradient;
import funkin.game.PlayState;
import Float;
import Int;
import String;
import funkin.game.ComboRating;
import funkin.backend.system.Control; // importing the Enum for usage
importScript("LJ Arcade API/tokens");

var _ratingSongsData:Array<Dynamic> = ratings_data.songsData;
if (_ratingSongsData.length == 0) leaveRatings();

var cheated:Bool = (usingBotplay && false);

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

    for (data in _ratingSongsData)  {
        allScore += data.songScore;

        averageSongLength += data.instLength;

        averageAccuracy += data.accuracy;
        for (ratingKeys in data.notes_rating_hit.keys()) notes_rating_hit.set(ratingKeys, data.notes_rating_hit.get(ratingKeys));
    }
    averageSongLength /= _ratingSongsData.length;

    averageAccuracy /= _ratingSongsData.length;
    if (averageAccuracy >= 1) properXPvalue = 1;
    else {
        var _array = rating_XP.keys().array;
        _array.sort(function(a:Int, b:Int):Int { return a - b; });
        for (accKeys in _array) {
            var _newKeys = accKeys * 0.01;
            if (averageAccuracy > _newKeys) continue;
            properXPvalue = rating_XP[accKeys];
            break;
        }
    }

    for (data in ratings_data.comboRatings) {
        if (averageAccuracy > data.percent) continue;
        _lastRating = data.rating;
        break;
    }

    xpGained = properXPvalue + ratings_data.extraXP;

    var tokenSongLength:Int = token_songLength(averageSongLength);
    var tokenRating:Int = token_rating(averageAccuracy);
    var newTokens:Int = tokenSongLength + tokenRating;

    if (!cheated) set_tokens(get_tokens() + newTokens);

    newRank = (cheated) ? false : update_xp(xpGained).rankedUp;
    if (!newRank && !cheated) set_xp(rank_data.xp + xpGained);
}

var notes_rating_hit:Map<String, Int> = [
    "sick" => 0,
    "good" => 0,
    "bad" => 0,
    "shit" => 0,
    "misses" => 0,
];
var _ratingsColor:Map<String, Int> = [
    "sick" => 0xFF22F70F,
    "good" => 0xFF17E0D9,
    "bad" => 0xFFFFFF00,
    "shit" => 0xFF890000,
    "misses" => 0xFF222222,
];
var ratings_piority:Array<String> = ["sick", "good", "bad", "shit", "misses"];

var averageSongLength:Float = 0;
var allScore:Float = 0;
var averageAccuracy:Float = 0;
var properXPvalue:Float = 0;

var _lastRating:String = "F";
var xpGained:Int = 0;
var newRank:Bool = false;

// set_xp(0);
// set_rank(0);
// set_tokens(0);
var rank_data = {
    xp: get_xp(),
    rank: get_rank(),
    tokens: get_tokens(),
};

var ratingSprite:FlxSprite;
var _ratingSprite_data = [
    {anim: "F", x: 0, y: 0},
];
var _ratingSprite_pos = {x: 0, y: 0};

var scoreText:FlxText;

var ratingsGroup:FlxTypedSpriteGroup;
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

    ratingsGroup = new FlxTypedSpriteGroup();
    add(ratingsGroup);

    for (ratingShit in ratings_piority) {
        if (!notes_rating_hit.exists(ratingShit)) continue;
        var ratingText:FlxText = new FlxText(0,0, FlxG.width/2, capitalizeFirstLetter(ratingShit)+": "+notes_rating_hit.get(ratingShit));
        ratingText.setFormat(Paths.font("HELVETICA NEUE.TTF"), 36, _ratingsColor.get(ratingShit), "right", FlxTextBorderStyle.OUTLINE, 0xFF000000);
        // ratingText.x = FlxG.width - ratingText.width - 15;
        ratingText.x = FlxG.width + ratingText.width;
        if (ratingsGroup.members.length > 0)
            ratingText.y = ratingsGroup.members[ratingsGroup.members.length-1].y + ratingText.height + 7.5;
        ratingText.ID = ratingsGroup.members.length;
        ratingsGroup.add(ratingText);
        ratingText.borderSize = 3;
    }
    ratingsGroup.y = FlxG.height * 0.5 - ratingsGroup.height * 0.5;
    
    var _ratingPog = _lastRating.split("");
    var theRating = _ratingPog.shift(0, 1);
    setRating(theRating, _ratingPog);

    _ratingSprite_pos.x = -ratingSprite.width*_ratingSprite_data.length;
    _ratingSprite_pos.y = FlxG.height * 0.5 - ratingSprite.height * 0.5;

    updateShit();

    trace("allScore: " + allScore);
    new FlxTimer().start(1, startScoreDisplay);
    // doUpdateShit();
}

var leaveButton:FlxText;
function postCreate() {
    var _acceptButton = controls.getKeyName(Control.ACCEPT);
    leaveButton = new FlxText(0,0, 0, "Press ["+_acceptButton+"] to leave");
    leaveButton.setFormat(Paths.font("HELVETICA NEUE.TTF"), 16, 0xFFFFFFFF, "center", FlxTextBorderStyle.SHADOW, 0xFF000000);
    leaveButton.borderSize = 3;
    leaveButton.shadowOffset.x = 0;
    leaveButton.shadowOffset.y = 1.5;
    leaveButton.x = FlxG.width - leaveButton.width - 15;
    leaveButton.y = FlxG.height - leaveButton.height - 15;
    leaveButton.alpha = 0.0001;
    add(leaveButton);
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
    _ratingSprite_data = [{anim: type.toUpperCase(), x: 0, y: 0}];

    for (data in addons) {
        _ratingSprite_data.push({anim: data.toUpperCase(),
            x: 100 + (150*_ratingSprite_data.length), y: (data.toLowerCase() == "-") ? 50 : 0,
        });
    }

}

function startScoreDisplay() {
    var gradientPosX = (flip_score) ? 0 : FlxG.width - bottomGradient.width;
    var scorePosX = (flip_score) ? 50 : FlxG.width - scoreText.width - 50;
    FlxTween.tween(bottomGradient, {x: gradientPosX}, Conductor.crochet / 500, {ease: FlxEase.quadOut});
    FlxTween.tween(scoreText, {x: scorePosX}, Conductor.crochet / 250, {ease: FlxEase.quintOut});
    new FlxTimer().start(Conductor.crochet / 250, function(tmr) {
        FlxTween.tween(_score, {theScore: allScore}, Conductor.crochet / 250,
        {startDelay: 0, ease: FlxEase.sineInOut, onUpdate: updateScoreText, onComplete: updateScoreText});
        
        for (spr in ratingsGroup.members)
            FlxTween.tween(spr, {x: FlxG.width - spr.width - 15}, 3, {startDelay: 0.05*(spr.ID), ease: FlxEase.backInOut});

        new FlxTimer().start(Conductor.crochet / 250 + 0.15, function(tmr) {
            FlxTween.tween(_ratingSprite_pos, {x: ratingSprite.width*0.125}, 1.5, {ease: FlxEase.quadInOut, onComplete: doUpdateShit });
        });
    });
}

var _score = { theScore: 0, };
function updateScoreText() {
    scoreText.text = "Score: " + Std.int(_score.theScore);
}

function doUpdateShit() {

    var _xp = (newRank) ? xpMaxLevels[rank_data.rank] : (rank_data.xp + xpGained);

    new FlxTimer().start(1, function(tmr) {
        FlxTween.tween(rank_data, {tokens: get_tokens() }, 1, {ease: FlxEase.sineOut});
        FlxTween.tween(rank_data, {xp: _xp }, 1.75, {ease: FlxEase.quadInOut, onUpdate: updateShit, onComplete: function() {
            updateShit();
            if (!newRank) allowedToLeave();
        }});
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

                allowedToLeave();
            });
        };
        var _zoom = FlxG.camera.zoom;
        FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.1}, 1.95, {ease: FlxEase.backInOut});
        FlxTween.tween(rank_data, {xp: 0}, 1.95, {ease: FlxEase.quintIn, onUpdate: updateShit, onComplete: function() {
            rank_data.rank = get_rank();
            levelBar.setRange(0, xpMaxLevels[rank_data.rank]);
            updateShit();
            bloomaMount = 0.65;
            
            var _ratingPog = _lastRating.split("");
            var theRating = _ratingPog.shift(0, 1);
            _ratingPog.push("+");
            setRating(theRating, _ratingPog);
            
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

    if (canLeave) {
        if (controls.ACCEPT) leaveRatings();
        var sinFunc = 0.45 + (Math.sin(Conductor.songPosition / 500) * 0.35);
        leaveButton.alpha = FlxMath.lerp(leaveButton.alpha, sinFunc, elapsed*10);
    }
}

function leaveRatings() {
    FlxG.sound.music.stop();
    FlxG.sound.music = null;
    FlxG.switchState(new ModState("ModMainMenu"));
}

var canLeave:Bool = false;
function allowedToLeave() {
    FlxTween.tween(leaveButton, {alpha: 1}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut, onComplete: function() {
        canLeave = true;
    }});
}

function capitalizeFirstLetter(s: String) {
    if (s.length == 0) return s; // Return the string as is if it's empty
    return s.substr(0, 1).toUpperCase() + s.substr(1, s.length - 1).toLowerCase();
}